#import "Flora.h"

NSUserDefaults *preferences;

// Suggested by jan (@yandevelop)
static BOOL shouldExecute() {
    NSArray *args = [[NSClassFromString(@"NSProcessInfo") processInfo] arguments];

    if (args.count == 0) {
        NSLog(@"[Flora] Skipping empty process arguments");
        return NO;
    }

    NSString *executablePath = args.firstObject;
    NSString *processName = [executablePath lastPathComponent];

    if (executablePath && processName) {
        BOOL isApplication = [executablePath containsString:@"/Application/"] 
            || [executablePath containsString:@"/Applications/"] 
            || [processName isEqualToString:@"SpringBoard"]; // SpringBoard is not an app however we want to include it
        BOOL isFileProvider = [[processName lowercaseString] containsString:@"fileprovider"];
        NSArray *skipList = @[@"AdSheet", @"CoreAuthUI", @"InCallService", @"MessagesNotificationViewService"];
        
        if (!isFileProvider && isApplication && ![skipList containsObject:processName] && ![executablePath containsString:@".appex/"]) {
            return YES;
        }
    }

    NSLog(@"[Flora] Skipping '%@'", executablePath);
    return NO;
}

static void init_preferences() {
    // We first get the extended preference plist
    int result = libSandy_applyProfile("Flora_Preferences");

    bool libSandyError = result == kLibSandyErrorXPCFailure;
    NSString *suiteName = libSandyError ? BUNDLE_ID : FS_PREFERENCES(BUNDLE_ID);
    preferences = [[NSUserDefaults alloc] initWithSuiteName:suiteName];

    id disableInAppsObject = [preferences objectForKey:@"disableInApps"];
    [preferences setObject:disableInAppsObject forKey:@"staticDisableInApps"];
    BOOL isDisabledInApps = [preferences boolForKey:@"staticDisableInApps"];

    // If the user has disabled Flora in apps, then load preferences again with just the bundle id
    // This won't exist in the context of the sandbox, so none of the colors would be themed anymore.
    // The only problem is that this requires a respring to turn off
    // TODO: See if it's possible to use a FloraPreferenceObserver here
    if (isDisabledInApps) {
        preferences = [[NSUserDefaults alloc] initWithSuiteName:BUNDLE_ID];
    }
}

static UIColor *getBubbleColor(NSString *type) {
    if (!preferences) {
        init_preferences();
    }

    NSString *color;

    if ([type isEqualToString:@"blue"]) {
        color = [preferences objectForKey:@"blueBubbleColor"] ?: [Utilities hexStringFromColor:[UIColor systemBlueColor]];
    }

    if ([type isEqualToString:@"green"]) {
        color = [preferences objectForKey:@"greenBubbleColor"] ?: [Utilities hexStringFromColor:[UIColor systemGreenColor]];
    }

    if (!color) return nil;
    return [Utilities colorFromHexString:color];
}

%group Base

// Hooks for theming iMessages bubble colors
%hook CKUITheme

- (id)blue_balloonColors {
    if (!preferences) {
        init_preferences();
    }

    if ([preferences boolForKey:@"enabled"]) {
        UIColor *color = getBubbleColor(@"blue");
        return [Utilities generateMessageBubbleColorWithColor:color];
    }

    return %orig;
}

- (id)green_balloonColors {
	if (!preferences) {
        init_preferences();
    }

    if ([preferences boolForKey:@"enabled"]) {
        UIColor *color = getBubbleColor(@"green");
        return [Utilities generateMessageBubbleColorWithColor:color];
    }

    return %orig;
}

%end

%hook UIColor

+ (UIColor *)sf_safariAccentColor {
    if (!preferences) {
        init_preferences();
    }

    if ([preferences boolForKey:@"enabled"]) {
        return [UIColor systemBlueColor];
    }

    return %orig;
}

%new
+ (UIColor *)blueBubbleColor {
    return getBubbleColor(@"blue");
}

%new
+ (UIColor *)greenBubbleColor {
    return getBubbleColor(@"green");
}

%end

%end

%group Music

%hook UILayoutContainerView

- (void)layoutSubviews {
    %orig;

    if (!preferences) {
        init_preferences();
    }

    if ([preferences boolForKey:@"enabled"]) {
        // It doesn't matter what color this is because it'll be overriden in the hook anyway
        [self setInteractionTintColor:[UIColor clearColor]];
    }
}

- (void)setInteractionTintColor:(UIColor *)color {
    if (!preferences) {
        init_preferences();
    }

    if (![preferences boolForKey:@"enabled"]) return %orig;
    if ([[preferences objectForKey:@"mode"] isEqualToString:@"Simple"]) {
        %orig([Utilities simpleColorWithIndex:0 preferences:preferences originalColor:[self interactionTintColor]]);
        return;
    }
    
    NSString *originalColorHex = [Utilities hexStringFromColor:[self interactionTintColor]];
    NSString *colorFromDefaults = [preferences objectForKey:@"musicTintColor"] ?: originalColorHex;

    %orig([Utilities colorFromHexString:colorFromDefaults]);
}

%end

%end

%ctor {
    if (!preferences) {
        init_preferences();
    }

    [preferences registerDefaults:@{
        @"floraPrimaryColor": @"#e8a7bfff",
        @"floraSecondaryColor": @"#d795f8ff",
        @"floraSaturationInfluence": @0.4,
        @"floraLightnessInfluence": @0.2,
    }];

    id enabledObject = [preferences objectForKey:@"enabled"];
    [preferences setObject:enabledObject forKey:@"staticEnabled"];
    BOOL isEnabled = [preferences boolForKey:@"staticEnabled"];
    BOOL isValidContext = shouldExecute();

    if (!isEnabled || !isValidContext) {
        NSLog(@"[Flora] Tweak is disabled. Exiting...");
        return;
    }

    %init(Base)

    [Utilities loopUIColorWithBlock:^(unsigned int index, SEL selector, NSString *name, Method method, Class uiColorClass) {
       __block UIColor *(*originalColorWithCGColor)(id self, SEL _cmd);

        MSHookMessageEx(
            uiColorClass,
            selector,
            imp_implementationWithBlock(^(id self, SEL _cmd) {
                UIColor *originalColor = originalColorWithCGColor(self, _cmd);
                
                // Disable tintColor in google services
                if ([[[NSBundle mainBundle] bundleIdentifier] hasPrefix:@"com.google"] && [name isEqualToString:@"tintColor"]) {
                    return originalColor;
                }

                if ([name isEqualToString:@"whiteColor"] && ![preferences boolForKey:@"whiteColorEnabled"]) {
                    return originalColor;
                }

                if ([[preferences objectForKey:@"mode"] isEqualToString:@"Simple"]) {
                    return [Utilities simpleColorWithIndex:index preferences:preferences originalColor:originalColor];
                }

                // It's necessary to use NSUserDefaults instead of GcColorPickerUtils here
                // so that we can take advantage of libSandy for the preferences
                NSString *originalColorHex = [Utilities hexStringFromColor:originalColor];
                NSString *colorFromDefaults = [preferences objectForKey:name] ?: originalColorHex;
                UIColor *parsedColor = [Utilities colorFromHexString:colorFromDefaults];

                return parsedColor;
            }),
            (IMP *)&originalColorWithCGColor
        ); 
    }];

    #pragma mark - Music Hooks
    if ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.Music"]) {
        %init(Music)
    }
}
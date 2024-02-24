#import "Flora.h"

NSUserDefaults *preferences;

%ctor {
    // We first get the extended preference plist
    int result = libSandy_applyProfile("Flora_Preferences");

    bool libSandyError = result == kLibSandyErrorXPCFailure;
    NSString *suiteName = libSandyError ? BUNDLE_ID : FS_PREFERENCES(BUNDLE_ID);
    preferences = [[NSUserDefaults alloc] initWithSuiteName:suiteName];

    id disableInAppsObject = [preferences objectForKey:@"disableInApps"];
    [preferences setObject:disableInAppsObject forKey:@"staticDisableInApps"];
    BOOL isDisabledInApps = [[preferences objectForKey:@"staticDisableInApps"] boolValue];

    // If the user has disabled Flora in apps, then load preferences again with just the bundle id
    // This won't exist in the context of the sandbox, so none of the colors would be themed anymore.
    // The only problem is that this requires a respring to turn off
    // TODO: See if it's possible to use a FloraPreferenceObserver here
    if (isDisabledInApps) {
        preferences = [[NSUserDefaults alloc] initWithSuiteName:BUNDLE_ID];
    }

    id enabledObject = [preferences objectForKey:@"enabled"];
    [preferences setObject:enabledObject forKey:@"staticEnabled"];
    BOOL isEnabled = [[preferences objectForKey:@"staticEnabled"] boolValue];

    if (!isEnabled) {
        NSLog(@"[Flora] Tweak is disabled. Exiting...");
        return;
    }

    [Utilities loopUIColorWithBlock:^(unsigned int index, SEL selector, NSString *name, Method method, Class uiColorClass) {
       __block UIColor *(*originalColorWithCGColor)(id self, SEL _cmd);

        MSHookMessageEx(
            uiColorClass,
            selector,
            imp_implementationWithBlock(^(id self, SEL _cmd) {
                UIColor *originalColor = originalColorWithCGColor(self, _cmd);
                NSString *originalColorHex = [Utilities hexStringFromColor:originalColor];

                if ([[preferences objectForKey:@"mode"] isEqualToString:@"Simple"]) {
                    NSString *key = [NSString stringWithFormat:@"flora%@Color", index % 2 == 0 ? @"Primary" : @"Secondary"];
                    NSString *colorFromDefaults = [preferences objectForKey:key] ?: (index % 2 == 0 ? @"e8a7bf" : @"d795f8");
                    UIColor *colorAtKey = [GcColorPickerUtils colorWithHex:colorFromDefaults];

                    NSDictionary *original = [Utilities convertToHSVColor:originalColor];
                    NSDictionary *custom = [Utilities convertToHSVColor:colorAtKey];

                    id saturationInfluence = [preferences objectForKey:@"floraSaturationInfluence"];
                    id lightnessInfluence = [preferences objectForKey:@"floraLightnessInfluence"];

                    double saturationSplit = saturationInfluence != nil ? [saturationInfluence doubleValue] : 0.40;
                    double lightnessSplit = lightnessInfluence != nil ? [lightnessInfluence doubleValue] : 0.20;

                    // Use the custom color, with 40% saturation influence and a 20% brightness influence.
                    // Alpha is not affected by the custom colors. This is intentional.
                    return [UIColor colorWithHue:[[custom objectForKey:@"hue"] doubleValue]
                                      saturation:[Utilities averageWithSplit:saturationSplit firstValue:[original objectForKey:@"saturation"] secondValue:[custom objectForKey:@"saturation"]]
                                      brightness:[Utilities averageWithSplit:lightnessSplit firstValue:[original objectForKey:@"brightness"] secondValue:[custom objectForKey:@"brightness"]]
                                           alpha:[[original objectForKey:@"alpha"] doubleValue]];
                }

                // It's necessary to use NSUserDefaults instead of GcColorPickerUtils here
                // so that we can take advantage of libSandy for the preferences
                NSString *colorFromDefaults = [preferences objectForKey:name] ?: originalColorHex;
                UIColor *parsedColor = [GcColorPickerUtils colorWithHex:colorFromDefaults];

                return parsedColor;
            }),
            (IMP *)&originalColorWithCGColor
        ); 
    }];
}
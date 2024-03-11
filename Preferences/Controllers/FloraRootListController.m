#include "FloraRootListController.h"

@implementation FloraRootListController {
    FloraPreferenceObserver *modeObserver;
    FloraPreferenceObserver *primaryColorObserver;
    FloraPreferenceObserver *secondaryColorObserver;
    FloraPreferenceObserver *enableObserver;
    FloraPreferenceObserver *disableInAppsObserver;
    NSUserDefaults *preferences;
    UIButton *respringButton;
}

- (instancetype)init {
    self = [super init];

    preferences = [[NSUserDefaults alloc] initWithSuiteName:BUNDLE_ID];
    BOOL staticEnabled = [[preferences objectForKey:@"staticEnabled"] boolValue];
    BOOL staticDisableInApps = [[preferences objectForKey:@"staticDisableInApps"] boolValue];
    [self initRespringButton:staticEnabled];

    modeObserver = [[FloraPreferenceObserver alloc] initWithKey:@"mode" withChangeHandler:^() {
        [self reloadSpecifiers];
    }];

    primaryColorObserver = [[FloraPreferenceObserver alloc] initWithKey:@"floraPrimaryColor" withChangeHandler:^() {
        [self reloadSpecifiers];
    }];

    secondaryColorObserver = [[FloraPreferenceObserver alloc] initWithKey:@"floraSecondaryColor" withChangeHandler:^() {
        [self reloadSpecifiers];
    }];

    enableObserver = [[FloraPreferenceObserver alloc] initWithKey:@"enabled" withChangeHandler:^() {
        BOOL currentEnabled = [[preferences objectForKey:@"enabled"] boolValue];

        [UIView animateWithDuration:0.3 
                        animations:^{
                            respringButton.alpha = staticEnabled == currentEnabled ? 0.0 : 1.0;
                        } 
                        completion:nil];
    }];

    disableInAppsObserver = [[FloraPreferenceObserver alloc] initWithKey:@"disableInApps" withChangeHandler:^() {
        BOOL currentDisableInApps = [[preferences objectForKey:@"disableInApps"] boolValue];

        if (staticDisableInApps != currentDisableInApps) {
            [self promptToRespring];
        }
    }];

    return self;
}

- (void)initRespringButton:(BOOL)enabled {
    respringButton = [UIButton buttonWithType:UIButtonTypeSystem];

    UIImageSymbolConfiguration *symbolConfig = [UIImageSymbolConfiguration configurationWithScale:UIImageSymbolScaleMedium];
    UIImage *respringImage = [UIImage systemImageNamed:@"arrow.counterclockwise" withConfiguration:symbolConfig];
    [respringButton setImage:respringImage forState:UIControlStateNormal];
    [respringButton setTitle:@"Respring" forState:UIControlStateNormal];

    respringButton.titleLabel.font = [UIFont systemFontOfSize:17.0];
    respringButton.tintColor = [UIColor redColor];
    respringButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, 10.0, 0.0, 0.0);
    respringButton.alpha = enabled == [[preferences objectForKey:@"enabled"] boolValue] ? 0.0 : 1.0;

    [respringButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [respringButton addTarget:self action:@selector(promptToRespring) forControlEvents:UIControlEventTouchUpInside];
    [respringButton sizeToFit];

    CGRect buttonFrame = respringButton.frame;
    buttonFrame.size.width = respringButton.intrinsicContentSize.width + 10.0;
    respringButton.frame = buttonFrame;

	UIBarButtonItem *respringButtonItem = [[UIBarButtonItem alloc] initWithCustomView:respringButton];
	self.navigationItem.rightBarButtonItem = respringButtonItem;
}

- (NSArray *)specifiers {
	if (!_specifiers) {
        NSMutableArray *baseSpecifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
        NSString *value = [preferences objectForKey:@"mode"] ?: @"Simple";

        for (PSSpecifier *specifier in baseSpecifiers) {
            if ([[specifier propertyForKey:@"id"] isEqualToString:@"credits"]) {
                [specifier setProperty:[NSString stringWithFormat:@"© Rosie (acquitelol) 2024 • %@/%@", BUNDLE_ID, PACKAGE_SCHEME] forKey:@"footerText"];
                [specifier setProperty:@YES forKey:@"isStaticText"];
            }

            // Parse icon images as SF Symbols, similar to how Cephei does it but a slightly lighter implementation
            NSDictionary *iconImageSystem = [specifier propertyForKey:@"iconImageSystem"];

            if (!iconImageSystem || ![iconImageSystem objectForKey:@"name"]) continue;

            [specifier setProperty:[UIImage systemImageNamed:[iconImageSystem objectForKey:@"name"]] forKey:@"iconImage"];
        }

        _specifiers = [self getSpecifiersWithValue:value specifiers:baseSpecifiers];
	}

	return _specifiers;
}

- (NSMutableArray *)getSpecifiersWithValue:(NSString *)value specifiers:(NSArray *)specifiers {
    NSMutableArray *specifiersToKeep = [NSMutableArray array];

    for (PSSpecifier *specifier in specifiers) {
        // If the specifier doesn't have a floraColorType then assume it isn't dynamic and *always* load it
        if (![specifier propertyForKey:@"floraColorType"]) {
            [specifiersToKeep addObject:specifier];
            continue;
        }

        if ([[value lowercaseString] isEqualToString:@"simple"] && [[specifier propertyForKey:@"floraColorType"] isEqualToString:@"simple"]) {
            [specifiersToKeep addObject:specifier];
            continue;
        }

        if ([[value lowercaseString] isEqualToString:@"advanced"] && [[specifier propertyForKey:@"floraColorType"] isEqualToString:@"advanced"]) {
            [specifiersToKeep addObject:specifier];
            continue;
        }
    }

    return specifiersToKeep;
}

- (void)promptToRespring {
    UIAlertController *respringAlert = [Utilities alertWithDescription:@"Are you sure you want to respring?"  handler:^{
        [Utilities respring];
    }];

	[self presentViewController:respringAlert animated:YES completion:nil];
}

- (void)promptToReset {
    UIAlertController *resetAlert = [Utilities alertWithDescription:@"Are you sure you want to clear your preferences?" handler:^{
        [self resetPreferences];
    }];

	[self presentViewController:resetAlert animated:YES completion:nil];
}

- (void)resetPreferences {
	NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:BUNDLE_ID];

	for (NSString *key in [userDefaults dictionaryRepresentation]) {
		[userDefaults removeObjectForKey:key];
	}

	[self reloadSpecifiers];

    UIAlertController *failedAlert = [Utilities alertWithDescription:@"Successfully cleared preferences! (≧◡≦)"];
    [self presentViewController:failedAlert animated:YES completion:nil];
}

- (void)displayError:(NSString *)error {
    UIAlertController *failedAlert = [Utilities alertWithDescription:[NSString stringWithFormat:@"Failed to import preferences (ó﹏ò ｡)\n\n%@", error]];
    [self presentViewController:failedAlert animated:YES completion:nil];
}

- (void)importData {
    UIAlertController *importAlert = [UIAlertController alertControllerWithTitle:@"Import preferences"
                                                                         message:nil
                                                                  preferredStyle:UIAlertControllerStyleAlert];

    [importAlert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Please enter encoded preference data...";
    }];

    UIAlertAction *okayAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *textField = importAlert.textFields.firstObject;
        NSString *enteredText = textField.text;

        // This data is a compressed base-64 string. It must be decompressed before it can be consumed.
        NSError *error = nil;
        NSData *compressedData = [[NSData alloc] initWithBase64EncodedString:enteredText options:0];

        if (!compressedData) {
            [self displayError:@"Invalid base64 string."];
            return;
        }

        NSData *jsonData = [Utilities decompressData:compressedData];
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];

        if (!dictionary || error != nil) {
            [self displayError:[error localizedDescription]];
            return;
        }

        for (NSString *key in dictionary) {
            id value = dictionary[key];

            [preferences setObject:value forKey:key];
        }

        // We don't have to reload specifiers here because there are already observers
        // which await for changes to the properties that matter like simple colors
        UIAlertController *successAlert = [Utilities alertWithDescription:@"Successfully imported preferences! (≧◡≦)\n\nWould you like to respring now?" handler:^{
            [Utilities respring];
        }];

        [self presentViewController:successAlert animated:YES completion:nil];
    }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [importAlert addAction:okayAction];
    [importAlert addAction:cancelAction];

    [self presentViewController:importAlert animated:YES completion:nil];
}

- (void)exportData {
    [preferences synchronize];

    NSError *error;
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@THEOS_PACKAGE_INSTALL_PREFIX "/var/mobile/Library/Preferences/%@.plist", BUNDLE_ID]];
    NSMutableDictionary *dictionary = [[NSDictionary dictionaryWithContentsOfURL:url error:&error] mutableCopy] ?: [NSMutableDictionary new];

    if (!dictionary || error) {
        [self displayError:[error localizedDescription]];
        return;
    }

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];

    if (!jsonData || error) {
        [self displayError:[error localizedDescription]];
        return;
    }

    // Compress data using zlib before copying to clipboard
    // This is done because the amount of text is very large when all of the advanced colors are themed
    NSData *compressedData = [Utilities compressData:jsonData];
    NSString *compressedString = [compressedData base64EncodedStringWithOptions:0];
    [UIPasteboard generalPasteboard].string = compressedString;

    UIAlertController *successAlert = [Utilities alertWithDescription:@"Exported preferences to clipboard! (≧◡≦)"];
    [self presentViewController:successAlert animated:YES completion:nil];
}

- (void)openDebugger {
    // Basic information
    NSString *information = @"Feel free to screenshot this and send to the developer for debugging purposes! (≧◡≦)";
    NSString *bundleIdentifier = [NSString stringWithFormat:@"Bundle ID: %@", BUNDLE_ID];
    NSString *packageScheme = [NSString stringWithFormat:@"Package Scheme: %@", PACKAGE_SCHEME];
    NSString *spacer = @"";

    struct utsname systemInfo;
    uname(&systemInfo);

    NSString *operatingSystem = [NSString stringWithFormat:@"iOS Version: %@", [[UIDevice currentDevice] systemVersion]];
    NSString *deviceIdentifier = [NSString stringWithFormat:@"Device ID: %@", [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding]];

    // Debug information
    NSString *libSandyWorking = [NSString stringWithFormat:@"Does libSandy work? %@", libSandy_works() ? @"✓" : @"✗"];

    int result = libSandy_applyProfile("Flora_Preferences");

    bool libSandyError = result == kLibSandyErrorXPCFailure;
    NSString *suiteName = libSandyError ? BUNDLE_ID : FS_PREFERENCES(BUNDLE_ID);
    preferences = [[NSUserDefaults alloc] initWithSuiteName:suiteName];
    id enabled = [preferences objectForKey:@"enabled"];

    NSString *preferencesWorking = [NSString stringWithFormat:@"Can you read preferences? %@", !libSandyError && (enabled != nil) ? @"✓" : @"✗"];
    NSString *disableInApps = [NSString stringWithFormat:@"Disabled in apps? %@", [preferences boolForKey:@"disableInApps"] ? @"✓" : @"✗"];
    NSString *whiteColorEnabled = [NSString stringWithFormat:@"White color enabled? %@", [preferences boolForKey:@"whiteColorEnabled"] ? @"✓" : @"✗"];

    NSString *primaryColor = [preferences objectForKey:@"floraPrimaryColor"];
    NSString *secondaryColor = [preferences objectForKey:@"floraSecondaryColor"];
    NSString *saturationInfluence = [preferences objectForKey:@"floraSaturationInfluence"];
    NSString *lightnessInfluence = [preferences objectForKey:@"floraLightnessInfluence"];

    NSString *primaryColorString = [NSString stringWithFormat:@"Primary Color: %@", primaryColor];
    NSString *secondaryColorString = [NSString stringWithFormat:@"Secondary Color: %@", secondaryColor];
    NSString *saturationString = [NSString stringWithFormat:@"Saturation Influence: %@", saturationInfluence];
    NSString *lightnessString = [NSString stringWithFormat:@"Lightness Influence: %@", lightnessInfluence];

    NSArray *strings = @[
        information,
        spacer,
        bundleIdentifier,
        deviceIdentifier,
        packageScheme,
        operatingSystem,
        spacer,
        libSandyWorking,
        preferencesWorking,
        disableInApps,
        whiteColorEnabled,
        spacer,
        primaryColorString,
        secondaryColorString,
        saturationString,
        lightnessString
    ];

    NSString *debugInformation = [strings componentsJoinedByString:@"\n"];

    UIAlertController *failedAlert = [Utilities alertWithDescription:debugInformation];
    [self presentViewController:failedAlert animated:YES completion:nil];
}

@end
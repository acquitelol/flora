#import "Flora.h"

%ctor {
    int result = libSandy_applyProfile("Flora_Preferences");

    bool libSandyError = result == kLibSandyErrorXPCFailure;
    NSString *suiteName = libSandyError ? BUNDLE_ID : FS_PREFERENCES(BUNDLE_ID);
    NSUserDefaults *preferences = [[NSUserDefaults alloc] initWithSuiteName:suiteName];

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

                    // Use the custom color, with 40% saturation influence and a 20% brightness influence.
                    // Alpha is not affected by the custom colors. This is intentional.
                    return [UIColor colorWithHue:[[custom objectForKey:@"hue"] doubleValue]
                                      saturation:[Utilities averageWithSplit:0.40 firstValue:[original objectForKey:@"saturation"] secondValue:[custom objectForKey:@"saturation"]]
                                      brightness:[Utilities averageWithSplit:0.20 firstValue:[original objectForKey:@"brightness"] secondValue:[custom objectForKey:@"brightness"]]
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
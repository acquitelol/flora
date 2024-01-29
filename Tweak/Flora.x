#import "Flora.h"

static void load_preferences() {
    preferences = [[NSUserDefaults alloc] initWithSuiteName:BUNDLE_ID];
}

%ctor {
    load_preferences();

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
                    UIColor *colorAtKey = [GcColorPickerUtils colorFromDefaults:BUNDLE_ID withKey:key fallback:(index % 2 == 0 ? @"e8a7bf" : @"d795f8")];

                    NSDictionary *original = [Utilities convertToHSVColor:originalColor];
                    NSDictionary *custom = [Utilities convertToHSVColor:colorAtKey];

                    return [UIColor colorWithHue:[[custom objectForKey:@"hue"] doubleValue]
                                      saturation:[Utilities averageWithSplit:0.40 firstValue:[original objectForKey:@"saturation"] secondValue:[custom objectForKey:@"saturation"]]
                                      brightness:[Utilities averageWithSplit:0.20 firstValue:[original objectForKey:@"brightness"] secondValue:[custom objectForKey:@"brightness"]]
                                           alpha:[[original objectForKey:@"alpha"] doubleValue]];
                }

                return [GcColorPickerUtils colorFromDefaults:BUNDLE_ID withKey:name fallback:originalColorHex];
            }),
            (IMP *)&originalColorWithCGColor
        ); 
    }];
}
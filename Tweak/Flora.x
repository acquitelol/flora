#import "Flora.h"

static void load_preferences() {
    preferences = [[NSUserDefaults alloc] initWithSuiteName:BUNDLE_ID];
}

%ctor {
    load_preferences();

    BOOL isEnabled = [[preferences objectForKey:@"enabled"] boolValue];

    if (!isEnabled) {
        NSLog(@"[Flora] Tweak is disabled. Exiting...");
        return;
    }

    [Utilities loopUIColorWithBlock:^(SEL selector, NSString *name, Method method, Class uiColorClass) {
       __block UIColor *(*originalColorWithCGColor)(id self, SEL _cmd);

        MSHookMessageEx(
            uiColorClass,
            selector,
            imp_implementationWithBlock(^(id self, SEL _cmd) {
                UIColor *originalColor = originalColorWithCGColor(self, _cmd);
                NSString *originalColorHex = [Utilities hexStringFromColor:originalColor];
                
                return [GcColorPickerUtils colorFromDefaults:BUNDLE_ID withKey:name fallback:originalColorHex];
            }),
            (IMP *)&originalColorWithCGColor
        ); 
    }];
}
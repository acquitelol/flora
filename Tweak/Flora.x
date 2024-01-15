#import "Flora.h"

static void load_preferences() {
    preferences = [[NSUserDefaults alloc] initWithSuiteName:BUNDLE_ID];
}

NSString *hexStringFromColor(UIColor *color) {
    CGFloat red, green, blue, alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];

    int redInt = (int)(red * 255.0);
    int greenInt = (int)(green * 255.0);
    int blueInt = (int)(blue * 255.0);

    return [NSString stringWithFormat:@"#%02X%02X%02X", redInt, greenInt, blueInt];
}

%ctor {
    load_preferences();

    BOOL isEnabled = [[preferences objectForKey:@"enabled"] boolValue];

    if (!isEnabled) {
        NSLog(@"[Flora] Tweak is disabled. Exiting...");
        return;
    }

    unsigned methodCount = 0;
    Class uiColorClass = object_getClass(NSClassFromString(@"UIColor"));
    Method *methods = class_copyMethodList(uiColorClass, &methodCount);

    for (unsigned int i = 0; i < methodCount; i++) {
        Method method = methods[i];
        SEL selector = method_getName(method);
        NSString *name = NSStringFromSelector(selector);

        const char *returnType = method_copyReturnType(method);
        if ((strcmp(returnType, @encode(UIColor *)) != 0) 
            || ![name hasSuffix:@"Color"] 
            || [name containsString:@"_"] 
            || [name isEqualToString:@"clearColor"]
        ) {
            continue;
        };

        __block UIColor *(*originalColorWithCGColor)(id self, SEL _cmd);

        MSHookMessageEx(
            uiColorClass,
            selector,
            imp_implementationWithBlock(^(id self, SEL _cmd) {
                UIColor *originalColor = originalColorWithCGColor(self, _cmd);
                NSString *originalColorHex = hexStringFromColor(originalColor);
                
                return [GcColorPickerUtils colorFromDefaults:BUNDLE_ID withKey:name fallback:originalColorHex];
            }),
            (IMP *)&originalColorWithCGColor
        );
        
        free((void *)returnType);
    }

    free(methods);
}
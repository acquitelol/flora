#include "FloraSystemColorListController.h"

static NSString *parseName(NSString *name) {
    NSString *nameWithoutSystem = [name stringByReplacingOccurrencesOfString:@"system" withString:@""];
    NSString *nameWithoutColor = [nameWithoutSystem stringByReplacingOccurrencesOfString:@"Color" withString:@""];

    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"([a-z])([A-Z])" options:0 error:nil];
    NSString *stringSplitIntoSpaces = [regex stringByReplacingMatchesInString:nameWithoutColor
                                                           options:0
                                                             range:NSMakeRange(0, [nameWithoutColor length])
                                                      withTemplate:@"$1 $2"];

    return stringSplitIntoSpaces;
}

@implementation FloraSystemColorListController

- (NSArray *)specifiers {
	if (!_specifiers) {
        _specifiers = [NSMutableArray array];

        unsigned methodCount = 0;
        Class uiColorClass = object_getClass(NSClassFromString(@"UIColor"));
        Method *methods = class_copyMethodList(uiColorClass, &methodCount);

        for (unsigned int i = 0; i < methodCount; i++) {
            Method method = methods[i];
            SEL selector = method_getName(method);
            NSString *name = NSStringFromSelector(selector);
            NSString *parsedName = parseName(name);

            if ([name hasPrefix:@"system"] && [name hasSuffix:@"Color"]) {
                id colorInstance = [UIColor performSelector:selector];
                NSString *hexColor = [self hexStringFromColor:colorInstance];

                PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:parsedName
                                                                  target:self
                                                                     set:@selector(setPreferenceValue:specifier:)
                                                                     get:@selector(readPreferenceValue:)
                                                                  detail:nil
                                                                    cell:PSLinkCell
                                                                    edit:nil];

                [specifier setProperty:[GcColorPickerCell class] forKey:@"cellClass"];
                [specifier setProperty:hexColor forKey:@"fallback"];
                [specifier setProperty:@1 forKey:@"style"];
                [specifier setProperty:parsedName forKey:@"label"];
                [specifier setProperty:BUNDLE_ID forKey:@"defaults"];
                [specifier setProperty:name forKey:@"key"];
                [_specifiers addObject:specifier];
            }
        }

        free(methods);
	}

	return _specifiers;
}

- (NSString *)hexStringFromColor:(UIColor *)color {
    CGFloat red, green, blue, alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];

    int redInt = (int)(red * 255.0);
    int greenInt = (int)(green * 255.0);
    int blueInt = (int)(blue * 255.0);

    return [NSString stringWithFormat:@"#%02X%02X%02X", redInt, greenInt, blueInt];
}

@end
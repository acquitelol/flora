#import "FloraColorListController.h"

@implementation FloraColorListController

- (PSSpecifier *)generateSpecifierWithName:(NSString *)name parsedName:(NSString *)parsedName hexColor:(NSString *)hexColor {
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

    return specifier;
}

- (NSString *)parseName:(NSString *)name {
    NSString *nameWithoutColor = [name stringByReplacingOccurrencesOfString:@"Color" withString:@""];
    NSString *nameWithBackground = [nameWithoutColor stringByReplacingOccurrencesOfString:@"Bg" withString:@"Background"];

    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"([a-z])([A-Z])" options:0 error:nil];
    NSString *stringSplitIntoSpaces = [regex stringByReplacingMatchesInString:nameWithBackground
                                                           options:0
                                                             range:NSMakeRange(0, [nameWithBackground length])
                                                      withTemplate:@"$1 $2"];

    return stringSplitIntoSpaces;
}

- (NSMutableArray *)getColorSpecifiersWithFilter:(BOOL (^)(NSString *name))filter parser:(NSString *(^)(NSString *name))parser {
    NSMutableArray *specifiers = [NSMutableArray array];

    [Utilities loopUIColorWithBlock:^(SEL selector, NSString *name, Method method, Class uiColorClass) {
        if (filter && !filter(name)) return;

        id colorInstance = [UIColor performSelector:selector];
        NSString *hexColor = [Utilities hexStringFromColor:colorInstance];
        NSString *parsedName = [self parseName:parser(name)];

        PSSpecifier *specifier = [self generateSpecifierWithName:name parsedName:parsedName hexColor:hexColor];
        [specifiers addObject:specifier];
    }];

    return specifiers;
}

@end
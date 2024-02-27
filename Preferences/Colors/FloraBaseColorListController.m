#import "../Controllers/FloraColorListController.h"

@interface FloraBaseColorListController : FloraColorListController
@end

@implementation FloraBaseColorListController

- (NSMutableArray *)specifiers {
    if (!_specifiers) {
        NSUserDefaults *preferences = [[NSUserDefaults alloc] initWithSuiteName:BUNDLE_ID];

        _specifiers = [self getColorSpecifiersWithFilter:^BOOL(NSString *name) {
            if ([name isEqualToString:@"whiteColor"] && ![preferences boolForKey:@"whiteColorEnabled"]) {
                return false;
            }

            return (
                (![name hasPrefix:@"dynamic"]
                && ![name hasPrefix:@"system"]
                && ![name hasPrefix:@"table"]
                && [name length] < 12)
                || [name isEqualToString:@"darkGrayColor"]
                || [name isEqualToString:@"lightGrayColor"]
                || [name isEqualToString:@"magentaColor"]
                || [name isEqualToString:@"separatorColor"]
            );
        } parser:^(NSString *name) {
            return [name stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[name substringToIndex:1] capitalizedString]];
        }];

        [super specifiers];
    }

    return _specifiers;
}

@end
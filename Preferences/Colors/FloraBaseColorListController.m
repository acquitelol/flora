#import "../Controllers/FloraColorListController.h"

@interface FloraBaseColorListController : FloraColorListController
@end

@implementation FloraBaseColorListController

- (NSMutableArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self getColorSpecifiersWithFilter:^BOOL(NSString *name) {
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
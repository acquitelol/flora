#import "../Controllers/FloraColorListController.h"

@interface FloraOtherColorListController : FloraColorListController
@end

@implementation FloraOtherColorListController

- (NSMutableArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self getColorSpecifiersWithFilter:^BOOL(NSString *name) {
            return (
                ![name hasPrefix:@"dynamic"]
                && ![name hasPrefix:@"system"]
                && ![name hasPrefix:@"table"]
                && [name length] >= 12
            );
        } parser:^(NSString *name) {
            return [name stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[name substringToIndex:1] capitalizedString]];
        }];
    }

    return _specifiers;
}

@end
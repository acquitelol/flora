#import "../Controllers/FloraColorListController.h"

@interface FloraSystemColorListController : FloraColorListController
@end

@implementation FloraSystemColorListController

- (NSMutableArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self getColorSpecifiersWithFilter:^BOOL(NSString *name) {
            return [name hasPrefix:@"system"];
        } parser:^(NSString *name) {
            return [name stringByReplacingOccurrencesOfString:@"system" withString:@""];
        }];

        [super specifiers];
    }

    return _specifiers;
}

@end
#import "../Controllers/FloraColorListController.h"

@interface FloraTableColorListController : FloraColorListController
@end

@implementation FloraTableColorListController

- (NSMutableArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self getColorSpecifiersWithFilter:^BOOL(NSString *name) {
            return [name hasPrefix:@"table"];
        } parser:^(NSString *name) {
            return [name stringByReplacingOccurrencesOfString:@"table" withString:@""];
        }];

        [super specifiers];
    }

    return _specifiers;
}

@end
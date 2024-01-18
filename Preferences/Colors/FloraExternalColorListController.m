#import "../Controllers/FloraColorListController.h"

@interface FloraExternalColorListController : FloraColorListController
@end

@implementation FloraExternalColorListController

- (NSMutableArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self getColorSpecifiersWithFilter:^BOOL(NSString *name) {
            return [name hasPrefix:@"external"];
        } parser:^(NSString *name) {
            return [name stringByReplacingOccurrencesOfString:@"external" withString:@""];
        }];

        [super specifiers];
    }

    return _specifiers;
}

@end
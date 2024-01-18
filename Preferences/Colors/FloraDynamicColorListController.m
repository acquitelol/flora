#import "../Controllers/FloraColorListController.h"

@interface FloraDynamicColorListController : FloraColorListController
@end

@implementation FloraDynamicColorListController

- (NSMutableArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self getColorSpecifiersWithFilter:^BOOL(NSString *name) {
            return [name hasPrefix:@"dynamic"];
        } parser:^(NSString *name) {
            return [name stringByReplacingOccurrencesOfString:@"dynamic" withString:@""];
        }];

        [super specifiers];
    }

    return _specifiers;
}

@end
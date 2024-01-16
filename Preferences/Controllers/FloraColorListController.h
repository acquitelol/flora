#import <Preferences/PSListController.h>
#import <Preferences/Preferences.h>
#import "../../Tweak/Utilities.h"

@interface FloraColorListController : PSListController <UISearchBarDelegate>
@property (nonatomic, assign) NSUInteger lastSearchBarTextLength;

- (PSSpecifier *)generateSpecifierWithName:(NSString *)name parsedName:(NSString *)parsedName hexColor:(NSString *)hexColor;
- (NSString *)parseName:(NSString *)name;
- (NSMutableArray *)getColorSpecifiersWithFilter:(BOOL (^)(NSString *name))filter parser:(NSString *(^)(NSString *name))parser;
@end

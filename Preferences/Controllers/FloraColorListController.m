#import "FloraColorListController.h"

@implementation FloraColorListController

- (instancetype)init {
    self = [super init];

    if (self) {
		[self initRespringButton];
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UISearchController *searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    searchController.definesPresentationContext = YES;
    searchController.hidesNavigationBarDuringPresentation = YES;
    searchController.searchBar.delegate = self;
    searchController.obscuresBackgroundDuringPresentation = NO;

    [((FloraColorListController *)self).navigationItem setSearchController:searchController];
    [((FloraColorListController *)self).navigationItem setHidesSearchBarWhenScrolling:YES];
    [self setLastSearchBarTextLength:0];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)text {
    if ([text length] < [self lastSearchBarTextLength]) {
        [self reloadSpecifiers];
    }

    if ([text length] > 0) {
        NSMutableArray *specifiersToKeep = [NSMutableArray array];
        
        for (PSSpecifier *specifier in [self valueForKey:@"_specifiers"]) {
            if ([specifier.name length] > 0 && [[specifier.name lowercaseString] containsString:[text lowercaseString]]) {
                [specifiersToKeep addObject:specifier];
            }
        }

        [self setSpecifiers:specifiersToKeep];
        [self reload];
    }

    [self setLastSearchBarTextLength:[text length]];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self reloadSpecifiers];
    [self setLastSearchBarTextLength:0];
}

- (void)initRespringButton {
	UIButton *respringButton = [UIButton buttonWithType:UIButtonTypeCustom];
	respringButton.frame = CGRectMake(0,0,26,26);
	[respringButton setImage:[[UIImage systemImageNamed:@"slowmo"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
	respringButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
	respringButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    [respringButton addTarget:self action:@selector(promptToRespring) forControlEvents:UIControlEventTouchUpInside];

	UIBarButtonItem *respringButtonItem = [[UIBarButtonItem alloc] initWithCustomView:respringButton];
	self.navigationItem.rightBarButtonItem = respringButtonItem;
}

- (void)promptToRespring {
    UIAlertController *respringAlert = [Utilities alertWithDescription:@"Are you sure you want to respring?"  handler:^{
        [Utilities respring];
    }];

	[self presentViewController:respringAlert animated:YES completion:nil];
}

- (PSSpecifier *)generateSpecifierWithName:(NSString *)name parsedName:(NSString *)parsedName hexColor:(NSString *)hexColor {
    PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:parsedName
                                                            target:self
                                                                set:@selector(setPreferenceValue:specifier:)
                                                                get:@selector(readPreferenceValue:)
                                                             detail:nil
                                                               cell:PSLinkCell
                                                               edit:nil];

    UIImage *originalImage = [UIImage systemImageNamed:@"paintpalette.fill"];
    UIImageSymbolConfiguration *symbolConfiguration = [UIImageSymbolConfiguration configurationWithScale:UIImageSymbolScaleSmall];
    UIImage *paletteImage = [originalImage imageByApplyingSymbolConfiguration:symbolConfiguration];

    [specifier setProperty:[GcColorPickerCell class] forKey:@"cellClass"];
    [specifier setProperty:hexColor forKey:@"fallback"];
    [specifier setProperty:@1 forKey:@"style"];
    [specifier setProperty:parsedName forKey:@"label"];
    [specifier setProperty:BUNDLE_ID forKey:@"defaults"];
    [specifier setProperty:paletteImage forKey:@"iconImage"];
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

    [Utilities loopUIColorWithBlock:^(unsigned int index, SEL selector, NSString *name, Method method, Class uiColorClass) {
        if (filter && !filter(name)) return;
        
        UIColor *colorInstance = [UIColor performSelector:selector];
        NSString *hexColor = [Utilities hexStringFromColor:colorInstance];
        NSString *parsedName = [self parseName:parser(name)];

        PSSpecifier *specifier = [self generateSpecifierWithName:name parsedName:parsedName hexColor:hexColor];
        [specifiers addObject:specifier];
    }];

    return specifiers;
}

@end
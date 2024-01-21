#import <UIKit/UIKit.h>
#import <rootless.h>
#import <spawn.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSControlTableCell.h>
#import "../../Tweak/Utilities.h"

@interface PSControlTableCell (PrivateHeader)
- (UIViewController *)_viewControllerForAncestor;
@end

@interface FloraHeaderCell : PSControlTableCell
@end
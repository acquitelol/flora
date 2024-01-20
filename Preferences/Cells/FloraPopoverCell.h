#import <Preferences/Preferences.h>
#import <UIKit/UIKit.h>
#import "../../Tweak/Constants.h"

@interface PSTableCell (PrivatePopover)
- (UIViewController *)_viewControllerForAncestor;
@end

@interface FloraPopoverCell : PSTableCell
@end
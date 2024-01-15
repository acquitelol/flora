#import <UIKit/UIKit.h>
#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSTableCell.h>
#import <rootless.h>
#import <objc/runtime.h>
#import <GcUniversal/GcColorPickerUtils.h>
#import "../../Tweak/Constants.h"

@interface FloraOtherColorListController : PSListController
@end

@interface GcColorPickerCell : PSTableCell
@end
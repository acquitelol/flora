#import <UIKit/UIKit.h>
#import <rootless.h>
#import <Foundation/Foundation.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSTableCell.h>
#import <objc/runtime.h>
#import <GcUniversal/GcColorPickerUtils.h>
#import "Constants.h"

@interface Utilities : NSObject
+ (void)loopUIColorWithBlock:(void (^)(SEL selector, NSString *name, Method method, Class uiColorClass))block;
+ (NSString *)hexStringFromColor:(UIColor *)color;
+ (UIAlertController *)alertWithDescription:(NSString *)description handler:(void (^)(void))block;
@end

@interface GcColorPickerCell : PSTableCell
@end
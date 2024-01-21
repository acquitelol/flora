#import <UIKit/UIKit.h>
#import <spawn.h>
#import <rootless.h>
#import <objc/runtime.h>
#import <sys/sysctl.h>
#import <Foundation/Foundation.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSTableCell.h>
#import <GcUniversal/GcColorPickerUtils.h>
#import "Constants.h"

@interface Utilities : NSObject
+ (void)loopUIColorWithBlock:(void (^)(SEL selector, NSString *name, Method method, Class uiColorClass))block;
+ (NSString *)hexStringFromColor:(UIColor *)color;
+ (void)respring;
+ (void)enumerateProcessesUsingBlock:(void (^)(pid_t pid, NSString *executablePath, BOOL *stop))enumerator;
+ (void)killProcess:(NSString *)processName;
+ (UIAlertController *)alertWithDescription:(NSString *)description handler:(void (^)(void))handler;
@end

@interface GcColorPickerCell : PSTableCell
@end
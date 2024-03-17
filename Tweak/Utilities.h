#import <UIKit/UIKit.h>
#import <spawn.h>
#import <rootless.h>
#import <objc/runtime.h>
#import <sys/sysctl.h>
#import <Foundation/Foundation.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSTableCell.h>
#import <GcUniversal/GcColorPickerUtils.h>
#import <zlib.h>
#import <substrate.h>
#import <spawn.h>
#import "Constants.h"
#import "rootless.h"

@interface Utilities : NSObject
+ (void)loopUIColorWithBlock:(void (^)(unsigned int index, SEL selector, NSString *name, Method method, Class uiColorClass))block;
+ (NSString *)hexStringFromColor:(UIColor *)color;
+ (UIColor *)colorFromHexString:(NSString *)hexString;
+ (NSDictionary *)hsvColorWithColor:(UIColor *)color;
+ (UIColor *)simpleColorWithIndex:(int)index preferences:(NSUserDefaults *)preferences originalColor:(UIColor *)originalColor;
+ (NSArray<UIColor *> *)generateMessageBubbleColorWithColor:(UIColor *)color;
+ (double)averageWithSplit:(double)split firstValue:(id)firstValue secondValue:(id)secondValue;
+ (void)respring;
+ (UIAlertController *)alertWithDescription:(NSString *)description handler:(void (^)(void))handler;
+ (UIAlertController *)alertWithDescription:(NSString *)description;
+ (NSData *)compressData:(NSData *)uncompressedData;
+ (NSData *)decompressData:(NSData *)compressedData;
@end

@interface GcColorPickerCell : PSTableCell
@end
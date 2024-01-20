#import <Foundation/Foundation.h>
#import "../../Tweak/Constants.h"

@interface FloraPreferenceObserver : NSObject
@property (nonatomic, copy) NSString *key;
- (instancetype)initWithKey:(NSString *)key withChangeHandler:(void (^)(void))block;
@end
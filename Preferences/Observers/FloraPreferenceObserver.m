#import "FloraPreferenceObserver.h"

@implementation FloraPreferenceObserver {
    NSUserDefaults *defaults;
    void (^_block)(void);
}

- (instancetype)initWithKey:(NSString *)key withChangeHandler:(void (^)(void))block {
    self = [super init];

    if (self) {
        _key = [key copy];
        _block = block;
        defaults = [[NSUserDefaults alloc] initWithSuiteName:BUNDLE_ID];
        [defaults addObserver:self forKeyPath:key options:NSKeyValueObservingOptionNew context:nil];
    }

    return self;
}

- (void)dealloc {
    [defaults removeObserver:self forKeyPath:self.key];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey, id> *)change context:(void *)context {
    _block();
}

@end
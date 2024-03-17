#import "Utilities.h"

static int compareMethods(const void *method1, const void *method2) {
    Method m1 = *(Method *)method1;
    Method m2 = *(Method *)method2;

    SEL sel1 = method_getName(m1);
    SEL sel2 = method_getName(m2);

    NSString *name1 = NSStringFromSelector(sel1);
    NSString *name2 = NSStringFromSelector(sel2);

    return [name1 compare:name2];
}

@implementation Utilities

+ (void)loopUIColorWithBlock:(void (^)(unsigned int index, SEL selector, NSString *name, Method method, Class uiColorClass))block {
    unsigned methodCount = 0;
    Class uiColorClass = object_getClass(NSClassFromString(@"UIColor"));
    Method *methods = class_copyMethodList(uiColorClass, &methodCount);

    // Sort the colors alphabetically
    qsort(methods, methodCount, sizeof(Method), compareMethods);

    for (unsigned int i = 0; i < methodCount; i++) {
        Method method = methods[i];
        SEL selector = method_getName(method);
        NSString *name = NSStringFromSelector(selector);

        const char *returnType = method_copyReturnType(method);
        if ((strcmp(returnType, @encode(UIColor *)) != 0) 
            || !name
            || ![name hasSuffix:@"Color"] 
            || [name containsString:@"_"] 
            || [name isEqualToString:@"clearColor"]
            || [name isEqualToString:@"desiredColor"]
            || [name hasPrefix:@"DMC"]
            || [name hasPrefix:@"DC"]
            || [name hasPrefix:@"mail"]
            || [name hasPrefix:@"fmf"]
            || [name hasPrefix:@"Cert"]
        ) {
            continue;
        };

        block(i, selector, name, method, uiColorClass);
        free((void *)returnType);
    }

    free(methods);
}

+ (NSString *)hexStringFromColor:(UIColor *)color {
    CGFloat red, green, blue, alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];

    int redInt = (int)(red * 255.0);
    int greenInt = (int)(green * 255.0);
    int blueInt = (int)(blue * 255.0);
    int alphaInt = (int)(alpha * 255.0);

    return [NSString stringWithFormat:@"#%02X%02X%02X%02X", redInt, greenInt, blueInt, alphaInt];
}

+ (UIColor *)colorFromHexString:(NSString *)hexString {
    NSString *cleanString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];

    if (cleanString.length == 6) {
        cleanString = [cleanString stringByAppendingString:@"FF"];
    } else if (cleanString.length != 8) {
        return nil;
    }
    
    unsigned int rgbaValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:cleanString];
    [scanner scanHexInt:&rgbaValue];
    
    CGFloat red = ((rgbaValue & 0xFF000000) >> 24) / 255.0;
    CGFloat green = ((rgbaValue & 0x00FF0000) >> 16) / 255.0;
    CGFloat blue = ((rgbaValue & 0x0000FF00) >> 8) / 255.0;
    CGFloat alpha = (rgbaValue & 0x000000FF) / 255.0;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (NSDictionary *)hsvColorWithColor:(UIColor *)color {
    CGFloat hue, saturation, brightness, alpha;
    [color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];

    return @{
        @"hue": @(hue),
        @"saturation": @(saturation),
        @"brightness": @(brightness),
        @"alpha": @(alpha)
    };
}

+ (UIColor *)simpleColorWithIndex:(int)index preferences:(NSUserDefaults *)preferences originalColor:(UIColor *)originalColor {
    NSString *key = [NSString stringWithFormat:@"flora%@Color", index % 2 == 0 ? @"Primary" : @"Secondary"];
    NSString *colorFromDefaults = [preferences objectForKey:key] ?: (index % 2 == 0 ? @"e8a7bf" : @"d795f8");
    UIColor *colorAtKey = [self colorFromHexString:colorFromDefaults];

    NSDictionary *original = [Utilities hsvColorWithColor:originalColor];
    NSDictionary *custom = [Utilities hsvColorWithColor:colorAtKey];

    id saturationInfluence = [preferences objectForKey:@"floraSaturationInfluence"];
    id lightnessInfluence = [preferences objectForKey:@"floraLightnessInfluence"];

    double saturationSplit = saturationInfluence != nil ? [saturationInfluence doubleValue] : 0.40;
    double lightnessSplit = lightnessInfluence != nil ? [lightnessInfluence doubleValue] : 0.20;

    // Use the custom color, with 40% saturation influence and a 20% brightness influence.
    // Alpha is not affected by the custom colors. This is intentional.
    return [UIColor colorWithHue:[[custom objectForKey:@"hue"] doubleValue]
                        saturation:[self averageWithSplit:saturationSplit firstValue:[original objectForKey:@"saturation"] secondValue:[custom objectForKey:@"saturation"]]
                        brightness:[self averageWithSplit:lightnessSplit firstValue:[original objectForKey:@"brightness"] secondValue:[custom objectForKey:@"brightness"]]
                            alpha:[[original objectForKey:@"alpha"] doubleValue]];
}

+ (NSArray<UIColor *> *)generateMessageBubbleColorWithColor:(UIColor *)color {
    NSDictionary *original = [self hsvColorWithColor:color];

    double originalBrightness = [[original objectForKey:@"brightness"] doubleValue];
    double modifiedBrightness = originalBrightness < 0.2 ? originalBrightness : originalBrightness - 0.2;

    UIColor *darkerColor = [UIColor colorWithHue:[[original objectForKey:@"hue"] doubleValue]
                                      saturation:[[original objectForKey:@"saturation"] doubleValue]
                                      brightness:modifiedBrightness
                                           alpha:[[original objectForKey:@"alpha"] doubleValue]];

    return @[color, darkerColor];
}

+ (double)averageWithSplit:(double)split firstValue:(id)firstValue secondValue:(id)secondValue {
    return ([firstValue doubleValue] * (1 - split)) + ([secondValue doubleValue] * (split));
}

+ (void)respring {
    extern char **environ;
    pid_t pid;

    NSFileManager *fileManager = [NSFileManager defaultManager];

	if ([fileManager fileExistsAtPath:@"/var/Liy/.procursus_strapped"] && ![fileManager fileExistsAtPath:@"/var/jb/usr/local/bin/Xinamine"]) {
		const char *args[] = {"killall", "SpringBoard", NULL};
		posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char *const *)args, environ);
		return;
	}

    const char *args[] = {"sbreload", NULL};
    posix_spawn(&pid, ROOT_PATH("/usr/bin/sbreload"), NULL, NULL, (char *const *)args, environ);
}

+ (UIAlertController *)alertWithDescription:(NSString *)description handler:(void (^)(void))handler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:TWEAK_NAME 
                                                                        message:description
                                                                        preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *continueAction = [UIAlertAction actionWithTitle:@"Continue" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        if (handler) {
            handler();
        }
	}];

	UIAlertAction *stopAction = [UIAlertAction actionWithTitle:@"No thanks" style:UIAlertActionStyleCancel handler:nil];

	[alert addAction:continueAction];
	[alert addAction:stopAction];

    return alert;
}

+ (UIAlertController *)alertWithDescription:(NSString *)description {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:TWEAK_NAME 
                                                                        message:description
                                                                        preferredStyle:UIAlertControllerStyleAlert];

	UIAlertAction *action = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleCancel handler:nil];

	[alert addAction:action];
    return alert;
}

+ (NSData *)compressData:(NSData *)uncompressedData {
    if ([uncompressedData length] == 0) {
        return uncompressedData;
    }

    z_stream stream;
    stream.zalloc = Z_NULL;
    stream.zfree = Z_NULL;
    stream.opaque = Z_NULL;
    stream.total_out = 0;
    stream.next_in = (Bytef *)[uncompressedData bytes];
    stream.avail_in = (uInt)[uncompressedData length];

    if (deflateInit2(&stream, Z_DEFAULT_COMPRESSION, Z_DEFLATED, (15+16), 8, Z_DEFAULT_STRATEGY) != Z_OK) {
        return nil;
    }

    NSMutableData *compressedData = [NSMutableData dataWithLength:16384];

    do {
        if (stream.total_out >= [compressedData length]) {
            [compressedData increaseLengthBy:16384];
        }

        stream.next_out = [compressedData mutableBytes] + stream.total_out;
        stream.avail_out = (uInt)([compressedData length] - stream.total_out);

        deflate(&stream, Z_FINISH);
    } while (stream.avail_out == 0);

    deflateEnd(&stream);
    [compressedData setLength:stream.total_out];

    return compressedData;
}

+ (NSData *)decompressData:(NSData *)compressedData {
    if ([compressedData length] == 0) {
        return compressedData;
    }

    z_stream stream;
    stream.zalloc = Z_NULL;
    stream.zfree = Z_NULL;
    stream.opaque = Z_NULL;
    stream.total_out = 0;
    stream.next_in = (Bytef *)[compressedData bytes];
    stream.avail_in = (uInt)[compressedData length];

    if (inflateInit2(&stream, (15 + 32)) != Z_OK) {
        return nil;
    }

    NSMutableData *decompressedData = [NSMutableData dataWithLength:(NSUInteger)([compressedData length] * 1.5)];

    do {
        if (stream.total_out >= [decompressedData length]) {
            [decompressedData increaseLengthBy:(NSUInteger)([compressedData length] * 0.5)];
        }

        stream.next_out = [decompressedData mutableBytes] + stream.total_out;
        stream.avail_out = (uInt)([decompressedData length] - stream.total_out);

        inflate(&stream, Z_FINISH);
    } while (stream.avail_out == 0);

    inflateEnd(&stream);
    [decompressedData setLength:stream.total_out];

    return decompressedData;
}

@end
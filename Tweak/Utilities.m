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

+ (void)loopUIColorWithBlock:(void (^)(SEL selector, NSString *name, Method method, Class uiColorClass))block {
    unsigned methodCount = 0;
    Class uiColorClass = object_getClass(NSClassFromString(@"UIColor"));
    Method *methods = class_copyMethodList(uiColorClass, &methodCount);

    qsort(methods, methodCount, sizeof(Method), compareMethods);

    for (unsigned int i = 0; i < methodCount; i++) {
        Method method = methods[i];
        SEL selector = method_getName(method);
        NSString *name = NSStringFromSelector(selector);

        const char *returnType = method_copyReturnType(method);
        if ((strcmp(returnType, @encode(UIColor *)) != 0) 
            || ![name hasSuffix:@"Color"] 
            || [name containsString:@"_"] 
            || [name isEqualToString:@"clearColor"]
            || [name hasPrefix:@"DMC"]
            || [name hasPrefix:@"DC"]
            || [name hasPrefix:@"mail"]
            || [name hasPrefix:@"fmf"]
            || [name hasPrefix:@"Cert"]
        ) {
            continue;
        };

        block(selector, name, method, uiColorClass);
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

    return [NSString stringWithFormat:@"#%02X%02X%02X", redInt, greenInt, blueInt];
}

+ (void)respring {
    [self killProcess:@"SpringBoard"];
    exit(0);
}

+ (void)enumerateProcessesUsingBlock:(void (^)(pid_t pid, NSString *executablePath, BOOL *stop))enumerator {
    static int maxArgumentSize = 0;

    if (maxArgumentSize == 0) {
        size_t size = sizeof(maxArgumentSize);

        if (sysctl((int[]){ CTL_KERN, KERN_ARGMAX }, 2, &maxArgumentSize, &size, NULL, 0) == -1) {
            perror("sysctl argument size");
            maxArgumentSize = 4096;
        }
    }

    int mib[3] = { CTL_KERN, KERN_PROC, KERN_PROC_ALL};
    struct kinfo_proc *info;
    size_t length;
    int count;
    
    if (sysctl(mib, 3, NULL, &length, NULL, 0) < 0)
        return;

    if (!(info = malloc(length)))
        return;

    if (sysctl(mib, 3, info, &length, NULL, 0) < 0) {
        free(info);
        return;
    }

    count = length / sizeof(struct kinfo_proc);

    for (int i = 0; i < count; i++) {
        @autoreleasepool {
            pid_t pid = info[i].kp_proc.p_pid;

            if (pid == 0) {
                continue;
            }

            size_t size = maxArgumentSize;
            char* buffer = (char *)malloc(length);

            if (sysctl((int[]){ CTL_KERN, KERN_PROCARGS2, pid }, 3, buffer, &size, NULL, 0) == 0) {
                NSString* executablePath = [NSString stringWithCString:(buffer+sizeof(int)) encoding:NSUTF8StringEncoding];
                
                BOOL stop = NO;
                enumerator(pid, executablePath, &stop);

                if(stop) {
                    free(buffer);
                    break;
                }
            }

            free(buffer);
        }
    }

    free(info);
}

+ (void)killProcess:(NSString *)processName {
    [self enumerateProcessesUsingBlock:^(pid_t pid, NSString* executablePath, BOOL* stop) {
        if([executablePath.lastPathComponent isEqualToString:processName]) {
            kill(pid, SIGTERM);
        }
    }];
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

@end
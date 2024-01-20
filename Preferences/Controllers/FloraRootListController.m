#include "FloraRootListController.h"

@implementation FloraRootListController {
    FloraPreferenceObserver *observer;
}

- (instancetype)init {
    self = [super init];

    observer = [[FloraPreferenceObserver alloc] initWithKey:@"mode" withChangeHandler:^() {
        [self reloadSpecifiers];
    }];

    return self;
}

- (NSArray *)specifiers {
	if (!_specifiers) {
        NSUserDefaults *preferences = [[NSUserDefaults alloc] initWithSuiteName:BUNDLE_ID];
        NSMutableArray *baseSpecifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
        NSString *value = [preferences objectForKey:@"mode"] ?: @"Simple";

        _specifiers = [self getSpecifiersWithValue:value specifiers:baseSpecifiers];
	}

	return _specifiers;
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
    [super setPreferenceValue:value specifier:specifier];

    if ([[specifier propertyForKey:@"key"] isEqualToString:@"enabled"]) {
		[self promptToRespring];
    }
}

- (NSMutableArray *)getSpecifiersWithValue:(NSString *)value specifiers:(NSArray *)specifiers {
    NSMutableArray *specifiersToKeep = [NSMutableArray array];
    
    for (PSSpecifier *specifier in specifiers) {
        if (![specifier propertyForKey:@"floraColorType"]) {
            [specifiersToKeep addObject:specifier];
            continue;
        }

        if ([[value lowercaseString] isEqualToString:@"simple"] && [[specifier propertyForKey:@"floraColorType"] isEqualToString:@"simple"]) {
            [specifiersToKeep addObject:specifier];
            continue;
        }

        if ([[value lowercaseString] isEqualToString:@"advanced"] && [[specifier propertyForKey:@"floraColorType"] isEqualToString:@"advanced"]) {
            [specifiersToKeep addObject:specifier];
            continue;
        }
    }

    return specifiersToKeep;
}

- (void)respring {
    [self killProcess:@"SpringBoard"];
    exit(0);
}

- (void)promptToRespring {
    UIAlertController *respringAlert = [self alertWithDescription:@"Are you sure you want to respring?"  handler:^{
        [self respring];
    }];

	[self presentViewController:respringAlert animated:YES completion:nil];
}

- (void)promptToReset {
    UIAlertController *resetAlert = [self alertWithDescription:@"Are you sure you want to reset your preferences?" handler:^{
        [self resetPreferences];
    }];

	[self presentViewController:resetAlert animated:YES completion:nil];
}

- (void)resetPreferences {
	NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:BUNDLE_ID];
	for (NSString *key in [userDefaults dictionaryRepresentation]) {
		[userDefaults removeObjectForKey:key];
	}

	[self reloadSpecifiers];

    UIAlertController *doneAlert = [UIAlertController alertControllerWithTitle:TWEAK_NAME 
                                                                        message:@"Successfully cleared preferences." 
                                                                        preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *okayAction = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleCancel handler:nil];

	[doneAlert addAction:okayAction];
	[self presentViewController:doneAlert animated:YES completion:nil];
}

- (void)enumerateProcessesUsingBlock:(void (^)(pid_t pid, NSString *executablePath, BOOL *stop))enumerator {
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

- (void)killProcess:(NSString *)processName {
    [self enumerateProcessesUsingBlock:^(pid_t pid, NSString* executablePath, BOOL* stop) {
        if([executablePath.lastPathComponent isEqualToString:processName]) {
            kill(pid, SIGTERM);
        }
    }];
}

- (UIAlertController *)alertWithDescription:(NSString *)description handler:(void (^)(void))handler {
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
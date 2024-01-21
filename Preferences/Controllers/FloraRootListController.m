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

        for (PSSpecifier *specifier in baseSpecifiers) {
            NSDictionary *iconImageSystem = [specifier propertyForKey:@"iconImageSystem"];

            if (!iconImageSystem || ![iconImageSystem objectForKey:@"name"]) continue;

            [specifier setProperty:[UIImage systemImageNamed:[iconImageSystem objectForKey:@"name"]] forKey:@"iconImage"];
        }

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

- (void)promptToRespring {
    UIAlertController *respringAlert = [Utilities alertWithDescription:@"Are you sure you want to respring?"  handler:^{
        [Utilities respring];
    }];

	[self presentViewController:respringAlert animated:YES completion:nil];
}

- (void)promptToReset {
    UIAlertController *resetAlert = [Utilities alertWithDescription:@"Are you sure you want to reset your preferences?" handler:^{
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

@end
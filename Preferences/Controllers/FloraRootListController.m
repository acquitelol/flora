#include "FloraRootListController.h"

@implementation FloraRootListController {
    FloraPreferenceObserver *modeObserver;
    FloraPreferenceObserver *enableObserver;
    NSUserDefaults *preferences;
    UIButton *respringButton;
}

- (instancetype)init {
    self = [super init];

    preferences = [[NSUserDefaults alloc] initWithSuiteName:BUNDLE_ID];
    BOOL staticEnabled = [[preferences objectForKey:@"staticEnabled"] boolValue];
    [self initRespringButton:staticEnabled];

    modeObserver = [[FloraPreferenceObserver alloc] initWithKey:@"mode" withChangeHandler:^() {
        [self reloadSpecifiers];
    }];

    enableObserver = [[FloraPreferenceObserver alloc] initWithKey:@"enabled" withChangeHandler:^() {
        BOOL currentEnabled = [[preferences objectForKey:@"enabled"] boolValue];

        [UIView animateWithDuration:0.3 
                        animations:^{
                            respringButton.alpha = staticEnabled == currentEnabled ? 0.0 : 1.0;
                        } 
                        completion:nil];
    }];

    return self;
}

- (void)initRespringButton:(BOOL)enabled {
    respringButton = [UIButton buttonWithType:UIButtonTypeSystem];

    UIImageSymbolConfiguration *symbolConfig = [UIImageSymbolConfiguration configurationWithScale:UIImageSymbolScaleMedium];
    UIImage *slowmoImage = [UIImage systemImageNamed:@"slowmo" withConfiguration:symbolConfig];
    [respringButton setImage:slowmoImage forState:UIControlStateNormal];
    [respringButton setTitle:@"Respring" forState:UIControlStateNormal];

    respringButton.titleLabel.font = [UIFont systemFontOfSize:17.0];
    respringButton.tintColor = [UIColor redColor];
    respringButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, 5.0, 0.0, 0.0);
    respringButton.alpha = enabled == [[preferences objectForKey:@"enabled"] boolValue] ? 0.0 : 1.0;

    [respringButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [respringButton addTarget:self action:@selector(promptToRespring) forControlEvents:UIControlEventTouchUpInside];
    [respringButton sizeToFit];

    CGRect buttonFrame = respringButton.frame;
    buttonFrame.size.width = respringButton.intrinsicContentSize.width + 10.0;
    respringButton.frame = buttonFrame;

	UIBarButtonItem *respringButtonItem = [[UIBarButtonItem alloc] initWithCustomView:respringButton];
	self.navigationItem.rightBarButtonItem = respringButtonItem;
}

- (NSArray *)specifiers {
	if (!_specifiers) {
        NSMutableArray *baseSpecifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
        NSString *value = [preferences objectForKey:@"mode"] ?: @"Simple";

        for (PSSpecifier *specifier in baseSpecifiers) {
            if ([[specifier propertyForKey:@"id"] isEqualToString:@"credits"]) {
                [specifier setProperty:[NSString stringWithFormat:@"© Rosie (acquitelol) 2024 • %@/%@", BUNDLE_ID, PACKAGE_SCHEME] forKey:@"footerText"];
                [specifier setProperty:@YES forKey:@"isStaticText"];
            }

            NSDictionary *iconImageSystem = [specifier propertyForKey:@"iconImageSystem"];

            if (!iconImageSystem || ![iconImageSystem objectForKey:@"name"]) continue;

            [specifier setProperty:[UIImage systemImageNamed:[iconImageSystem objectForKey:@"name"]] forKey:@"iconImage"];
        }

        _specifiers = [self getSpecifiersWithValue:value specifiers:baseSpecifiers];
	}

	return _specifiers;
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
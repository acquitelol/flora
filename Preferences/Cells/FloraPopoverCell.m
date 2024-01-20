#import "FloraPopoverCell.h"

@implementation FloraPopoverCell {
    UIButton *selectedItemButton;
    NSUserDefaults *preferences;
    NSArray *options;
    NSString *selected;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier specifier:specifier];

    if (self) {
        preferences = [[NSUserDefaults alloc] initWithSuiteName:BUNDLE_ID];
        options = specifier.properties[@"options"];

        selectedItemButton = [UIButton buttonWithType:UIButtonTypeSystem];
        selectedItemButton.translatesAutoresizingMaskIntoConstraints = NO;
        [selectedItemButton addTarget:self action:@selector(createMenu) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:selectedItemButton];

        [NSLayoutConstraint activateConstraints:@[
            [selectedItemButton.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16.0],
            [selectedItemButton.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
        ]];

        selectedItemButton.menu = [self createMenu];
        selectedItemButton.showsMenuAsPrimaryAction = true;

        selected = [preferences objectForKey:specifier.properties[@"key"]] ?: specifier.properties[@"default"];
    }

    return self;
}

- (id)target {
    return self;
}

- (id)cellTarget {
    return self;
}

- (SEL)action {
        return @selector(openMenu);
}

- (SEL)cellAction {
    return @selector(openMenu);
}

- (UIMenu *)createMenu {
    NSMutableArray *items = [NSMutableArray array];

    for (NSDictionary *dict in options) {
        UIAction *action = [UIAction actionWithTitle:[dict objectForKey:@"name"]
											   image:[UIImage systemImageNamed:[dict objectForKey:@"icon"]]
								          identifier:nil
											 handler:^(UIAction *action) {
            [preferences setObject:[dict objectForKey:@"name"] forKey:[self.specifier propertyForKey:@"key"]];
            selected = [preferences objectForKey:self.specifier.properties[@"key"]];
            [self updatePreview];
        }];

        [items addObject:action];
    }

    UIMenu *menu = [UIMenu menuWithTitle:@"" children:items];
    return menu;
}

- (void)updatePreview {
    [selectedItemButton setTitle:selected forState:UIControlStateNormal];
}

- (void)openMenu {
    [selectedItemButton sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    [self updatePreview];
    [self.specifier setTarget:self];
    [self.specifier setButtonAction:@selector(openMenu)];
}

@end
#import "FloraPopoverCell.h"

@implementation FloraPopoverCell {
    UIButton *selectedItemButton;
    NSUserDefaults *preferences;
    NSArray *options;
    NSString *title;
    NSString *selected;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier specifier:specifier];

    if (self) {
        preferences = [[NSUserDefaults alloc] initWithSuiteName:BUNDLE_ID];
        selected = [preferences objectForKey:specifier.properties[@"key"]] ?: specifier.properties[@"default"];
        options = specifier.properties[@"options"];
        title = specifier.properties[@"title"];

        UIMenu *menu = [self createMenu];

        UIButton *accessoryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        accessoryButton.frame = CGRectMake(0, 0, 20, 16);
        accessoryButton.adjustsImageWhenHighlighted = NO;
        accessoryButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
        accessoryButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
        accessoryButton.menu = menu;
        accessoryButton.showsMenuAsPrimaryAction = true;

        [accessoryButton setImage:[[UIImage systemImageNamed:@"arrow.up.and.down.and.sparkles"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] 
                       forState:UIControlStateNormal];

        UIView *accessoryContainerView = [[UIView alloc] initWithFrame:accessoryButton.frame];
        [accessoryContainerView addSubview:accessoryButton];

        [self setAccessoryView:accessoryContainerView];

        UIButton *menuResponderButton = [UIButton buttonWithType:UIButtonTypeCustom];
        menuResponderButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView insertSubview:menuResponderButton belowSubview:self.accessoryView];

        [NSLayoutConstraint activateConstraints:@[
            [menuResponderButton.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            [menuResponderButton.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
            [menuResponderButton.topAnchor constraintEqualToAnchor:self.topAnchor],
            [menuResponderButton.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        ]];

        menuResponderButton.menu = menu;
        menuResponderButton.showsMenuAsPrimaryAction = true;

        selectedItemButton = [UIButton buttonWithType:UIButtonTypeSystem];
        selectedItemButton.translatesAutoresizingMaskIntoConstraints = NO;
        selectedItemButton.userInteractionEnabled = NO;
        selectedItemButton.titleLabel.font = [UIFont systemFontOfSize:17.0];
        [selectedItemButton addTarget:self action:@selector(createMenu) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:selectedItemButton];

        [NSLayoutConstraint activateConstraints:@[
            [selectedItemButton.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],
            [selectedItemButton.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
        ]];
    }

    return self;
}

- (id)target {
    return self;
}

- (id)cellTarget {
    return self;
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

    UIMenu *menu = [UIMenu menuWithTitle:title children:items];
    return menu;
}

- (void)updatePreview {
    [selectedItemButton setTitle:selected forState:UIControlStateNormal];
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    [self updatePreview];
    [self.specifier setTarget:self];

    // Needed to make the underlying PSLinkCell not open
    // when user taps tiny part which does not open the menu.
    [self.specifier setButtonAction:@selector(nothing)];
}

@end
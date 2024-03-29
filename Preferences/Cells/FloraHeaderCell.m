#import "FloraHeaderCell.h"

@implementation FloraHeaderCell {
    UIImageView *imageView;
    NSUserDefaults *preferences;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier specifier:(PSSpecifier *)specifier {
    self = [super initWithStyle:style reuseIdentifier:identifier specifier:specifier];

    if (self) {
        preferences = [[NSUserDefaults alloc] initWithSuiteName:BUNDLE_ID];

        UILabel *title = [UILabel new];
        title.text = [NSString stringWithFormat:@"%@ • %@", [specifier propertyForKey:@"title"], PACKAGE_VERSION];
        title.font = [UIFont boldSystemFontOfSize:30];
        title.textAlignment = NSTextAlignmentCenter;
        title.translatesAutoresizingMaskIntoConstraints = false;
        [self.contentView addSubview:title];

        [NSLayoutConstraint activateConstraints:@[
            [title.widthAnchor constraintEqualToAnchor:self.contentView.widthAnchor],
            [title.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-75.0],
            [title.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor],
        ]];

        UILabel *description = [UILabel new];
        description.text = [specifier propertyForKey:@"description"];
        description.font = [UIFont systemFontOfSize:15];
        description.textColor = [UIColor systemGrayColor];
        description.textAlignment = NSTextAlignmentCenter;
        description.translatesAutoresizingMaskIntoConstraints = false;
        [self.contentView addSubview:description];

        [NSLayoutConstraint activateConstraints:@[
            [description.widthAnchor constraintEqualToAnchor:self.contentView.widthAnchor],
            [description.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-55.0],
            [description.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor],
        ]];

        BOOL enabled = [[preferences objectForKey:@"enabled"] boolValue];
        NSString *imageName = (enabled ? @"FullIcon.png" : @"FullIconNoCC.png");

        UIImage *image = [UIImage imageNamed:imageName inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
        imageView = [[UIImageView alloc] initWithImage:image];
        imageView.layer.masksToBounds = true;
        imageView.layer.cornerRadius = 10.0f;
        imageView.translatesAutoresizingMaskIntoConstraints = false;
        [self.contentView addSubview:imageView];

        [NSLayoutConstraint activateConstraints:@[
            [imageView.widthAnchor constraintEqualToConstant:80.0],
            [imageView.heightAnchor constraintEqualToConstant:80.0],
            [imageView.bottomAnchor constraintEqualToAnchor:title.topAnchor constant:-10.0],
            [imageView.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor],
        ]];

        UISwitch *toggle = [[UISwitch alloc] initWithFrame:CGRectZero];
        toggle.transform = CGAffineTransformMakeScale(1.3, 1.3);
        toggle.translatesAutoresizingMaskIntoConstraints = false;
        toggle.on = enabled;
        [toggle addTarget: self action:@selector(handleToggle) forControlEvents:UIControlEventValueChanged];
        [self.contentView addSubview:toggle];

        [NSLayoutConstraint activateConstraints:@[
            [toggle.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-5.0],
            [toggle.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor],
        ]];

        [self setControl:toggle];
    }

    return self;
}

- (void)handleToggle {
    [preferences setObject:@(((UISwitch *)(self.control)).on) forKey:@"enabled"];
    [preferences synchronize];

    BOOL enabled = [[preferences objectForKey:@"enabled"] boolValue];
    NSString *imageName = (enabled ? @"FullIcon.png" : @"FullIconNoCC.png");

    [UIView transitionWithView:imageView
                  duration:0.3
                   options:UIViewAnimationOptionTransitionCrossDissolve
                animations:^{
                    [imageView setImage:[UIImage imageNamed:imageName
                                                  inBundle:[NSBundle bundleForClass:self.class]
                             compatibleWithTraitCollection:nil]];
                }
                completion:nil];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    for (UIView *view in self.subviews) {
        if (view != self.contentView) {
            [view removeFromSuperview];
        }
    }
}

- (void)setSeparatorStyle:(UITableViewCellSeparatorStyle)style {
    [super setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

- (void)setBackgroundColor:(UIColor *)color {
    [super setBackgroundColor:[UIColor clearColor]];
}

@end
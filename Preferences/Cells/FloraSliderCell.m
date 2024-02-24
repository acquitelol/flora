#import "FloraSliderCell.h"

@implementation FloraSliderCell {
    NSUserDefaults *preferences;
    PSSpecifier *specifier;
    UISlider *slider;
    UITextField *textLabel;
    UITapGestureRecognizer *tapGestureRecognizer;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)_specifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier specifier:specifier];

    if (self) {
        preferences = [[NSUserDefaults alloc] initWithSuiteName:BUNDLE_ID];
        specifier = _specifier;
        slider = [[UISlider alloc] initWithFrame:CGRectZero];

        id userValue = [preferences objectForKey:[specifier propertyForKey:@"key"]];
        double baseValue = userValue != nil ? [userValue doubleValue] : [[specifier propertyForKey:@"default"] doubleValue];

        [slider setValue:baseValue animated:YES];
        [slider addTarget:self action:@selector(valueChanged) forControlEvents:UIControlEventValueChanged];
        [self.contentView addSubview:slider];

        textLabel = [[UITextField alloc] initWithFrame:CGRectZero];
        textLabel.font = [UIFont systemFontOfSize:17.0];
        textLabel.textAlignment = NSTextAlignmentRight;
        textLabel.keyboardType = UIKeyboardTypeDecimalPad;
        textLabel.text = [NSString stringWithFormat:@"%.2f", baseValue];
        [textLabel addTarget:self action:@selector(textInputChanged) forControlEvents:UIControlEventEditingChanged];
        [self.contentView addSubview:textLabel];

        tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
        [self.contentView addGestureRecognizer:tapGestureRecognizer];
    }

    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat textLabelWidth = 35.0;
    CGFloat textLabelHeight = self.contentView.bounds.size.height;
    CGFloat textLabelX = self.contentView.bounds.size.width - textLabelWidth - 16.0;
    CGFloat textLabelY = 0.0;
    textLabel.frame = CGRectMake(textLabelX, textLabelY, textLabelWidth, textLabelHeight);
    
    CGFloat sliderX = self.textLabel.frame.origin.x + self.textLabel.frame.size.width + 16.0;
    CGFloat sliderWidth = textLabelX - sliderX - 8.0;
    CGFloat sliderHeight = 31.0;
    CGFloat sliderY = (self.contentView.bounds.size.height - sliderHeight) / 2.0;
    slider.frame = CGRectMake(sliderX, sliderY, sliderWidth, sliderHeight);
}

- (void)valueChanged {
    CGFloat sliderValue = slider.value;
    NSString *formattedValue = [NSString stringWithFormat:@"%.2f", sliderValue];
    textLabel.text = formattedValue;
    
    [preferences setObject:formattedValue forKey:specifier.properties[@"key"]];
}

- (void)textInputChanged {
    NSString *textInputValue = textLabel.text;
    CGFloat value = [textInputValue doubleValue];
    if (value > 1.0) value = 1.0;
    
    NSString *formattedValue = [NSString stringWithFormat:@"%.2f", value];
    [slider setValue:value animated:YES];
    [preferences setObject:formattedValue forKey:specifier.properties[@"key"]];
}

- (void)dismissKeyboard {
    NSString *textInputValue = textLabel.text;
    CGFloat value = [textInputValue doubleValue];
    if (value > 1.0) value = 1.0;

    NSString *formattedValue = [NSString stringWithFormat:@"%.2f", value];
    textLabel.text = formattedValue;
    [textLabel resignFirstResponder];
}

@end
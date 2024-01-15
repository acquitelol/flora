#define TWEAK_NAME @"Flora"

#define BUNDLE_ID @"com.rosiepie.flora"
#define BUNDLE_ID_FUNCTION(arg) [NSString stringWithFormat:@"%@%@", BUNDLE_ID, @#arg]

#define ENABLED_KEY BUNDLE_ID_FUNCTION(.enabled)
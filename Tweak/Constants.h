#define TWEAK_NAME @"Flora"

#define BUNDLE_ID @"com.rosiepie.flora"
#define BUNDLE_ID_FUNCTION(arg) [NSString stringWithFormat:@"%@%@", BUNDLE_ID, @#arg]
#define FS_PREFERENCES(arg) [NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", BUNDLE_ID]

#define ENABLED_KEY BUNDLE_ID_FUNCTION(.enabled)
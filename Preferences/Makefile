BUNDLE_NAME = FloraPreferences
FloraPreferences_FILES = $(wildcard Controllers/*.m ../Tweak/Utilities.m Colors/*.m Cells/*.m Observers/*.m)
FloraPreferences_FRAMEWORKS = UIKit
FloraPreferences_PRIVATE_FRAMEWORKS = Preferences
FloraPreferences_INSTALL_PATH = /Library/PreferenceBundles
FloraPreferences_CFLAGS = -fobjc-arc -DPACKAGE_VERSION='@"$(THEOS_PACKAGE_BASE_VERSION)"' -DPACKAGE_SCHEME='@"$(THEOS_PACKAGE_SCHEME)"'
FloraPreferences_LIBRARIES = gcuniversal sandy

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/bundle.mk
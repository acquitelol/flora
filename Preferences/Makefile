BUNDLE_NAME = FloraPreferences
FloraPreferences_FILES = $(wildcard Controllers/*.m ../Tweak/Utilities.m Colors/*.m Cells/*.m Observers/*.m)
FloraPreferences_FRAMEWORKS = UIKit
FloraPreferences_PRIVATE_FRAMEWORKS = Preferences
FloraPreferences_INSTALL_PATH = /Library/PreferenceBundles
FloraPreferences_CFLAGS = -fobjc-arc -DPACKAGE_VERSION='@"$(THEOS_PACKAGE_BASE_VERSION)"' -DPACKAGE_DESCRIPTION='@"$(THEOS_PACKAGE_BASE_DESCRIPTION)"'
FloraPreferences_LIBRARIES = gcuniversal

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/bundle.mk
BUNDLE_NAME = FloraPreferences
FloraPreferences_FILES = $(wildcard Controllers/*.m ../Tweak/Utilities.m Colors/*.m Cells/*.m Observers/*.m)
FloraPreferences_FRAMEWORKS = UIKit
FloraPreferences_PRIVATE_FRAMEWORKS = Preferences
FloraPreferences_INSTALL_PATH = /Library/PreferenceBundles
FloraPreferences_CFLAGS = -fobjc-arc
FloraPreferences_LIBRARIES = gcuniversal
FloraPreferences_EXTRA_FRAMEWORKS += Cephei, CepheiPrefs

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/bundle.mk
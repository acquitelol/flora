export ARCHS = arm64 arm64e
THEOS_PACKAGE_SCHEME = rootless
TARGET := iphone:clang:latest:14.0
SUBPROJECTS = Tweak Preferences
# FINALPACKAGE = 1

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

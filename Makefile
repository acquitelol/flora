export ARCHS = arm64 arm64e

TARGET := iphone:clang:latest:14.0
SUBPROJECTS = Tweak Preferences

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
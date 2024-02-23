TWEAK_NAME = Flora
Flora_FILES = $(wildcard *.x *.m)
Flora_CFLAGS = -fobjc-arc
Flora_FRAMEWORKS = UIKit
Flora_LIBRARIES = gcuniversal sandy
Flora_LDFLAGS += -framework SpringBoardServices
Flora_LDFLAGS += -framework FrontBoardServices

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
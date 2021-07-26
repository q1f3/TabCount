GO_EASY_ON_ME = 1
FINALPACKAGE=1
DEBUG=0

THEOS_DEVICE_IP = 127.0.0.1 -p 2222

ARCHS := arm64
TARGET := iphone:clang:14.4:13.1

INSTALL_TARGET_PROCESSES = MobileSafari


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TabCount

TabCount_FILES = Tweak.x
TabCount_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

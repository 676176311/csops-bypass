THEOS_DEVICE_IP ?= YOUR_DEVICE_IP
THEOS_DEVICE_PORT ?= 22
export THEOS_PACKAGE_SCHEME = rootless

TARGET := iphone:clang:latest:14.0
ARCHS = arm64 arm64e

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CSOpsBypass

CSOpsBypass_FILES = Tweak.x
CSOpsBypass_CFLAGS = -fobjc-arc -Wno-unused-variable

include $(THEOS)/makefiles/tweak.mk

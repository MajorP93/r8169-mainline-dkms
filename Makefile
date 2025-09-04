# Kbuild for external r8169
obj-m := r8169.o
r8169-objs := src/r8169_main.o src/r8169_firmware.o src/r8169_phy_config.o

# If the LEDs helper is present in the imported sources, build it too
ifneq ($(wildcard $(src)/src/r8169_leds.c),)
  r8169-objs += src/r8169_leds.o
endif

# Embed provenance (visible via modinfo | strings)
ccflags-y += -DR8169_BACKPORT_TAG=\"$(shell cat VENDOR_TAG 2>/dev/null || echo unknown)\" \
             -DR8169_BACKPORT_COMMIT=\"$(shell cat VENDOR_COMMIT 2>/dev/null || echo unknown)\"

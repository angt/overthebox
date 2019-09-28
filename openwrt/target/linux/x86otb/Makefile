#
# Copyright (C) 2006-2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

ARCH:=i386
BOARD:=x86otb
BOARDNAME:=OverTheBox x86
FEATURES:=squashfs fpu
SUBTARGETS:=generic 64

KERNEL_PATCHVER:=4.14

KERNELNAME:=bzImage

include $(INCLUDE_DIR)/target.mk

DEFAULT_PACKAGES += partx-utils mkf2fs

$(eval $(call BuildTarget))

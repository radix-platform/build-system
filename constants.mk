# include once
ifndef CONSTANTS_MK

#######
####### Constants:
#######

SYSTEM_VERSION       = 0.0.1

#
# Distribution:
#
DISTRO_NAME          = radix

DISTRO_CAPTION       = Radix

DISTRO_VERSION       = 1.0

BUG_URL              = http://www.radix.pro


#
# Download Sources:
#
DOWNLOAD_SERVER      = ftp://ftp.radix.pro

WGET_OPTIONS         = -q -N



CACHED_CC_OUTPUT     = /opt/extra/ccache

TOOLCHAINS_BASE_PATH = /opt/toolchain


################################################################
#######
####### Target Package suffixes & functions:
#######

# pkgtool/make-package script creates three files:
#  - package tarball,
#  - package signature,
#  - package description.
# extensions of these files are depend on pkgtool.

pkg_arch_suffix = tgz
pkg_sign_suffix = sha256
pkg_desc_suffix = txt

#
# functions:
#
sign-name = $(subst .$(pkg_arch_suffix),.$(pkg_sign_suffix),$1)
desc-name = $(subst .$(pkg_arch_suffix),.$(pkg_desc_suffix),$1)
pkg-files = $1 $(call sign-name,$1) $(call desc-name,$1)

#
# usage:
#
#   pkg_archive     = $(TARGET_BUILD_DIR)/$(PKG_GROUP)/$(pkg_basename).$(pkg_arch_suffix)
#   pkg_signature   = $(call sign-name,$(pkg_archive))
#   pkg_description = $(call desc-name,$(pkg_archive))
#   products        = $(call pkg-files,$(pkg_archive))
#
#   PRODUCT_TARGETS = $(products)
#   ROOTFS_TARGETS  = $(pkg_archive)
#
#   $(pkg_signature)   : $(pkg_archive) ;
#   $(pkg_description) : $(pkg_archive) ;
#
#   $(pkg_archive): '''dependencies'''
#   	```package creation procedure'''

#######
####### End of Target Package suffixes & functions.
#######
################################################################


#
# NOTE:
# ====
#   Hardware names defined by 'HARDWARE_...' variables.
#   Hardware IDs variable names such as ..._ID_STD should have prefix
#   which is equal to $(HARDWARE_...) in upper case letters and symbol '-' should be replaced with '_'.
#   In other words the PREFIX is equal to PREFIX = $(shell echo $(HARDWARE_...) | tr '[a-z-]' '[A-Z_]').
#

#######
####### Hardware names:
#######
# noarch:
HARDWARE_NOARCH     = none
# Host Build:
HARDWARE_BUILD      = build
# x86 Personal Computer:
HARDWARE_PC32       = pc32
# {x86|x86_64} Personal Computer:
HARDWARE_PC64       = pc64

# A1N newlib devices (cubieboard 1):
HARDWARE_CB1N       = cb1n
# A1X devices (cubieboard 1 eglibc):
HARDWARE_CB1X       = cb1x
# A2N newlib devices (cubieboard 2):
HARDWARE_CB2N       = cb2n
# A2X devices (cubieboard 2 eglibc):
HARDWARE_CB2X       = cb2x
# A3N newlib devices (cubieboard 3):
HARDWARE_CB3N       = cb3n
# A3X devices (cubieboard 3 eglibc):
HARDWARE_CB3X       = cb3x

# AT91SAM7S devices:
HARDWARE_AT91S      = at91s
# DM644X newlib devices:
HARDWARE_VIP1830N   = vip1830n
# DM644X devices:
HARDWARE_VIP1830    = vip1830
# LPC17XX devices:
HARDWARE_L17UC      = l17uc
# OMAP35X devices:
HARDWARE_BEAGLE     = beagle
# OMAP543X devices:
HARDWARE_OMAP5UEVM  = omap5uevm
HARDWARE_DRA7XXEVM  = dra7xxevm
# BCM74X devices:
HARDWARE_B74        = b74


#######
####### Hardware IDs:
#######
        PC32_ID_STD = 01
        PC64_ID_STD = 02
        CB1N_ID_STD = 10
        CB1X_ID_STD = 11
        CB2N_ID_STD = 12
        CB2X_ID_STD = 13
        CB3N_ID_STD = 14
        CB3X_ID_STD = 15
       AT91S_ID_STD = 20
    VIP1830N_ID_STD = 30
     VIP1830_ID_STD = 31
       L17UC_ID_STD = 40
      BEAGLE_ID_STD = 50
   OMAP5UEVM_ID_STD = 60
   DRA7XXEVM_ID_STD = 61
         B74_ID_STD = 70



#######
####### Available Toolchains:
#######

#
# NOTE:
# ====
#   Toolchain names defined by 'TOOLCHAIN_...' variables.
#   Configuration variable names such as ..._ARCH, ..._DIR, ..._PATH should have prefix
#   which is equal to $(TOOLCHAIN_...) in upper case letters and symbol '-' should be replaced with '_'.
#   In other words the PREFIX is equal to PREFIX = $(shell echo $(TOOLCHAIN_...) | tr '[a-z-]' '[A-Z_]').
#

#   if variable ..._DEST_SYSROOT equal to "yes" then the switch --sysroot=$(TARGET_DEST_DIR)
#   is used to say that cross compiler have to usre $(TARGET_DEST_DIR) as system root instead
#   of compiler default sysroot $(TOOLCHAIN_PATH)/$(TARGET)/sys-root
#   The '...' as usually shoul be equal to suffix of some 'TOOLCHAIN_...' name.



# NOARCH
TOOLCHAIN_NOARCH  = noarch

NOARCH_ARCH       = noarch
NOARCH_VERSION    =
NOARCH_DIR        =
NOARCH_PATH       =

NOARCH_HARDWARE_VARIANTS := $(HARDWARE_NOARCH)


# BUILD machine
TOOLCHAIN_BUILD_MACHINE      = build-machine

BUILD_MACHINE_ARCH           = $(shell $(BUILDSYSTEM)/canonical-build)
BUILD_MACHINE_VERSION        =
BUILD_MACHINE_DIR            =
BUILD_MACHINE_PATH           = /usr

BUILD_MACHINE_HARDWARE_VARIANTS := $(HARDWARE_BUILD)



# I686-EGLIBC
TOOLCHAIN_I686_EGLIBC        = i686-eglibc

I686_EGLIBC_ARCH             = i486-radix-linux-gnu
I686_EGLIBC_VERSION          = 1.0.8
I686_EGLIBC_DIR              = i486-PC-linux-eglibc
I686_EGLIBC_PATH             = $(TOOLCHAINS_BASE_PATH)/$(I686_EGLIBC_DIR)

I686_EGLIBC_ARCH_DEFS        = -D__I686_EGLIBC__=1
I686_EGLIBC_ARCH_FLAGS       = -m32 -march=i486 -mtune=i686

I686_EGLIBC_SYSROOT          = sys-root
I686_EGLIBC_DEST_SYSROOT     = yes

I686_EGLIBC_HAS_CHRPATH      = yes

I686_EGLIBC_HARDWARE_VARIANTS := $(HARDWARE_PC32)



# X86_64-EGLIBC
TOOLCHAIN_X86_64_EGLIBC      = x86_64-eglibc

X86_64_EGLIBC_ARCH           = x86_64-radix-linux-gnu
X86_64_EGLIBC_VERSION        = 1.0.8
X86_64_EGLIBC_DIR            = x86_64-PC-linux-eglibc
X86_64_EGLIBC_PATH           = $(TOOLCHAINS_BASE_PATH)/$(X86_64_EGLIBC_DIR)

X86_64_EGLIBC_ARCH_DEFS      = -D__X86_64_EGLIBC__=1

X86_64_EGLIBC_SYSROOT        = sys-root
X86_64_EGLIBC_DEST_SYSROOT   = yes

X86_64_EGLIBC_HAS_CHRPATH    = yes

X86_64_EGLIBC_HARDWARE_VARIANTS := $(HARDWARE_PC64)



# A1X-NEWLIB
TOOLCHAIN_A1X_NEWLIB         = a1x-newlib

A1X_NEWLIB_ARCH              = arm-a1x-eabi
A1X_NEWLIB_VERSION           = 1.0.8
A1X_NEWLIB_DIR               = arm-A1X-eabi-newlib
A1X_NEWLIB_PATH              = $(TOOLCHAINS_BASE_PATH)/$(A1X_NEWLIB_DIR)

A1X_NEWLIB_ARCH_DEFS         = -D__ALLWINNER_1N__=1

A1X_NEWLIB_HARDWARE_VARIANTS := $(HARDWARE_CB1N)



# A1X-EGLIBC
TOOLCHAIN_A1X_EGLIBC         = a1x-eglibc

A1X_EGLIBC_ARCH              = arm-a1x-linux-gnueabihf
A1X_EGLIBC_VERSION           = 1.0.8
A1X_EGLIBC_DIR               = arm-A1X-linux-eglibc
A1X_EGLIBC_PATH              = $(TOOLCHAINS_BASE_PATH)/$(A1X_EGLIBC_DIR)

A1X_EGLIBC_ARCH_DEFS         = -D__ALLWINNER_1X__=1
A1X_EGLIBC_ARCH_FLAGS        = -march=armv7-a -mtune=cortex-a8 -mfloat-abi=hard -mfpu=neon -mabi=aapcs-linux -fomit-frame-pointer

A1X_EGLIBC_SYSROOT           = sys-root
A1X_EGLIBC_DEST_SYSROOT      = yes

A1X_EGLIBC_HAS_CHRPATH       = yes

A1X_EGLIBC_HARDWARE_VARIANTS := $(HARDWARE_CB1X)



# A2X-NEWLIB
TOOLCHAIN_A2X_NEWLIB         = a2x-newlib

A2X_NEWLIB_ARCH              = arm-a2x-eabi
A2X_NEWLIB_VERSION           = 1.0.8
A2X_NEWLIB_DIR               = arm-A2X-eabi-newlib
A2X_NEWLIB_PATH              = $(TOOLCHAINS_BASE_PATH)/$(A2X_NEWLIB_DIR)

A2X_NEWLIB_ARCH_DEFS         = -D__ALLWINNER_2N__=1

A2X_NEWLIB_HARDWARE_VARIANTS := $(HARDWARE_CB2N) $(HARDWARE_CB3N)



# A1X-EGLIBC
TOOLCHAIN_A2X_EGLIBC         = a2x-eglibc

A2X_EGLIBC_ARCH              = arm-a2x-linux-gnueabihf
A2X_EGLIBC_VERSION           = 1.0.8
A2X_EGLIBC_DIR               = arm-A2X-linux-eglibc
A2X_EGLIBC_PATH              = $(TOOLCHAINS_BASE_PATH)/$(A2X_EGLIBC_DIR)

A2X_EGLIBC_ARCH_DEFS         = -D__ALLWINNER_2X__=1
A2X_EGLIBC_ARCH_FLAGS        = -march=armv7ve -mtune=cortex-a7 -mfloat-abi=hard -mfpu=neon-vfpv4 -mabi=aapcs-linux -fomit-frame-pointer

A2X_EGLIBC_SYSROOT           = sys-root
A2X_EGLIBC_DEST_SYSROOT      = yes

A2X_EGLIBC_HAS_CHRPATH       = yes

A2X_EGLIBC_HARDWARE_VARIANTS := $(HARDWARE_CB2X) $(HARDWARE_CB3X)



# AT91SAM7S-NEWLIB
TOOLCHAIN_AT91SAM7S_NEWLIB   = at91sam7s-newlib

AT91SAM7S_NEWLIB_ARCH        = arm-at91sam7s-eabi
AT91SAM7S_NEWLIB_VERSION     = 1.0.8
AT91SAM7S_NEWLIB_DIR         = arm-AT91SAM7S-eabi-newlib
AT91SAM7S_NEWLIB_PATH        = $(TOOLCHAINS_BASE_PATH)/$(AT91SAM7S_NEWLIB_DIR)

AT91SAM7S_NEWLIB_ARCH_DEFS   = -D__AT91SAM7S__=1

AT91SAM7S_NEWLIB_HARDWARE_VARIANTS := $(HARDWARE_AT91S)



# DM644X-NEWLIB
TOOLCHAIN_DM644X_NEWLIB      = dm644x-newlib

DM644X_NEWLIB_ARCH           = arm-dm644x-eabi
DM644X_NEWLIB_VERSION        = 1.0.8
DM644X_NEWLIB_DIR            = arm-DM644X-eabi-newlib
DM644X_NEWLIB_PATH           = $(TOOLCHAINS_BASE_PATH)/$(DM644X_NEWLIB_DIR)

DM644X_NEWLIB_ARCH_DEFS      = -D__TMS320DM644X__=1

DM644X_NEWLIB_HARDWARE_VARIANTS := $(HARDWARE_VIP1830N)



# DM644X-EGLIBC
TOOLCHAIN_DM644X_EGLIBC      = dm644x-eglibc

DM644X_EGLIBC_ARCH           = arm-dm644x-linux-gnueabi
DM644X_EGLIBC_VERSION        = 1.0.8
DM644X_EGLIBC_DIR            = arm-DM644X-linux-eglibc
DM644X_EGLIBC_PATH           = $(TOOLCHAINS_BASE_PATH)/$(DM644X_EGLIBC_DIR)

DM644X_EGLIBC_ARCH_DEFS      = -D__DM644X__=1
DM644X_EGLIBC_ARCH_FLAGS     = -march=armv5te -mtune=arm926ej-s -mabi=aapcs-linux -fomit-frame-pointer

DM644X_EGLIBC_SYSROOT        = sys-root
DM644X_EGLIBC_DEST_SYSROOT   = yes

DM644X_EGLIBC_HAS_CHRPATH    = yes

DM644X_EGLIBC_HARDWARE_VARIANTS := $(HARDWARE_VIP1830)



# LPC17XX-UCLIBC
TOOLCHAIN_LPC17XX_UCLIBC     = lpc17xx-uclibc

LPC17XX_UCLIBC_ARCH          = arm-lpc17xx-uclinuxeabi
LPC17XX_UCLIBC_VERSION       = 1.0.8
LPC17XX_UCLIBC_DIR           = arm-LPC17XX-uclinuxeabi
LPC17XX_UCLIBC_PATH          = $(TOOLCHAINS_BASE_PATH)/$(LPC17XX_UCLIBC_DIR)

LPC17XX_UCLIBC_ARCH_DEFS     = -D__LPC17XX__=1

LPC17XX_EGLIBC_SYSROOT       = sys-root

LPC17XX_UCLIBC_HARDWARE_VARIANTS := $(HARDWARE_L17UC)



# OMAP35X-EGLIBC
TOOLCHAIN_OMAP35X_EGLIBC     = omap35x-eglibc

OMAP35X_EGLIBC_ARCH          = arm-omap35x-linux-gnueabihf
OMAP35X_EGLIBC_VERSION       = 1.0.8
OMAP35X_EGLIBC_DIR           = arm-OMAP35X-linux-eglibc
OMAP35X_EGLIBC_PATH          = $(TOOLCHAINS_BASE_PATH)/$(OMAP35X_EGLIBC_DIR)

OMAP35X_EGLIBC_ARCH_DEFS     = -D__OMAP35X__=1
OMAP35X_EGLIBC_ARCH_FLAGS    = -march=armv7-a -mtune=cortex-a8 -mfloat-abi=hard -mfpu=neon -mabi=aapcs-linux -fomit-frame-pointer

OMAP35X_EGLIBC_SYSROOT       = sys-root
OMAP35X_EGLIBC_DEST_SYSROOT  = yes

OMAP35X_EGLIBC_HAS_CHRPATH   = yes

OMAP35X_EGLIBC_HARDWARE_VARIANTS := $(HARDWARE_BEAGLE)



# OMAP543X-EGLIBC
TOOLCHAIN_OMAP543X_EGLIBC    = omap543x-eglibc

OMAP543X_EGLIBC_ARCH         = arm-omap543x-linux-gnueabihf
OMAP543X_EGLIBC_VERSION      = 1.0.8
OMAP543X_EGLIBC_DIR          = arm-OMAP543X-linux-eglibc
OMAP543X_EGLIBC_PATH         = $(TOOLCHAINS_BASE_PATH)/$(OMAP543X_EGLIBC_DIR)

OMAP543X_EGLIBC_ARCH_DEFS    = -D__OMAP543X__=1
OMAP543X_EGLIBC_ARCH_FLAGS   = -march=armv7-a -mtune=cortex-a15 -mfloat-abi=hard -mfpu=neon-vfpv4 -mabi=aapcs-linux -fomit-frame-pointer

OMAP543X_EGLIBC_SYSROOT      = sys-root
OMAP543X_EGLIBC_DEST_SYSROOT = yes

OMAP543X_EGLIBC_HAS_CHRPATH  = yes

OMAP543X_EGLIBC_HARDWARE_VARIANTS := $(HARDWARE_OMAP5UEVM) $(HARDWARE_DRA7XXEVM)



# BCM74X-EGLIBC
TOOLCHAIN_BCM74X_EGLIBC      = bcm74x-eglibc

BCM74X_EGLIBC_ARCH           = mipsel-bcm74x-linux-gnu
BCM74X_EGLIBC_VERSION        = 1.0.8
BCM74X_EGLIBC_DIR            = mipsel-BCM74X-linux-eglibc
BCM74X_EGLIBC_PATH           = $(TOOLCHAINS_BASE_PATH)/$(BCM74X_EGLIBC_DIR)

BCM74X_EGLIBC_ARCH_DEFS      = -D__BCM74X__=1

BCM74X_EGLIBC_SYSROOT        = sys-root
BCM74X_EGLIBC_DEST_SYSROOT   = yes

BCM74X_EGLIBC_HAS_CHRPATH    = yes

BCM74X_EGLIBC_HARDWARE_VARIANTS := $(HARDWARE_B74)




CONSTANTS_MK=1
endif

# include once
ifndef CONSTANTS_MK

#######
####### Constants:
#######

SYSTEM_VERSION       = 1.0.5

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

TOOLCHAINS_FTP_BASE  = toolchains/x86_64
TARBALL_SUFFIX       = tar.gz



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
###                  |---HW-spec-handy-ruler-----------------------|
# noarch:
HARDWARE_NOARCH     = none
# Host Build:
HARDWARE_BUILD      = build
# x86 Personal Computer:
HARDWARE_PC32       = pc32
PC32_SPEC           = Intel x86_32 generic Linux machine
# {x86|x86_64} Personal Computer:
HARDWARE_PC64       = pc64
PC64_SPEC           = Intel x86_32 generic Linux machine

# A1N newlib devices (cubieboard 1):
HARDWARE_CB1N       = cb1n
CB1N_SPEC           = Cubieboard A10 \(Newlib based\)
# A1X devices (cubieboard 1 glibc):
HARDWARE_CB1X       = cb1x
CB1X_SPEC           = Cubieboard A10 \(Linux, GNU Libc based\)
# A2N newlib devices (cubieboard 2):
HARDWARE_CB2N       = cb2n
CB2N_SPEC           = Cubieboard A20 \(Newlib based\)
# A2X devices (cubieboard 2 glibc):
HARDWARE_CB2X       = cb2x
CB2X_SPEC           = Cubieboard A20 \(Linux, GNU Libc based\)
# A3N newlib devices (cubieboard 3):
HARDWARE_CB3N       = cb3n
CB3N_SPEC           = Cubietrack A20 \(Newlib based\)
# A3X devices (cubieboard 3 glibc):
HARDWARE_CB3X       = cb3x
CB3X_SPEC           = Cubietrack A20 \(Linux, GNU Libc based\)

# AT91SAM7S devices:
HARDWARE_AT91S      = at91s
AT91S_SPEC          = Atmel at91sam7s \(Newlib based\)
# DM644X newlib devices:
HARDWARE_VIP1830N   = vip1830n
VIP1830N_SPEC       = Texas dm644x \(Newlib based\)
# DM644X devices:
HARDWARE_VIP1830    = vip1830
VIP1830_SPEC        = Texas dm644x \(Linux, GNU Libc based\)
# LPC17XX devices:
HARDWARE_L17UC      = l17uc
L17UC_SPEC          = NXP lpc17xx \(uCLibc based\)
# OMAP35X devices:
HARDWARE_BEAGLE     = beagle
BEAGLE_SPEC         = Beagleboard OMAP3 \(Linux, GNU Libc based\)
# OMAP543X devices:
HARDWARE_OMAP5UEVM  = omap5uevm
OMAP5UEVM_SPEC      = Texas OMAP5 uEVM \(Linux, GNU Libc based\)
HARDWARE_DRA7XXEVM  = dra7xxevm
DRA7XXEVM_SPEC      = Texas DRA7xx EVM \(Linux, GNU Libc based\)
# BCM74X devices:
HARDWARE_B74        = b74
B74_SPEC            = Broadcom bcm74XX \(Linux, GNU Libc based\)

# JZ47XX devices:
# --------------
# MIPS Creator CI20 [http://www.elinux.org/MIPS_Creator_CI20]:
HARDWARE_CI20       = ci20
CI20_SPEC           = MIPS Creator CI20 \(Linux, GNU Libc based\)

# RK328X devices:
# --------------
# Firefly-RK3288 [http://en.t-firefly.com/en/firenow/firefly_rk3288]:
HARDWARE_FFRK3288   = ffrk3288
FFRK3288_SPEC       = Firefly RK3288 \(Linux, GNU Libc based\)


#######
####### Hardware IDs:
#######
        PC32_ID_STD = 01
        PC64_ID_STD = 02
        CB1N_ID_STD = 10
        CB1X_ID_STD = 11
        CB2N_ID_STD = 20
        CB2X_ID_STD = 21
        CB3N_ID_STD = 30
        CB3X_ID_STD = 31
       AT91S_ID_STD = 40
    VIP1830N_ID_STD = 50
     VIP1830_ID_STD = 51
       L17UC_ID_STD = 60
      BEAGLE_ID_STD = 71
   OMAP5UEVM_ID_STD = 81
   DRA7XXEVM_ID_STD = 82
         B74_ID_STD = 91
        CI20_ID_STD = A1
    FFRK3288_ID_STD = B1



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
NOARCH_TARBALL    =

NOARCH_HARDWARE_VARIANTS := $(HARDWARE_NOARCH)


# BUILD machine
TOOLCHAIN_BUILD_MACHINE      = build-machine

BUILD_MACHINE_ARCH           = $(shell $(BUILDSYSTEM)/canonical-build)
BUILD_MACHINE_VERSION        =
BUILD_MACHINE_DIR            =
BUILD_MACHINE_PATH           = /usr
BUILD_MACHINE_TARBALL        =

BUILD_MACHINE_HARDWARE_VARIANTS := $(HARDWARE_BUILD)



# ======= I686-GLIBC =========================================================

TOOLCHAIN_I686_GLIBC         = i686-glibc

I686_GLIBC_ARCH              = i486-radix-linux-gnu
I686_GLIBC_VERSION           = 1.0.9
I686_GLIBC_DIR               = i486-PC-linux-glibc
I686_GLIBC_PATH              = $(TOOLCHAINS_BASE_PATH)/$(I686_GLIBC_DIR)
I686_GLIBC_TARBALL           = $(TOOLCHAINS_FTP_BASE)/$(I686_GLIBC_VERSION)/$(I686_GLIBC_DIR)-$(I686_GLIBC_VERSION).$(TARBALL_SUFFIX)

I686_GLIBC_ARCH_DEFS         = -D__I686_GLIBC__=1
I686_GLIBC_ARCH_FLAGS        = -m32 -march=i486 -mtune=i686

I686_GLIBC_SYSROOT           = sys-root
I686_GLIBC_DEST_SYSROOT      = yes

I686_GLIBC_HAS_CHRPATH       = yes

I686_GLIBC_HARDWARE_VARIANTS := $(HARDWARE_PC32)



# ======= X86_64-GLIBC =======================================================

TOOLCHAIN_X86_64_GLIBC       = x86_64-glibc

X86_64_GLIBC_ARCH            = x86_64-radix-linux-gnu
X86_64_GLIBC_VERSION         = 1.0.9
X86_64_GLIBC_DIR             = x86_64-PC-linux-glibc
X86_64_GLIBC_PATH            = $(TOOLCHAINS_BASE_PATH)/$(X86_64_GLIBC_DIR)
X86_64_GLIBC_TARBALL         = $(TOOLCHAINS_FTP_BASE)/$(X86_64_GLIBC_VERSION)/$(X86_64_GLIBC_DIR)-$(X86_64_GLIBC_VERSION).$(TARBALL_SUFFIX)

X86_64_GLIBC_ARCH_DEFS       = -D__X86_64_GLIBC__=1

X86_64_GLIBC_SYSROOT         = sys-root
X86_64_GLIBC_DEST_SYSROOT    = yes

X86_64_GLIBC_HAS_CHRPATH     = yes

X86_64_GLIBC_HARDWARE_VARIANTS := $(HARDWARE_PC64)



# ======= A1X-NEWLIB =========================================================

TOOLCHAIN_A1X_NEWLIB         = a1x-newlib

A1X_NEWLIB_ARCH              = arm-a1x-eabi
A1X_NEWLIB_VERSION           = 1.0.9
A1X_NEWLIB_DIR               = arm-A1X-eabi-newlib
A1X_NEWLIB_PATH              = $(TOOLCHAINS_BASE_PATH)/$(A1X_NEWLIB_DIR)
A1X_NEWLIB_TARBALL           = $(TOOLCHAINS_FTP_BASE)/$(A1X_NEWLIB_VERSION)/$(A1X_NEWLIB_DIR)-$(A1X_NEWLIB_VERSION).$(TARBALL_SUFFIX)

A1X_NEWLIB_ARCH_DEFS         = -D__ALLWINNER_1N__=1

A1X_NEWLIB_HARDWARE_VARIANTS := $(HARDWARE_CB1N)



# ======= A1X-GLIBC ==========================================================

TOOLCHAIN_A1X_GLIBC          = a1x-glibc

A1X_GLIBC_ARCH               = arm-a1x-linux-gnueabihf
A1X_GLIBC_VERSION            = 1.0.9
A1X_GLIBC_DIR                = arm-A1X-linux-glibc
A1X_GLIBC_PATH               = $(TOOLCHAINS_BASE_PATH)/$(A1X_GLIBC_DIR)
A1X_GLIBC_TARBALL            = $(TOOLCHAINS_FTP_BASE)/$(A1X_GLIBC_VERSION)/$(A1X_GLIBC_DIR)-$(A1X_GLIBC_VERSION).$(TARBALL_SUFFIX)

A1X_GLIBC_ARCH_DEFS          = -D__ALLWINNER_1X_GLIBC__=1
A1X_GLIBC_ARCH_FLAGS         = -march=armv7-a -mtune=cortex-a8 -mfloat-abi=hard -mfpu=neon -mabi=aapcs-linux -fomit-frame-pointer

A1X_GLIBC_SYSROOT            = sys-root
A1X_GLIBC_DEST_SYSROOT       = yes

A1X_GLIBC_HAS_CHRPATH        = yes

A1X_GLIBC_HARDWARE_VARIANTS := $(HARDWARE_CB1X)



# ======= A2X-NEWLIB =========================================================

TOOLCHAIN_A2X_NEWLIB         = a2x-newlib

A2X_NEWLIB_ARCH              = arm-a2x-eabi
A2X_NEWLIB_VERSION           = 1.0.9
A2X_NEWLIB_DIR               = arm-A2X-eabi-newlib
A2X_NEWLIB_PATH              = $(TOOLCHAINS_BASE_PATH)/$(A2X_NEWLIB_DIR)
A2X_NEWLIB_TARBALL           = $(TOOLCHAINS_FTP_BASE)/$(A2X_NEWLIB_VERSION)/$(A2X_NEWLIB_DIR)-$(A2X_NEWLIB_VERSION).$(TARBALL_SUFFIX)

A2X_NEWLIB_ARCH_DEFS         = -D__ALLWINNER_2N__=1

A2X_NEWLIB_HARDWARE_VARIANTS := $(HARDWARE_CB2N) $(HARDWARE_CB3N)



# ======= A2X-GLIBC =========================================================

TOOLCHAIN_A2X_GLIBC          = a2x-glibc

A2X_GLIBC_ARCH               = arm-a2x-linux-gnueabihf
A2X_GLIBC_VERSION            = 1.0.9
A2X_GLIBC_DIR                = arm-A2X-linux-glibc
A2X_GLIBC_PATH               = $(TOOLCHAINS_BASE_PATH)/$(A2X_GLIBC_DIR)
A2X_GLIBC_TARBALL            = $(TOOLCHAINS_FTP_BASE)/$(A2X_GLIBC_VERSION)/$(A2X_GLIBC_DIR)-$(A2X_GLIBC_VERSION).$(TARBALL_SUFFIX)

A2X_GLIBC_ARCH_DEFS          = -D__ALLWINNER_2X_GLIBC__=1
A2X_GLIBC_ARCH_FLAGS         = -march=armv7ve -mtune=cortex-a7 -mfloat-abi=hard -mfpu=neon-vfpv4 -mabi=aapcs-linux -fomit-frame-pointer

A2X_GLIBC_SYSROOT            = sys-root
A2X_GLIBC_DEST_SYSROOT       = yes

A2X_GLIBC_HAS_CHRPATH        = yes

A2X_GLIBC_HARDWARE_VARIANTS := $(HARDWARE_CB2X) $(HARDWARE_CB3X)



# ======= RK328X-GLIBC ======================================================

TOOLCHAIN_RK328X_GLIBC       = rk328x-glibc

RK328X_GLIBC_ARCH            = arm-rk328x-linux-gnueabihf
RK328X_GLIBC_VERSION         = 1.0.9
RK328X_GLIBC_DIR             = arm-RK328X-linux-glibc
RK328X_GLIBC_PATH            = $(TOOLCHAINS_BASE_PATH)/$(RK328X_GLIBC_DIR)
RK328X_GLIBC_TARBALL         = $(TOOLCHAINS_FTP_BASE)/$(RK328X_GLIBC_VERSION)/$(RK328X_GLIBC_DIR)-$(RK328X_GLIBC_VERSION).$(TARBALL_SUFFIX)

RK328X_GLIBC_ARCH_DEFS       = -D__RK328X_GLIBC__=1
RK328X_GLIBC_ARCH_FLAGS      = -march=armv7ve -mtune=cortex-a12 -mfloat-abi=hard -mfpu=neon-vfpv4 -mabi=aapcs-linux -fomit-frame-pointer

RK328X_GLIBC_SYSROOT         = sys-root
RK328X_GLIBC_DEST_SYSROOT    = yes

RK328X_GLIBC_HAS_CHRPATH     = yes

RK328X_GLIBC_HARDWARE_VARIANTS := $(HARDWARE_FFRK3288)



# ======= AT91SAM7S-NEWLIB ===================================================

TOOLCHAIN_AT91SAM7S_NEWLIB   = at91sam7s-newlib

AT91SAM7S_NEWLIB_ARCH        = arm-at91sam7s-eabi
AT91SAM7S_NEWLIB_VERSION     = 1.0.9
AT91SAM7S_NEWLIB_DIR         = arm-AT91SAM7S-eabi-newlib
AT91SAM7S_NEWLIB_PATH        = $(TOOLCHAINS_BASE_PATH)/$(AT91SAM7S_NEWLIB_DIR)
AT91SAM7S_NEWLIB_TARBALL     = $(TOOLCHAINS_FTP_BASE)/$(AT91SAM7S_NEWLIB_VERSION)/$(AT91SAM7S_NEWLIB_DIR)-$(AT91SAM7S_NEWLIB_VERSION).$(TARBALL_SUFFIX)

AT91SAM7S_NEWLIB_ARCH_DEFS   = -D__AT91SAM7S__=1

AT91SAM7S_NEWLIB_HARDWARE_VARIANTS := $(HARDWARE_AT91S)



# ======= DM644X-NEWLIB ======================================================

TOOLCHAIN_DM644X_NEWLIB      = dm644x-newlib

DM644X_NEWLIB_ARCH           = arm-dm644x-eabi
DM644X_NEWLIB_VERSION        = 1.0.9
DM644X_NEWLIB_DIR            = arm-DM644X-eabi-newlib
DM644X_NEWLIB_PATH           = $(TOOLCHAINS_BASE_PATH)/$(DM644X_NEWLIB_DIR)
DM644X_NEWLIB_TARBALL        = $(TOOLCHAINS_FTP_BASE)/$(DM644X_NEWLIB_VERSION)/$(DM644X_NEWLIB_DIR)-$(DM644X_NEWLIB_VERSION).$(TARBALL_SUFFIX)

DM644X_NEWLIB_ARCH_DEFS      = -D__TMS320DM644X__=1

DM644X_NEWLIB_HARDWARE_VARIANTS := $(HARDWARE_VIP1830N)



# ======= DM644X-GLIBC =======================================================

TOOLCHAIN_DM644X_GLIBC       = dm644x-glibc

DM644X_GLIBC_ARCH            = arm-dm644x-linux-gnueabi
DM644X_GLIBC_VERSION         = 1.0.9
DM644X_GLIBC_DIR             = arm-DM644X-linux-glibc
DM644X_GLIBC_PATH            = $(TOOLCHAINS_BASE_PATH)/$(DM644X_GLIBC_DIR)
DM644X_GLIBC_TARBALL         = $(TOOLCHAINS_FTP_BASE)/$(DM644X_GLIBC_VERSION)/$(DM644X_GLIBC_DIR)-$(DM644X_GLIBC_VERSION).$(TARBALL_SUFFIX)

DM644X_GLIBC_ARCH_DEFS       = -D__DM644X_GLIBC__=1
DM644X_GLIBC_ARCH_FLAGS      = -march=armv5te -mtune=arm926ej-s -mabi=aapcs-linux -fomit-frame-pointer

DM644X_GLIBC_SYSROOT         = sys-root
DM644X_GLIBC_DEST_SYSROOT    = yes

DM644X_GLIBC_HAS_CHRPATH     = yes

DM644X_GLIBC_HARDWARE_VARIANTS := $(HARDWARE_VIP1830)



# ======= LPC17XX-UCLIBC =====================================================

TOOLCHAIN_LPC17XX_UCLIBC     = lpc17xx-uclibc

LPC17XX_UCLIBC_ARCH          = arm-lpc17xx-uclinuxeabi
LPC17XX_UCLIBC_VERSION       = 1.0.9
LPC17XX_UCLIBC_DIR           = arm-LPC17XX-uclinuxeabi
LPC17XX_UCLIBC_PATH          = $(TOOLCHAINS_BASE_PATH)/$(LPC17XX_UCLIBC_DIR)
LPC17XX_UCLIBC_TARBALL       = $(TOOLCHAINS_FTP_BASE)/$(LPC17XX_UCLIBC_VERSION)/$(LPC17XX_UCLIBC_DIR)-$(LPC17XX_UCLIBC_VERSION).$(TARBALL_SUFFIX)

LPC17XX_UCLIBC_ARCH_DEFS     = -D__LPC17XX__=1

LPC17XX_UCLIBC_SYSROOT       = sys-root

LPC17XX_UCLIBC_HARDWARE_VARIANTS := $(HARDWARE_L17UC)



# ======= OMAP35X-GLIBC ======================================================

TOOLCHAIN_OMAP35X_GLIBC      = omap35x-glibc

OMAP35X_GLIBC_ARCH           = arm-omap35x-linux-gnueabihf
OMAP35X_GLIBC_VERSION        = 1.0.9
OMAP35X_GLIBC_DIR            = arm-OMAP35X-linux-glibc
OMAP35X_GLIBC_PATH           = $(TOOLCHAINS_BASE_PATH)/$(OMAP35X_GLIBC_DIR)
OMAP35X_GLIBC_TARBALL        = $(TOOLCHAINS_FTP_BASE)/$(OMAP35X_GLIBC_VERSION)/$(OMAP35X_GLIBC_DIR)-$(OMAP35X_GLIBC_VERSION).$(TARBALL_SUFFIX)

OMAP35X_GLIBC_ARCH_DEFS      = -D__OMAP35X_GLIBC__=1
OMAP35X_GLIBC_ARCH_FLAGS     = -march=armv7-a -mtune=cortex-a8 -mfloat-abi=hard -mfpu=neon -mabi=aapcs-linux -fomit-frame-pointer

OMAP35X_GLIBC_SYSROOT        = sys-root
OMAP35X_GLIBC_DEST_SYSROOT   = yes

OMAP35X_GLIBC_HAS_CHRPATH    = yes

OMAP35X_GLIBC_HARDWARE_VARIANTS := $(HARDWARE_BEAGLE)



# ======= OMAP543X-GLIBC =====================================================

TOOLCHAIN_OMAP543X_GLIBC     = omap543x-glibc

OMAP543X_GLIBC_ARCH          = arm-omap543x-linux-gnueabihf
OMAP543X_GLIBC_VERSION       = 1.0.9
OMAP543X_GLIBC_DIR           = arm-OMAP543X-linux-glibc
OMAP543X_GLIBC_PATH          = $(TOOLCHAINS_BASE_PATH)/$(OMAP543X_GLIBC_DIR)
OMAP543X_GLIBC_TARBALL       = $(TOOLCHAINS_FTP_BASE)/$(OMAP543X_GLIBC_VERSION)/$(OMAP543X_GLIBC_DIR)-$(OMAP543X_GLIBC_VERSION).$(TARBALL_SUFFIX)

OMAP543X_GLIBC_ARCH_DEFS     = -D__OMAP543X_GLIBC__=1
OMAP543X_GLIBC_ARCH_FLAGS    = -march=armv7-a -mtune=cortex-a15 -mfloat-abi=hard -mfpu=neon-vfpv4 -mabi=aapcs-linux -fomit-frame-pointer

OMAP543X_GLIBC_SYSROOT       = sys-root
OMAP543X_GLIBC_DEST_SYSROOT  = yes

OMAP543X_GLIBC_HAS_CHRPATH   = yes

OMAP543X_GLIBC_HARDWARE_VARIANTS := $(HARDWARE_OMAP5UEVM) $(HARDWARE_DRA7XXEVM)



# ======= BCM74X-GLIBC =======================================================

TOOLCHAIN_BCM74X_GLIBC       = bcm74x-glibc

BCM74X_GLIBC_ARCH            = mipsel-bcm74x-linux-gnu
BCM74X_GLIBC_VERSION         = 1.0.9
BCM74X_GLIBC_DIR             = mipsel-BCM74X-linux-glibc
BCM74X_GLIBC_PATH            = $(TOOLCHAINS_BASE_PATH)/$(BCM74X_GLIBC_DIR)
BCM74X_GLIBC_TARBALL         = $(TOOLCHAINS_FTP_BASE)/$(BCM74X_GLIBC_VERSION)/$(BCM74X_GLIBC_DIR)-$(BCM74X_GLIBC_VERSION).$(TARBALL_SUFFIX)

BCM74X_GLIBC_ARCH_DEFS       = -D__BCM74X_GLIBC__=1

BCM74X_GLIBC_SYSROOT         = sys-root
BCM74X_GLIBC_DEST_SYSROOT    = yes

BCM74X_GLIBC_HAS_CHRPATH     = yes

BCM74X_GLIBC_HARDWARE_VARIANTS := $(HARDWARE_B74)



# ======= JZ47XX-GLIBC =======================================================

TOOLCHAIN_JZ47XX_GLIBC       = jz47xx-glibc

JZ47XX_GLIBC_ARCH            = mipsel-jz47xx-linux-gnu
JZ47XX_GLIBC_VERSION         = 1.0.9
JZ47XX_GLIBC_DIR             = mipsel-JZ47XX-linux-glibc
JZ47XX_GLIBC_PATH            = $(TOOLCHAINS_BASE_PATH)/$(JZ47XX_GLIBC_DIR)
JZ47XX_GLIBC_TARBALL         = $(TOOLCHAINS_FTP_BASE)/$(JZ47XX_GLIBC_VERSION)/$(JZ47XX_GLIBC_DIR)-$(JZ47XX_GLIBC_VERSION).$(TARBALL_SUFFIX)

JZ47XX_GLIBC_ARCH_DEFS       = -D__JZ47XX_GLIBC__=1
JZ47XX_GLIBC_ARCH_FLAGS      = -march=mips32r2 -mel -mhard-float -fomit-frame-pointer

JZ47XX_GLIBC_SYSROOT         = sys-root
JZ47XX_GLIBC_DEST_SYSROOT    = yes

JZ47XX_GLIBC_HAS_CHRPATH     = yes

JZ47XX_GLIBC_HARDWARE_VARIANTS := $(HARDWARE_CI20)




CONSTANTS_MK=1
endif

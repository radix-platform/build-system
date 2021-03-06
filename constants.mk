# include once
ifndef CONSTANTS_MK

#######
####### Constants:
#######

SYSTEM_VERSION       = 1.2.3

#
# Distribution:
#
DISTRO_NAME          = radix

DISTRO_CAPTION       = Radix

DISTRO_VERSION       = 1.1

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

pkg_arch_suffix = txz
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
####### Hardware names and specific attributes:
#######

####### noarch:
HARDWARE_NOARCH     = none
####### Host Build:
HARDWARE_BUILD      = build

#
# NOTE:
# ====
#   $(HARDWARE)_USE_BUILT_GCC_LIBS - defines that the system is based on GCC Runtime Libraries
#                                    which built in the platform instead of Libraries which
#                                    are taken from TOOLCHAIN.
#
#   These variables give their values to the global variable named as __USE_BUILT_GCC_LIBS__
#   and defined in the target-setup.mk file. Variable __USE_BUILT_GCC_LIBS__ can be used in
#   user's Makefile to deside do we need to wait gcc built or we can to set dependencies from
#   GNU Libc which based on GCC Runtime Libs taken from toolchain.
#
#   [see: app/inputattach/1.4.7/Makefile, for example].
#

####### x86 Personal Computer:
HARDWARE_PC32                  = pc32
###                             |---HW-spec-handy-ruler-----------------------|
PC32_SPEC                      = Intel x86_32 generic Linux machine
PC32_USE_BUILT_GCC_LIBS        = yes

####### {x86|x86_64} Personal Computer:
HARDWARE_PC64                  = pc64
###                             |---HW-spec-handy-ruler-----------------------|
PC64_SPEC                      = Intel x86_64 generic Linux machine
PC64_USE_BUILT_GCC_LIBS        = yes

####### x86 micro Linux:
HARDWARE_PC32M                 = pc32m
###                             |---HW-spec-handy-ruler-----------------------|
PC32M_SPEC                     = x86_32 micro Linux
PC32M_USE_BUILT_GCC_LIBS       = no

####### x86_64 micro Linux:
HARDWARE_PC64M                 = pc64m
###                             |---HW-spec-handy-ruler-----------------------|
PC64M_SPEC                     = x86_64 micro Linux
PC64M_USE_BUILT_GCC_LIBS       = no


####### A1N newlib devices (cubieboard 1):
HARDWARE_CB1N                  = cb1n
###                             |---HW-spec-handy-ruler-----------------------|
CB1N_SPEC                      = Cubieboard A10 \(Newlib based\)
CB1N_USE_BUILT_GCC_LIBS        = no

####### A1X devices (cubieboard 1 glibc):
HARDWARE_CB1X                  = cb1x
###                             |---HW-spec-handy-ruler-----------------------|
CB1X_SPEC                      = Cubieboard A10 \(Linux, GNU Libc based\)
CB1X_USE_BUILT_GCC_LIBS        = yes

####### A2N newlib devices (cubieboard 2):
HARDWARE_CB2N                  = cb2n
###                             |---HW-spec-handy-ruler-----------------------|
CB2N_SPEC                      = Cubieboard A20 \(Newlib based\)
CB2N_USE_BUILT_GCC_LIBS        = no

####### A2X devices (cubieboard 2 glibc):
HARDWARE_CB2X                  = cb2x
###                             |---HW-spec-handy-ruler-----------------------|
CB2X_SPEC                      = Cubieboard A20 \(Linux, GNU Libc based\)
CB2X_USE_BUILT_GCC_LIBS        = yes

####### A3N newlib devices (cubieboard 3):
HARDWARE_CB3N                  = cb3n
###                             |---HW-spec-handy-ruler-----------------------|
CB3N_SPEC                      = Cubietrack A20 \(Newlib based\)
CB3N_USE_BUILT_GCC_LIBS        = no

####### A3X devices (cubieboard 3 glibc):
HARDWARE_CB3X                  = cb3x
###                             |---HW-spec-handy-ruler-----------------------|
CB3X_SPEC                      = Cubietrack A20 \(Linux, GNU Libc based\)
CB3X_USE_BUILT_GCC_LIBS        = yes

####### AT91SAM7S devices:
HARDWARE_AT91S                 = at91s
###                             |---HW-spec-handy-ruler-----------------------|
AT91S_SPEC                     = Atmel at91sam7s \(Newlib based\)
AT91S_USE_BUILT_GCC_LIBS       = no

####### LPC17XX devices:
HARDWARE_L17UC                 = l17uc
###                             |---HW-spec-handy-ruler-----------------------|
L17UC_SPEC                     = NXP lpc17xx \(uCLibc based\)
L17UC_USE_BUILT_GCC_LIBS       = no

####### i.MX6 devices:
####### -------------
####### Nitrogen6X [https://boundarydevices.com/product/nitrogen6x-board-imx6-arm-cortex-a9-sbc]:
HARDWARE_NIT6Q                 = nit6q
###                             |---HW-spec-handy-ruler-----------------------|
NIT6Q_SPEC                     = Nitrogen6X Nit6Q \(Linux, GNU Libc based\)
NIT6Q_USE_BUILT_GCC_LIBS       = yes

####### OMAP543X devices:
HARDWARE_OMAP5UEVM             = omap5uevm
###                             |---HW-spec-handy-ruler-----------------------|
OMAP5UEVM_SPEC                 = Texas OMAP5 uEVM \(Linux, GNU Libc based\)
OMAP5UEVM_USE_BUILT_GCC_LIBS   = yes

HARDWARE_DRA7XXEVM             = dra7xxevm
###                             |---HW-spec-handy-ruler-----------------------|
DRA7XXEVM_SPEC                 = Texas DRA7xx EVM \(Linux, GNU Libc based\)
DRA7XXEVM_USE_BUILT_GCC_LIBS   = yes

####### JZ47XX devices:
####### --------------
####### MIPS Creator CI20 [http://www.elinux.org/MIPS_Creator_CI20]:
HARDWARE_CI20                  = ci20
###                             |---HW-spec-handy-ruler-----------------------|
CI20_SPEC                      = MIPS Creator CI20 \(Linux, GNU Libc based\)
CI20_USE_BUILT_GCC_LIBS        = yes

####### MIPS Warrior P-class P5600 devices:
####### ----------------------------------
####### Baikal T1 based boards [http://baikalelectronics.com/products/168]:
HARDWARE_BT1                   = bt1
###                             |---HW-spec-handy-ruler-----------------------|
BT1_SPEC                       = MIPS Baikal T1 \(Linux, GNU Libc based\)
BT1_USE_BUILT_GCC_LIBS         = yes

####### RK328X devices:
####### --------------
####### Firefly-RK3288 [http://en.t-firefly.com/en/firenow/firefly_rk3288]:
HARDWARE_FFRK3288              = ffrk3288
###                             |---HW-spec-handy-ruler-----------------------|
FFRK3288_SPEC                  = Firefly RK3288 \(Linux, GNU Libc based\)
FFRK3288_USE_BUILT_GCC_LIBS    = yes


####### S8XX devices:
####### ------------

####### Amlogic S805 meson8b m201:
HARDWARE_M201                  = m201
###                             |---HW-spec-handy-ruler-----------------------|
M201_SPEC                      = Amlogic M201 S805 \(Linux, GNU Libc based\)
M201_USE_BUILT_GCC_LIBS        = yes

HARDWARE_MXV                   = mxv
###                             |---HW-spec-handy-ruler-----------------------|
MXV_SPEC                       = MXV OTT Box S805 \(Linux, GNU Libc based\)
MXV_USE_BUILT_GCC_LIBS         = yes


####### S9XX devices:
####### ------------

####### Amlogic S905 meson-gxbb p201:
HARDWARE_P201                  = p201
###                             |---HW-spec-handy-ruler-----------------------|
P201_SPEC                      = Amlogic P201 S905 \(Linux, GNU Libc based\)
P201_USE_BUILT_GCC_LIBS        = yes

HARDWARE_NEXBOX_A95X           = nexbox-a95x
###                             |---HW-spec-handy-ruler-----------------------|
NEXBOX_A95X_SPEC               = NEXBOX A95X S905 \(Linux, GNU Libc based\)
NEXBOX_A95X_USE_BUILT_GCC_LIBS = yes

HARDWARE_ODROID_C2             = odroid-c2
###                             |---HW-spec-handy-ruler-----------------------|
ODROID_C2_SPEC                 = ODROID C2 S905 \(Linux, GNU Libc based\)
ODROID_C2_USE_BUILT_GCC_LIBS   = yes

####### Amlogic S905X meson-gxl p212:
HARDWARE_P212                  = p212
###                             |---HW-spec-handy-ruler-----------------------|
P212_SPEC                      = Amlogic P212 S905X \(Linux, GNU Libc based\)
P212_USE_BUILT_GCC_LIBS        = yes

HARDWARE_KHADAS_VIM            = khadas-vim
###                             |---HW-spec-handy-ruler-----------------------|
KHADAS_VIM_SPEC                = Khadas Vim S905X \(Linux, GNU Libc based\)
KHADAS_VIM_USE_BUILT_GCC_LIBS  = yes

####### Amlogic S912 meson-gxm q201:
HARDWARE_Q201                  = q201
###                             |---HW-spec-handy-ruler-----------------------|
Q201_SPEC                      = Amlogic Q201 S912 \(Linux, GNU Libc based\)
Q201_USE_BUILT_GCC_LIBS        = yes

HARDWARE_ENYBOX_X2             = enybox-x2
###                             |---HW-spec-handy-ruler-----------------------|
ENYBOX_X2_SPEC                 = Enybox X2 S912 \(Linux, GNU Libc based\)
ENYBOX_X2_USE_BUILT_GCC_LIBS   = yes



HW_SPEC                = $(shell echo $($(shell echo $(HARDWARE) | tr '[a-z-]' '[A-Z_]')_SPEC) | sed "s, (.*),,")
__USE_BUILT_GCC_LIBS__ = $(strip $(shell echo $($(shell echo $(HARDWARE) | tr '[a-z-]' '[A-Z_]')_USE_BUILT_GCC_LIBS)))


#######
####### Hardware IDs:
#######
        PC32_ID_STD = 01
        PC64_ID_STD = 02
       PC32M_ID_STD = 04
       PC64M_ID_STD = 08
        CB1N_ID_STD = 10
        CB1X_ID_STD = 11
        CB2N_ID_STD = 20
        CB2X_ID_STD = 21
        CB3N_ID_STD = 30
        CB3X_ID_STD = 31
       AT91S_ID_STD = 40
       L17UC_ID_STD = 50
       NIT6Q_ID_STD = 61
   OMAP5UEVM_ID_STD = 81
   DRA7XXEVM_ID_STD = 82
        CI20_ID_STD = 91
         BT1_ID_STD = A1
    FFRK3288_ID_STD = B1
        M201_ID_STD = C1
         MXV_ID_STD = C2
        P201_ID_STD = D1
 NEXBOX_A95X_ID_STD = D2
   ODROID_C2_ID_STD = D4
        P212_ID_STD = E1
  KHADAS_VIM_ID_STD = E2
        Q201_ID_STD = F1
   ENYBOX_X2_ID_STD = F2



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

I686_GLIBC_ARCH              = i686-radix-linux-gnu
I686_GLIBC_VERSION           = 1.1.4
I686_GLIBC_DIR               = i686-PC-linux-glibc
I686_GLIBC_PATH              = $(TOOLCHAINS_BASE_PATH)/$(I686_GLIBC_DIR)
I686_GLIBC_TARBALL           = $(TOOLCHAINS_FTP_BASE)/$(I686_GLIBC_VERSION)/$(I686_GLIBC_DIR)-$(I686_GLIBC_VERSION).$(TARBALL_SUFFIX)

I686_GLIBC_ARCH_DEFS         = -D__I686_GLIBC__=1
I686_GLIBC_ARCH_FLAGS        = -m32 -march=i686 -mtune=i686

I686_GLIBC_SYSROOT           = sys-root
I686_GLIBC_DEST_SYSROOT      = yes

I686_GLIBC_HAS_CHRPATH       = yes

I686_GLIBC_HARDWARE_VARIANTS := $(HARDWARE_PC32) $(HARDWARE_PC32M)



# ======= X86_64-GLIBC =======================================================

TOOLCHAIN_X86_64_GLIBC       = x86_64-glibc

X86_64_GLIBC_ARCH            = x86_64-radix-linux-gnu
X86_64_GLIBC_VERSION         = 1.1.4
X86_64_GLIBC_DIR             = x86_64-PC-linux-glibc
X86_64_GLIBC_PATH            = $(TOOLCHAINS_BASE_PATH)/$(X86_64_GLIBC_DIR)
X86_64_GLIBC_TARBALL         = $(TOOLCHAINS_FTP_BASE)/$(X86_64_GLIBC_VERSION)/$(X86_64_GLIBC_DIR)-$(X86_64_GLIBC_VERSION).$(TARBALL_SUFFIX)

X86_64_GLIBC_ARCH_DEFS       = -D__X86_64_GLIBC__=1

X86_64_GLIBC_SYSROOT         = sys-root
X86_64_GLIBC_DEST_SYSROOT    = yes

X86_64_GLIBC_HAS_CHRPATH     = yes

X86_64_GLIBC_HARDWARE_VARIANTS := $(HARDWARE_PC64) $(HARDWARE_PC64M)



# ======= A1X-NEWLIB =========================================================

TOOLCHAIN_A1X_NEWLIB         = a1x-newlib

A1X_NEWLIB_ARCH              = arm-a1x-eabi
A1X_NEWLIB_VERSION           = 1.1.4
A1X_NEWLIB_DIR               = arm-A1X-eabi-newlib
A1X_NEWLIB_PATH              = $(TOOLCHAINS_BASE_PATH)/$(A1X_NEWLIB_DIR)
A1X_NEWLIB_TARBALL           = $(TOOLCHAINS_FTP_BASE)/$(A1X_NEWLIB_VERSION)/$(A1X_NEWLIB_DIR)-$(A1X_NEWLIB_VERSION).$(TARBALL_SUFFIX)

A1X_NEWLIB_ARCH_DEFS         = -D__ALLWINNER_1N__=1

A1X_NEWLIB_HARDWARE_VARIANTS := $(HARDWARE_CB1N)



# ======= A1X-GLIBC ==========================================================

TOOLCHAIN_A1X_GLIBC          = a1x-glibc

A1X_GLIBC_ARCH               = arm-a1x-linux-gnueabihf
A1X_GLIBC_VERSION            = 1.1.4
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
A2X_NEWLIB_VERSION           = 1.1.4
A2X_NEWLIB_DIR               = arm-A2X-eabi-newlib
A2X_NEWLIB_PATH              = $(TOOLCHAINS_BASE_PATH)/$(A2X_NEWLIB_DIR)
A2X_NEWLIB_TARBALL           = $(TOOLCHAINS_FTP_BASE)/$(A2X_NEWLIB_VERSION)/$(A2X_NEWLIB_DIR)-$(A2X_NEWLIB_VERSION).$(TARBALL_SUFFIX)

A2X_NEWLIB_ARCH_DEFS         = -D__ALLWINNER_2N__=1

A2X_NEWLIB_HARDWARE_VARIANTS := $(HARDWARE_CB2N) $(HARDWARE_CB3N)



# ======= A2X-GLIBC =========================================================

TOOLCHAIN_A2X_GLIBC          = a2x-glibc

A2X_GLIBC_ARCH               = arm-a2x-linux-gnueabihf
A2X_GLIBC_VERSION            = 1.1.4
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
RK328X_GLIBC_VERSION         = 1.1.4
RK328X_GLIBC_DIR             = arm-RK328X-linux-glibc
RK328X_GLIBC_PATH            = $(TOOLCHAINS_BASE_PATH)/$(RK328X_GLIBC_DIR)
RK328X_GLIBC_TARBALL         = $(TOOLCHAINS_FTP_BASE)/$(RK328X_GLIBC_VERSION)/$(RK328X_GLIBC_DIR)-$(RK328X_GLIBC_VERSION).$(TARBALL_SUFFIX)

RK328X_GLIBC_ARCH_DEFS       = -D__RK328X_GLIBC__=1
RK328X_GLIBC_ARCH_FLAGS      = -march=armv7ve -mtune=cortex-a17 -mfloat-abi=hard -mfpu=neon-vfpv4 -mabi=aapcs-linux -fomit-frame-pointer

RK328X_GLIBC_SYSROOT         = sys-root
RK328X_GLIBC_DEST_SYSROOT    = yes

RK328X_GLIBC_HAS_CHRPATH     = yes

RK328X_GLIBC_HARDWARE_VARIANTS := $(HARDWARE_FFRK3288)



# ======= S8XX-GLIBC =========================================================

TOOLCHAIN_S8XX_GLIBC         = s8xx-glibc

S8XX_GLIBC_ARCH              = arm-s8xx-linux-gnueabihf
S8XX_GLIBC_VERSION           = 1.1.4
S8XX_GLIBC_DIR               = arm-S8XX-linux-glibc
S8XX_GLIBC_PATH              = $(TOOLCHAINS_BASE_PATH)/$(S8XX_GLIBC_DIR)
S8XX_GLIBC_TARBALL           = $(TOOLCHAINS_FTP_BASE)/$(S8XX_GLIBC_VERSION)/$(S8XX_GLIBC_DIR)-$(S8XX_GLIBC_VERSION).$(TARBALL_SUFFIX)

S8XX_GLIBC_ARCH_DEFS         = -D__AMLOGIC_S8XX_GLIBC__=1
S8XX_GLIBC_ARCH_FLAGS        = -march=armv7-a -mtune=cortex-a5 -mfloat-abi=hard -mfpu=neon -mabi=aapcs-linux -fomit-frame-pointer

S8XX_GLIBC_SYSROOT           = sys-root
S8XX_GLIBC_DEST_SYSROOT      = yes

S8XX_GLIBC_HAS_CHRPATH       = yes

S8XX_GLIBC_HARDWARE_VARIANTS := $(HARDWARE_M201) $(HARDWARE_MXV)



# ======= S9XX-GLIBC =========================================================

TOOLCHAIN_S9XX_GLIBC         = s9xx-glibc

S9XX_GLIBC_ARCH              = aarch64-s9xx-linux-gnu
S9XX_GLIBC_VERSION           = 1.1.4
S9XX_GLIBC_DIR               = aarch64-S9XX-linux-glibc
S9XX_GLIBC_PATH              = $(TOOLCHAINS_BASE_PATH)/$(S9XX_GLIBC_DIR)
S9XX_GLIBC_TARBALL           = $(TOOLCHAINS_FTP_BASE)/$(S9XX_GLIBC_VERSION)/$(S9XX_GLIBC_DIR)-$(S9XX_GLIBC_VERSION).$(TARBALL_SUFFIX)

S9XX_GLIBC_ARCH_DEFS         = -D__AMLOGIC_S9XX_GLIBC__=1
S9XX_GLIBC_ARCH_FLAGS        = -march=armv8-a -mcpu=cortex-a53 -mabi=lp64 -fomit-frame-pointer

S9XX_GLIBC_SYSROOT           = sys-root
S9XX_GLIBC_DEST_SYSROOT      = yes

S9XX_GLIBC_HAS_CHRPATH       = yes

S9XX_GLIBC_HARDWARE_VARIANTS := $(HARDWARE_P201) $(HARDWARE_NEXBOX_A95X) \
                                                 $(HARDWARE_ODROID_C2)   \
                                $(HARDWARE_P212) $(HARDWARE_KHADAS_VIM)  \
                                $(HARDWARE_Q201) $(HARDWARE_ENYBOX_X2)



# ======= AT91SAM7S-NEWLIB ===================================================

TOOLCHAIN_AT91SAM7S_NEWLIB   = at91sam7s-newlib

AT91SAM7S_NEWLIB_ARCH        = arm-at91sam7s-eabi
AT91SAM7S_NEWLIB_VERSION     = 1.1.4
AT91SAM7S_NEWLIB_DIR         = arm-AT91SAM7S-eabi-newlib
AT91SAM7S_NEWLIB_PATH        = $(TOOLCHAINS_BASE_PATH)/$(AT91SAM7S_NEWLIB_DIR)
AT91SAM7S_NEWLIB_TARBALL     = $(TOOLCHAINS_FTP_BASE)/$(AT91SAM7S_NEWLIB_VERSION)/$(AT91SAM7S_NEWLIB_DIR)-$(AT91SAM7S_NEWLIB_VERSION).$(TARBALL_SUFFIX)

AT91SAM7S_NEWLIB_ARCH_DEFS   = -D__AT91SAM7S__=1

AT91SAM7S_NEWLIB_HARDWARE_VARIANTS := $(HARDWARE_AT91S)



# ======= LPC17XX-UCLIBC =====================================================

TOOLCHAIN_LPC17XX_UCLIBC     = lpc17xx-uclibc

LPC17XX_UCLIBC_ARCH          = arm-lpc17xx-uclinuxeabi
LPC17XX_UCLIBC_VERSION       = 1.1.4
LPC17XX_UCLIBC_DIR           = arm-LPC17XX-uclinuxeabi
LPC17XX_UCLIBC_PATH          = $(TOOLCHAINS_BASE_PATH)/$(LPC17XX_UCLIBC_DIR)
LPC17XX_UCLIBC_TARBALL       = $(TOOLCHAINS_FTP_BASE)/$(LPC17XX_UCLIBC_VERSION)/$(LPC17XX_UCLIBC_DIR)-$(LPC17XX_UCLIBC_VERSION).$(TARBALL_SUFFIX)

LPC17XX_UCLIBC_ARCH_DEFS     = -D__LPC17XX__=1

LPC17XX_UCLIBC_SYSROOT       = sys-root

LPC17XX_UCLIBC_HARDWARE_VARIANTS := $(HARDWARE_L17UC)



# ======= IMX6-GLIBC ======================================================

TOOLCHAIN_IMX6_GLIBC         = imx6-glibc

IMX6_GLIBC_ARCH              = arm-imx6-linux-gnueabihf
IMX6_GLIBC_VERSION           = 1.1.4
IMX6_GLIBC_DIR               = arm-IMX6-linux-glibc
IMX6_GLIBC_PATH              = $(TOOLCHAINS_BASE_PATH)/$(IMX6_GLIBC_DIR)
IMX6_GLIBC_TARBALL           = $(TOOLCHAINS_FTP_BASE)/$(IMX6_GLIBC_VERSION)/$(IMX6_GLIBC_DIR)-$(IMX6_GLIBC_VERSION).$(TARBALL_SUFFIX)

IMX6_GLIBC_ARCH_DEFS         = -D__IMX6_GLIBC__=1
IMX6_GLIBC_ARCH_FLAGS        = -march=armv7-a -mtune=cortex-a9 -mfloat-abi=hard -mfpu=vfpv3 -mabi=aapcs-linux -fomit-frame-pointer

IMX6_GLIBC_SYSROOT           = sys-root
IMX6_GLIBC_DEST_SYSROOT      = yes

IMX6_GLIBC_HAS_CHRPATH       = yes

IMX6_GLIBC_HARDWARE_VARIANTS := $(HARDWARE_NIT6Q)



# ======= OMAP543X-GLIBC =====================================================

TOOLCHAIN_OMAP543X_GLIBC     = omap543x-glibc

OMAP543X_GLIBC_ARCH          = arm-omap543x-linux-gnueabihf
OMAP543X_GLIBC_VERSION       = 1.1.4
OMAP543X_GLIBC_DIR           = arm-OMAP543X-linux-glibc
OMAP543X_GLIBC_PATH          = $(TOOLCHAINS_BASE_PATH)/$(OMAP543X_GLIBC_DIR)
OMAP543X_GLIBC_TARBALL       = $(TOOLCHAINS_FTP_BASE)/$(OMAP543X_GLIBC_VERSION)/$(OMAP543X_GLIBC_DIR)-$(OMAP543X_GLIBC_VERSION).$(TARBALL_SUFFIX)

OMAP543X_GLIBC_ARCH_DEFS     = -D__OMAP543X_GLIBC__=1
OMAP543X_GLIBC_ARCH_FLAGS    = -march=armv7-a -mtune=cortex-a15 -mfloat-abi=hard -mfpu=neon-vfpv4 -mabi=aapcs-linux -fomit-frame-pointer

OMAP543X_GLIBC_SYSROOT       = sys-root
OMAP543X_GLIBC_DEST_SYSROOT  = yes

OMAP543X_GLIBC_HAS_CHRPATH   = yes

OMAP543X_GLIBC_HARDWARE_VARIANTS := $(HARDWARE_OMAP5UEVM) $(HARDWARE_DRA7XXEVM)



# ======= JZ47XX-GLIBC =======================================================

TOOLCHAIN_JZ47XX_GLIBC       = jz47xx-glibc

JZ47XX_GLIBC_ARCH            = mipsel-jz47xx-linux-gnu
JZ47XX_GLIBC_VERSION         = 1.1.4
JZ47XX_GLIBC_DIR             = mipsel-JZ47XX-linux-glibc
JZ47XX_GLIBC_PATH            = $(TOOLCHAINS_BASE_PATH)/$(JZ47XX_GLIBC_DIR)
JZ47XX_GLIBC_TARBALL         = $(TOOLCHAINS_FTP_BASE)/$(JZ47XX_GLIBC_VERSION)/$(JZ47XX_GLIBC_DIR)-$(JZ47XX_GLIBC_VERSION).$(TARBALL_SUFFIX)

JZ47XX_GLIBC_ARCH_DEFS       = -D__JZ47XX_GLIBC__=1
JZ47XX_GLIBC_ARCH_FLAGS      = -march=mips32r2 -mhard-float
JZ47XX_GLIBC_OPTIMIZATION    = -O2

JZ47XX_GLIBC_SYSROOT         = sys-root
JZ47XX_GLIBC_DEST_SYSROOT    = yes

JZ47XX_GLIBC_HAS_CHRPATH     = yes

JZ47XX_GLIBC_HARDWARE_VARIANTS := $(HARDWARE_CI20)



# ======= P5600-GLIBC =======================================================

TOOLCHAIN_P5600_GLIBC        = p5600-glibc

P5600_GLIBC_ARCH             = mipsel-p5600-linux-gnu
P5600_GLIBC_VERSION          = 1.1.4
P5600_GLIBC_DIR              = mipsel-P5600-linux-glibc
P5600_GLIBC_PATH             = $(TOOLCHAINS_BASE_PATH)/$(P5600_GLIBC_DIR)
P5600_GLIBC_TARBALL          = $(TOOLCHAINS_FTP_BASE)/$(P5600_GLIBC_VERSION)/$(P5600_GLIBC_DIR)-$(P5600_GLIBC_VERSION).$(TARBALL_SUFFIX)

P5600_GLIBC_ARCH_DEFS        = -D__P5600_GLIBC__=1
P5600_GLIBC_ARCH_FLAGS       = -march=mips32r5 -mtune=p5600 -mhard-float
P5600_GLIBC_OPTIMIZATION     = -O2

P5600_GLIBC_SYSROOT          = sys-root
P5600_GLIBC_DEST_SYSROOT     = yes

P5600_GLIBC_HAS_CHRPATH      = yes

P5600_GLIBC_HARDWARE_VARIANTS := $(HARDWARE_BT1)




CONSTANTS_MK=1
endif

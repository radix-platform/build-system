# include once
ifndef TARGET_SETUP_MK


include $(BUILDSYSTEM)/constants.mk



################################################################
# Get hw_id & hw_name by HARDWARE functions:
#
# hw_id(), hw_name()
#
hw_id = $($(strip $(foreach v, $(filter-out HARDWARE_NAMES HARDWARE_ALL,$(filter HARDWARE_%, $(.VARIABLES))),  \
                    $(if $(filter $1, $($(v))),                      \
                      $(addsuffix _ID_STD,$(subst HARDWARE_,,$(v))), \
                     ))))


hw_name = $(strip $(foreach v, $(filter-out HARDWARE_NAMES HARDWARE_ALL,$(filter HARDWARE_%, $(.VARIABLES))), \
                    $(if $(filter $1, $($(v))),$(subst HARDWARE_,,$(v)),)))

# usage:
#   HW_ID = $(call hw_id,$(HARDWARE))
#
# Get hw_id & hw_name by HARDWARE function.
################################################################


HW_DEFS = $(strip                                                                       \
            $(foreach v,                                                                \
              $(filter-out  HARDWARE_ALL HARDWARE_NAMES HARDWARE_NOARCH HARDWARE_BUILD, \
                $(filter HARDWARE_%, $(.VARIABLES))),                                   \
                  -D$(subst HARDWARE_,,$(v))=$($(strip $(addsuffix _ID_STD,$(subst HARDWARE_,,$(v)))))))


################################################################
# Is the switch --sysroot=$(TARGET_DEST_DIR) should be used.
#
sysroot = $($(strip                                          \
              $(foreach v, $(filter TOOLCHAIN_%,             \
                             $(filter-out TOOLCHAIN_ALL      \
                                          TOOLCHAIN_NAMES    \
                                          TOOLCHAIN_DIR      \
                                          TOOLCHAIN_PATH     \
                                          TOOLCHAIN_VERSION  \
                                          TOOLCHAIN_INCPATH, \
                                          $(.VARIABLES))),   \
                $(if $(filter $1, $($(v))),                  \
                  $(addsuffix _DEST_SYSROOT,$(subst TOOLCHAIN_,,$(v))), \
                 ))))

# usage:
#   enable_sysroot = $(call sysroot,$(TOOLCHAIN))
#
# Is the switch --sysroot=$(TARGET_DEST_DIR) should be used.
################################################################


################################################################
# The name of toolchain sysroot directory (default 'sys-root').
#

# This is a last directory name in the absolute toolchain
# sysroot path. If this name is 'sys-root' then absolute
# toolchain system root is placed in
#
#   $(TOOLCHAIN_PATH)/$(TARGET)/sys-root
#
# directory. If this function returns "", then toolchain
# has been built without '--with-sysroot=DIR' switch.

toolchain-sysroot = $($(strip                                          \
                        $(foreach v, $(filter TOOLCHAIN_%,             \
                                       $(filter-out TOOLCHAIN_ALL      \
                                                    TOOLCHAIN_NAMES    \
                                                    TOOLCHAIN_DIR      \
                                                    TOOLCHAIN_PATH     \
                                                    TOOLCHAIN_VERSION  \
                                                    TOOLCHAIN_INCPATH, \
                                                    $(.VARIABLES))),   \
                          $(if $(filter $1, $($(v))),                  \
                            $(addsuffix _SYSROOT,$(subst TOOLCHAIN_,,$(v))), \
                           ))))

# usage:
#   toolchain_sysroot = $(call toolchain-sysroot,$(TOOLCHAIN))
#
# The name of toolchain sysroot directory.
################################################################


################################################################
# Is there 'chrpath' utility in the toolchain.
#
has-chrpath = $($(strip                                          \
                  $(foreach v, $(filter TOOLCHAIN_%,             \
                                 $(filter-out TOOLCHAIN_ALL      \
                                              TOOLCHAIN_NAMES    \
                                              TOOLCHAIN_DIR      \
                                              TOOLCHAIN_PATH     \
                                              TOOLCHAIN_VERSION  \
                                              TOOLCHAIN_INCPATH, \
                                              $(.VARIABLES))),   \
                    $(if $(filter $1, $($(v))),                  \
                      $(addsuffix _HAS_CHRPATH,$(subst TOOLCHAIN_,,$(v))), \
                     ))))

# usage:
#   enable_chrpath = $(call has-chrpath,$(TOOLCHAIN))
#
# Is there 'chrpath' utility in the toolchain.
################################################################


#######
####### Setup ccache:
#######

ifeq ($(NO_CCACHE),)
CCACHE = /usr/bin/ccache$(space)

ifeq ($(wildcard $(CCACHE)),)
$(info )
$(info #######)
$(info ####### Please install 'ccache' package)
$(info ####### or disable ccache with "NO_CCACHE=1 make ...")
$(info #######)
$(info )
$(error Error: ccache not found)
endif

ifeq ($(wildcard $(CACHED_CC_OUTPUT)),)
$(info )
$(info #######)
$(info ####### Please create directory $(CACHED_CC_OUTPUT) for cached compiler output)
$(info ####### or disable ccache with "NO_CCACHE=1 make ...")
$(info #######)
$(info )
$(error Error: cached compiler output directory doesn't exist)
endif

export CCACHE_BASEDIR = $(TOP_BUILD_DIR_ABS)
export CCACHE_DIR     = $(CACHED_CC_OUTPUT)
export CCACHE_UMASK   = 000

unexport CCACHE_PREFIX
else
CCACHE =
endif



#######
####### Setup current toolchain variables:
#######

ifeq ($(TOOLCHAIN),$(TOOLCHAIN_BUILD_MACHINE))
TOOLCHAIN_PATH     = $($(shell echo $(TOOLCHAIN) | tr '[a-z-]' '[A-Z_]')_PATH)
else
TOOLCHAIN_PATH     = $($(shell echo $(TOOLCHAIN) | tr '[a-z-]' '[A-Z_]')_PATH)/$(TOOLCHAIN_VERSION)
endif

TOOLCHAIN_TARBALL  = $($(shell echo $(TOOLCHAIN) | tr '[a-z-]' '[A-Z_]')_TARBALL)
TOOLCHAIN_VERSION  = $($(shell echo $(TOOLCHAIN) | tr '[a-z-]' '[A-Z_]')_VERSION)
TOOLCHAIN_DIR      = $($(shell echo $(TOOLCHAIN) | tr '[a-z-]' '[A-Z_]')_DIR)
TARGET             = $($(shell echo $(TOOLCHAIN) | tr '[a-z-]' '[A-Z_]')_ARCH)

ARCH_DEFS         ?= $($(shell echo $(TOOLCHAIN) | tr '[a-z-]' '[A-Z_]')_ARCH_DEFS)
ARCH_FLAGS        ?= $($(shell echo $(TOOLCHAIN) | tr '[a-z-]' '[A-Z_]')_ARCH_FLAGS)
ARCH_OPTIMIZATION ?= $($(shell echo $(TOOLCHAIN) | tr '[a-z-]' '[A-Z_]')_OPTIMIZATION)

ifeq ($(filter $(TOOLCHAIN),$(TOOLCHAIN_NOARCH) $(TOOLCHAIN_BUILD_MACHINE)),)
HW_FLAGS           = -D__HARDWARE__=$(call hw_id,$(HARDWARE)) $(HW_DEFS)
endif


ifeq ($(filter $(TOOLCHAIN), $(TOOLCHAIN_NOARCH) $(TOOLCHAIN_BUILD_MACHINE)),)
CC                 = $(CCACHE)$(TOOLCHAIN_PATH)/bin/$(TARGET)-gcc
CXX                = $(CCACHE)$(TOOLCHAIN_PATH)/bin/$(TARGET)-g++
AS                 = $(TOOLCHAIN_PATH)/bin/$(TARGET)-as
AR                 = $(TOOLCHAIN_PATH)/bin/$(TARGET)-ar
LD                 = $(TOOLCHAIN_PATH)/bin/$(TARGET)-ld
RANLIB             = $(TOOLCHAIN_PATH)/bin/$(TARGET)-ranlib
SIZE               = $(TOOLCHAIN_PATH)/bin/$(TARGET)-size
STRIP              = $(TOOLCHAIN_PATH)/bin/$(TARGET)-strip
OBJCOPY            = $(TOOLCHAIN_PATH)/bin/$(TARGET)-objcopy
OBJDUMP            = $(TOOLCHAIN_PATH)/bin/$(TARGET)-objdump
NM                 = $(TOOLCHAIN_PATH)/bin/$(TARGET)-nm
CROSS_PREFIX       = $(TOOLCHAIN_PATH)/bin/$(TARGET)-
CHRPATH            = $(strip                                                \
                       $(if $(filter yes,$(call has-chrpath,$(TOOLCHAIN))), \
                         $(TOOLCHAIN_PATH)/bin/$(TARGET)-chrpath,           \
                        ))
else
ifeq ($(TOOLCHAIN),$(TOOLCHAIN_BUILD_MACHINE))
CC                 = $(TOOLCHAIN_PATH)/bin/gcc
CXX                = $(TOOLCHAIN_PATH)/bin/g++
AS                 = $(TOOLCHAIN_PATH)/bin/as
AR                 = $(TOOLCHAIN_PATH)/bin/ar
LD                 = $(TOOLCHAIN_PATH)/bin/ld
RANLIB             = $(TOOLCHAIN_PATH)/bin/ranlib
SIZE               = $(TOOLCHAIN_PATH)/bin/size
STRIP              = $(TOOLCHAIN_PATH)/bin/strip
OBJCOPY            = $(TOOLCHAIN_PATH)/bin/objcopy
OBJDUMP            = $(TOOLCHAIN_PATH)/bin/objdump
NM                 = $(TOOLCHAIN_PATH)/bin/nm
CHRPATH            = $(strip                                                \
                       $(if $(filter yes,$(call has-chrpath,$(TOOLCHAIN))), \
                         $(TOOLCHAIN_PATH)/bin/chrpath,                     \
                        ))
else
# TOOLCHAIN_NOARCH doesn't need these variables but:
CC                 = gcc
CXX                = g++
AS                 = as
AR                 = ar
LD                 = ld
RANLIB             = ranlib
SIZE               = size
STRIP              = strip
OBJCOPY            = objcopy
OBJDUMP            = objdump
NM                 = nm
endif
endif


#
# The user may reject the sysroot usage. For this the user have to declare
# the USE_TARGET_DEST_DIR_SYSROOT variable with value 'no':
#
#   USE_TARGET_DEST_DIR_SYSROOT = no
#
ifneq ($(USE_TARGET_DEST_DIR_SYSROOT),no)
USE_TARGET_DEST_DIR_SYSROOT := yes
endif


#######
####### Build machine triplet:
#######

ifeq ($(shell echo $(shell ${BUILDSYSTEM}/canonical-build 2> /dev/null)),)
BUILD = unknown-unknown-unknown-unknown
$(error Errorr: Unknown BUILD System '${BUILD}')
else
BUILD = $(shell echo $(shell ${BUILDSYSTEM}/canonical-build 2> /dev/null))
endif





################################################################
#######
####### Include Directories setup Section:
#######

INCPATH += -I.

TARGET_INCPATH += -I$(TARGET_DEST_DIR)/usr/include

ROOTFS_INCPATH += -I$(ROOTFS_DEST_DIR)/usr/include

#
# Toolchain include path:
#
ifneq ($(call toolchain-sysroot,$(TOOLCHAIN)),)
TOOLCHAIN_INCPATH += -I$(TOOLCHAIN_PATH)/$(TARGET)/$(call toolchain-sysroot,$(TOOLCHAIN))/usr/include
endif

#######
####### End of Include Directories setup Section.
#######
################################################################


################################################################
#######
####### Library directory suffixes for BUILD MACHINE.
#######

#
# NOTE: LIBSUFFIX=64 is valid for Slackware64 distro where native libraries are placed in /usr/lib64 directory
#       for example ubuntu has /usr/lib for x86_64 libraries and /usr/lib32 for x86_32 libraries as well as
#       our X86_64-glibc toolchain.
# TODO: Create the canonical-distro script such as $(BULDSYSTEM)/canonical-build we have.
#
ifeq ($(TOOLCHAIN),$(TOOLCHAIN_BUILD_MACHINE))
LIBSUFFIX ?= 64
endif

#
# BUILD_CC lib SUFFIX
#
BUILD_MULTILIB_X86_32_SUFFIX = $(shell echo $(shell gcc -m32 -print-multi-os-directory) | sed -e 's/\(^.*lib\)\([0-9]*\)/\2/')
BUILD_MULTILIB_SUFFIX = $(shell echo $(shell gcc -print-multi-os-directory) | sed -e 's/\(^.*lib\)\([0-9]*\)/\2/')

#######
####### End of Library directory suffixes for BUILD MACHINE.
#######
################################################################






# NOTE:
# ====
#
#   Default optimization is -O3 and defined by 'OPTIMIZATION_FLAGS' variable
#   in the target-setup.mk. The 'OPTIMIZATION_FLAGS' variable can be overriden
#   in user Makefile by following definition.
#
#   OPTIMIZATION_FLAGS = -O2
#
#   However some HW requires specific optimization which should't be overriden
#   by user. In this case we define toolchain depended variable *_OPTIMIZATION
#   within constants.mk file. This variable is used to assign a value to the
#   ARCH_OPTIMIZATION variable, which, in turn, sets the actual (depending on
#   the current HW) optimization.
#
#   This way allow us prioritize the HW specific optimisation. If user
#   want  to override HW specific optimization then hi can override the
#   ARCH_OPTIMISATION variable. In this case user have to be sure that
#   this redefinition doesn't affect other HW:
#
#   ifeq ($(HARDWARE),$(HARDWARE_CI20))
#   ARCH_OPTIMIZATION = -O2
#   endif
#
#   Resume:
#   ------
#    - OPTIMIZATION_FLAGS can be overriden only if ARCH_OPTIMIZATION is not set.
#    - ARCH_OPTIMIZATION can be overriden always and ARCH_OPTIMIZATION has highest priority.
#    - default optimization is -O3
#    - the condition (OPTIMIZATION_FLAGS == ARCH_OPTIMIZATION) is always true.
#
ifneq ($(ARCH_OPTIMIZATION),)
OPTIMIZATION_FLAGS         = $(ARCH_OPTIMIZATION)
else
OPTIMIZATION_FLAGS        ?= -O3
ARCH_OPTIMIZATION          = $(OPTIMIZATION_FLAGS)
endif


################################################################
#######
####### Common Compiler & Linker flags:
#######

ifeq ($(USE_TARGET_DEST_DIR_SYSROOT),yes)
LDFLAGS += -L$(TARGET_DEST_DIR)/lib$(LIBSUFFIX) -L$(TARGET_DEST_DIR)/usr/lib$(LIBSUFFIX)
endif

# Common CPP/C/C++ flags
COMMON_FLAGS  = $(INCPATH)
ifeq ($(USE_TARGET_DEST_DIR_SYSROOT),yes)
COMMON_FLAGS += $(TARGET_INCPATH)
endif
COMMON_FLAGS += -g $(OPTIMIZATION_FLAGS) $(ARCH_FLAGS) $(ARCH_DEFS) $(HW_FLAGS)


CFLAGS    += $(COMMON_FLAGS)
CXXFLAGS  += $(COMMON_FLAGS)

#######
####### End of Common Compiler & Linker flags.
#######
################################################################


################################################################
#######
####### Default Linkers:
#######

ifeq ($(call sysroot,$(TOOLCHAIN))_$(USE_TARGET_DEST_DIR_SYSROOT),yes_yes)
CC_LINKER  = $(CC) --sysroot=$(TARGET_DEST_DIR)
CXX_LINKER = $(CXX) --sysroot=$(TARGET_DEST_DIR)
else
CC_LINKER  = $(CC)
CXX_LINKER = $(CXX)
endif

#######
####### Default Linkers.
#######
################################################################




################################################################
#######
####### Development environment:
#######


BUILD_ENVIRONMENT  = PATH=$(PATH):$(TOOLCHAIN_PATH)/bin

ifeq ($(call sysroot,$(TOOLCHAIN))_$(USE_TARGET_DEST_DIR_SYSROOT),yes_yes)
BUILD_ENVIRONMENT += CC="$(CC) --sysroot=$(TARGET_DEST_DIR)"
BUILD_ENVIRONMENT += CXX="$(CXX) --sysroot=$(TARGET_DEST_DIR)"
BUILD_ENVIRONMENT += LD="$(LD) --sysroot=$(TARGET_DEST_DIR)"
else
BUILD_ENVIRONMENT += CC="$(CC)" CXX="$(CXX)" LD="$(LD)"
endif

BUILD_ENVIRONMENT += AS="$(AS)" AR="$(AR)" RANLIB="$(RANLIB)" SIZE="$(SIZE)" STRIP="$(STRIP)" OBJCOPY="$(OBJCOPY)" NM="$(NM)"
BUILD_ENVIRONMENT += BUILD_CC="$(BUILD_CC)" BUILD_CXX="$(BUILD_CXX)" BUILD_AS="$(BUILD_AS)" BUILD_AR="$(BUILD_AR)" BUILD_LD="$(BUILD_LD)" BUILD_RANLIB="$(BUILD_RANLIB)" BUILD_SIZE="$(BUILD_SIZE)" BUILD_STRIP="$(BUILD_STRIP)" BUILD_OBJCOPY="$(BUILD_OBJCOPY)" BUILD_NM="$(BUILD_NM)"
BUILD_ENVIRONMENT += CFLAGS="$(CFLAGS)" CXXFLAGS="$(CXXFLAGS)" CPPFLAGS="$(CPPFLAGS)"
BUILD_ENVIRONMENT += LDFLAGS="$(LDFLAGS)"

#
#  PKG_CONFIG_PATH - directories to add to pkg-config's search path
#
PKG_CONFIG_PATH    = $(TARGET_DEST_DIR)/usr/lib$(LIBSUFFIX)/pkgconfig:$(TARGET_DEST_DIR)/usr/share/pkgconfig
PKG_CONFIG_LIBDIR  = $(TARGET_DEST_DIR)/usr/lib$(LIBSUFFIX)/pkgconfig:$(TARGET_DEST_DIR)/usr/share/pkgconfig

BUILD_ENVIRONMENT += PKG_CONFIG_PATH="$(PKG_CONFIG_PATH)"
BUILD_ENVIRONMENT += PKG_CONFIG_LIBDIR="$(PKG_CONFIG_LIBDIR)"

#######
####### Development environment.
#######
################################################################



################################################################
#######
####### Multilib Support:
#######


#######
####### x86_32:
#######

####### Multilib directory suffixes for TARGETs:

ifeq ($(TOOLCHAIN),$(TOOLCHAIN_X86_64_GLIBC))
MULTILIB_X86_32_SUFFIX ?= 32
endif

ifneq ($(filter $(HARDWARE),$(HARDWARE_PC64)),)
ifeq ($(CREATE_X86_32_PACKAGE),true)

CC               += -m32
CXX              += -m32

ifeq ($(USE_TARGET_DEST_DIR_SYSROOT),yes)
LDFLAGS           = -L$(TARGET_DEST_DIR)/lib$(MULTILIB_X86_32_SUFFIX)
LDFLAGS          += -L$(TARGET_DEST_DIR)/usr/lib$(MULTILIB_X86_32_SUFFIX)
endif

PKG_CONFIG_PATH   = $(TARGET_DEST_DIR)/usr/lib$(MULTILIB_X86_32_SUFFIX)/pkgconfig:$(TARGET_DEST_DIR)/usr/share/pkgconfig
PKG_CONFIG_LIBDIR = $(TARGET_DEST_DIR)/usr/lib$(MULTILIB_X86_32_SUFFIX)/pkgconfig:$(TARGET_DEST_DIR)/usr/share/pkgconfig

ARCH_FLAGS        = -m32 -march=i686 -mtune=i686

TARGET32          = $(shell echo $(TARGET) | sed 's/x86_64/i686/')

endif
endif


#######
####### sparc32:
#######

####### Multilib directory suffixes for TARGETs:

ifeq ($(TOOLCHAIN),$(TOOLCHAIN_R1000_GLIBC))
MULTILIB_SPARC32_SUFFIX ?= 32
endif

ifneq ($(filter $(HARDWARE),$(HARDWARE_MBC4_PC)),)
ifeq ($(CREATE_SPARC32_PACKAGE),true)

CC               += -m32
CXX              += -m32

ifeq ($(USE_TARGET_DEST_DIR_SYSROOT),yes)
LDFLAGS           = -L$(TARGET_DEST_DIR)/lib$(MULTILIB_SPARC32_SUFFIX)
LDFLAGS          += -L$(TARGET_DEST_DIR)/usr/lib$(MULTILIB_SPARC32_SUFFIX)
endif

PKG_CONFIG_PATH   = $(TARGET_DEST_DIR)/usr/lib$(MULTILIB_SPARC32_SUFFIX)/pkgconfig:$(TARGET_DEST_DIR)/usr/share/pkgconfig
PKG_CONFIG_LIBDIR = $(TARGET_DEST_DIR)/usr/lib$(MULTILIB_SPARC32_SUFFIX)/pkgconfig:$(TARGET_DEST_DIR)/usr/share/pkgconfig

ARCH_FLAGS        = -m32 -mtune=ultrasparc3 -mv8plus -mptr32 -mhard-float -mlong-double-128 -mglibc

TARGET32          = $(shell echo $(TARGET) | sed 's/sparc64/sparc/')

endif
endif


#######
####### powerpc32:
#######

####### Multilib directory suffixes for TARGETs:

ifneq ($(filter $(TOOLCHAIN),$(TOOLCHAIN_POWER8_GLIBC) \
                             $(TOOLCHAIN_POWER9_GLIBC)),)
MULTILIB_PPC32_SUFFIX ?= 32
endif

ifneq ($(filter $(HARDWARE),$(HARDWARE_S824L)  \
                            $(HARDWARE_VESNIN) \
                            $(HARDWARE_TL2WK2) \
                            $(HARDWARE_TL2SV2)),)
ifeq ($(CREATE_PPC32_PACKAGE),true)

CC               += -m32
CXX              += -m32

ifeq ($(USE_TARGET_DEST_DIR_SYSROOT),yes)
LDFLAGS           = -L$(TARGET_DEST_DIR)/lib$(MULTILIB_PPC32_SUFFIX)
LDFLAGS          += -L$(TARGET_DEST_DIR)/usr/lib$(MULTILIB_PPC32_SUFFIX)
endif

PKG_CONFIG_PATH   = $(TARGET_DEST_DIR)/usr/lib$(MULTILIB_PPC32_SUFFIX)/pkgconfig:$(TARGET_DEST_DIR)/usr/share/pkgconfig
PKG_CONFIG_LIBDIR = $(TARGET_DEST_DIR)/usr/lib$(MULTILIB_PPC32_SUFFIX)/pkgconfig:$(TARGET_DEST_DIR)/usr/share/pkgconfig

ifeq ($(TOOLCHAIN),$(TOOLCHAIN_POWER8_GLIBC))
ARCH_FLAGS        = -m32 -mcpu=power8 -mlong-double-128
endif
ifeq ($(TOOLCHAIN),$(TOOLCHAIN_POWER9_GLIBC))
ARCH_FLAGS        = -m32 -mcpu=power9 -mlong-double-128
endif

TARGET32          = $(shell echo $(TARGET) | sed 's/ppc64/ppc/')

endif
endif




#######
####### End of Multilib Support.
#######
################################################################






TARGET_SETUP_MK=1
endif

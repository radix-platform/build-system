
# include once
ifndef CORE_MK

#######
####### helpful variables
#######

comma := ,
empty :=
space := $(empty) $(empty)


#######
####### Set up TOP_BUILD_DIR, TOP_BUILD_DIR_ABS and BUILDSYSTEM variables
#######

ifndef MAKEFILE_LIST

# Work-around for GNU make pre-3.80, which lacks MAKEFILE_LIST and $(eval ...)

TOP_BUILD_DIR := $(shell perl -e 'for ($$_ = "$(CURDIR)"; ! -d "$$_/build-system"; s!(.*)/(.*)!\1!) { $$q .= "../"; } chop $$q; print "$$q"')
ifeq ($(TOP_BUILD_DIR),)
TOP_BUILD_DIR=.
endif
export TOP_BUILD_DIR_ABS := $(shell perl -e 'for ($$_ = "$(CURDIR)"; ! -d "$$_/build-system"; s!(.*)/(.*)!\1!) { } print')
export BUILDSYSTEM := $(TOP_BUILD_DIR_ABS)/build-system

else

# Normal operation for GNU make 3.80 and above

__pop = $(patsubst %/,%,$(dir $(1)))
__tmp := $(call __pop,$(word $(words $(MAKEFILE_LIST)),$(MAKEFILE_LIST)))
# Special case for build-system/Makefile
ifeq ($(__tmp),.)
__tmp := ../$(notdir $(CURDIR))
endif

ifndef TOP_BUILD_DIR
TOP_BUILD_DIR := $(call __pop,$(__tmp))
endif

ifndef TOP_BUILD_DIR_ABS
TOP_BUILD_DIR_ABS := $(CURDIR)
ifneq ($(TOP_BUILD_DIR),.)
$(foreach ,$(subst /, ,$(TOP_BUILD_DIR)),$(eval TOP_BUILD_DIR_ABS := $(call __pop,$(TOP_BUILD_DIR_ABS))))
endif
export TOP_BUILD_DIR_ABS
endif

ifndef BUILDSYSTEM
export BUILDSYSTEM := $(TOP_BUILD_DIR_ABS)/$(notdir $(__tmp))
endif

endif




#######
####### Config:
#######

include $(BUILDSYSTEM)/constants.mk

#
# All available hardware:
#
HARDWARE_ALL = $(strip $(foreach hw, $(filter HARDWARE_%,       \
                                 $(filter-out HARDWARE_ALL      \
                                              HARDWARE_NAMES,   \
                                              $(.VARIABLES))), $($(hw))))

HARDWARE_NAMES = $(filter-out $(HARDWARE_NOARCH), $(HARDWARE_ALL))

#
# All available toolchains:
#
TOOLCHAIN_ALL = $(strip $(foreach t, $(filter TOOLCHAIN_%,       \
                                 $(filter-out TOOLCHAIN_ALL      \
                                              TOOLCHAIN_NAMES    \
                                              TOOLCHAIN_DIR      \
                                              TOOLCHAIN_PATH     \
                                              TOOLCHAIN_VERSION, \
                                              $(.VARIABLES))), $($(t))))

TOOLCHAIN_NAMES = $(TOOLCHAIN_ALL)

COMPONENT_TOOLCHAINS = $(TOOLCHAIN_ALL)




#######
####### Config:
#######

ifneq ($(wildcard $(BUILDSYSTEM)/build-config.mk),)
include $(BUILDSYSTEM)/build-config.mk
else
include $(BUILDSYSTEM)/build-config.mk.template
endif

# Reading build-config.mk:

# ENABLE_NOARCH & ENABLE_BUILD always enabled:
ENABLE_NOARCH = true
ENABLE_BUILD  = true

enabled = $(filter ENABLE_%, $(filter-out ENABLE_ARCH ENABLE_TARGETS, $(.VARIABLES)))

hardware_filter = $(strip $(foreach t, \
                     $(strip $(foreach b, \
                       $(enabled), $(if $(filter true, $($(b))), \
                         $(subst ENABLE_, HARDWARE_, $(b))))), $($(t))))

# If no HARDWARE set
ifeq ($(HARDWARE),)

# COMPONENT_TARGETS must have a value specified in the Makefile
ifeq ($(COMPONENT_TARGETS),)
$(error Error: COMPONENT_TARGETS must have a value)
endif

# End if no HARDWARE set
endif



#######
####### Filter out disabled targets
#######

COMPONENT_TARGETS := $(filter $(hardware_filter), $(COMPONENT_TARGETS))

# Remove duplicates:
COMPONENT_TARGETS := $(sort $(COMPONENT_TARGETS))


#######
####### Filter out disabled toolchains:
#######

COMPONENT_TOOLCHAINS := $(strip \
                          $(foreach toolchain, $(COMPONENT_TOOLCHAINS), \
                            $(if $(filter $($(shell echo $(toolchain) | tr '[a-z-]' '[A-Z_]')_HARDWARE_VARIANTS), \
                                          $(COMPONENT_TARGETS)),$(toolchain),)))

COMPONENT_TOOLCHAINS := $(sort $(COMPONENT_TOOLCHAINS))



# Error if TOOLCHAIN is invalid
ifneq ($(TOOLCHAIN),)
ifeq ($(filter $(TOOLCHAIN), $(COMPONENT_TOOLCHAINS)),)
$(error Error: TOOLCHAIN=$(TOOLCHAIN) is invalid for selected COMPONENT_TARGETS in Makefile)
endif
endif

# Error if HARDWARE is invalid
ifneq ($(HARDWARE),)
ifeq ($(filter $(HARDWARE), $(COMPONENT_TARGETS)),)
$(error Error: HARDWARE=$(HARDWARE) is invalid for selected COMPONENT_TARGETS in Makefile)
endif
endif


################################################################
#######
####### Directories setup Section:
#######

#
# Set up SOURCE PACKAGE directory:
#
export SRC_PACKAGE_DIR       := sources
export SRC_PACKAGE_PATH      := $(TOP_BUILD_DIR)/$(SRC_PACKAGE_DIR)
export SRC_PACKAGE_PATH_ABS  := $(TOP_BUILD_DIR_ABS)/$(SRC_PACKAGE_DIR)


#
# Set up DESTINATION directories:
#
DEST_DIR_ABS           = $(TOP_BUILD_DIR_ABS)/dist

ifeq ($(NEED_ABS_PATH),)
DEST_DIR               = $(TOP_BUILD_DIR)/dist
else
DEST_DIR               = $(DEST_DIR_ABS)
endif


#
# Default PREFIX: is $(TOP_BUILD_DIR)/dist
#
PREFIX ?= $(DEST_DIR)


#
# Install DIRs (for SCRIPT_, BIN_, ... TARGETS) [should be always ABS]:
#
TARGET_DEST_DIR   = $(DEST_DIR_ABS)/$(addprefix ., $(TOOLCHAIN))/$(HARDWARE)
PRODUCTS_DEST_DIR = $(DEST_DIR_ABS)/products/$(TOOLCHAIN)/$(HARDWARE)
ROOTFS_DEST_DIR   = $(DEST_DIR_ABS)/rootfs/$(TOOLCHAIN)/$(HARDWARE)

#######
####### End of Directories setup Section.
#######
################################################################



################################################################
#######
####### Targets setup Section:
#######

ifdef TARGET_SETUP_MK
$(error Error: 'target-setup.mk' should not be included directly, include 'constants.mk' instead.)
endif

include $(BUILDSYSTEM)/target-setup.mk

#######
####### End of Targets setup Section.
#######
################################################################








################################################################
# Get toolchain by HARDWARE function:
#
# toolchain()
#
toolchain = $($(strip                                                          \
                $(foreach v, $(filter %_HARDWARE_VARIANTS, $(.VARIABLES)),     \
                  $(if $(filter $1, $($(v))),                                  \
                    $(addprefix TOOLCHAIN_,$(subst _HARDWARE_VARIANTS,,$(v))), \
                   ))))

# usage:
#   pc32_toolchain = $(call toolchain,$(HARDWARE_PC32))
#
# Get toolchain by HARDWARE function.
################################################################


################################################################
# Check the list of available targets for current Makefile
#
__available_targets =                                                                      \
  $(foreach arch, $(shell echo $(COMPONENT_TOOLCHAINS) | sed -e 's/x86_64/x86-64/g'),      \
    $(foreach hardware, $($(shell echo ${arch} | tr '[a-z-]' '[A-Z_]')_HARDWARE_VARIANTS), \
      $(if $(filter $(hardware),$(COMPONENT_TARGETS)),                                     \
        $(if $($(shell echo $(hardware) | tr '[a-z]' '[A-Z]')_FLAVOURS),                   \
          $(foreach flavour, $($(shell echo $(hardware) | tr '[a-z]' '[A-Z]')_FLAVOURS),   \
            .target_$(arch)_$(hardware)_$(flavour)                                         \
           ) .target_$(arch)_$(hardware),                                                  \
          $(if $(FLAVOURS),                                                                \
            $(foreach flavour, $(FLAVOURS),                                                \
              .target_$(arch)_$(hardware)_$(flavour)                                       \
             ) .target_$(arch)_$(hardware),                                                \
            .target_$(arch)_$(hardware)                                                    \
           )                                                                               \
         ),                                                                                \
       )                                                                                   \
     )                                                                                     \
   )

__available_targets := $(strip $(__available_targets))
__available_targets := $(sort $(__available_targets))
#
#
################################################################



#######
####### Silent make:
#######

#ifeq ($(VERBOSE),)
#ifeq ($(COMPONENT_IS_3PP),)
#MAKEFLAGS += -s
#endif
#endif
#
#ifeq ($(VERBOSE),)
#guiet = @
#else
#quiet =
#endif


#######
####### Number of CPU cores:
#######

NUMPROCS := 1
OS       := $(shell uname -s)

ifeq ($(OS),Linux)
NUMPROCS := $(shell grep -c ^processor /proc/cpuinfo)
endif


#######
####### Parallel control:
#######

ifneq ($(NOT_PARALLEL),)
MAKEFLAGS += -j1
.NOTPARALLEL:
endif

MAKEFLAGS += --output-sync=target



CLEANUP_FILES +=  $(addprefix ., $(TOOLCHAIN))

# temporaty collections:
#CLEANUP_FILES +=  .*.dist.*
#CLEANUP_FILES +=  .*.rootfs.*

#
# do not clean .*_requires* files to save time when Makefile has not been changed.
#



all: BUILD_TREE := true
export BUILD_TREE

all:
	@$(MAKE) local_all


clean: CLEAN_TREE := true
export CLEAN_TREE

clean:
	@$(MAKE) local_clean


dist_clean: DIST_CLEAN_TREE := true
export DIST_CLEAN_TREE

dist_clean:
	@$(MAKE) local_dist_clean


rootfs_clean: ROOTFS_CLEAN_TREE := true
export ROOTFS_CLEAN_TREE

rootfs_clean:
	@$(MAKE) local_rootfs_clean




# MAKE goals which not depended from Makefile
__quick_targets := help ccache_stats configure_targets local_clean global_clean downloads_clean build-config.mk $(HACK_TARGETS)




################################################################
#######
####### Build preparations & HW Independed GOALs Section:
#######

#
# GLOBAL setup targets:
# ====================
#   These targets are built before all targets. For example, source tarballs
#   have to be downloaded before starting the build.
#
#   NOTE:
#     BUILDSYSTEM is a setup target for other directories and the BUILDSYSTEM
#     requires only '.sources' target as a setup target.
#
ifeq ($(filter %_clean,$(MAKECMDGOALS)),)
ifeq ($(shell pwd),$(BUILDSYSTEM))
__setup_targets = .sources
else
__setup_targets = .sources .build_system
endif
endif


.setup:
ifeq ($(__final__),)
.setup: $(__setup_targets)
else
.setup: .makefile
endif


#######
####### If Makefile has been changed we cannot warranty that this is afected only
####### one  HW  target from the list of targets prepared by this local Makefile.
#######
####### So, in this case we have to clean up all built targets.
#######

# Check if Makefile has been changed:
.makefile: Makefile
ifneq ($(shell pwd),$(TOP_BUILD_DIR_ABS))
ifneq ($(if $(MAKECMDGOALS),$(filter-out $(__quick_targets),$(MAKECMDGOALS)),true),)
	@touch $@
ifeq ($(shell pwd | grep $(TOP_BUILD_DIR_ABS)/$(SRC_PACKAGE_DIR))$(shell pwd | grep $(BUILDSYSTEM)/3pp/sources),)
	@echo ""
	@echo -e "#######"
	@echo -e "####### New makefile ($(<F)), clean up & rebuild source requires!"
	@echo -e "#######"
	@echo ""
	@$(MAKE) local_dist_clean
	@if $(MAKE) local_clean; then true; else rm -f $@; fi
else
	@if $(MAKE) download_clean; then true; else rm -f $@; fi
endif
endif
endif



#######
####### Build directory dependencies into .src_requires  which
####### is used as a Makefile for srource tarballs downloading
#######

#######
####### NOTE:
####### ====
#######  Source tarballs are downloaded once for whole dependencies tree
#######  of the current directory where we make the build using command
#######  such as 'make' or 'make local_all'.
#######  Target local_all is not affects the downloading sources for the
#######  whole dependencies tree (target local_all affects the building
#######  of packages only).
#######  In this case the $(__final__) variable is not defined.
#######  On the contrary when the BUILDSYSTEM builds each packages of
#######  dependencies tree the $(__final__) variable is defined and
#######  we don't try to download sources because they already downloaded.
#######  More over we don't need to have the '.src_requires' and
#######  '.src_requires_depend' files.
#######
#######  Such behavior is invented aspecialy to avoid competition in case
#######  when during parallel build different processes can run the same
#######  Makefile and all of them can start the sources preparation.
#######

.sources: .src_requires

.src_requires_depend: .src_requires ;

.src_requires: .makefile
ifneq ($(shell pwd),$(TOP_BUILD_DIR_ABS))
ifeq ($(filter %_clean,$(MAKECMDGOALS)),)
ifeq ($(__final__),)
	@echo ""
	@echo -e "################################################################"
	@echo -e "#######"
	@echo -e "####### Start of building source requires for '$(subst $(TOP_BUILD_DIR_ABS)/,,$(CURDIR))':"
	@echo -e "#######"
	@$(BUILDSYSTEM)/build_src_requires $(TOP_BUILD_DIR_ABS)
	@__final__= TREE_RULE=local_all $(MAKE) TOOLCHAIN=$(TOOLCHAIN_NOARCH) HARDWARE=$(HARDWARE_NOARCH) FLAVOUR= -f .src_requires
	@echo -e "#######"
	@echo -e "####### End of building source requires for '$(subst $(TOP_BUILD_DIR_ABS)/,,$(CURDIR))'."
	@echo -e "#######"
	@echo -e "################################################################"
	@echo ""
	@touch $@
	@touch .src_requires_depend
endif
endif
endif



.build_system: .src_requires
ifneq ($(shell pwd),$(TOP_BUILD_DIR_ABS))
ifeq ($(shell pwd | grep $(TOP_BUILD_DIR_ABS)/$(SRC_PACKAGE_DIR))$(shell pwd | grep $(BUILDSYSTEM)/3pp/sources),)
ifeq ($(shell pwd | grep $(BUILDSYSTEM)),)
	@echo -e "################################################################"
	@echo -e "#######"
	@echo -e "####### Start to Check the BUILDSYSTEM is ready:"
	@echo -e "#######"
	@( cd $(BUILDSYSTEM) ; __final__= $(MAKE) TOOLCHAIN=$(TOOLCHAIN_BUILD_MACHINE) HARDWARE=$(HARDWARE_BUILD) FLAVOUR= all )
	@echo -e "#######"
	@echo -e "####### End of checking the BUILDSYSTEM."
	@echo -e "#######"
	@echo -e "################################################################"
endif
endif
endif



#######
####### Clean the whole source tree
#######

global_clean: .global_clean

.global_clean:
	@echo ""
	@echo -e "#######"
	@echo -e "####### Cleaning the whole sources tree excluding downloaded sources..."
	@echo -e "#######"
	@$(BUILDSYSTEM)/global_clean $(addprefix ., $(TOOLCHAIN_NAMES)) $(TOP_BUILD_DIR_ABS)


#######
####### Clean all downloaded source tarballs
#######

downloads_clean: .downloads_clean

.downloads_clean:
	@echo ""
	@echo -e "#######"
	@echo -e "####### Cleaning Up all downloaded sources..."
	@echo -e "#######"
	@$(BUILDSYSTEM)/downloads_clean $(addprefix ., $(TOOLCHAIN_NOARCH)) $(BUILDSYSTEM)/3pp/sources
ifneq ($(wildcard $(TOP_BUILD_DIR_ABS)/$(SRC_PACKAGE_DIR)),)
	@$(BUILDSYSTEM)/downloads_clean $(addprefix ., $(TOOLCHAIN_NOARCH)) $(TOP_BUILD_DIR_ABS)/$(SRC_PACKAGE_DIR)
endif


help:
	@echo ""
	@echo -e "Build System $(SYSTEM_VERSION)"
	@echo ""
	@echo -e "You can build and install software using command line such as follow:"
	@echo ""
	@echo -e "   $$ [TOOLCHAIN=toolchain] [HARDWARE=hardware] [FLAVOUR=flavour] make [goal]"
	@echo ""
	@echo -e "The following MAKE goals are available:"
	@echo ""
	@echo -e "   all                - perform make build and install software in the all"
	@echo -e "                        required directories which defined by REQUIRES"
	@echo -e "                        variable in the local Makefile;"
	@echo -e "   local_all          - build and install software prepared onlu by local"
	@echo -e "                        Makefile;"
	@echo -e "   dist_clean,"
	@echo -e "   local_dist_clean   - remove distribution packages from target directory"
	@echo -e "                        defined by PRODUCTS_DEST_DIR variable. Note that"
	@echo -e "                        is depends from targets defined by COMPONENT_TARGETS"
	@echo -e "                        variable or command line;"
	@echo -e "   rootfs_clean,"
	@echo -e "   local_rootfs_clean - uninstall packages installed into target 'root file"
	@echo -e "                        system' directory which defined by ROOTFS_DEST_DIR"
	@echo -e "                        variable;"
	@echo -e "   clean,"
	@echo -e "   local_clean        - clean up all built targets by this Makefile;"
	@echo ""
	@echo -e "   If the one from above goals has prefix 'local_' then this goal affects only"
	@echo -e "   current directory.  Otherwise this goal will be performed for all required"
	@echo -e "   directories which defined by REQUIRES variable."
	@echo ""
	@echo -e "   configure_targets  - select hardwares, for which the software will be built."
	@echo -e "                        This command edits the build-config.mk file;"
	@echo ""
	@echo -e "   requires_tree      - create HTML file to show the requires tree for current"
	@echo -e "                        directory. Note that this goal depends on goal all;"
	@echo -e "   devices_table      - create Devices Table for rootfs image creation procedure;"
	@echo -e "   ext4fs_image       - create Ext4 Root FS for target Boot Image;"
	@echo ""
	@echo -e "   global_clean       - clean up whole sourses tree excluding downloaded"
	@echo -e "                        source tarballs;"
	@echo -e "   downloads_clean    - remove all sourse tarball from 'sourses' directory;"
	@echo ""
	@echo -e "   ccache_stats       - show the ccache statistic."
	@echo ""
	@echo -e "Local Makefile is prepared for following target HW platforms:"
	@echo ""
	@for platform in $(COMPONENT_TARGETS) ; do \
	  echo -e "   $$platform"; \
	 done
	@echo ""
	@echo -e "Enjoy."
	@echo ""

ccache_stats:
ifeq ($(NO_CCACHE),)
	@echo ""
	@echo -e "CCACHE statistic:"
	@echo ""
	@CCACHE_DIR=$(CACHED_CC_OUTPUT) $(CCACHE) -s
	@echo ""
	@echo -e "To set max cache size make use the following command"
	@echo ""
	@echo -e "   $$ CCACHE_DIR=$(CACHED_CC_OUTPUT) $(CCACHE)-M 64G"
	@echo ""
	@echo -e "see CCACHE(1) for more information."
	@echo ""
else
	@echo ""
	@echo -e "CCACHE disabled by setting 'NO_CCACHE=$(NO_CCACHE)' variable for this Makefile."
	@echo ""
endif

configure_targets: $(BUILDSYSTEM)/build-config.mk
	@BUILDSYSTEM=$(BUILDSYSTEM)            \
	 CONFIG=$(BUILDSYSTEM)/build-config.mk \
	 CONSTANTS=$(BUILDSYSTEM)/constants.mk \
	 $(BUILDSYSTEM)/configure-targets

#######
####### End of Build preparations & HW Independed GOALs Section.
#######
################################################################


################################################################
#######
####### Source archive and patch handling:
#######

# Patch dependency:
PATCHES_DEP = $(foreach patch,$(PATCHES),\
	$(shell $(BUILDSYSTEM)/apply_patches $(patch) -dep-))

SRC_DIR_BASE = $(dir $(SRC_DIR))

# Unpack SRC_ARCHIVE in SRC_DIR and backup old SRC_DIR:
UNPACK_SRC_ARCHIVE = \
	@echo "Expanding $(SRC_ARCHIVE)"; \
	if [ -d $(SRC_DIR) ]; then mv $(SRC_DIR) $$(mktemp -d $(SRC_DIR).bak.XXXXXX); fi; \
	mkdir -p $(SRC_DIR_BASE); \
	$(if $(findstring .rpm,$(SRC_ARCHIVE)), \
	  cd $(SRC_DIR_BASE) && rpm2cpio $(SRC_ARCHIVE) | cpio -id --quiet, \
	  $(if $(findstring .zip,$(SRC_ARCHIVE)), \
	    unzip -q -d $(SRC_DIR_BASE) $(SRC_ARCHIVE), \
	    tar $(if $(findstring .bz2,$(SRC_ARCHIVE)),-xjf, \
	             $(if $(findstring .xz,$(SRC_ARCHIVE)),-xJf, \
	             $(if $(findstring .txz,$(SRC_ARCHIVE)),-xJf,-xzf))) \
	        $(SRC_ARCHIVE) -C $(SRC_DIR_BASE))); \
	chmod -R u+w $(SRC_DIR)

# Apply patches in PATCHES on SRC_DIR_BASE:
APPLY_PATCHES = $(quiet)$(foreach patch,$(PATCHES),\
	$(BUILDSYSTEM)/apply_patches $(patch) $(SRC_DIR_BASE) &&) true

# Apply patches in PATCHES on SRC_DIR_BASE:
APPLY_OPT_PATCHES = $(quiet)$(foreach patch,$(OPT_PATCHES),\
	$(BUILDSYSTEM)/apply_patches $(patch) $(SRC_DIR_BASE) &&) true


################################################################
# Functions:
# =========
#
# Install package content into the current
# development environment:
# --------------------------------------------------------------
#
# NOTE:
#     - When we pass ARGS through STDIN [using '--' as end of options] we splits ARGS
#       by new-line '\n' symbol.
#     - When we pass ARGS in the command line, we have to add  | tr '\n' ' ' | filter
#       to change new-line with space.
#
install-into-devenv = \
	@( cd $1 ; \
	   find . \( -type d -empty -o -type f -o -type l \) -printf '%P\n' | sed -e 's, ,\\040,g' | \
	   DO_CREATE_DIST_FILES=1 CWD=$(CURDIR) \
	   $(BUILDSYSTEM)/install_targets       \
	     --preserve-source-dir=true         \
	     --destination=$(TARGET_DEST_DIR)   \
	     --toolchain=$(TOOLCHAIN)           \
	     --hardware=$(HARDWARE)             \
	     --flavour=$(FLAVOUR)               \
	     --                                 \
	 )
# usage:
#   $(call install-into-devenv,$(PKGDIR))
#   where PKGDIR - is a directory where package installed from sources.
# --------------------------------------------------------------
#
#
# End of unctios.
################################################################



################################################################
#
# Example rule:
#
# src_done = $(SRC_DIR)/.source-done
#
# $(src_done): $(SRC_ARCHIVE) $(PATCHES_DEP)
# 	$(UNPACK_SRC_ARCHIVE)
# 	$(APPLY_PATCHES)
# 	 <other stuff that needs to be done to the source,
# 	   should be empty in most cases>
# 	@touch $@
#
################################################################

#######
####### Source archive and patch handling.
#######
################################################################


################################################################
#######
####### Include files with references to BUILD-SYSTEM scripts:
#######

-include $(BUILDSYSTEM)/pkgtool/.config
-include $(BUILDSYSTEM)/progs/.config
-include $(BUILDSYSTEM)/scripts/.config
-include $(BUILDSYSTEM)/sbin/.config

#######
####### References to BUILD-SYSTEM scripts.
#######
################################################################



################################################################
#
# No '__final__' target selected:
# ==============================
#
# Parse TOOLCHAIN, HARDWARE, FLAVOUR selected in command line
# and build the list of '__final__' targets.
#
ifeq ($(__final__),)

#
# The FLAVOUR can be defined in command line.
# If command line defines empty flavour FLAVOUR= then
# we define that variable is set but has no values.
#
__cmdline_flavour_defined = $(if $(filter FLAVOUR,$(.VARIABLES)),true,false)
ifeq ($(__cmdline_flavour_defined),true)
__cmdline_flavour_value = $(FLAVOUR)
else
__cmdline_flavour_value =
endif

##############################################################
# -----------+----------+---------+-------------------+-----
#  TOOLCHAIN | HARDWARE | FLAVOUR | FLAVOUR has VALUE | REF
# -----------+----------+---------+-------------------+-----
#    defined |  defined | defined |         yes       | (0)
#    defined |  defined | defined |         no        | (1)
#    defined |  defined |    ~    |         ~         | (2)
# -----------+----------+---------+-------------------+-----
#    defined |     ~    | defined |         yes       | (3)
#    defined |     ~    | defined |         no        | (4)
#    defined |     ~    |    ~    |         ~         | (5)
# -----------+----------+---------+-------------------+-----
#       ~    |  defined | defined |         yes       | (6)
#       ~    |  defined | defined |         no        | (7)
#       ~    |  defined |    ~    |         ~         | (8)
# -----------+----------+---------+-------------------+-----
#       ~    |     ~    | defined |         yes       | (9)
#       ~    |     ~    | defined |         no        | (A)
#       ~    |     ~    |    ~    |         ~         | (B)
# -----------+----------+---------+-------------------+-----
##############################################################

# we allow only available combinations according to component targets and flavours lists

ifeq ($(TOOLCHAIN),)
ifeq ($(HARDWARE),)
ifeq ($(FLAVOUR),)
ifeq ($(__cmdline_flavour_defined),false)
# (B) ======= loop: T, H, F;                           =======
__target_args = $(__available_targets)
else
# (A) ======= loop: T, H   ; where          F=0        =======
__target_args = $(foreach arch, $(shell echo $(COMPONENT_TOOLCHAINS) | sed -e 's/x86_64/x86-64/g'),        \
                  $(foreach hardware, $($(shell echo ${arch} | tr '[a-z-]' '[A-Z_]')_HARDWARE_VARIANTS),   \
                    .target_$(arch)_$(hardware)                                                            \
                   )                                                                                       \
                 )
endif
else
# (9) ======= loop: T, H   ; where          F=const    =======
__target_args = $(foreach arch, $(shell echo $(COMPONENT_TOOLCHAINS) | sed -e 's/x86_64/x86-64/g'),        \
                  $(foreach hardware, $($(shell echo ${arch} | tr '[a-z-]' '[A-Z_]')_HARDWARE_VARIANTS),   \
                    $(if $(filter $(FLAVOUR), $($(shell echo ${hardware} | tr '[a-z]' '[A-Z]')_FLAVOURS)), \
                       .target_$(arch)_$(hardware)_$(FLAVOUR),                                             \
                       $(if $(filter $(FLAVOUR), $(FLAVOURS)),                                             \
                         .target_$(arch)_$(hardware)_$(FLAVOUR),                                           \
                        )                                                                                  \
                     )                                                                                     \
                   )                                                                                       \
                 )
endif
else
ifeq ($(FLAVOUR),)
ifeq ($(__cmdline_flavour_defined),false)
# (8) ======= loop: T,  , F; where H=const             =======
__target_args = $(foreach arch, $(shell echo $(call toolchain,$(HARDWARE)) | sed -e 's/x86_64/x86-64/g'), \
                  $(if $($(shell echo $(HARDWARE) | tr '[a-z]' '[A-Z]')_FLAVOURS),                        \
                    $(foreach flavour, $($(shell echo $(HARDWARE) | tr '[a-z]' '[A-Z]')_FLAVOURS),        \
                      .target_$(arch)_$(HARDWARE)_$(flavour)                                              \
                     ) .target_$(arch)_$(HARDWARE),                                                       \
                     $(if $(FLAVOURS),                                                                    \
                       $(foreach flavour, $(FLAVOURS),                                                    \
                         .target_$(arch)_$(HARDWARE)_$(flavour)                                           \
                        ),                                                                                \
                      ) .target_$(arch)_$(HARDWARE)                                                       \
                   )                                                                                      \
                 )
else
# (7) ======= loop: T,  ,  ; where H=const, F=0        =======
__target_args = $(foreach arch, $(shell echo $(call toolchain,$(HARDWARE)) | sed -e 's/x86_64/x86-64/g'), \
                    .target_$(arch)_$(HARDWARE)                                                           \
                 )
endif
else
# (6) ======= loop: T,  ,  ; where H=const, F=const    =======
__target_args = $(foreach arch, $(shell echo $(call toolchain,$(HARDWARE)) | sed -e 's/x86_64/x86-64/g'), \
                    .target_$(arch)_$(HARDWARE)_$(FLAVOUR)                                                \
                 )
endif
endif
else
ifeq ($(HARDWARE),)
ifeq ($(FLAVOUR),)
ifeq ($(__cmdline_flavour_defined),false)
# (5) ======= loop:  , H, F; where T=const             =======
__target_args = $(foreach hardware, $($(shell echo $(TOOLCHAIN) | tr '[a-z-]' '[A-Z_]')_HARDWARE_VARIANTS),    \
                  $(if $($(shell echo ${hardware} | tr '[a-z]' '[A-Z]')_FLAVOURS),                             \
                    $(foreach flavour, $($(shell echo ${hardware} | tr '[a-z]' '[A-Z]')_FLAVOURS),             \
                      .target_$(shell echo $(TOOLCHAIN) | sed -e 's/x86_64/x86-64/g')_$(hardware)_$(flavour)   \
                     ) .target_$(shell echo $(TOOLCHAIN) | sed -e 's/x86_64/x86-64/g')_$(hardware),            \
                    $(if $(FLAVOURS),                                                                          \
                      $(foreach flavour, $(FLAVOURS),                                                          \
                        .target_$(shell echo $(TOOLCHAIN) | sed -e 's/x86_64/x86-64/g')_$(hardware)_$(flavour) \
                       ),                                                                                      \
                     )                                                                                         \
                     .target_$(shell echo $(TOOLCHAIN) | sed -e 's/x86_64/x86-64/g')_$(hardware)               \
                   )                                                                                           \
                 )
else
# (4) ======= loop:  , H,  ; where T=const, F=0        =======
__target_args = $(foreach hardware, $($(shell echo $(TOOLCHAIN) | tr '[a-z-]' '[A-Z_]')_HARDWARE_VARIANTS), \
                    .target_$(shell echo $(TOOLCHAIN) | sed -e 's/x86_64/x86-64/g')_$(hardware)             \
                 )
endif
else
# (3) ======= loop:  , H,  ; where T=const, F=const    =======
__target_args = $(foreach hardware, $($(shell echo $(TOOLCHAIN) | tr '[a-z-]' '[A-Z_]')_HARDWARE_VARIANTS), \
                    .target_$(shell echo $(TOOLCHAIN) | sed -e 's/x86_64/x86-64/g')_$(hardware)_$(FLAVOUR)  \
                 )
endif
else
ifeq ($(FLAVOUR),)
ifeq ($(__cmdline_flavour_defined),false)
# (2) ======= loop:  ,  , F; where T=const, H=const    =======
__target_args = $(if $($(shell echo $(HARDWARE) | tr '[a-z]' '[A-Z]')_FLAVOURS),                              \
                  $(foreach flavour, $($(shell echo $(HARDWARE) | tr '[a-z]' '[A-Z]')_FLAVOURS),              \
                    .target_$(shell echo $(TOOLCHAIN) | sed -e 's/x86_64/x86-64/g')_$(HARDWARE)_$(flavour)    \
                   ) .target_$(shell echo $(TOOLCHAIN) | sed -e 's/x86_64/x86-64/g')_$(HARDWARE),             \
                   $(if $(FLAVOURS),                                                                          \
                     $(foreach flavour, $(FLAVOURS),                                                          \
                       .target_$(shell echo $(TOOLCHAIN) | sed -e 's/x86_64/x86-64/g')_$(HARDWARE)_$(flavour) \
                      ) .target_$(shell echo $(TOOLCHAIN) | sed -e 's/x86_64/x86-64/g')_$(HARDWARE),          \
                    ) .target_$(shell echo $(TOOLCHAIN) | sed -e 's/x86_64/x86-64/g')_$(HARDWARE)             \
                 )
else
# (1) ======= loop:  ,  ,  ; T=const, H=const, F=0     =======
__target_args = .target_$(shell echo $(TOOLCHAIN) | sed -e 's/x86_64/x86-64/g')_$(HARDWARE)
endif
else
# (0) ======= loop:  ,  ,  ; T=const, H=const, F=const =======
__target_args = .target_$(shell echo $(TOOLCHAIN) | sed -e 's/x86_64/x86-64/g')_$(HARDWARE)_$(FLAVOUR)
endif
endif
endif

__target_args := $(strip $(__target_args))


__targets = $(filter $(__target_args), $(__available_targets))

# Now we have to sort targets for that the main targets should be built before flavours!
__targets := $(sort $(__targets))


ifeq ($(__targets),)
$(error Error: Selected combination [TOOLCHAIN=$(TOOLCHAIN), HARDWARE=$(HARDWARE), FLAVOUR=$(FLAVOUR)] is invalid for this Makefile)
endif

$(__targets): .setup


#
# NOTE:
# ====
#     Several FLAVOURS can require the same package, for example, base/pkgtool.
#     To avoid concurrency problems we have to diable parallel building for Makefiles
#     where there are FLAVOURS.
#
#     We have to check both HW specific and general FLAVOURS.
#
all-flavour-values = $(strip $(foreach flname, $(filter FLAVOURS %_FLAVOURS, $(.VARIABLES)), $($(flname))))

ifneq ($(all-flavour-values),)
.NOTPARALLEL: $(__targets)
endif


local_all: GOAL = local_all
local_all: $(__targets)


local_clean: GOAL = local_clean
local_clean: $(__targets)


local_dist_clean: GOAL = local_dist_clean
local_dist_clean: $(__targets)


local_rootfs_clean: GOAL = local_rootfs_clean
local_rootfs_clean: $(__targets)

requires_tree: GOAL = requires_tree
requires_tree: $(__targets)

devices_table: GOAL = devices_table
devices_table: $(__targets)

ext4fs_image:  GOAL = ext4fs_image
ext4fs_image:  $(__targets)


.target_%: TOOLCHAIN = $(shell echo $(word 2, $(subst _, , $@)) | sed -e 's/x86-64/x86_64/g')
.target_%: HARDWARE = $(if $(filter $(shell echo $(word 3, $(subst _, , $@))),$(HARDWARE_ALL)),$(word 3, $(subst _, , $@)))
.target_%: FLAVOUR = $(if $(word 4, $(subst _, , $@)),$(word 4, $(subst _, , $@)),$(if $(filter $(shell echo $(word 3, $(subst _, , $@))),$(HARDWARE_ALL)),,$(word 3, $(subst _, , $@))))
.target_%:
	@echo ""
	@echo -e "################################################################"
	@echo -e "#######"
	@echo -e "####### TOOLCHAIN=$(TOOLCHAIN) ; HARDWARE=$(HARDWARE) ; FLAVOUR=$(if $(FLAVOUR),$(FLAVOUR)) ;"
	@echo -e "#######"
	@__final__=true $(MAKE) TOOLCHAIN=$(TOOLCHAIN) HARDWARE=$(HARDWARE) FLAVOUR=$(FLAVOUR) $(GOAL)


else
#
################################################################
#
# The '__final__' target is defined, run the build process.


targetflavour = .$(TOOLCHAIN)/$(HARDWARE)$(if $(FLAVOUR),/$(FLAVOUR),)

TARGET_BUILD_DIR = $(targetflavour)

ifeq ($(filter %_clean,$(MAKECMDGOALS)),)
ifneq ($(shell pwd),$(TOP_BUILD_DIR_ABS))
ifeq ($(shell pwd | grep $(TOP_BUILD_DIR_ABS)/$(SRC_PACKAGE_DIR))$(shell pwd | grep $(BUILDSYSTEM)/3pp/sources),)
$(shell mkdir -p .$(TOOLCHAIN)/$(HARDWARE)$(if $(FLAVOUR),/$(FLAVOUR)))
endif
endif
endif

ifneq ($(NO_CREATE_DIST_FILES),true)
local_all: CREATE_DIST_FILES = 1
endif


ifeq ($(BUILD_TREE),true)
_tree := .tree_all
else
_tree := .requires_makefile
endif

#
local_all: .toolchain $(_tree) _install


ifeq ($(CLEAN_TREE),true)
local_clean: .tree_clean
else
local_clean:
endif

ifeq ($(DIST_CLEAN_TREE),true)
local_dist_clean: .tree_dist_clean
else
local_dist_clean:
endif

ifeq ($(ROOTFS_CLEAN_TREE),true)
local_rootfs_clean: .tree_rootfs_clean
else
local_rootfs_clean:
endif

.toolchain:
ifneq ($(TOOLCHAIN_PATH),)
ifeq ($(wildcard $(TOOLCHAIN_PATH)),)
	@echo -e "################################################################"
	@echo -e "#######"
	@echo -e "####### Start of downloading toolchain '$(shell basename $(TOOLCHAIN_TARBALL))':"
	@echo -e "#######"
	@if [ -d $(TOOLCHAINS_BASE_PATH) -a -w $(TOOLCHAINS_BASE_PATH) ] ; then \
	  ( cd $(TOOLCHAINS_BASE_PATH) ; \
	    $(BUILDSYSTEM)/download-toolchain "$(DOWNLOAD_SERVER)/$(TOOLCHAIN_TARBALL)" ; \
	  ) ; \
	 else \
	   echo -e "#" ; \
	   echo -e "#" ; \
	   echo -e "# Please create '$(TOOLCHAINS_BASE_PATH)' directory" ; \
	   echo -e "# and give write permissions to '$(shell echo "`id -u -n`")':" ; \
	   echo -e "#" ; \
	   echo -e "#    # sudo mkdir -p $(TOOLCHAINS_BASE_PATH)" ; \
	   echo -e "#    # sudo chown -R $(shell echo "`id -u -n`"):$(shell echo "`id -g -n`") $(TOOLCHAINS_BASE_PATH)" ; \
	   echo -e "#" ; \
	   echo -e "#" ; \
	   echo -e "# ERROR: $(TOOLCHAINS_BASE_PATH): Permission denied. Stop." ; \
	   echo -e "#" ; \
	   exit 1 ; \
	 fi
	@echo -e "#######"
	@echo -e "####### End of downloading toolchain '$(shell basename $(TOOLCHAIN_TARBALL))'."
	@echo -e "#######"
	@echo -e "################################################################"
endif
endif


.tree_all: BUILD_TREE := false

.tree_all: $(TARGET_BUILD_DIR)/.requires
ifneq ($(shell pwd),$(TOP_BUILD_DIR_ABS))
ifeq ($(shell pwd | grep $(TOP_BUILD_DIR_ABS)/$(SRC_PACKAGE_DIR))$(shell pwd | grep $(BUILDSYSTEM)/3pp/sources),)
	@echo -e "################################################################"
	@echo -e "#######"
ifeq ($(shell pwd),$(BUILDSYSTEM))
	@echo -e "####### Start of building requires for '$(subst $(TOP_BUILD_DIR_ABS)/,,$(CURDIR))':"
else
	@echo -e "####### Start of building requires for TOOLCHAIN=$(TOOLCHAIN) HARDWARE=$(HARDWARE) FLAVOUR=$(FLAVOUR) in '$(subst $(TOP_BUILD_DIR_ABS)/,,$(CURDIR))':"
endif
	@echo -e "#######"
ifeq ($(shell pwd),$(BUILDSYSTEM))
	@__final__=true TREE_RULE=local_all $(MAKE) TOOLCHAIN=$(TOOLCHAIN_BUILD_MACHINE) HARDWARE=$(HARDWARE_BUILD) FLAVOUR= -f $(TARGET_BUILD_DIR)/.requires
else
	@__final__=true TREE_RULE=local_all $(MAKE) TOOLCHAIN=$(TOOLCHAIN) HARDWARE=$(HARDWARE) FLAVOUR= -f $(TARGET_BUILD_DIR)/.requires
endif
	@echo -e "#######"
	@echo -e "####### End of building requires for '$(subst $(TOP_BUILD_DIR_ABS)/,,$(CURDIR))'."
	@echo -e "#######"
	@echo -e "################################################################"
endif
endif


# We always build requires Makeile '.requires_makefile' (for both local and tree build processes).
# This is needed to cover all tree. In other words we want to have '$(TARGET_BUILD_DIR)/.requires'
# file in the each directory to be able run 'make requires_tree' command.
#

.requires_makefile: $(TARGET_BUILD_DIR)/.requires


#######
####### Build directory dependencies into $(TARGET_BUILD_DIR)/.requires
####### file which is used as a Makefile for tree builds.
#######

$(TARGET_BUILD_DIR)/.requires_depend: $(TARGET_BUILD_DIR)/.requires ;

$(TARGET_BUILD_DIR)/.requires: .makefile
ifeq ($(filter %_clean,$(MAKECMDGOALS)),)
ifneq ($(shell pwd),$(TOP_BUILD_DIR_ABS))
ifeq ($(shell pwd | grep $(TOP_BUILD_DIR_ABS)/$(SRC_PACKAGE_DIR))$(shell pwd | grep $(BUILDSYSTEM)/3pp/sources),)
ifeq ($(shell pwd),$(BUILDSYSTEM))
	@$(BUILDSYSTEM)/build_requires $(TOP_BUILD_DIR_ABS) $(TOOLCHAIN_BUILD_MACHINE) $(HARDWARE_BUILD) ; wait
else
	@$(BUILDSYSTEM)/build_requires $(TOP_BUILD_DIR_ABS) $(TOOLCHAIN) $(HARDWARE) $(FLAVOUR) ; wait
endif
endif
endif
endif




################################################################
#######
####### Tree Clean up rules:
#######

.tree_clean: CLEAN_TREE := false

.tree_clean: $(TARGET_BUILD_DIR)/.requires
ifneq ($(shell pwd),$(TOP_BUILD_DIR_ABS))
ifeq ($(shell pwd | grep $(TOP_BUILD_DIR_ABS)/$(SRC_PACKAGE_DIR))$(shell pwd | grep $(BUILDSYSTEM)/3pp/sources),)
ifneq ($(wildcard $(TARGET_BUILD_DIR)/.requires),)
ifeq ($(shell pwd),$(BUILDSYSTEM))
	@__final__=true TREE_RULE=local_clean $(MAKE) TOOLCHAIN=$(TOOLCHAIN_BUILD_MACHINE) HARDWARE=$(HARDWARE_BUILD) FLAVOUR= -f $(TARGET_BUILD_DIR)/.requires
else
	@__final__=true TREE_RULE=local_clean $(MAKE) TOOLCHAIN=$(TOOLCHAIN) HARDWARE=$(HARDWARE) FLAVOUR= -f $(TARGET_BUILD_DIR)/.requires
endif
endif
endif
endif


.tree_dist_clean: DIST_CLEAN_TREE := false

.tree_dist_clean: $(TARGET_BUILD_DIR)/.requires
ifneq ($(shell pwd),$(TOP_BUILD_DIR_ABS))
ifeq ($(shell pwd | grep $(TOP_BUILD_DIR_ABS)/$(SRC_PACKAGE_DIR))$(shell pwd | grep $(BUILDSYSTEM)/3pp/sources),)
ifneq ($(shell pwd),$(BUILDSYSTEM))
	@__final__=true TREE_RULE=local_dist_clean $(MAKE) TOOLCHAIN=$(TOOLCHAIN) HARDWARE=$(HARDWARE) FLAVOUR= -f $(TARGET_BUILD_DIR)/.requires
endif
endif
endif


.tree_rootfs_clean: ROOTFS_CLEAN_TREE := false

.tree_rootfs_clean: $(TARGET_BUILD_DIR)/.requires
ifneq ($(shell pwd),$(TOP_BUILD_DIR_ABS))
ifeq ($(shell pwd | grep $(TOP_BUILD_DIR_ABS)/$(SRC_PACKAGE_DIR))$(shell pwd | grep $(BUILDSYSTEM)/3pp/sources),)
ifneq ($(shell pwd),$(BUILDSYSTEM))
	@__final__=true TREE_RULE=local_rootfs_clean $(MAKE) TOOLCHAIN=$(TOOLCHAIN) HARDWARE=$(HARDWARE) FLAVOUR= -f $(TARGET_BUILD_DIR)/.requires
endif
endif
endif


#######
####### End of Tree Clean up rules.
#######
################################################################



################################################################
#######
####### Clean up default rules:
#######


#######
####### Clean:
#######

local_clean: .local_clean
ifeq ($(shell pwd | grep $(TOP_BUILD_DIR_ABS)/$(SRC_PACKAGE_DIR))$(shell pwd | grep $(BUILDSYSTEM)/3pp/sources),)
ifneq ($(wildcard .$(TOOLCHAIN)),)
	@rm -rf $(CLEANUP_FILES)
endif
endif

.local_clean:
ifneq ($(shell pwd | grep $(TOP_BUILD_DIR_ABS)/$(SRC_PACKAGE_DIR))$(shell pwd | grep $(BUILDSYSTEM)/3pp/sources),)
	@echo -e "####### Cleaning in '`basename $(CURDIR)`' directory is not supported."
else
	@echo -e "####### Local Cleaning in '`basename $(CURDIR)`' directory..."
endif


#######
####### Destination Clean:
#######

#
# dist & rootfs cleaning perform only if *.dist, *.rootfs file exists
# For the product packages, BIN & SCRIPT ..._TARGETS we create *.dist
# files for each hardware:
#
#   .$(HARDWARE).dist
#
# Rootfs target have to be alone because we install into root fs only
# main package (flavour package we copy only into dist/products/...)
#
#   .$(HARDWARE).rootfs
#

local_dist_clean: .local_dist_clean
ifneq ($(shell pwd),$(BUILDSYSTEM))
ifeq ($(shell pwd | grep $(TOP_BUILD_DIR_ABS)/$(SRC_PACKAGE_DIR))$(shell pwd | grep $(BUILDSYSTEM)/3pp/sources),)
ifeq ($(wildcard $(TARGET_BUILD_DIR)/.dist),)
	@echo -e "   (nothing to be done)."
else
	@if [ -f $(TARGET_BUILD_DIR)/.dist ] ; then \
	  $(BUILDSYSTEM)/dist_clean --destination=$(DEST_DIR) \
	                            --toolchain=$(TOOLCHAIN) --hardware=$(HARDWARE) --flavour=$(FLAVOUR)  ; \
	  rm -f $(TARGET_BUILD_DIR)/.dist ; \
	fi
	@rm -rf $(TARGET_BUILD_DIR)/.dist*
	@echo -e "   (done)."
endif
endif
endif

.local_dist_clean:
ifeq ($(shell pwd),$(BUILDSYSTEM))
	@echo -e "####### Destination cleaning in '`basename $(CURDIR)`' directory is not supported."
else
ifneq ($(shell pwd | grep $(TOP_BUILD_DIR_ABS)/$(SRC_PACKAGE_DIR))$(shell pwd | grep $(BUILDSYSTEM)/3pp/sources),)
	@echo -e "####### Destination cleaning in '`basename $(CURDIR)`' directory is not supported."
else
	@echo -n -e "####### Destination cleaning in '`basename $(CURDIR)`' directory..."
endif
endif


#######
####### Root File System Clean:
#######

local_rootfs_clean: .local_rootfs_clean
ifneq ($(shell pwd),$(BUILDSYSTEM))
ifeq ($(shell pwd | grep $(TOP_BUILD_DIR_ABS)/$(SRC_PACKAGE_DIR))$(shell pwd | grep $(BUILDSYSTEM)/3pp/sources),)
ifeq ($(wildcard $(TARGET_BUILD_DIR)/.rootfs),)
	@echo -e "####### Root File System cleaning...   (nothing to be done)."
else
	@if [ -f $(TARGET_BUILD_DIR)/.rootfs ]; then \
	  REMOVE_PACKAGE="$(REMOVE_PACKAGE)" $(BUILDSYSTEM)/rootfs_clean \
	                                                    --destination=$(DEST_DIR) \
	                                                    --toolchain=$(TOOLCHAIN)  \
	                                                    --hardware=$(HARDWARE)    \
	                                                    --flavour=$(FLAVOUR)    ; \
	else \
	  echo -e "B####### ... Nothing to be done (there are no installed packages)." ; \
	fi
	@rm -rf $(TARGET_BUILD_DIR)/.rootfs
endif
endif
endif

.local_rootfs_clean:
ifeq ($(shell pwd),$(BUILDSYSTEM))
	@echo -e "####### Root file system cleaning in '`basename $(CURDIR)`' directory is not supported."
else
ifneq ($(shell pwd | grep $(TOP_BUILD_DIR_ABS)/$(SRC_PACKAGE_DIR))$(shell pwd | grep $(BUILDSYSTEM)/3pp/sources),)
	@echo -e "####### Root file system cleaning in '`basename $(CURDIR)`' directory is not supported."
else
	@echo -e "#######"
	@echo -e "####### Remove packages from 'dist/rootfs/$(TOOLCHAIN)/$(HARDWARE)/...' file system..."
	@echo -e "#######"
endif
endif


#######
####### End of Clean up default rules.
#######
################################################################


################################################################
#######
####### Build REQUIRES tree:
#######

#
# $(HARDWARE).pkglist - is a main target of `make requires_tree' procedure:
#
requires_tree: $(PRODUCTS_DEST_DIR)/$(HARDWARE).pkglist

#
# Requires Tree perform only if goal 'all' is done and all packages installed
# into root filesystem or into products directory.
#
# NOTE:
#   GNU Make `wildcard' function doesn't work with files which created
#   during Makefile works. For normal work all tested files should be
#   created before the Makefile starting my make command.
#
$(PRODUCTS_DEST_DIR)/$(HARDWARE).pkglist:
ifneq ($(shell pwd),$(BUILDSYSTEM))
ifeq ($(shell pwd | grep $(TOP_BUILD_DIR_ABS)/$(SRC_PACKAGE_DIR))$(shell pwd | grep $(BUILDSYSTEM)/3pp/sources),)
ifeq ($(shell pwd),$(TOP_BUILD_DIR_ABS))
	@echo -e "#######"
	@echo -e "####### Requires Tree creation in the top of '`basename $(CURDIR)`' directory is not supported."
	@echo -e "#######"
else
ifeq ($(wildcard $(TARGET_BUILD_DIR)/.requires),)
	@echo -e "   (nothing to be done)."
	@echo -e "#######"
	@echo -e "####### Before creating a dependency tree all goals have to be made."
	@echo -e "#######"
else
	@echo -e "################################################################"
	@echo -e "#######"
	@echo -e "####### Start of building Requires Tree in '`echo $(CURDIR) | sed 's,$(TOP_BUILD_DIR_ABS)/,,'`' directory..."
	@echo -e "#######"
	@JSMIN=$(JSMIN) $(BUILDSYSTEM)/build_requires_tree $(TOP_BUILD_DIR_ABS) $(TOOLCHAIN) $(HARDWARE) $(FLAVOUR)
	@mkdir -p $(PRODUCTS_DEST_DIR)
	@cp -a $(TARGET_BUILD_DIR)/$(HARDWARE).html     \
	       $(TARGET_BUILD_DIR)/$(HARDWARE).min.json \
	       $(TARGET_BUILD_DIR)/$(HARDWARE).pkglist  \
	       $(PRODUCTS_DEST_DIR)
	@ln -sf $(PRODUCTS_DEST_DIR)/$(HARDWARE).pkglist $(PRODUCTS_DEST_DIR)/.pkglist
	@touch $@
	@echo -e "#######"
	@echo -e "####### End of building Requires Tree in '`echo $(CURDIR) | sed 's,$(TOP_BUILD_DIR_ABS)/,,'`' directory."
	@echo -e "#######"
	@echo -e "################################################################"
endif
endif
endif
endif

#######
####### End of Build REQUIRES tree.
#######
################################################################


################################################################
#######
####### Build Devices Table:
#######

devices_table: $(TARGET_BUILD_DIR)/.DEVTABLE

$(TARGET_BUILD_DIR)/.DEVTABLE: $(PRODUCTS_DEST_DIR)/$(HARDWARE).pkglist
ifneq ($(shell pwd),$(BUILDSYSTEM))
ifeq ($(shell pwd | grep $(TOP_BUILD_DIR_ABS)/$(SRC_PACKAGE_DIR))$(shell pwd | grep $(BUILDSYSTEM)/3pp/sources),)
ifeq ($(shell pwd),$(TOP_BUILD_DIR_ABS))
	@echo -e "#######"
	@echo -e "####### Devices Table creation in the top of '`basename $(CURDIR)'`' directory is not supported."
	@echo -e "#######"
else
	@echo -e "################################################################"
	@echo -e "#######"
	@echo -e "####### Start of building Devices Table in '`echo $(CURDIR) | sed 's,$(TOP_BUILD_DIR_ABS)/,,'`' directory..."
	@echo -e "#######"
	@SYSTEM_VERSION=$(SYSTEM_VERSION) \
	 DISTRO_VERSION=$(DISTRO_VERSION) \
	 DISTRO_NAME=$(DISTRO_NAME)       \
	  $(BUILDSYSTEM)/build_devices_table $(TOP_BUILD_DIR_ABS) $(TOOLCHAIN) $(HARDWARE) $(FLAVOUR)
	@echo -e "#######"
	@echo -e "####### End of building Devices Table in '`echo $(CURDIR) | sed 's,$(TOP_BUILD_DIR_ABS)/,,'`' directory."
	@echo -e "#######"
	@echo -e "################################################################"
endif
endif
endif

#######
####### End of Build Devices Table.
#######
################################################################


################################################################
#######
####### Build ext4 Root FS image:
#######

ext4fs_image: $(PRODUCTS_DEST_DIR)/$(HARDWARE).ext4fs

$(PRODUCTS_DEST_DIR)/$(HARDWARE).ext4fs: $(TARGET_BUILD_DIR)/.DEVTABLE
ifneq ($(shell pwd),$(BUILDSYSTEM))
ifeq ($(shell pwd | grep $(TOP_BUILD_DIR_ABS)/$(SRC_PACKAGE_DIR))$(shell pwd | grep $(BUILDSYSTEM)/3pp/sources),)
ifeq ($(shell pwd),$(TOP_BUILD_DIR_ABS))
	@echo -e "#######"
	@echo -e "####### Ext4 Root FS Image creation in the top of '`basename $(CURDIR)`' directory is not supported."
	@echo -e "#######"
else
	@echo -e "################################################################"
	@echo -e "#######"
	@echo -e "####### Start of building Ext4 Root FS Image in '`echo $(CURDIR) | sed 's,$(TOP_BUILD_DIR_ABS)/,,'`' directory..."
	@echo -e "#######"
	@( size=`echo $(MAKEFLAGS) | grep 'size=' | sed -e 's,.*size=\([0-9.]*[KMG]\?\).*,\1,'` ; \
	   if [ -z "$$size" ] ; then \
	     sizeoption="" ; \
	   else \
	     sizeoption="--size=$$size" ; \
	   fi ; \
	   MKEE4FS=$(MKE4FS) E4FSCK=$(E4FSCK) POPULATEFS=$(POPULATEFS) \
	      $(BUILDSYSTEM)/build_ext4fs $$sizeoption $(TOP_BUILD_DIR_ABS) $(TOOLCHAIN) $(HARDWARE) $(FLAVOUR) ; \
	 )
	@cp -a $(TARGET_BUILD_DIR)/$(HARDWARE).SD.MBR $(PRODUCTS_DEST_DIR)/$(HARDWARE).SD.MBR
	@cp -a $(TARGET_BUILD_DIR)/$(HARDWARE).ext4fs $(PRODUCTS_DEST_DIR)/$(HARDWARE).ext4fs
	@$(E4FSCK) -fy $(PRODUCTS_DEST_DIR)/$(HARDWARE).ext4fs
	@echo -e "#######"
	@echo -e "####### End of building Ext4 Root FS Image in '`echo $(CURDIR) | sed 's,$(TOP_BUILD_DIR_ABS)/,,'`' directory."
	@echo -e "#######"
	@echo -e "################################################################"
endif
endif
endif

#######
####### End of Build ext4 Root FS image.
#######
################################################################


#######
####### Install rules:
#######

ifdef SCRIPT_TARGETS
_install_scripts := .install_scripts
endif

ifdef BIN_TARGETS
_install_bins := .install_bins
endif

ifdef BUILD_TARGETS
_install_builds := .install_builds
endif

ifdef PRODUCT_TARGETS
_install_products := .install_products
endif

ifdef ROOTFS_TARGETS
_install_pkgs := .install_pkgs
endif

ifdef ROOTFS_UPDATE_TARGETS
_update_pkgs := .update_pkgs
endif


################################################################
#######
####### Waiting for build whole required tree:
#######

$(BUILD_TARGETS)          : | $(_tree)

#######
####### End of waiting for build whole required tree.
#######
################################################################


$(PRODUCT_TARGETS)        : | $(BUILD_TARGETS)
$(ROOTFS_TARGETS)         : | $(BUILD_TARGETS)
$(ROOTFS_UPDATE_TARGETS)  : | $(BUILD_TARGETS)



_install: .install
	@if [ "$$(echo $(TARGET_BUILD_DIR)/.dist*)" != "$(TARGET_BUILD_DIR)/.dist*" ]; then \
	     sort -o $(TARGET_BUILD_DIR)/.dist.tmp -u $(TARGET_BUILD_DIR)/.dist* ; \
	     mv $(TARGET_BUILD_DIR)/.dist.tmp $(TARGET_BUILD_DIR)/.dist ; \
	 fi
	@rm -f $(TARGET_BUILD_DIR)/.dist.*



.install: $(_install_scripts)
.install: $(_install_bins)
.install: $(_install_builds)
.install: $(_install_products)
.install: $(_install_pkgs)
.install: $(_update_pkgs)


# create files which contains the list of installed files
.install_%: DO_CREATE_DIST_FILES = $(CREATE_DIST_FILES)
export DO_CREATE_DIST_FILES


#
# Note:
#    The check such as 'ifdef SCRIPT_TARGETS' realy doesn't need. This
#    practice can be used in other cases, for example, if we will need
#    to check some variables used in the following commands.
#    As example only, we can check existence of FLAVOUR variable:
#
#    $(_install_scripts): $(SCRIPT_TARGETS)
#    ifdef FLAVOUR
#       @$(BUILDSYSTEM)/install_targets $^ $(TARGET_DEST_DIR)/bin $(HARDWARE) $(FLAVOUR)
#    else
#       @$(BUILDSYSTEM)/install_targets $^ $(TARGET_DEST_DIR)/bin $(HARDWARE)
#    endif
#
$(_install_scripts): $(SCRIPT_TARGETS)
ifdef SCRIPT_TARGETS
	@$(BUILDSYSTEM)/install_targets         \
	   --destination=$(TARGET_DEST_DIR)/bin \
	   --toolchain=$(TOOLCHAIN)             \
	   --hardware=$(HARDWARE)               \
	   --flavour=$(FLAVOUR)                 \
	   $^
endif

$(_install_bins): $(BIN_TARGETS)
ifdef BIN_TARGETS
	@$(BUILDSYSTEM)/install_targets         \
	   --destination=$(TARGET_DEST_DIR)/bin \
	   --toolchain=$(TOOLCHAIN)             \
	   --hardware=$(HARDWARE)               \
	   --flavour=$(FLAVOUR)                 \
	   $^
endif

$(_install_builds): $(BUILD_TARGETS)
ifdef BUILD_TARGETS
# Do nothing
endif

# preserve source dir with depth=1 ; then collect installed products in the .$(HARDWARE).products file
$(_install_products): $(PRODUCT_TARGETS)
ifdef PRODUCT_TARGETS
	@$(BUILDSYSTEM)/install_targets         \
	   --preserve-source-dir=$(if $(FLAVOUR),two,one) \
	   --destination=$(PRODUCTS_DEST_DIR)   \
	   --toolchain=$(TOOLCHAIN)             \
	   --hardware=$(HARDWARE)               \
	   --flavour=$(FLAVOUR)                 \
	   $^
endif

#
# NOTE:
#   We use CWD=$(CURDIR) as a directory for collect .$(HARDWARE).rootfs.* files, also
#   to allow parallel installation the 'install_pkgs' script install packages from
#   $(TARGET_BUILD_DIR)/$(PKG_GROUP) directory. In other words if ROOTFS_TARGETS equal to
#
#      ROOTFS_TARGETS = $(TARGET_BUILD_DIR)/$(PKG_GROUP)/$(pkg_basename).tgz
#
#   then 'install_pkgs' going to $(TARGET_BUILD_DIR)/$(PKG_GROUP) directory and installs
#   the $(pkg_basename).tgz package directly from this directory to keep temporary files
#   separately from other HARDWAREs. In this case we need to use CWD environment variable
#   to set the directory where the .$(HARDWARE).rootfs.* files will be collected by
#   'install_pkgs' script (see the 'install_pkgs' source code).
#
#   Parallel installation when ROOTFS_TARGETS presents not alone package not tested.
#
$(_install_pkgs): $(ROOTFS_TARGETS)
ifdef ROOTFS_TARGETS
	@echo -e "#######"
	@echo -e "####### Install packages into 'dist/rootfs/$(TOOLCHAIN)/$(HARDWARE)/...' file system..."
	@echo -e "#######"
ifeq ($(wildcard $(TARGET_BUILD_DIR)/.rootfs),)
	@CWD=$(CURDIR) INSTALL_PACKAGE="$(INSTALL_PACKAGE)" \
	   $(BUILDSYSTEM)/install_pkgs --destination=$(ROOTFS_DEST_DIR) \
	                               --toolchain=$(TOOLCHAIN)         \
	                               --hardware=$(HARDWARE)           \
	                               --flavour=$(FLAVOUR)             \
	                               $^
else
	@echo ""
	@for pkg in $(ROOTFS_TARGETS) ; do \
	   echo -e "#######  ... package `basename $$pkg` is already installed." ; \
	 done
	@echo ""
endif
endif


$(_update_pkgs): $(ROOTFS_UPDATE_TARGETS)
ifdef ROOTFS_UPDATE_TARGETS
	@echo -e "#######"
	@echo -e "####### Update packages into 'dist/rootfs/$(TOOLCHAIN)/$(HARDWARE)/...' file system..."
	@echo -e "#######"
ifeq ($(wildcard $(TARGET_BUILD_DIR)/.rootfs),)
	@CWD=$(CURDIR) UPDATE_PACKAGE="$(UPDATE_PACKAGE)" \
	   $(BUILDSYSTEM)/update_pkgs --destination=$(ROOTFS_DEST_DIR) \
	                              --toolchain=$(TOOLCHAIN)         \
	                              --hardware=$(HARDWARE)           \
	                              --flavour=$(FLAVOUR)             \
	                              $^
else
	@echo ""
	@for pkg in $(ROOTFS_UPDATE_TARGETS) ; do \
	   echo -e "#######  ... package `basename $$pkg` is already installed." ; \
	 done
	@echo ""
endif
endif





################################################################
#######
####### Generic Rules Section:
#######

# link rule, used to build binaries
# $(target): $(objs)
# 	$(LINK)
#

LINKER = $(if $(filter .cpp,$(suffix $(SRCS))),$(CXX_LINKER),$(CC_LINKER))

ifeq ($(COMPONENT_IS_3PP),)
LINKMAP = -Wl,-Map,$@.linkmap
endif

BASIC_LDOPTS  = $(LDFLAGS) $(LINKMAP)
BASIC_LDOPTS += -o $@ $(filter %.o,$^)


define cmdheader
  @echo -e ""
  @echo -e "======= $(1) ======="
  $(2)
  @echo -e ""
endef


LINK = $(call cmdheader,"Linking $@",$(LINKER) $(BASIC_LDOPTS))

# LINK_C overrides the automatic linker selection provided with LINK
# and always  uses gcc. Useful when building both C and C++ targets
# in the same component:
LINK_C = $(call cmdheader,"Linking $@",$(CC) $(BASIC_LDOPTS))

LINK_SO = $(call cmdheader,"Linking $@", $(LINKER) $(BASIC_LDOPTS) -shared)

LINK_A = $(call cmdheader,"Building $@",$(AR) cru $@ $^)


#######
####### Source dependency
#######

flatfile = $(subst /,_,$(subst ./,,$(1)))
DEPFILE = $(patsubst %.o,%.d,$(if $(findstring $(TOOLCHAIN),$@),$(TARGET_BUILD_DIR)/$(call flatfile,$(subst $(TARGET_BUILD_DIR)/,,$@)),$(call flatfile,$@)))
DEPSETUP = -MD -MP -MF $(DEPFILE) -MT $@

####### .cpp -> .o
%.o: %.cpp
	@echo -e ""
	@echo -e "======= $< -> $@ ======="
	$(quiet)$(CXX) -c $(CXXFLAGS) $(CPPFLAGS) -o $@ $(DEPSETUP) $<

$(TARGET_BUILD_DIR)/%.o: %.cpp
	@echo -e "\n======= $< -> $@ ======="
	@mkdir -p $(dir $@)
	$(quiet)$(CXX) -c $(CXXFLAGS) $(CPPFLAGS) -o $@ $(DEPSETUP) $<

####### .c -> .o
%.o: %.c
	@echo -e ""
	@echo -e "======= $< -> $@ ======="
	$(quiet)$(CC) -c $(CFLAGS) $(CPPFLAGS) -o $@ $(DEPSETUP) $<

$(TARGET_BUILD_DIR)/%.o: %.c
	@echo -e "======= $< -> $@ ======="
	@mkdir -p $(dir $@)
	$(quiet)$(CC) -c $(CFLAGS) $(CPPFLAGS) -o $@ $(DEPSETUP) $<

#######
####### Generic Rules Section.
#######
################################################################



#######
####### NOTE: Include dependencies should be in section where
####### the symbol __final__ is defined: ifneq ($(__final__),)
#######

#######
####### Include dependencies if they exist
#######

-include $(targetflavour)/*.d

# Include HW dependencies
-include $(TARGET_BUILD_DIR)/.requires_depend

#######
####### Include sources dependency if they exist
#######

-include .src_requires_depend



################################################################
#######
####### HW depended macro for create PKG requires:
#######
    BUILD_PKG_REQUIRES = $(BUILDSYSTEM)/build_pkg_requires $(REQUIRES)
BUILD_ALL_PKG_REQUIRES = $(BUILDSYSTEM)/build_pkg_requires --pkg-type=all $(REQUIRES)
BUILD_BIN_PKG_REQUIRES = $(BUILDSYSTEM)/build_pkg_requires --pkg-type=bin $(REQUIRES)
BUILD_DEV_PKG_REQUIRES = $(BUILDSYSTEM)/build_pkg_requires --pkg-type=dev $(REQUIRES)
#######
####### HW depended macro for create PKG requires.
#######
################################################################


endif
#
# end of ifeq ($(__final__),)
#
################################################################




# HW depended targets:
.PHONY: .target*

.PHONY: .toolchain

.PHONY: $(_tree)
.PHONY: .requires_makefile

.PHONY:    .tree_all  .tree_clean  .tree_dist_clean  .tree_rootfs_clean
.PHONY: all _install        clean        dist_clean        rootfs_clean
.PHONY:    local_all  local_clean  local_dist_clean  local_rootfs_clean
.PHONY:              .local_clean .local_dist_clean .local_rootfs_clean

.PHONY: .install $(_install_scripts) $(_install_builds) $(_install_bins) $(_install_products)
.PHONY:          $(_install_pkgs) $(_update_pkgs)

# HW independed targets:
.PHONY: help
.PHONY: .setup
.PHONY: .sources      .build_system
.PHONY:  global_clean  downloads_clean
.PHONY: .global_clean .downloads_clean

.SUFFIXES:





CORE_MK = 1
endif


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
        $(if $($(shell echo ${hardware} | tr '[a-z]' '[A-Z]')_FLAVOURS),                   \
          $(foreach flavour, $($(shell echo ${hardware} | tr '[a-z]' '[A-Z]')_FLAVOURS),   \
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
	@shtool echo -e "%B#######%b"
	@shtool echo -e "%B#######%b %BNew makefile (%b$(<F)%B), clean up & rebuild source requires!%b"
	@shtool echo -e "%B#######%b"
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
	@shtool echo -e "%B################################################################%b"
	@shtool echo -e "%B#######%b"
	@shtool echo -e "%B#######%b %BStart of building source requires for '%b$(subst $(TOP_BUILD_DIR_ABS)/,,$(CURDIR))%B':%b"
	@shtool echo -e "%B#######%b"
	@$(BUILDSYSTEM)/build_src_requires $(TOP_BUILD_DIR_ABS)
	@__final__= TREE_RULE=local_all $(MAKE) TOOLCHAIN=$(TOOLCHAIN_NOARCH) HARDWARE=$(HARDWARE_NOARCH) FLAVOUR= -f .src_requires
	@shtool echo -e "%B#######%b"
	@shtool echo -e "%B#######%b %BEnd of building source requires for '%b$(subst $(TOP_BUILD_DIR_ABS)/,,$(CURDIR))%B'.%b"
	@shtool echo -e "%B#######%b"
	@shtool echo -e "%B################################################################%b"
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
	@shtool echo -e "%B################################################################%b"
	@shtool echo -e "%B#######%b"
	@shtool echo -e "%B#######%b %BStart to Check the BUILDSYSTEM is ready:%b"
	@shtool echo -e "%B#######%b"
	@( cd $(BUILDSYSTEM) ; __final__= $(MAKE) TOOLCHAIN=$(TOOLCHAIN_BUILD_MACHINE) HARDWARE=$(HARDWARE_BUILD) FLAVOUR= all )
	@shtool echo -e "%B#######%b"
	@shtool echo -e "%B#######%b %BEnd of checking the BUILDSYSTEM.%b"
	@shtool echo -e "%B#######%b"
	@shtool echo -e "%B################################################################%b"
endif
endif
endif



#######
####### Clean the whole source tree
#######

global_clean: .global_clean

.global_clean:
	@echo ""
	@shtool echo -e "%B#######%b"
	@shtool echo -e "%B#######%b %BCleaning the whole sources tree excluding downloaded sources...%b"
	@shtool echo -e "%B#######%b"
	@$(BUILDSYSTEM)/global_clean $(addprefix ., $(TOOLCHAIN_NAMES)) $(TOP_BUILD_DIR_ABS)


#######
####### Clean all downloaded source tarballs
#######

downloads_clean: .downloads_clean

.downloads_clean:
	@echo ""
	@shtool echo -e "%B#######%b"
	@shtool echo -e "%B#######%b %BCleaning Up all downloaded sources...%b"
	@shtool echo -e "%B#######%b"
	@$(BUILDSYSTEM)/downloads_clean $(addprefix ., $(TOOLCHAIN_NOARCH)) $(BUILDSYSTEM)/3pp/sources
ifneq ($(wildcard $(TOP_BUILD_DIR_ABS)/$(SRC_PACKAGE_DIR)),)
	@$(BUILDSYSTEM)/downloads_clean $(addprefix ., $(TOOLCHAIN_NOARCH)) $(TOP_BUILD_DIR_ABS)/$(SRC_PACKAGE_DIR)
endif


help:
	@echo ""
	@shtool echo -e "%BBuild System $(SYSTEM_VERSION)%b"
	@echo ""
	@shtool echo -e "You can build and install software using command line such as follow:"
	@echo ""
	@shtool echo -e "   %B$$%b [%BTOOLCHAIN=%btoolchain] [%BHARDWARE=%bhardware] [%BFLAVOUR=%bflavour] %Bmake%b [%Bgoal%b]"
	@echo ""
	@shtool echo -e "The following MAKE goals are available:"
	@echo ""
	@shtool echo -e "   %Ball%b                - perform make build and install software in the all"
	@shtool echo -e "                        required directories which defined by %BREQUIRES%b"
	@shtool echo -e "                        variable in the local Makefile;"
	@shtool echo -e "   %Blocal_all%b          - build and install software prepared onlu by local"
	@shtool echo -e "                        Makefile;"
	@shtool echo -e "   %Bdist_clean%b,"
	@shtool echo -e "   %Blocal_dist_clean%b   - remove distribution packages from target directory"
	@shtool echo -e "                        defined by %BPRODUCTS_DEST_DIR%b variable. Note that"
	@shtool echo -e "                        is depends from targets defined by %BCOMPONENT_TARGETS%b"
	@shtool echo -e "                        variable or command line;"
	@shtool echo -e "   %Brootfs_clean%b,"
	@shtool echo -e "   %Blocal_rootfs_clean%b - uninstall packages installed into target 'root file"
	@shtool echo -e "                        system' directory which defined by %BROOTFS_DEST_DIR%b"
	@shtool echo -e "                        variable;"
	@shtool echo -e "   %Bclean%b,"
	@shtool echo -e "   %Blocal_clean%b        - clean up all built targets by this Makefile;"
	@echo ""
	@shtool echo -e "   If the one from above goals has prefix '%Blocal_%b' then this goal affects only"
	@shtool echo -e "   current directory.  Otherwise this goal will be performed for all required"
	@shtool echo -e "   directories which defined by %BREQUIRES%b variable."
	@echo ""
	@shtool echo -e "   %Bconfigure_targets%b  - select hardwares, for which the software will be built."
	@shtool echo -e "                        This command edits the %Bbuild-config.mk%b file;"
	@shtool echo -e "   %Brequires_tree%b      - create %BHTML%b file to show the requires tree for current"
	@shtool echo -e "                        directory. Note that this goal depends on goal %Ball%b;"
	@shtool echo -e "   %Bglobal_clean%b       - clean up %Bwhole%b sourses tree excluding downloaded"
	@shtool echo -e "                        source tarballs;"
	@shtool echo -e "   %Bdownloads_clean%b    - remove %Ball%b sourse tarball from '%Bsourses%b' directory;"
	@echo ""
	@shtool echo -e "   %Bccache_stats%b       - show the %Bccache%b statistic."
	@echo ""
	@shtool echo -e "Local Makefile is prepared for following target HW platforms:"
	@echo ""
	@for platform in $(COMPONENT_TARGETS) ; do \
	  shtool echo -e "   %B$$platform%b"; \
	 done
	@echo ""
	@shtool echo -e "%BEnjoy%b."
	@echo ""

ccache_stats:
ifeq ($(NO_CCACHE),)
	@echo ""
	@shtool echo -e "%BCCACHE statistic:%b"
	@echo ""
	@CCACHE_DIR=$(CACHED_CC_OUTPUT) $(CCACHE) -s
	@echo ""
	@shtool echo -e "To set max %Bcache%b size make use the following command"
	@echo ""
	@shtool echo -e "   %B$$%b CCACHE_DIR=$(CACHED_CC_OUTPUT) $(CCACHE)%B-M%b 64%BG%b"
	@echo ""
	@shtool echo -e "see %BCCACHE%b(%B1%b) for more information."
	@echo ""
else
	@echo ""
	@shtool echo -e "%BCCACHE%b disabled by setting '%BNO_CCACHE%b=$(NO_CCACHE)' variable for this Makefile."
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
install-into-devenv = \
	@( cd $1 ; \
	   DO_CREATE_DIST_FILES=1 CWD=$(CURDIR) \
	   $(BUILDSYSTEM)/install_targets       \
	     --preserve-source-dir=true         \
	     --destination=$(TARGET_DEST_DIR)   \
	     --toolchain=$(TOOLCHAIN)           \
	     --hardware=$(HARDWARE)             \
	     --flavour=$(FLAVOUR)               \
	    $$(find * \( -type f -o -type l \) -print) > /dev/null ; \
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

# we allow available combinations, for example, if HW specified then we allow only HW specific flavours

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
                     ),                                                                                   \
                     .target_$(arch)_$(HARDWARE)                                                          \
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
                     ),                                                                                        \
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
                    .target_$(TOOLCHAIN)_$(hardware)                                                        \
                 )
endif
else
# (3) ======= loop:  , H,  ; where T=const, F=const    =======
__target_args = $(foreach hardware, $($(shell echo $(TOOLCHAIN) | tr '[a-z-]' '[A-Z_]')_HARDWARE_VARIANTS), \
                    .target_$(TOOLCHAIN)_$(hardware)_$(FLAVOUR)                                             \
                 )
endif
else
ifeq ($(FLAVOUR),)
ifeq ($(__cmdline_flavour_defined),false)
# (2) ======= loop:  ,  , F; where T=const, H=const    =======
__target_args = $(foreach flavour, $($(shell echo $(HARDWARE) | tr '[a-z]' '[A-Z]')_FLAVOURS),           \
                  .target_$(shell echo $(TOOLCHAIN) | sed -e 's/x86_64/x86-64/g')_$(HARDWARE)_$(flavour) \
                 ) .target_$(shell echo $(TOOLCHAIN) | sed -e 's/x86_64/x86-64/g')_$(HARDWARE)
else
# (1) ======= loop:  ,  ,  ; T=const, H=const, F=0     =======
__target_args = .target_$(TOOLCHAIN)_$(HARDWARE)
endif
else
# (0) ======= loop:  ,  ,  ; T=const, H=const, F=const =======
__target_args = .target_$(TOOLCHAIN)_$(HARDWARE)_$(FLAVOUR)
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


.target_%: TOOLCHAIN = $(shell echo $(word 2, $(subst _, , $@)) | sed -e 's/x86-64/x86_64/g')
.target_%: HARDWARE = $(if $(filter $(shell echo $(word 3, $(subst _, , $@))),$(HARDWARE_ALL)),$(word 3, $(subst _, , $@)))
.target_%: FLAVOUR = $(if $(word 4, $(subst _, , $@)),$(word 4, $(subst _, , $@)),$(if $(filter $(shell echo $(word 3, $(subst _, , $@))),$(HARDWARE_ALL)),,$(word 3, $(subst _, , $@))))
.target_%:
	@echo ""
	@shtool echo -e "%B################################################################%b"
	@shtool echo -e "%B#######%b"
	@shtool echo -e "%B#######%b TOOLCHAIN=%B$(TOOLCHAIN)%b ; HARDWARE=%B$(HARDWARE)%b ; FLAVOUR=%B$(if $(FLAVOUR),$(FLAVOUR))%b ;"
	@shtool echo -e "%B#######%b"
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
	@shtool echo -e "%B################################################################%b"
	@shtool echo -e "%B#######%b"
	@shtool echo -e "%B#######%b %BStart of downloading toolchain '%b$(shell basename $(TOOLCHAIN_TARBALL))%B':%b"
	@shtool echo -e "%B#######%b"
	@if [ -d $(TOOLCHAINS_BASE_PATH) -a -w $(TOOLCHAINS_BASE_PATH) ] ; then \
	  ( cd $(TOOLCHAINS_BASE_PATH) ; \
	    $(BUILDSYSTEM)/download-toolchain "$(DOWNLOAD_SERVER)/$(TOOLCHAIN_TARBALL)" ; \
	  ) ; \
	 else \
	   shtool echo -e "%B#%b" ; \
	   shtool echo -e "%B#%b" ; \
	   shtool echo -e "%B#%b Please create '%B$(TOOLCHAINS_BASE_PATH)%b' directory" ; \
	   shtool echo -e "%B#%b and give write permissions to '%B$(shell echo "`id -u -n`")%b':" ; \
	   shtool echo -e "%B#%b" ; \
	   shtool echo -e "%B#%b    # sudo mkdir -p %B$(TOOLCHAINS_BASE_PATH)%b" ; \
	   shtool echo -e "%B#%b    # sudo chown -R %B$(shell echo "`id -u -n`")%b:%B$(shell echo "`id -g -n`")%b $(TOOLCHAINS_BASE_PATH)" ; \
	   shtool echo -e "%B#%b" ; \
	   shtool echo -e "%B#%b" ; \
	   shtool echo -e "%B# ERROR:%b $(TOOLCHAINS_BASE_PATH): Permission denied. Stop." ; \
	   shtool echo -e "%B#%b" ; \
	   exit 1 ; \
	 fi
	@shtool echo -e "%B#######%b"
	@shtool echo -e "%B#######%b %BEnd of downloading toolchain '%b$(shell basename $(TOOLCHAIN_TARBALL))%B'.%b"
	@shtool echo -e "%B#######%b"
	@shtool echo -e "%B################################################################%b"
endif
endif


.tree_all: BUILD_TREE := false

.tree_all: $(TARGET_BUILD_DIR)/.requires
ifneq ($(shell pwd),$(TOP_BUILD_DIR_ABS))
ifeq ($(shell pwd | grep $(TOP_BUILD_DIR_ABS)/$(SRC_PACKAGE_DIR))$(shell pwd | grep $(BUILDSYSTEM)/3pp/sources),)
	@shtool echo -e "%B################################################################%b"
	@shtool echo -e "%B#######%b"
ifeq ($(shell pwd),$(BUILDSYSTEM))
	@shtool echo -e "%B#######%b %BStart of building requires for '%b$(subst $(TOP_BUILD_DIR_ABS)/,,$(CURDIR))%B':%b"
else
	@shtool echo -e "%B#######%b %BStart of building requires for %bTOOLCHAIN=%B$(TOOLCHAIN) %bHARDWARE=%B$(HARDWARE) %bFLAVOUR=%B$(FLAVOUR) in '%b$(subst $(TOP_BUILD_DIR_ABS)/,,$(CURDIR))%B':%b"
endif
	@shtool echo -e "%B#######%b"
ifeq ($(shell pwd),$(BUILDSYSTEM))
	@__final__=true TREE_RULE=local_all $(MAKE) TOOLCHAIN=$(TOOLCHAIN_BUILD_MACHINE) HARDWARE=$(HARDWARE_BUILD) FLAVOUR= -f $(TARGET_BUILD_DIR)/.requires
else
	@__final__=true TREE_RULE=local_all $(MAKE) TOOLCHAIN=$(TOOLCHAIN) HARDWARE=$(HARDWARE) FLAVOUR= -f $(TARGET_BUILD_DIR)/.requires
endif
	@shtool echo -e "%B#######%b"
	@shtool echo -e "%B#######%b %BEnd of building requires for '%b$(subst $(TOP_BUILD_DIR_ABS)/,,$(CURDIR))%B'.%b"
	@shtool echo -e "%B#######%b"
	@shtool echo -e "%B################################################################%b"
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
	@shtool echo -e "%B#######%b %BCleaning in '%b`basename $(CURDIR)`%B' directory is not supported.%b"
else
	@shtool echo -e "%B#######%b %BLocal Cleaning in '%b`basename $(CURDIR)`%B' directory...%b"
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
	@shtool echo -e "   %B(nothing to be done).%b"
else
	@if [ -f $(TARGET_BUILD_DIR)/.dist ] ; then \
	  $(BUILDSYSTEM)/dist_clean --destination=$(DEST_DIR) \
	                            --toolchain=$(TOOLCHAIN) --hardware=$(HARDWARE) --flavour=$(FLAVOUR)  ; \
	  rm -f $(TARGET_BUILD_DIR)/.dist ; \
	fi
	@rm -rf $(TARGET_BUILD_DIR)/.dist*
	@shtool echo -e "   %B(done).%b"
endif
endif
endif

.local_dist_clean:
ifeq ($(shell pwd),$(BUILDSYSTEM))
	@shtool echo -e "%B#######%b %BDestination cleaning in '%b`basename $(CURDIR)`%B' directory is not supported.%b"
else
ifneq ($(shell pwd | grep $(TOP_BUILD_DIR_ABS)/$(SRC_PACKAGE_DIR))$(shell pwd | grep $(BUILDSYSTEM)/3pp/sources),)
	@shtool echo -e "%B#######%b %BDestination cleaning in '%b`basename $(CURDIR)`%B' directory is not supported.%b"
else
	@shtool echo -n -e "%B#######%b %BDestination cleaning in '%b`basename $(CURDIR)`%B' directory...%b"
endif
endif


#######
####### Root File System Clean:
#######

local_rootfs_clean: .local_rootfs_clean
ifneq ($(shell pwd),$(BUILDSYSTEM))
ifeq ($(shell pwd | grep $(TOP_BUILD_DIR_ABS)/$(SRC_PACKAGE_DIR))$(shell pwd | grep $(BUILDSYSTEM)/3pp/sources),)
ifeq ($(wildcard $(TARGET_BUILD_DIR)/.rootfs),)
	@shtool echo -e "%B#######%b %BRoot File System cleaning...   (nothing to be done).%b"
else
	@if [ -f $(TARGET_BUILD_DIR)/.rootfs ]; then \
	  REMOVE_PACKAGE="$(REMOVE_PACKAGE)" $(BUILDSYSTEM)/rootfs_clean \
	                                                    --destination=$(DEST_DIR) \
	                                                    --toolchain=$(TOOLCHAIN)  \
	                                                    --hardware=$(HARDWARE)    \
	                                                    --flavour=$(FLAVOUR)    ; \
	else \
	  shtool echo -e "B#######%b %B... Nothing to be done (there are no installed packages).%b" ; \
	fi
	@rm -rf $(TARGET_BUILD_DIR)/.rootfs
endif
endif
endif

.local_rootfs_clean:
ifeq ($(shell pwd),$(BUILDSYSTEM))
	@shtool echo -e "%B#######%b %BRoot file system cleaning in '%b`basename $(CURDIR)`%B' directory is not supported.%b"
else
ifneq ($(shell pwd | grep $(TOP_BUILD_DIR_ABS)/$(SRC_PACKAGE_DIR))$(shell pwd | grep $(BUILDSYSTEM)/3pp/sources),)
	@shtool echo -e "%B#######%b %BRoot file system cleaning in '%b`basename $(CURDIR)`%B' directory is not supported.%b"
else
	@shtool echo -e "%B#######%b"
	@shtool echo -e "%B#######%b %BRemove packages from%b 'dist/rootfs/$(TOOLCHAIN)/$(HARDWARE)/...' %Bfile system...%b"
	@shtool echo -e "%B#######%b"
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
# Requires Tree perform only if goal 'all' is done and all packages installed
# into root filesystem or into products directory.
#
# NOTE:
#   The requires tree creation takes a time.
#
requires_tree: .requires_tree
ifneq ($(shell pwd),$(BUILDSYSTEM))
ifeq ($(shell pwd | grep $(TOP_BUILD_DIR_ABS)/$(SRC_PACKAGE_DIR))$(shell pwd | grep $(BUILDSYSTEM)/3pp/sources),)
ifeq ($(wildcard $(TARGET_BUILD_DIR)/.requires),)
	@shtool echo -e "   %B(nothing to be done).%b"
ifeq ($(shell pwd),$(TOP_BUILD_DIR_ABS))
	@shtool echo -e "%B#######%b"
	@shtool echo -e "%B#######%b %BRequires Tree creation in the top of '%b`basename $(CURDIR)`%B' directory is not supported.%b"
	@shtool echo -e "%B#######%b"
else
	@shtool echo -e "%B#######%b"
	@shtool echo -e "%B#######%b %BBefore creating a dependency tree all goals have to be made.%b"
	@shtool echo -e "%B#######%b"
endif
else
	@$(BUILDSYSTEM)/build_requires_tree $(TOP_BUILD_DIR_ABS) $(TOOLCHAIN) $(HARDWARE) $(FLAVOUR)
	@shtool echo -e "%B#######%b"
	@shtool echo -e "%B#######%b %BEnd of building Requires Tree in '%b`basename $(CURDIR)`%B' directory.%b"
	@shtool echo -e "%B#######%b"
	@shtool echo -e "%B################################################################%b"
endif
endif
endif

.requires_tree:
ifeq ($(shell pwd),$(BUILDSYSTEM))
	@shtool echo -e "%B#######%b %BRequires Tree creation in '%b`basename $(CURDIR)`%B' directory is not supported.%b"
else
ifneq ($(shell pwd | grep $(TOP_BUILD_DIR_ABS)/$(SRC_PACKAGE_DIR))$(shell pwd | grep $(BUILDSYSTEM)/3pp/sources),)
	@shtool echo -e "%B#######%b %BRequires Tree creation in '%b`basename $(CURDIR)`%B' directory is not supported.%b"
else
	@shtool echo -e "%B################################################################%b"
	@shtool echo -e "%B#######%b"
	@shtool echo -e "%B#######%b %BStart of building Requires Tree in '%b`basename $(CURDIR)`%B' directory...%b"
	@shtool echo -e "%B#######%b"
endif
endif

#######
####### End of Build REQUIRES tree.
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
	@shtool echo -e "%B#######%b"
	@shtool echo -e "%B#######%b %BInstall packages into%b 'dist/rootfs/$(TOOLCHAIN)/$(HARDWARE)/...' %Bfile system...%b"
	@shtool echo -e "%B#######%b"
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
	   shtool echo -e "%B#######%b %B ... package `basename $$pkg` is already installed.%b" ; \
	 done
	@echo ""
endif
endif


$(_update_pkgs): $(ROOTFS_UPDATE_TARGETS)
ifdef ROOTFS_UPDATE_TARGETS
	@shtool echo -e "%B#######%b"
	@shtool echo -e "%B#######%b %BUpdate packages into%b 'dist/rootfs/$(TOOLCHAIN)/$(HARDWARE)/...' %Bfile system...%b"
	@shtool echo -e "%B#######%b"
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
	   shtool echo -e "%B#######%b %B ... package `basename $$pkg` is already installed.%b" ; \
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
  @shtool echo -e "%B=======%b $(1) %B=======%b"
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
	@shtool echo -e "%B=======%b $< -> $@ %B=======%b"
	$(quiet)$(CXX) -c $(CXXFLAGS) $(CPPFLAGS) -o $@ $(DEPSETUP) $<

$(TARGET_BUILD_DIR)/%.o: %.cpp
	@echo -e "\n======= $< -> $@ ======="
	@mkdir -p $(dir $@)
	$(quiet)$(CXX) -c $(CXXFLAGS) $(CPPFLAGS) -o $@ $(DEPSETUP) $<

####### .c -> .o
%.o: %.c
	@echo -e ""
	@shtool echo -e "%B=======%b $< -> $@ %B=======%b"
	$(quiet)$(CC) -c $(CFLAGS) $(CPPFLAGS) -o $@ $(DEPSETUP) $<

$(TARGET_BUILD_DIR)/%.o: %.c
	@shtool echo -e "%B=======%b $< -> $@ %B=======%b"
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

.PHONY: .requires_tree

# HW independed targets:
.PHONY: help
.PHONY: .setup
.PHONY: .sources      .build_system
.PHONY:  global_clean  downloads_clean
.PHONY: .global_clean .downloads_clean

.SUFFIXES:





CORE_MK = 1
endif

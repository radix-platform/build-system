
# Generic rule used for build-system directories

all $(TREEDIRS):

$(TREEDIRS):
	@$(MAKE) FLAVOUR= -C $(TOP_BUILD_DIR_ABS)/$@ $(TREE_RULE)

.PHONY: all $(TREEDIRS)

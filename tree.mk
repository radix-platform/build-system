
# Generic rule used for directories

all $(TREEDIRS):

$(TREEDIRS):
	@FLAVOUR= $(MAKE) -C $(TOP_BUILD_DIR_ABS)/$@ $(TREE_RULE)

.PHONY: all $(TREEDIRS)

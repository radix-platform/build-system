
# Generic rule used for source directories

all $(TREEDIRS):

$(TREEDIRS):
	@$(MAKE) -C $(TOP_BUILD_DIR_ABS)/$@ $(TREE_RULE)

.PHONY: all $(TREEDIRS)

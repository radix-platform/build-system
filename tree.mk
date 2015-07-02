
# Generic rule used for directories

all $(TREEDIRS):

get-flavour = $(if $(shell echo $1 | grep "\^"),$(shell echo $1 | cut -f 2 -d '^'),)

$(TREEDIRS):
	@$(MAKE) FLAVOUR=$(call get-flavour,$@) -C $(TOP_BUILD_DIR_ABS)/$(shell echo $@ | cut -f 1 -d '^') $(TREE_RULE)

.PHONY: all $(TREEDIRS)

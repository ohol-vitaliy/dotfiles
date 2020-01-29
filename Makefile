.PHONY: all help dotfiles

EXCLUDES := -name .git -o -name additional -o -name Makefile -o -name setup.sh -o -name README.md -o -name LICENSE -o -name .gitignore
BASHRC_INC := "[ -f ~/.config/bashrc ] && source ~/.config/bashrc"

all: dotfiles

dotfiles: ## Install dotfiles into HOME
	# Creating config directory structure...
	@find . \( $(EXCLUDES) \) -prune -o -type d -print | sed "1d;s|^./||" | xargs -I{} mkdir -p "$(HOME)/{}"

	# Creating links to the config files
	@find . \( $(EXCLUDES) \) -prune -o -type f -print | sed "s|^./||" | xargs -I{} ln -sf "$(PWD)/{}" "$(HOME)/{}"

	# Including config in ~/.bashrc
	@grep -qxF $(BASHRC_INC) ~/.bashrc || echo $(BASHRC_INC) >> ~/.bashrc

help: ## Show this help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| sort \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'


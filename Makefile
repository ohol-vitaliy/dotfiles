.PHONY: all help dotfiles

EXCLUDES := -name .git -o -name .doom.d -o -name additional -o -name Makefile -o -name setup.sh -o -name README.md -o -name LICENSE -o -name .gitignore -o -name .claude
BASHRC_INC := "[ -f ~/.config/bashrc ] && . ~/.config/bashrc"

all: dotfiles

dotfiles: ## Install dotfiles into HOME
	# Creating config directory structure...
	@find . \( $(EXCLUDES) \) -prune -o -type d -print | sed "1d;s|^./||" | xargs -I{} mkdir -p "$(HOME)/{}"

	# Creating links to the config files
	@find . \( $(EXCLUDES) \) -prune -o -type f -print | sed "s|^./||" | xargs -I{} ln -sf "$(CURDIR)/{}" "$(HOME)/{}"

	# Dropping ~/.gitconfig entries that duplicate .config/git/config
	# ~/.gitconfig must exist, or git config --global writes into the linked repo file
	@touch ~/.gitconfig
	@git config --file .config/git/config --list | while IFS='=' read -r k v; do git config --file ~/.gitconfig --fixed-value --unset-all "$$k" "$$v" 2>/dev/null; done; true

	# Including config in ~/.bashrc
	@for f in ~/.bashrc ~/.ashrc ~/.profile; do grep -qxF $(BASHRC_INC) $$f || echo $(BASHRC_INC) >> $$f || exit 1; done
	@echo "Dont forget to run :PlugInstall inside vim"

help: ## Show this help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| sort \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'


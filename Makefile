.PHONY: all apps help dotfiles essential-remove useless-remove essential-install

INSTALL_DIR=$(HOME)/repos

ESSENTIAL=bash bash-completion curl git wget ripgrep htop 
USELESS=fish nano zsh

all: dotfiles 
apps: essential-install useless-remove

dotfiles: ## install this configs
	# === DOTFILES-DIRS ===
	@for dir in $(shell find $(PWD) -type d \
			| egrep -v "(additional|.git)" \
			| sed s:"$(PWD)/":: | sed 1d); do \
		mkdir -p $(HOME)/$$dir; \
	done;
	# === DOTFILES-FILES ===
	@for file in $(shell find $(PWD) -type f \
			| egrep -v "(.git|Makefile|additional|setup.sh|README.md|LICENSE)" \
			| sed s:"$(PWD)/"::); do \
		ln -sf $(PWD)/$$file $(HOME)/$$file; \
	done;
	echo "[ -f ~/.config/bashrc ] && source ~/.config/bashrc" >> ~/.bashrc

essential-install: ## install essential utils
	sudo apt install $(ESSENTIAL) -y
essential-remove: ## remove essential utils
	sudo apt purge $(ESSENTIAL) -y
useless-remove: ## remove useless (for me) utils
	sudo apt purge $(USELESS) -y

help: ## this help window
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| sort \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

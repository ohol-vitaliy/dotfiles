.PHONY: all apps help dunst dmenu st dwm dotfiles apps vim emacs
.PHONY: essential-remove useless-remove essential-install

INSTALL_DIR=$(HOME)/Documents

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

dwm: ## install dwm tiling manager with my patches and configs
	sudo apt install libx11-dev libxft-dev libxinerama-dev -y
	git clone https://github.com/Vitalii-Ohol/dwm \
			$(INSTALL_DIR)/dwm || (cd $(INSTALL_DIR)/dwm ; git pull)
	(cd $(INSTALL_DIR)/dwm && sudo make clean install)
	sudo cp $(PWD)/.config/additional/dwm-wrapper /usr/local/bin/
	sudo cp $(PWD)/.config/additional/dwm.desktop /usr/share/xsessions/

st: ## install ST with my patches and configs
	git clone https://github.com/Vitalii-Ohol/st \
			$(INSTALL_DIR)/st || (cd $(INSTALL_DIR)/st ; git pull)
	(cd $(INSTALL_DIR)/st && sudo make clean install)

dmenu: ## install dmenu
	git clone https://git.suckless.org/dmenu \
			$(INSTALL_DIR)/dmenu || (cd $(INSTALL_DIR)/dmenu ; git pull)
	ln -sf $(PWD)/.config/additional/dmenu.h $(INSTALL_DIR)/dmenu/config.h
	(cd $(INSTALL_DIR)/dmenu && sudo make clean install)

emacs: ## install emacs with doom-emacs and my configs
	git clone https://github.com/Vitalii-Ohol/doom_emacs_config \
			$(INSTALL_DIR)/doom_config \
			|| (cd $(INSTALL_DIR)/doom_config; git pull)
	(cd $(INSTALL_DIR)/doom_config && make all)

vim: ## install vim with my configs
	git clone https://github.com/Vitalii-Ohol/vim_config \
			$(INSTALL_DIR)/vim_config \
			|| (cd $(INSTALL_DIR)/vim_config; git pull)
	(cd $(INSTALL_DIR)/vim_config && make all)

help: ## this help window
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| sort \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

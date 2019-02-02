# DEFINE FIRST THE CURRENT USER NAME
C_USER = $(shell ls -l "$(shell pwd)"| cut -d' ' -f3 | sed -n "2p")
PREFIX = /usr/local
DRIVER_DIR = /opt
USER_DIR = /home/$(C_USER)
CONF_DIR = $(USER_DIR)/.zenvidia
INSTALL_DIR = $(PREFIX)/NVIDIA
BIN_DIR = $(PREFIX)/bin
NVIDIA_BAK = $(PREFIX)/NVIDIA_DRIVERS

.PHONY: install uninstall safeuninstall update

all: install

install: install
	mkdir -p $(INSTALL_DIR) $(DRIVER_DIR) $(CONF_DIR)
	mkdir -p $(PREFIX)/share/{applications,pixmaps}
	install -Dm755 -t $(BIN_DIR)/ zenvidia zen_notify zen_start
	install -Dm644 -t $(INSTALL_DIR)/ *.conf 
	install -Dm644 -t $(INSTALL_DIR)/distro/ distro/*
	install -Dm644 -t $(INSTALL_DIR)/ README.md
	install -Dm644 -t $(INSTALL_DIR)/translations/ translations/*
	install -Dm644 -t $(USER_DIR)/.config/autostart/ desktop_files/zen_notify.desktop
	install -Dm644 -t $(PREFIX)/share/applications/ desktop_files/zenvidia.desktop
	install -Dm644 -t $(PREFIX)/share/pixmaps/ swiss_knife.png
	install -Dm644 -t $(PREFIX)/share/pixmaps/ xkill.png
	install -Dm644 -t /usr/share/polkit-1/actions/ com.github.pkexec.zenvidia.policy
#	sudo -u $(C_USER) cp -Rf ./.git $(CONF_DIR)/
	
uninstall:
	rm -Rf $(INSTALL_DIR) $(DRIVER_DIR) $(CONF_DIR)
	rm -f $(BIN_DIR)/{zenvidia,zen_notify,zen_start}
	rm -f $(PREFIX)/share/applications/zenvidia.desktop
	rm -f /usr/share/polkit-1/actions/com.github.pkexec.zenvidia.policy
	
safeuninstall:
	mkdir $(NVIDIA_BAK)
	cp -Rf $(INSTALL_DIR)/release/ $(NVIDIA_BAK)/
	rm -Rf $(INSTALL_DIR) $(DRIVER_DIR) $(CONF_DIR)
	rm -f $(BIN_DIR)/{zenvidia,zen_notify,zen_start}
	rm -f $(PREFIX)/share/applications/zenvidia.desktop
	rm -f /usr/share/polkit-1/actions/com.github.pkexec.zenvidia.policy
	
update:
	sudo -u $(C_USER) git pull
	install -Dm755 -t $(BIN_DIR)/ zenvidia zen_notify zen_start
	install -Dm644 -t $(INSTALL_DIR)/distro/ distro/*
	install -Dm644 -t $(INSTALL_DIR)/ README.md
	install -Dm644 -t $(INSTALL_DIR)/translations/ translations/*
	install -Dm644 -t $(USER_DIR)/.config/autostart/ desktop_files/zen_notify.desktop
	install -Dm644 -t $(PREFIX)/share/applications/ desktop_files/zenvidia.desktop
	install -Dm644 -t $(PREFIX)/share/pixmaps/ swiss_knife.png
	install -Dm644 -t $(PREFIX)/share/pixmaps/ xkill.png
	install -Dm644 -t /usr/share/polkit-1/actions/ com.github.pkexec.zenvidia.policy
#	cp -Rf ./translations $(INSTALL_DIR)/
#	cp -Rf ./distro $(INSTALL_DIR)/
#	cp -f ./README.md $(INSTALL_DIR)/
#	cp -f ./desktop_files/zenvidia.desktop $(PREFIX)/share/applications/
#	cp -f ./swiss_knife.png $(PREFIX)/share/pixmaps/
#	cp -f ./xkill.png $(PREFIX)/share/pixmaps/
#	sudo -u $(C_USER) cp -Rf ./.git $(CONF_DIR)/
	./update.sh


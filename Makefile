# DEFINE FIRST THE CURRENT USER NAME
# C_USER = $(shell ls -l "$(shell pwd)"| cut -d' ' -f3 | sed -n "2p")
C_USER = $(shell who | cut -d' ' -f1 | sed -n "1p")
PREFIX = /usr/local
USER_DIR = /home/$(C_USER)
CONF_DIR = $(USER_DIR)/.zenvidia
INSTALL_DIR = $(PREFIX)/zenvidia
BIN_DIR = $(PREFIX)/bin
NVIDIA_BAK = $(PREFIX)/NVIDIA_DRIVERS

.PHONY: install uninstall safeuninstall update

all: install

install:
	mkdir -p $(INSTALL_DIR) $(CONF_DIR)
	mkdir -p $(PREFIX)/share/{applications,pixmaps,doc/zenvidia}
	install -Dm755 -t $(BIN_DIR)/ zenvidia zen_notify zen_start
	install -Dm644 -t $(INSTALL_DIR)/ *.conf
	install -Dm644 -t $(INSTALL_DIR)/distro/ distro/*
	install -Dm644 -t $(INSTALL_DIR)/ {README,HELP}.md
	install -Dm644 -t $(INSTALL_DIR)/ OLD-README.md
	install -Dm644 -t $(USER_DIR)/.config/autostart/ desktop_files/zen_notify.desktop
	install -Dm644 -t $(PREFIX)/share/applications/ desktop_files/{zenvidia,zenvidia-unpriviledge}.desktop
	install -Dm644 -t $(PREFIX)/share/pixmaps/ *.png
	install -Dm644 -t $(PREFIX)/share/doc/zenvidia/ docs/*.txt
	install -Dm644 -t /usr/share/polkit-1/actions/ com.github.pkexec.zenvidia.policy
	mkdir -p $(INSTALL_DIR)/{temp,build,log,release,backups,compats}
	git log origin/master -n 1 | egrep -o "v[0-9]..*" > $(CONF_DIR)/zen_version

uninstall:
	rm -Rf $(INSTALL_DIR) $(CONF_DIR)
	rm -f $(BIN_DIR)/{zenvidia,zen_notify,zen_start}
	rm -f $(USER_DIR)/.config/autostart/zen_notify.desktop
	rm -f $(PREFIX)/share/applications/{zenvidia,zenvidia-unpriviledge}.desktop
	rm -f $(PREFIX)/share/pixmaps/{swiss_knife,swiss_knife_green,xkill}.png
	rm -Rf $(PREFIX)/share/doc/zenvidia
	rm -f /usr/share/polkit-1/actions/com.github.pkexec.zenvidia.policy

safeuninstall:
	mkdir -p $(NVIDIA_BAK)
	mv -Rf $(INSTALL_DIR)/release/ $(NVIDIA_BAK)/
	rm -Rf $(INSTALL_DIR) $(CONF_DIR)
	rm -f $(BIN_DIR)/{zenvidia,zen_notify,zen_start}
	rm -f $(USER_DIR)/.config/autostart/zen_notify.desktop
	rm -f $(PREFIX)/share/applications/{zenvidia,zenvidia-unpriviledge}.desktop
	rm -f $(PREFIX)/share/pixmaps/{swiss_knife,swiss_knife_green,xkill}.png
	rm -Rf $(PREFIX)/share/doc/zenvidia
	rm -f /usr/share/polkit-1/actions/com.github.pkexec.zenvidia.policy

update:
	sudo -u $(C_USER) git pull
	install -Dm755 -t $(BIN_DIR)/ zenvidia zen_notify zen_start
	install -Dm644 -t $(INSTALL_DIR)/distro/ distro/*
	install -Dm644 -t $(INSTALL_DIR)/ {README,HELP}.md
	install -Dm644 -t $(USER_DIR)/.config/autostart/ desktop_files/zen_notify.desktop
	install -Dm644 -t $(PREFIX)/share/applications/ desktop_files/{zenvidia,zenvidia-unpriviledge}.desktop
	install -Dm644 -t $(PREFIX)/share/pixmaps/ *.png
	install -Dm644 -t $(PREFIX)/share/doc/zenvidia/ docs/*.txt
	install -Dm644 -t /usr/share/polkit-1/actions/ com.github.pkexec.zenvidia.policy
	git log origin/master -n 1 | egrep -o "v[0-9]..*" > $(CONF_DIR)/zen_version

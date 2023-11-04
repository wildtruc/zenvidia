# DEFINE FIRST THE CURRENT USER NAME
#C_USER = $(shell ls -l "$(shell pwd)"| cut -d' ' -f3 | sed -n "2p")
C_USER = $(shell stat -c %U ../zenvidia)
# CHECK IF USER IS IN SU MODE
S_USER = $(shell whoami)
PREFIX = /usr/local
USER_DIR = /home/$(C_USER)
CONF_DIR = $(USER_DIR)/.zenvidia
INSTALL_DIR = $(PREFIX)/zenvidia
BIN_DIR = $(PREFIX)/bin
NVIDIA_BAK = $(PREFIX)/NVIDIA_DRIVERS

.PHONY: install uninstall safeuninstall update

check_su:
ifneq ($(S_USER),root)
	$(error "ERROR: You can't run this shell as $(S_USER). You must be ROOT"))
endif

all: install

install: check_su
	mkdir -p $(INSTALL_DIR) $(CONF_DIR)
	mkdir -p $(PREFIX)/share/{applications,pixmaps,doc/zenvidia}
	install -Dm755 -t $(BIN_DIR)/ zenvidia zen_notify zen_start zen_task_menu
	install -Dm644 -t $(INSTALL_DIR)/ *.conf
	install -Dm644 -t $(INSTALL_DIR)/distro/ distro/*
	install -Dm644 -t $(INSTALL_DIR)/ {README,HELP}.md
	install -Dm644 -t $(INSTALL_DIR)/ OLD-README.md
	install -Dm644 -t $(USER_DIR)/.config/autostart/ desktop_files/zen_notify.desktop
	install -Dm644 -t $(USER_DIR)/.config/autostart/ desktop_files/nvidia-settings-rc.desktop
	install -Dm644 -t $(PREFIX)/share/applications/ desktop_files/{zenvidia,zenvidia-unpriviledge}.desktop
	install -Dm644 -t $(PREFIX)/share/pixmaps/ pixmaps/*.png
	install -Dm644 -t $(PREFIX)/share/doc/zenvidia/ docs/*.txt
	install -Dm644 -t $(PREFIX)/share/doc/zenvidia/ Changelog.txt
	install -Dm644 -t /usr/share/polkit-1/actions/ com.github.pkexec.zenvidia.policy
	mkdir -p $(INSTALL_DIR)/{temp,build,log,release,backups,compats}
# 	sudo -u "$(C_USER)" git config global --add safe.directory $(shell pwd)
	sudo -u "$(C_USER)" git log origin/master -n 1 | grep -E -o "v[0-9]..*" > $(CONF_DIR)/zen_version

uninstall: check_su
	rm -Rf $(INSTALL_DIR) $(CONF_DIR)
	rm -f $(BIN_DIR)/{zenvidia,zen_notify,zen_start,zen_task_menu}
	rm -f $(USER_DIR)/.config/autostart/{zen_notify,nvidia-settings-rc}.desktop
	rm -f $(PREFIX)/share/applications/{zenvidia,zenvidia-unpriviledge}.desktop
	rm -f $(PREFIX)/share/pixmaps/zen-*.png
	rm -Rf $(PREFIX)/share/doc/zenvidia
	rm -f /usr/share/polkit-1/actions/com.github.pkexec.zenvidia.policy

safeuninstall: check_su
	rm -f $(BIN_DIR)/{zenvidia,zen_notify,zen_start,zen_task_menu}
	rm -f $(USER_DIR)/.config/autostart/{zen_notify,nvidia-settings-rc}.desktop
	rm -f $(PREFIX)/share/applications/{zenvidia,zenvidia-unpriviledge}.desktop
	rm -f $(PREFIX)/share/pixmaps/zen-*.png
	rm -Rf $(PREFIX)/share/doc/zenvidia
	rm -f /usr/share/polkit-1/actions/com.github.pkexec.zenvidia.policy

update: check_su
	sudo -u $(C_USER) git pull
	install -CDm755 -b -t $(BIN_DIR)/ zenvidia zen_notify zen_start zen_task_menu
	install -CDm644 -b -t $(INSTALL_DIR)/distro/ distro/*
	install -CDm644 -b -t $(INSTALL_DIR)/ *.conf
	install -Dm644 -t $(INSTALL_DIR)/ {README,HELP}.md
	install -Dm644 -t $(USER_DIR)/.config/autostart/ desktop_files/{zen_notify,nvidia-settings-rc}.desktop
	install -Dm644 -t $(PREFIX)/share/applications/ desktop_files/{zenvidia,zenvidia-unpriviledge}.desktop
	install -Dm644 -t $(PREFIX)/share/pixmaps/ pixmaps/*.png
	install -Dm644 -t $(PREFIX)/share/doc/zenvidia/ docs/*.txt
	install -Dm644 -t $(PREFIX)/share/doc/zenvidia/ Changelog.txt
	install -Dm644 -t /usr/share/polkit-1/actions/ com.github.pkexec.zenvidia.policy
	echo -e "\nPLEASE, UPDATE ZENVIDIA BASIC CONFIGURATION AS APPROPRIATE IF NEEDED.\n"
# 	sudo -u "$(C_USER)" git config global --add safe.directory $(shell pwd)
	sudo -u "$(C_USER)" git log origin/master -n 1 | grep -E -o "v[0-9]..*" > $(CONF_DIR)/zen_version

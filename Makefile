L_DIR = /usr/local
D_DIR = /opt
INSTALL_DIR = $(L_DIR)/NVIDIA
BIN_DIR = $(L_DIR)/bin
CONF_DIR = $(L_DIR)/etc/zenvidia
DRIVER_DIR = $(D_DIR)
NVIDIA_BAK = $(L_DIR)/NVIDIA_DRIVERS

.PHONY: all install uninstall safeuninstall update

all: install

install:
	mkdir -p $(INSTALL_DIR) $(DRIVER_DIR) $(CONF_DIR)
	cp -Rf ./translations $(INSTALL_DIR)/
	cp -Rf ./distro $(INSTALL_DIR)/
	cp -f ./*.conf $(INSTALL_DIR)/
	cp -f ./zenvidia.sh $(BIN_DIR)/
	cp -f ./zen_notify.sh $(BIN_DIR)/
	cp -f ./desktop_files/zenvidia.desktop $(L_DIR)/share/applications/
	cp -f ./swiss_knife.png $(L_DIR)/share/pixmaps/

uninstall:
	rm -Rf $(INSTALL_DIR) $(DRIVER_DIR) $(CONF_DIR)
	rm -f $(BIN_DIR)/zenvidia.sh
	rm -f $(BIN_DIR)/zen_notify.sh
	rm -f $(_DIR)/share/applications/zenvidia.desktop
	
safeuninstall:
	mkdir $(NVIDIA_BAK)
	cp -Rf $(INSTALL_DIR)/release/ $(NVIDIA_BAK)/
	rm -Rf $(INSTALL_DIR) $(DRIVER_DIR) $(CONF_DIR)
	rm -f $(BIN_DIR)/zenvidia.sh
	rm -f $(BIN_DIR)/zen_notify.sh
	rm -f $(L_DIR)/share/applications/zenvidia.desktop
	
update:
	./update.sh

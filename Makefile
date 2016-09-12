INSTALL_DIR = /usr/local/NVIDIA
BIN_DIR = /usr/local/bin
CONF_DIR = /usr/local/etc/zenvidia
DRIVER_DIR = /usr/local/DRIVERS
NVIDIA_BAK = /usr/local/NVIDIA_DRIVERS

.PHONY: all install uninstall safeuninstall

all: install

install:
	mkdir -p $(INSTALL_DIR) $(DRIVER_DIR) $(CONF_DIR)
	cp -Rf ./translations $(INSTALL_DIR)/
	cp -Rf ./distro $(INSTALL_DIR)/
	cp -f ./*.conf $(INSTALL_DIR)/
	cp -f ./zenvidia.sh $(BIN_DIR)/

uninstall:
	rm -Rf $(INSTALL_DIR) $(DRIVER_DIR) $(CONF_DIR)
	rm -f $(BIN_DIR)/zenvidia.sh
	
safeuninstall:
	mkdir $(NVIDIA_BAK)
	cp -Rf $(INSTALL_DIR)/release/ $(NVIDIA_BAK)/
	rm -Rf $(INSTALL_DIR) $(DRIVER_DIR) $(CONF_DIR)
	rm -f $(BIN_DIR)/zenvidia.sh

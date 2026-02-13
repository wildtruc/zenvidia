#! /bin/bash
set -e -o functrace

# DEFINE FIRST THE CURRENT USER NAME
C_USER=$(stat -c %U -- /run/user/*| grep -v "root")
# CHECK IF USER IS IN SU MODE
S_USER=$(whoami)
PREFIX=/usr/local
USER_DIR=/home/${C_USER}
CONF_DIR=${USER_DIR}/.zenvidia
INSTALL_DIR=${PREFIX}/share/zenvidia
BIN_DIR=${PREFIX}/bin

## terminal fonts colors.
red='\e[1;31m'
yel='\e[0;33m'
grn='\e[0;32m'
blu='\e[0;34m'
cya='\e[0;36m'
pur='\e[0;35m'
nc='\e[0m'


check_su(){
if [ ${S_USER} != "root" ]; then
	echo -e "${red}WARNING: You can't run this shell as ${S_USER}. You must be ROOT${nc}"	; exit ; fi
}
make_install(){
	## pre install
	mkdir -p ${INSTALL_DIR} ${CONF_DIR}/{compats/series,updates,release}
	mkdir -p ${PREFIX}/share/{applications,pixmaps,doc/zenvidia}
	mkdir -p ${INSTALL_DIR}/{temp,build,log,release,backups,compats,locale/locale_dev/locale_po}
	## install system
	install -Dm755 -t ${BIN_DIR}/ zenvidia zen_notify zen_start zen_task_menu zenvidia-modules-reload
	install -Dm644 -t ${INSTALL_DIR}/ *.conf
	install -Dm644 -t ${INSTALL_DIR}/ README.md
	install -Dm644 -t ${INSTALL_DIR}/ OLD-README.md
	install -Dm644 -t ${PREFIX}/share/applications/ desktop_files/{zenvidia,zenvidia-unpriviledge}.desktop
	install -Dm644 -t ${PREFIX}/share/pixmaps/ pixmaps/*.png
	install -Dm644 -t ${PREFIX}/share/doc/zenvidia/ docs/*.txt
	install -Dm644 -t ${PREFIX}/share/doc/zenvidia/ Changelog.txt
	install -Dm644 -t /usr/share/polkit-1/actions/ com.github.pkexec.zenvidia.policy
	install -Dm644 -t ${INSTALL_DIR}/locale_dev locale/{Readme_translation.txt,translation_report_helper.sh,translation.pot}
	install -Dm644 -t ${INSTALL_DIR}/locale_dev/locale_po locale/locale_dev/*
	cp -rf -t ${INSTALL_DIR}/ locale/locale
	# install user
	mkdir -p ${USER_DIR}/.config/autostart ${CONF_DIR}/{compats/series,updates,release,backups}
	install -Dm644 -t ${CONF_DIR}/ basic.conf distro.conf
# 	install -Dm644 -o ${C_USER} -g ${C_USER} -t ${USER_DIR}/.config/autostart/ desktop_files/zen_notify.desktop
# 	install -Dm644 -o ${C_USER} -g ${C_USER} -t ${USER_DIR}/.config/autostart/ desktop_files/nvidia-settings-rc.desktop
# 	install -Dm644 -t ${USER_DIR}/.config/autostart/ desktop_files/zen_notify.desktop
	install -Dm644 -t ${USER_DIR}/.config/autostart/ desktop_files/{zen_notify,nvidia-settings-rc}.desktop
	## post install
	sudo -u "${C_USER}" git log -n1 | grep -E -o "v[0-9]..*" > ${INSTALL_DIR}/zen_version
# 	sudo -u "${C_USER}" git log -n1 | grep -E -o "v[0-9]..*" > ${CONF_DIR}/zen_version
	cp -f ${INSTALL_DIR}/zen_version ${CONF_DIR}/
	chown -R ${C_USER}:${C_USER} ${CONF_DIR} ${USER_DIR}/.config/autostart
	## restart polkit service
	systemctl daemon-reload
	systemctl restart polkit.service
	echo -e "INSTALL DONE."
	# start xtray zenvidia task bar
	echo -e "Please reload your desktop manager for the system tray task bar menu starting."
}
make_uninstall(){
	rm -Rf ${INSTALL_DIR} ${CONF_DIR}
	rm -f ${BIN_DIR}/{zenvidia,zen_notify,zen_start,zen_task_menu,zenvidia-modules-reload}
	rm -f ${USER_DIR}/.config/autostart/{zen_notify,nvidia-settings-rc}.desktop
	rm -f ${PREFIX}/share/applications/{zenvidia,zenvidia-unpriviledge}.desktop
	rm -f ${PREFIX}/share/pixmaps/zen-*.png
	rm -Rf ${PREFIX}/share/doc/zenvidia
	rm -f /usr/share/polkit-1/actions/com.github.pkexec.zenvidia.policy
	echo -e "UNINSTALL DONE."
}
make_safeuninstall(){
	rm -f ${BIN_DIR}/{zenvidia,zen_notify,zen_start,zen_task_menu,zenvidia-modules-reload}
	rm -f ${USER_DIR}/.config/autostart/{zen_notify,nvidia-settings-rc}.desktop
	rm -f ${PREFIX}/share/applications/{zenvidia,zenvidia-unpriviledge}.desktop
	rm -f ${PREFIX}/share/pixmaps/zen-*.png
	rm -Rf ${PREFIX}/share/doc/zenvidia
	rm -f /usr/share/polkit-1/actions/com.github.pkexec.zenvidia.policy
	echo -e "SAFE UNINSTALL DONE."
}
make_udapte(){
	sudo -u ${C_USER} git pull
	## system
	install -CDm755 -b -t ${BIN_DIR}/ zenvidia zen_notify zen_start zen_task_menu zenvidia-modules-reload
	install -CDm644 -b -t ${INSTALL_DIR}/ *.conf
	install -Dm644 -t ${INSTALL_DIR}/ README.md
	install -Dm644 -t ${PREFIX}/share/applications/ desktop_files/{zenvidia,zenvidia-unpriviledge}.desktop
	install -Dm644 -t ${PREFIX}/share/pixmaps/ pixmaps/*.png
	install -Dm644 -t ${PREFIX}/share/doc/zenvidia/ docs/*.txt
	install -Dm644 -t ${PREFIX}/share/doc/zenvidia/ Changelog.txt
	install -Dm644 -t /usr/share/polkit-1/actions/ com.github.pkexec.zenvidia.policy
	install -CDm644 -t ${INSTALL_DIR}/locale_dev locale/{Readme_translation.txt,translation_report_helper.sh,translation.pot}
	install -CDm644 -t ${INSTALL_DIR}/locale_dev/locale_po locale/locale_dev/*
	cp -ruf -t ${INSTALL_DIR}/ locale/locale
	# user
	install -Dm644 -t ${USER_DIR}/.config/autostart/ desktop_files/{zen_notify,nvidia-settings-rc}.desktop
	sudo -u "${C_USER}" git log -n1 | grep -E -o "v[0-9]..*" > ${INSTALL_DIR}/zen_version
# 	sudo -u "${C_USER}" git log -n1 | grep -E -o "v[0-9]..*" > ${CONF_DIR}/zen_version
	cp -f ${INSTALL_DIR}/zen_version ${CONF_DIR}/
	chown -R ${C_USER}:${C_USER} ${CONF_DIR}
	echo -e "UPDATE DONE."
	echo -e "\nPLEASE, CONTROL ZENVIDIA USER CONFIGURATION AFTER FIRST LAUNCH.\n"
	echo -e "(user config is automaically control and update at zenvidia start, a little check could be necessary)"
	echo -e "Please reload your desktop manager for the system tray task bar update."
}
make_help(){
	echo -e ${grn}"Command line: $(basename $0 ) [option]"
	echo -e "Options are:${cya}"
	echo -e "	install		-> Install fresh."
	echo -e " 	uninstall	-> Uninstall and remove all trace."
	echo -e "	safeuninstall	-> Uninstall and keep config and data."
	echo -e "	update		-> Execute git command and update."
	echo -e "	help		-> Display help."
	echo -e "${nc}"
}
check_su
if [ $# -gt 0 ]; then
	while (( $# > 0 )); do
		case ${1} in
			install) make_install ;;
			uninstall) make_uninstall ;;
			safeuninstall) make_safeuninstall ;;
			udapte) make_udapte ;;
			*|help) echo -e "${red}Wrong option${nc}"; make_help ;;
		esac
		shift
	done
else
	make_help
fi

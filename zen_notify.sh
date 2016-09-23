#! /bin/bash

## basics
nvdir=/usr/local/NVIDIA
script_conf=$nvdir/script.conf
locale=$nvdir/translations

################################################
## DEVELOPPEMENT only, DON'T EDIT OR UNCOMMENT'
devel=/home/mike/Developpement/NVIDIA/zenvidia
script_conf=$devel/script.conf.devel
################################################

[ $script_conf ]|| exit 0
. $script_conf
. $basic_conf

if [ ! -s home/$USER/.config/autostart/zen_notify.desktop ]; then
	cp -f $local_src/zenvidia/zen_notify.desktop /home/$USER/.config/autostart/
fi
if [ $locale/$LG\_PACK ]; then
	PACK=$LG\_PACK
	. $locale/$PACK
else
	msg_driver="driver update is out"
	msg_git="a GIT update is out"
fi
nvtmp=/home/$USER/tmp
ARCH=$(uname -p)

driver_ctrl(){
lftp -c "anon; cd ftp://$nvidia_ftp-$ARCH/ ; ls > $nvtmp/drvlist ; cat latest.txt > $nvtmp/last_update"
LAST_DRV=$(cat $nvtmp/last_update | awk '{ print $1 }')
LAST_BETA=$(cat $nvtmp/drvlist | awk '{ print $9 }' | sort -gr | sed -n 1p)
#LAST_BETA='370.29'
if [-s $nvdir/version.txt]; then
	version=$(cat $nvdir/version.txt|sed -n "s/\.//p")
else
	version=$(modinfo -F version nvidia)
fi
for driver in "$LAST_DRV,official" "$LAST_BETA,beta"; do
	drv_short=$(printf "$driver"|cut -d',' -f1 |sed -n "s/\.//p")
	release=$(printf "$driver"|cut -d',' -f2)
	driver=$(printf "$driver"|cut -d',' -f1)
	if [ $drv_short -gt $version ]; then
		zenity --notification --window-icon=swiss_knife --text="Nvidia $driver $release $msg_driver !"
	fi
done
}
source_ctrl(){
[ -d $local_src ]|| exit 0
for local_list in "${local_src_list[@]}"; do
	local_git=$local_src/$local_list
	cd $local_git
	git fetch --dry-run &>$local_src/notif.log
	if [[ $(cat $local_src/notif.log|grep -c "master") -eq 1 ]]; then
		zenity --notification --window-icon=swiss_knife --text="$local_list : $msg_git !"
	fi
done
}
usage_help(){
	printf "# Usage : zen_notif.sh option #\n"
	printf "\t -a : check all.\n"
	printf "\t -z : check nvidia & zenvidia.\n"
	printf "\t -n : check nvidia only.\n"
	printf "\t -h : this help.\n"
}
while [ $# -gt 0 ]
	getopts "a-z-n-h" OPT; do
	case $OPT in
		a) driver_ctrl
		local_src_list=( 'bbswitch' 'Bumblebee' 'primus' 'nvidia-prime-select' 'zenvidia' )
		source_ctrl
		;;
		z) driver_ctrl
		local_src_list=( 'zenvidia' )
		source_ctrl
		;;
		n) driver_ctrl;;
		h) usage_help ;;
	esac
done

#! /bin/bash

## basics vars
nvdir=/usr/local/NVIDIA
local_src=./zenvidia_src
local_dir='.'
local_tmp=/home/$USER/tmp
nvidia_ftp=download.nvidia.com/XFree86/Linux

# control if desktop file and bitmap exist
if [ ! -e /home/$USER/.config/autostart/zen_notify.desktop ]; then
	cp -f $local_dir/zen_notify.desktop /home/$USER/.config/autostart/
	sed -i "s/Exec=.*$/Exec=zen_notify_standalone.sh/" /home/$USER/.config/autostart/zen_notify.desktop
	[ -e $local_dir/swiss_knife.png ]&& cp -f $local_dir/swiss_knife.png /usr/local/share/pixmaps/
	
fi
# define checker messages
msg_driver="driver update is out"
msg_git="a GIT update is out"
# control if tmp dir exist, then create it if not
[ -d $local_tmp ]|| mkdir -p $local_tmp
# define CPU arch
ARCH=$(uname -p)
# check ftp server for update and form data for script messages
lftp -c "anon; cd ftp://$nvidia_ftp-$ARCH/ ; ls > $local_tmp/drvlist ; cat latest.txt > $local_tmp/last_update"
LAST_DRV=$(cat $local_tmp/last_update | awk '{ print $1 }')
LAST_BETA=$(cat $local_tmp/drvlist | awk '{ print $9 }' | sort -gr | sed -n 1p)
# check current nvidia driver version if any
version=$(modinfo -F version nvidia|sed -n "s/\.//p")
[ $version ]|| version=0
# produce the notification message if ftp check give something
for driver in "$LAST_DRV,official" "$LAST_BETA,beta"; do
	drv_short=$(printf "$driver"|cut -d',' -f1 |sed -n "s/\.//p")
	release=$(printf "$driver"|cut -d',' -f2)
	driver=$(printf "$driver"|cut -d',' -f1)
	if [ $drv_short -gt $version ]; then
		zenity --notification --window-icon=swiss_knife --text="Nvidia $driver $release $msg_driver !"
	fi
done
exit 0

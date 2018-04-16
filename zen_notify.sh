#! /bin/bash

#  Zen_notify
#  mar. oct. 11 16:21:02 CEST 2016
#  Copyright  2010-2016  PirateProd
#  <wildtruc@noneltd.net>
#  This program is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Lesser General Public
#  License as published by the Free Software Foundation; either
#  version 2.1 of the License, or (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public
#  License along with main.c;if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor Boston, MA 02110-1301,  USA

## basics
nvdir=/usr/local/NVIDIA
script_conf=$nvdir/script.conf
basic_conf=$nvdir/basic.conf

################################################
## DEVELOPPEMENT only, DON'T EDIT OR UNCOMMENT'
#devel=/home/mike/Developpement/NVIDIA/zenvidia
#script_conf=$devel/script.conf.devel
################################################

[ $script_conf ]|| exit 0
. $script_conf
. $basic_conf

msg_git="GIT update."
[ -d $nvtmp ]|| mkdir -p $nvtmp
nvtmp=/home/$USER/.zenvidia
ARCH=$(uname -p)
drv_temp=$(mktemp --tmpdir zen_notif-XXXX)
[[ -d $nvtmp ]]|| mkdir -p $nvtmp
local_src=$nvtmp/src
if [[ ! -e home/$USER/.config/autostart/zen_notify.desktop ]]; then
	cp -f $local_src/zenvidia/desktop_files/zen_notify.desktop /home/$USER/.config/autostart/
fi

driver_ctrl(){
#lftp -c "anon; cd ftp://$nvidia_ftp-$ARCH/ ; ls > $nvtmp/drvlist ; cat latest.txt > $nvtmp/last_update"
## get all driver list.
wget -q -O $drv_temp https://$nvidia_ftp-$ARCH/
## get latest.txt file.
wget -q -O $nvtmp/last_update https://$nvidia_ftp-$ARCH/latest.txt
#cat $nvtmp/drvlist_0 |  egrep -o "href.*[0-9]+/'"| perl -pe "s/^.*\'(.*)\/\'/\1/p" > $nvtmp/drvlist
cat $drv_temp| sed -En "s/^.*href.*'(.*)\/'>.*$/\1/p" > $nvtmp/drvlist
cat 	$drv_temp| sed -En "s/^.*href.*'(.*)\/'>.*$/\1/p"| tail -n1 > $nvtmp/last_beta
LAST_DRV=$(cat $nvtmp/last_update | awk '{ print $1 }')
#LAST_BETA=$(cat $nvtmp/drvlist | awk '{ print $9 }' | sort -gr | sed -n 1p)
LAST_BETA=$(cat $nvtmp/last_beta)
#LAST_BETA='370.29'

if [ -s $nvdir/version.txt ]; then
	version=$(cat $nvdir/version.txt| sed -En "s|^(.{6}).*$|\1|;s|\.||p")
else
	version=$(modinfo -F version nvidia| sed -En "s|^(.{6}).*$|\1|;s|\.||p")
fi
offi_short=$(printf "$LAST_DRV"|  sed -En "s|^(.{6}).*$|\1|;s|\.||p")
beta_short=$(printf "$LAST_BETA"| sed -En "s|^(.{6}).*$|\1|;s|\.||p")
[[ $beta_short ]]|| beta_short=0
if [ $beta_short -eq $offi_short ]; then
	DRV_LIST=( "$LAST_DRV,official and beta drivers" )
else
	DRV_LIST=( "$LAST_DRV,official driver" "$LAST_BETA,beta driver" )
fi
[ $version ]|| version=0
if [ ${#DRV_LIST[@]} -gt 0 ]; then
	ifs=$IFS
	IFS=$(echo -en "\n\b")
	for driver in ${DRV_LIST[@]}; do
		drv_short=$(printf "$driver"|cut -d',' -f1 |sed -n "s/\.//p")
		release=$(printf "$driver"|cut -d',' -f2)
		driver=$(printf "$driver"|cut -d',' -f1)
		_driver_notif+=( "$driver $release update.\n" )
	done
	if [ $drv_short -gt $version ]; then
		zenity --notification --window-icon=swiss_knife --text="Nvidia ${_driver_notif[@]}"
	fi
	IFS=$ifs
fi
}
source_ctrl(){
#[[ -d $local_src ]]|| exit 0
for local_git in "${local_git_list[@]}"; do
#	local_git_list=/home/$def_user/tmp/$local_list
	if [[ -d $local_git ]]; then	
		cd $local_git
		git fetch --dry-run &>$nvtmp/git.log	
		if [[ $(cat $nvtmp/git.log|grep -c "master") -eq 1 ]]; then
			local_git_name=$(printf "$local_git"| sed -n "s/^.*\///g;p")
			zenity --notification --window-icon=swiss_knife --text="$local_git_name $msg_git"
		fi
	else
		exit 0
	fi
done
}
usage_help(){
	printf "# Usage : zen_notify option,where option is:\n"
#	printf "\t -a : check all.\n"
	printf "\t -z : check nvidia & zenvidia.\n"
	printf "\t -n : check nvidia only.\n"
	printf "\t -h : this help.\n"
}
while [ $# -gt 0 ]
#	getopts "a-z-n-h" OPT; do
	getopts "z-n-h" OPT; do
	case $OPT in
#		a) driver_ctrl
#		local_src_list=( 'bbswitch' 'Bumblebee' 'primus' 'nvidia-prime-select' 'zenvidia' )
#		source_ctrl
#		;;
		z) driver_ctrl
		local_git_list=( "$HOME/.zenvidia/src/.git" )
		source_ctrl
		;;
		n) driver_ctrl;;
		h) usage_help ;;
	esac
done

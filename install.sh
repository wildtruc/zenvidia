#! /bin/bash

### 	WARNING THIS SCRIPT IS FOR SUPERUSER ONLY###

#  zenvidia v0.9
#  Sat Feb  6 16:58:20 2010
#  Copyright  2010  PirateProd
#  <mike@noneltd.net>
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

[ -e ./script.conf ]|| exit 0
. ./script.conf

end='</span>'
v='<span color=\"#005400\">'		#green
y='<span color=\"#2700FF\">'		#blue
j='<span color=\"#FF6800\">'		#orange
jB='<span color=\"#FF3300\" weight=\"bold\">'
#big red orange title
eN='<span color=\"#FF3300\" weight=\"bold\" font=\"20\">'
#Bold
vB='<span color=\"#005400\" weight=\"bold\">'

user_id(){
	if [[ $(whoami) != "root" ]] ; then
#		pass=$(zenity --password --text="$v\Enter SuperUser password$end")
		if [ -f /proc/version ] ; then
			distro_list=$(echo -e "ubuntu\ndebian\nfedora\nredhat\nmandriva")
			for distro in $distro_list ; do
				proc_version=$(cat /proc/version | grep $distro)
				if [[ $proc_version != '' ]] ; then
					proc_version=$distro
					if [[ $(echo $proc_version | grep "ubuntu\|debian") != '' ]] ; then
						SU="sudo"
					else
						SU="su -c"
					fi
				fi
			done
			zenity --password --text="$v\Enter SuperUser password$end"| $SU "sh $0"
			exit 0
		else
			zenity --width=450 --error \
			--text="$v SORRY, CAN'T IDENTIFY DISTRO.\nPROMPT DIRECTLY AS SU\nAND TYPE $J sudo $(basename $0)$end$v FOR DEBIAN LIKE,\nOR$j su -c $(basename $0)$end$v FOR OTHER DISTRO.$end"
			exit 0
		fi
	fi
}
menu(){
#zenity --width=450 --title="Zenvidia" --question \
menu_box=$(zenity --height=460 --title="Zenvidia" --list --radiolist --hide-header \
	--ok-label="Continue" --cancel-label="Quit" \
	--text="$eN\Zenvidia Installer$end\n
$vB\You're going to install Zenvidia and Bashvidia on your system$end
$v\nInstaller will ask you some question:
\t- Default system user name.
\t- Where to install Zenvidia files.
\t- Where to install drivers files.
\t- Where to install Nvidia binary files.
\nYou can leave set to default or change them as appropriate.
$jB\Don't edit the script.conf file before install, it is useless.$end
\nClick$end $j\Continue$end$v button to install.$end" \
	--column "1" --column "2" --column "3" --separator=";" --hide-column=2 \
	true 1 "Install" false 2 "Edit config" false 3 "About scripts") 
if [ $? = 1 ]; then exit 0; fi
	case $menu_box in
		"1") fn_install ;;
		"2") fn_edit_conf ;;
		"3") fn_readme ;;
	esac
}
fn_install(){
for pre_entry in {$USER,$nvdir,$croot,$install_dir,$LG}; do
	if [ $pre_entry = $USER ]; then ENTRY="Default User"
	elif [ $pre_entry = $nvdir ]; then ENTRY="Zenvidia directory"
	elif [ $pre_entry = $croot ]; then ENTRY="Drivers directory"
	elif [ $pre_entry = $install_dir ]; then ENTRY="Nvidia binaries directory"
	elif [ $pre_entry = $LG ]; then ENTRY="Language pack (FR,EN)";fi
	conf+=$(zenity --width=300 --title="Zenvidia" --entry \
	--entry-text="$pre_entry" --text="$ENTRY"),
	if [ $? = 1 ]; then exit 0; fi
done

conf=$(echo "$conf"|sed -n 's/\//\\\//g;s/,$//p')

default_user=$(printf "$conf"|cut -d"," -f1)
default_nvdir=$(printf "$conf"|cut -d"," -f2)
default_croot=$(printf "$conf"|cut -d"," -f3)
default_install_dir=$(printf "$conf"|cut -d"," -f4)
default_LG=$(printf "$conf"|cut -d"," -f5)

sed -ni "s/def_user=\(.*\)/def_user=$default_user/i;p" ./script.conf
sed -ni "s/nvdir=\(.*\)/nvdir=$default_nvdir/i;p" ./script.conf
sed -ni "s/croot=\(.*\)/croot=$default_croot/i;p" ./script.conf
sed -ni "s/install_dir=\(.*\)/install_dir=$default_install_dir/i;p" ./script.conf
sed -ni "s/LG=\(.*\)/LG=$default_LG/i;p" ./script.conf

if [[ $(cat ./script.conf|grep "def_user=$default_user") != '' ]]; then
	. ./script.conf
fi

for binary in {"bashvidia.sh","zenvidia.sh",nvidia-installer}; do
#	echo "copy $binary to $install_dir/bin/"
	cp -f $binary $install_dir/bin/
done
mkdir -p $nvdir/locale $croot
for files in {"script.conf",FR_PACK,EN_PACK,README.md}; do
#	echo "copy $files to $nvdir"
	if [ $(echo "$files"| grep "PACK") != '' ]; then
		cp -f $files $nvdir/locale/
	fi
	cp -f $files $nvdir/ 
done
}
# control script conf
fn_edit_conf(){
	edit_script=$(zenity --width=500 --height=400 --title="Zenvidia" --text-info \
	--editable --text="$v\Edit script config file$end" --filename="$nvdir/script.conf" \
	--checkbox="Confirm to overwrite" )
	if [[ $(printf "$edit_script"| sed -n '1p') != '' ]]; then
		printf "$edit_script" > $script_conf
	fi
	menu
}
fn_readme(){
	zenity --width=500 --height=400 --title="Zenvidia" --text-info \
	--text="$v\About Zenvidia/Bashvidia$end" --filename="./README.md"
	menu
}
user_id; menu
exit 0

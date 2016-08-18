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

# defaults
SHELL=/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin

# export PATH=${PATH}:XX
# nvidia_ftp=download.nvidia.com/XFree86/Linux
## special dev only, DON'T EDIT OR UNCOMMENT'
devel="/home/mike/Developpement/NVIDIA/zenvidia"
EXEC=$devel
script_conf=$devel/script.conf.devel

cd /
### VARS
## Master Vars.
install_dir="/usr/local"
nvdir="$install_dir/NVIDIA"
#script_conf=$nvdir/script.conf
predifined_dir="$install_dir/DRIVERS"
croot="$install_dir/DRIVERS"
locale="$nvdir/locale"							# language packs
nvtar="$nvdir/tgz"								# archies directory
nvtmp="$nvdir/temp"								# extract temp directory
buildtmp="$nvdir/build"							# build temp directory
nvlog="$nvdir/log"								# logs directory
nvdl="$nvdir/release"							# downlaod driver backups directory
nvupdate="$nvdir/update"						# update temp directory
logfile="--log-file-name=$nvlog/install.log"	# nvidia-installer options
temp="--tmpdir=$buildtmp"						# nvidia-installer option: install temp dir
dltemp="--tmpdir=$nvtmp"						# nvidia-installer option: update temp dir
kernel="--kernel-install-path"
help_pages="$install_dir/share/doc/NVIDIA_GLX-1.0"
docs="--documentation-prefix=$install_dir"
profile="--application-profile-path=$install_dir/share/nvidia"
#kernel_src="--kernel-source-path"
dl_delay=2

# custom configuration file
. $script_conf

end='</span>'
v='<span color=\"#005400\">'		#green
y='<span color=\"#2700FF\">'		#blue
j='<span color=\"#FF6800\">'		#orange
cBl='\e[40m\e[1m\e[37m'
#big red orange title
eN='<span color=\"#FF3300\" weight=\"bold\" font=\"20\">'
#Bold
vB='<span color=\"#005400\" weight=\"bold\">'


### FUNCTIONS
ID(){
## card id
#pci_bus=$($d_lspci | grep NVIDIA | awk '{print $1}'|sed -n "s/[[:punct:]]/:/g;p")
#pci=$($d_lspci -nn | grep NVIDIA | awk '{ print $1 }')
#device=$($d_lspci -n | grep "$pci" | grep NVIVIA | cut -d ':' -f 4 | awk '{ print $1 }')
#device=$($d_lspci -nn | grep NVIDIA | sed -n 's/^.*\([[:digit:]]\|[[:alpha:]]\)://;s/].*$//p')
## vendor GeForce,Quadro,NVS,Tesla,GRID
#for pci_card in {GeForce,Quadro,NVS,Tesla,GRID}; do
#	detected=$(lspci -nn | grep NVIDIA | sed -n "/$pci_card/p")
#	if [[ "$detected" != '' ]]; then
#		if [[ $(printf "$detected"| grep "\[$pci_card") != '' ]]; then
#			device_name=$(printf "$detected" | sed -n "s/^.*\[$pci_card/$pci_card/;s/\] .*$//p")
#		else
#			device_name=$(printf "$detected" | sed -n "s/^.*$pci_card/$pci_card/;s/\ \[.*$//p")
#		fi
#		pci_0=$(printf "$detected"| awk '{print $1}')
#		if [ $($d_lspci|grep -c VGA) -gt 1 ]; then
#			pci_1=$($d_lspci|grep VGA|grep -v "$pci_0"|awk '{print $1}')
#		fi
#	fi
#done
	i=0
	unset pci_n
	for vnd_list in {10de,8086,1022}; do
		if [[ $($d_lspci -nn|grep VGA|grep -o "$vnd_list:") != '' ]]; then
			if [ $($d_lspci -nn|grep VGA|grep -c "$vnd_list:") = 1 ]; then
				vga_list=$vnd_list
			else
				vga_list=$($d_lspci -nn|grep VGA|grep "$vnd_list"|awk '{print $1}')
			fi
			for pci_list in $vga_list; do
				pci_bus=$($d_lspci -nn|grep VGA|grep "$pci_list"|awk '{print $1}')
				pci_id=$($d_lspci -n|grep "$pci_bus"|sed -n 's/^.*:.*://;s/ .*$//p')
				vnd_nm=$(cat /usr/share/hwdata/pci.ids | sed -n 's/\t/*/g;s/  /#/p'| \
						grep "$vnd_list"|grep -v '*'| sed -n 's/^.*#//p')
				vnd_id=$vnd_list
				detect=$($d_lspci|grep "$pci_bus")
				if [[ $(printf "$detect"| grep -o "GeForce\|Quadro\|NVS\|Tesla\|GRID") != '' ]]; then
					for pci_card in {GeForce,Quadro,NVS,Tesla,GRID}; do
						detected=$($d_lspci|grep "$pci_bus"|grep "$pci_card")
						if [[ "$detected" != '' ]]; then
							dev_nm=$(printf "$detect"|sed -n "s/^.*$pci_card/$pci_card/;s/\( (\|] (\).*$//p")
						fi
					done
				else
#					if [ $vnd_list = 8086 ]; then
#						dev_nm=$(printf "Intel Graphic")
#					else
						dev_nm=$(printf "Default Graphic")
#					fi
				fi
				if [[ $pci_bus != '' ]]; then
				# list order : 0>nb, 1>pci slot, 2>pci id, 3>vendor, 4>device_name
					pci_n+=("$i","$pci_bus","$pci_id","$vnd_id","$vnd_nm","$dev_nm")
					((i++))
				fi
			done
		fi
	done
	ifs=$IFS
	IFS="
	
"
	pci_dev="${pci_n[*]}"
	pci_dev_nb=$(printf "$pci_dev"|cut -d, -f1)
	IFS=$ifs
	unset {nm,dev,slot,slot_id,vnd,vnd_id}
	for c in $pci_dev_nb; do
		var="${pci_n[$c]}"
		nm+=("$(printf "$var"|cut -d, -f1)")
		dev+=("$(printf "$var"|cut -d, -f6)")
		slot+=("$(printf "$var"|cut -d, -f2)")
		slot_id+=("$(printf "$var"|cut -d, -f3)")
		vnd+=("$(printf "$var"|cut -d, -f5)")
		vnd_id+=("$(printf "$var"|cut -d, -f4)")
	done
#device_name=$($d_lspci -nn | grep NVIDIA | sed -n 's/^.*\[G/G/;s/\].*$//p')
#if [[ $device_name != '' ]]; then
#	vendor=$device_name
#	board=$device_name
#else
#	vendor=$($d_lspci -nn | grep NVIDIA | sed -n 's/^.*: //;s/ \[.*$//p')
#	board=$($d_lspci -nn | grep NVIDIA | grep -v "$vendor")
#fi
user=$(whoami)
}
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
#			zenity --password --text="$v\Enter SuperUser password$end"| $SU /$EXEC$0
			zenity --password --text="$v\Enter SuperUser password$end"| $SU $0
#			$SU $EXEC$0|zenity --password --text="$v\Enter SuperUser password$end"
#			SU_pass=$(zenity --password --text="$v\Enter SuperUser password$end")
#			$SU $EXEC$0 | echo "$SU_pass"			
#			zenity --password --text="$v\Enter SuperUser password$end" | sudo $locale$0
			exit 0
		else
			zenity --width=450 --error --text="$v SORRY, CAN'T IDENTIFY DISTRO.\nPROMPT DIRECTLY AS SU\nAND TYPE $J sudo $(basename $0)$end$v FOR DEBIAN LIKE,\nOR$j su -c $(basename $0)$end$v FOR OTHER DISTRO.$end"
			exit 0
		fi
	fi
}

# elf types
libclass(){
	if [[ $(uname -p |grep -o "64") != 64 ]] ; then
		ELF_TYPE=""
	else
		ELF_TYPE="64"
	fi
}
## system arch
arch(){
#ARCH=`uname -a | awk '{ print $12 }'`
ARCH=$(uname -p)
if [ $ARCH != "i686\|i586\|i386\|x86" ] ; then
	RUN_PCK="pkg2"
else
	ARCH="x86"
	RUN_PCK="pkg1"
fi
}
## system distro --> need progress
# FOR UBUNTU CLASS
# FOR MAGEIA CLASS
# FOR GENTO CLASS TODO
# FOR ARCH CLASS TODO
distro(){
if [ -f /proc/version ] ; then
#	d_version=$(cat /proc/version)
#	cat /proc/version | grep ubuntu > /dev/null
#	if [[ $? -eq 0 ]]; then
	if [[ $(cat /proc/version | grep "[Dd]ebian\|[Uu]buntu\|[Mm]int") ]]&&[ $? = 0 ]; then
		DISTRO="UBUNTU/DEBIAN"
		dist_type=0
		PKG_INSTALLER="apt-get"
		d_version=$( uname -r | cut -d '-' -f 1 )
		DEP="lftp gcc dkms xterm"
		kernel_hd="kernel-headers-$d_version"
		X="Xorg"
		d_lspci=/usr/bin/lspci
		d_modinfo=/sbin/modinfo
		pkg_cmd="install"
		pkg_opts="-y "
		lib_X=/usr/lib/x86_64-linux-gnu/libX11.so.6
		ex_lib=x86_64-linux-gnu/
		if [[ $ELF_TYPE == 64 ]]; then
#			ELF_32=32
#			ELF_64=""
			ELF_32=/i3686-linux-gnu
			ELF_64=/x86_64-linux-gnu
			master=lib
		else
			ELF_32=""
			ELF_64=""
			master=lib
		fi
		kernel_src=/usr/src/linux-headers-$(uname -r)
	fi
#	﻿/usr/lib/x86_64-linux-gnu/libGL.so.1 -> libGL.so.352.30
#	/usr/lib/x86_64-linux-gnu/libGLESv1_CM.so.1 -> libGLESv1_CM.so.352.30
#	/usr/lib/x86_64-linux-gnu/libGLESv2.so.2 -> libGLESv2.so.352.30
	
#	cat /proc/version | grep mandriva > /dev/null
#	if [[ $? -eq 0 ]]; then
	if [[ $(cat /proc/version | grep "[Mn]andriva\|[Mn]ageia") ]]&&[ $? = 0 ]; then
		DISTRO="MANDRIVA/MAGEIA"
		dist_type=1
		PKG_INSTALLER="urpmi"
		desk=$( uname -r | cut -d '-' -f 2 )
		kernel=$( uname -r | cut -d '-' -f 1 )
		d_version=$( uname -r | cut -d '-' -f 3 )
		DEP="lftp gcc dkms xterm"
		kernel_hd="kernel-$desk-devel-$kernel-$d_version"
		X="X"
		d_lspci=/usr/sbin/lspci
		d_modinfo=/usr/sbin/modinfo
		SUd="su"
		pkg_cmd=""
		pkg_opts=""
		# default distro libs directories
		if [[ $ELF_TYPE == 64 ]]; then
			ELF_32=""
			ELF_64=64
			master=lib
		else
			ELF_32=""
			ELF_64=""
			master=lib
		fi
		kernel_src=/usr/src/linux-$(uname -r)
	fi
#	cat /proc/version | grep fedora > /dev/null
	if [[ $(cat /proc/version | grep "[Ff]edora\|red hat\|Red Hat") ]]&&[ $? = 0 ]; then
		DISTRO="FEDORA/RED HAT"
		dist_type=2
		FLAVOUR=$(cat /etc/redhat-release | awk '{print $1}')
		PKG_INSTALLER="yum"
		desk=$( uname -r | cut -d '-' -f 2 )
		kernel=$( uname -r | cut -d '-' -f 1 )
		d_version=$( uname -r | cut -d '-' -f 3 )
		DEP="lftp gcc dkms"
		kernel_hd="kernel-devel"
		X="X"
		d_lspci=/usr/sbin/lspci
		d_modinfo=/usr/sbin/modinfo
		SUd="su"
		pkg_cmd="install"
		pkg_opts="-y "
		ex_lib=""
		# default distro libs directories
		if [[ $ELF_TYPE == 64 ]]; then
			ELF_32=""
			ELF_64=64
			master=lib
		else
			ELF_32=""
			ELF_64=""
			master=lib
		fi
		## compiler options
		alt=/kernels
		kernel_src=/usr/src/kernels/$(uname -r)
#		SElinux="--force-selinux=yes"
		SElinux=""
		quiet="-q"
		# UEFI capable?
		[[ $(dmesg| grep -o "EFI"| sed -n '1p') ]] && bios="efi" || bios="bios"
		# UEFI enabled ?
		[ -d /sys/firmware/efi ] && bios_efi=1 || bios_efi=0
		if [ $bios_efi = 1 ]; then
#		if [ -e /boot/efi/EFI/$(printf "$DISTRO"|sed -n "s/.*/\L&/p")/grub.cfg ]; then
			if [ ! -e $kernel_src/public_key.x509 ] ; then
			efi_warnings
			
			nv_gen_keys
			quiet=""
#			SIGN_S="--module-signing-script=$kernel_src/scripts/sign-file"
			SIGN_K="--module-signing-secret-key=$kernel_src/private_key.priv"
			SIGN_X="--module-signing-public-key=$kernel_src/public_key.x509"
			fi
		fi
		
		
	fi
else
	echo -e "\f$r $msg101 " ###
fi
}
efi_warnings(){
	zenity --width=450 --title="Zenvidia" --question \
	--text="$vB\THE SYSTEM IS BOOTING OVER UEFI FILE SYSTEM$end
$v\A PUBLIC KEY IS NEEDED TO COMPIL THE NVIDIA DRIVER,
THEN RECORDED IN THE UEFI DATABASE.\n
BEFORE ANY PROCESS TO START, SCRIPT NEED TO CREATE THAT KEY.$end
$vB\YOU SHALL REBOOT THE SYSTEM AFTER KEY GEN PROCESS$end"
}
# dependencies control
dep_control(){
	unset deplist
	[ -x /usr/bin/lftp ]|| deplist+=("lftp")
	[ -x /usr/bin/xterm ]|| deplist+=("xterm")
	[ -x /usr/bin/make ]|| deplist+=("gcc")
	[ -x /usr/sbin/dkms ]|| deplist+=("dkms")
	[ -d $kernel_src ]|| deplist+=("$kernel_hd")
	if [[ $(echo "${deplist[*]}") != '' ]] ; then
		zenity --question --text="$v Required dependencies are not met.\n Will you install them now ?$end" --ok-label="Install"
		if [ $? = 0 ]; then
			( $PKG_INSTALLER $pkg_opts$pkg_cmd ${deplist[*]} #$PKG 
			) | zenity --progress --pulsate --auto-close --text="Installing missing dependencies..."
		else
			exit 0
		fi
	fi
}

driver_loaded(){
	if [ ! -x $install_dir/bin/optirun ]; then
		if [[ $(/sbin/lsmod | grep "nvidia") != '' ]]; then
			pilote_msg="$j$msg120$end\n"
			if [[ $(/sbin/lsmod | grep -w nvidia | awk '{print $3}' | sed -n '1p') -gt 0 ]]; then
				pilote_msg="$msg121"
				if [ -e /tmp/.X0-lock ]; then
					pilote_msg="$msg121a\n"
				else
					pilote_msg="$msg121b\n"
					modprobe -r nvidia
					if [[ ! $(/sbin/lsmod | grep "nvidia") != '' ]]; then
						pilote_msg="$msg124\n"
					else
						pilote_msg="$msg125\n"
						exit 0
					fi
				fi
			else
				pilote_msg="$msg122\n"
			fi
		else
			pilote_msg="\f$msg123\n"
		fi
	else
			pilote_msg="$v$msg122$end\n"
	fi
}
connection_control(){
	cnx=$(ping -c2 nvidia.com)
	cnx=$?
	(	[[ $(ping -c2 nvidia.com) ]]|| (zenity --width=300 --error --text="$v$msg106$end")
	) | zenity --width=450 --title="Zenvidia" --progress --pulsate --auto-close \
	--text="$v$msg205...$end" 
	if [ $cnx = 0 ]; then cnx_msg="$ansOK"
	else cnx_msg=$ansNA
	fi
}

## gcc compatibility control
compil_vars(){
	GCC=$(gcc --version | grep "gcc" | sed -n "s/^.*) //p"| awk '{print $1}')
	NV_bin_ver=$(nvidia-installer -v | grep "nvidia-installer"|awk '{print $3}')
	kernel_ver=$(uname -r)
}
# define installed driver version, if any
version_id(){
	if [ -d /lib/modules/$(uname -r) ]; then
		mod_version=$($d_modinfo -F version nvidia)
		if [[ $mod_version != '' ]]; then
			if [[ -s /lib/modules/$(uname -r)/extra/nvidia.ko ]]; then
				version=$mod_version
			fi
		else
			if [[ $(cat $nvdir/version.txt) != '' ]]; then
			version=$(cat $nvdir/version.txt)
			else
				version="undefined"
			fi			
		fi
	fi
}

nv_gen_keys(){
	# make keys config
	append_conf="[ req ]
default_bits = 4096
distinguished_name = req_distinguished_name
prompt = no
string_mask = utf8only
x509_extensions = myexts

[ req_distinguished_name ]
O = $(uname -n).local
CN = $(uname -n).local signing key
emailAddress = root@$(uname -n).local

[ myexts ]
basicConstraints=critical,CA:FALSE
keyUsage=digitalSignature
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid"
	printf "$append_conf\n" > $nvdir/nv_ssl.conf
	# create keys
	/usr/bin/openssl req -x509 -new -nodes -utf8 -sha256 -days 36500 -batch -config $nvdir/nv_ssl.conf -outform DER -out $nvdir/public_key.der -out $nvdir/public_key.x509 -keyout $nvdir/private_key.priv
	if [ -e $nvdir/public_key.der ]; then
#		rm -f $nvdir/nv_ssl.conf
		# secure them
		chmod 600 $nvdir/public_key.der $nvdir/public_key.x509 $nvdir/private_key.priv
		# enroll keys in DER for UEFI
		mokutil --import $nvdir/public_key.der
		mv -f -t $kernel_src $nvdir/public_key.x509 $nvdir/private_key.priv
	fi
}

## VIRTUALIZER BUILDING PART
optimus_src_ctrl(){
#	() | zenity --width=450 --title="Zenvidia" --progress --pulsate --auto-close \
	# Full optimus control. Update or installing it if necessary
	optimus_dependencies_ctrl 
	if [ -x $install_dir/bin/optirun ]; then
		operande="$m_02_16"
		(	c=33
			for git_src in "bbswitch" "Bumblebee" "primus"; do
				cd $optimus_src/$git_src
				if [[ "$git_src" == "bbswitch" ]]; then git_build=bb_build
				elif [[ "$git_src" == "Bumblebee" ]]; then git_build=bumble_build
				elif [[ "$git_src" == "primus" ]]; then git_build=primus_build
				fi
				echo "# GIT : $m_02_18 $git_src..." ; sleep 1
				if [[ $(git pull | grep -o "up-to-date") != '' ]]; then
					echo "# GIT : $(printf "$git_src"|sed -n 's/[[:alpha:]]/\U&/p') $m_02_19"; sleep 1
				else
					echo "# GIT : $m_02_20 $git_src..."
					make clean
					git pull ; ${git_build}
#					echo "$[ 100/$c ]"
#					c=$[ $c-1 ]
					sleep 1
				fi
				
				echo "$c"; c=$[ $c+33 ]; sleep 1
			done
			echo "100"; sleep 1
		) | zenity --width=450 --title="Zenvidia (updating)" --progress --percentage=0 \
		--auto-close --text="$y\GIT$end $v: $m_02_17.$end"
	else
		build_all
	fi
}
optimus_dependencies_ctrl(){
	# optimus compiling dependecies check/install.
	unset pkg_list
	[ -x /usr/bin/git ]|| pkg_list+=("git")
	[ -e /usr/bin/autoconf ]|| pkg_list+=("autoconf")
	[ -e /usr/include/glib-2*/glib.h ]|| pkg_list+=("glib2-devel")
	[ -e /usr/include/gnu/stubs-32.h ]|| pkg_list+=("glibc-devel.i686")
	[ -e /usr/include/bsd/bsd.h ]|| pkg_list+=("libbsd-devel")
	[ -e /usr/include/X11/X.h ]|| pkg_list+=("libX11-devel libbsd-devel")
	[ -e /usr/sbin/dkms ]|| pkg_list+=("dkms")
	(	sleep 2
		if [[ ${pkg_list[@]} != '' ]]; then
			echo "# $m_02_22..."
			$PKG_INSTALLER $pkg_opts$pkg_cmd ${pkg_list[@]}
			echo "# $m_02_23."; sleep 2
		else
			echo "# $m_02_23..."; sleep 2
		fi
		echo "# $m_02_24."; sleep 2
	) | zenity --width=450 --title="Zenvidia" --progress --pulsate --auto-close \
	--text="$y\Optimus :$end$v $m_02_21.$end"
}
build_all(){
	# compile/recompile all missing/present optimus elements
	if [ ! -x $install_dir/bin/optirun ]; then
	mkdir -p $optimus_src
	cd $optimus_src
	(	operande="Building"
		echo "# GIT : $m_02_29..."; sleep 1
		/usr/bin/git clone $bbswitch_git
		bb_build
		echo "$[ 100/3 ]"; sleep 1
		/usr/bin/git clone $bumblebee_git
		bumble_build
		echo "$[ 100/2 ]"; sleep 1
		/usr/bin/git clone $primus_git
		primus_build
		echo "100"
		echo "# GIT : $m_02_30."; sleep 1
		) | zenity --width=450 --title="Zenvidia ($operande)" --progress --precentage=0 \
		--auto-close --text="$y\GIT :$end$v $m_02_25...$end"
	else
		zenity --width=450 --title="Zenvidia ($operande)" --question --title="Zenvidia" \
		--text="$vm_02_26$end \n>> $j$m_02_27.$end" \
		--ok-label="$m_02_28" --cancel-label="$MM"
		if [ $? = 0 ]; then optimus_src_ctrl
		else base_menu
		fi
	fi
}
bb_build(){
	if [ -d $optimus_src/bbswitch ]; then
		cd $optimus_src/bbswitch
		( echo "# GIT : $operande bbswitch driver..."
		sed -i "s/depmod/\/usr\/sbin\/depmod/" Makefile
		sed -i "s/= dkms/= \/usr\/sbin\/dkms/" Makefile.dkms
		sleep 1
		/usr/bin/make; /usr/bin/make install; sleep 1
		/usr/bin/make -f Makefile.dkms; /usr/bin/make install
		echo "# GIT : $operande bbswitch, done."; sleep 1
		) | zenity --width=450 --title="Zenvidia" --progress --pulsate --auto-close
	fi
	cd $nvdir
}
bumble_build(){
	if [ -d $optimus_src/Bumblebee ]; then
		cd $optimus_src/Bumblebee
		( echo "# GIT : $operande bumblebee daemon..."
		if [ ! -x $optimus_src/Bumblebee/configure ]; then
			/usr/bin/autoreconf -fi
		fi
		[[ $( $d_modinfo -F version nvidia ) == $version ]]|| \
		version=$( $d_modinfo -F version nvidia )
		nvroot="nvidia"
		[[ $(printf "$xorg_dir") != "" ]]|| xorg_dir=$croot/$nvroot/xorg
		./configure --prefix=$tool_dir CONF_DRIVER=nvidia \
		CONF_DRIVER_MODULE_NVIDIA=nvidia \
		CONF_LDPATH_NVIDIA=$croot/$nvroot/$master$ELF_64:$croot/$nvroot/$master$ELF_32 \
		CONF_MODPATH_NVIDIA=$xorg_dir/modules,/usr/lib$ELF_TYPE/xorg/modules  
		/usr/bin/make 
		/usr/bin/make install
		## FIXME : make nvidia conf links ##
		## FIXME : bumblebee conf link broken at recompil ##
		
		echo "# GIT : $operande bumblebee, done."; sleep 1
		) | zenity --width=450 --title="Zenvidia" --progress --pulsate --auto-close
	fi
	if [ ! -e /usr/lib/systemd/system/bumblebeed.service ]; then
		echo "# GIT : Optimus : Copy bumblebee.service in systemd path."; sleep 1
		cp -f ./scripts/systemd/bumblebeed.* /usr/lib/systemd/system/
	fi
	if [[ $(systemctl status bumblebeed.service | grep -o "inactive") != '' ]]; then
		echo "# Optimus : Enable bumblebee.service at boot start."; sleep 1
		if [[ $(cat /proc/version | grep -o "[Dd]ebian|(Rr)ed [Hh]at") != '' ]]; then
			/usr/bin/systemctl enable bumblebeed.service
			/usr/bin/systemctl start bumblebeed.service
		else
			/usr/bin/service enable bumblebeed
			/usr/bin/service start bumblebeed
		fi
	fi
	if [[ $(cat /proc/version | grep -o "[Dd]ebian|(Rr)ed [Hh]at") != '' ]]; then
		/usr/bin/systemctl restart bumblebeed.service
	else
		/usr/bin/service restart bumblebeed
	fi
	cd $nvdir
}
primus_build(){
	if [ -d $optimus_src/primus ]; then
		if [ $dist_type = 2 ]; then
			[ -h /usr/$master$ELF_32/libX11.so ]|| \
			( cd /usr/$master$ELF_32; ln -sf ./libX11.so.6 ./libX11.so )
		fi
		cd $optimus_src/primus
		rm -rf lib/ lib64/
		( echo "# GIT : $operande primus libraries..."; sleep 1
		# patch primus makefile
		sed -i "s/LIBDIR   ?= lib/LIBDIR   ?=$master$ELF_64/" Makefile
		sed -i "s/PRIMUS_SYNC        ?= 0/PRIMUS_SYNC        ?= 1/" Makefile
		sed -i "s/\/usr\/\$\$LIB\/nvidia/\/opt\/nvidia\/\$\$LIB/g" Makefile
#		sed -i "s/\/usr\/\$\$LIB\/nvidia/\/opt\/nvidia\/\$\$LIB/" Makefile
		## TODO glx primus backup first		
		LIBDIR=$master$ELF_64 /usr/bin/make && CXX=g++\ -m32 LIBDIR=$master$ELF_32 /usr/bin/make
		[ -d $croot/primus ]|| mkdir -p $croot/primus
		cp -Rf ./$master$ELF_32 $croot/primus
		cp -Rf ./$master$ELF_64 $croot/primus
		) | zenity --width=450 --title="Zenvidia" --progress --pulsate --auto-close $b_text
		echo "# GIT : Creating primusrun script in $tool_dir..."; sleep 1
		primus_script
		echo "# GIT : $operande primus done."; sleep 1
	fi
	cd $nvdir
}
installer_build(){
	inst_build(){
		(	cd $optimus_src/nvidia-installer
			make
			make install
		) | zenity --width=450 --title="Zenvidia (installing)" --progress pulsate \
		--auto-close --text="$y\GIT$end $v: $proc nvidia-installer from sources.$end"	
	}
	# Dependencies control
	unset inst_list
#	[ -e /usr/sbin/dkms ]|| inst_list+=("dkms")
	[ -e /usr/include/ncurses/ncurses.h ]|| inst_list+=("ncurses-devel")
	[ -e /usr/include/libkmod.h ]|| inst_list+=("kmod-devel")
	[ -e /usr/include/pci/config.h ]|| inst_list+=("pciutils-devel")
	[ -e /usr/include/pciaccess.h ]||  inst_list+=("libpciaccess-devel")
	(	sleep 2
		if [[ ${inst_list[@]} != '' ]]; then
			echo "# $m_03_51..."
			$PKG_INSTALLER $pkg_opts install ${inst_list[@]}
			echo "# $m_03_52."; sleep 2
		else
			echo "# $m_03_53..."; sleep 2
		fi
		echo "# Proceed to Nvidia-installer control."; sleep 2
	) | zenity --width=450 --title="Zenvidia" --progress --pulsate --auto-close \
	--text="$y\GIT :$end$v Nvidia-Installer sources dependencies control.$end"
	echo "$n"; n=$[ $n+4 ]
	# Install or upgrade from source
	if [ -d $optimus_src/nvidia-installer ]; then
		cd $optimus_src/nvidia-installer
		echo "# GIT : Controling nvidia-installer..." ; sleep 1
		if [[ $operande = "Rebuild" ]]; then
			proc="Re-building"
			inst_build
			optimus_source_rebuild
		else
			proc="Updating"
			if [[ $(git pull | grep -o "up-to-date") == '' ]]; then
				echo "# GIT : Updating nvidia-installer..."
				make clean
				git pull ; inst_build
				sleep 2
				echo "# GIT : $proc nvidia-installer done."; sleep 1
			else
				echo "# GIT : Nvidia_installer is already up-to-date. Pass"; sleep 1
			fi
			echo "$n"; n=$[ $n+4 ]
		fi
	else
		proc="Installing"
		echo "# GIT : Donwloading nvidia-installer..." ; sleep 1
		mkdir -p $optimus_src/nvidia-installer
		/usr/bin/git clone $nv_git
		inst_build
		echo "# GIT : $proc nvidia-installer done."; sleep 2
		echo "$n"; n=$[ $n+4 ]
	fi
}
optimus_source_rebuild(){
	if [ -x $install_dir/bin/optirun ]; then
		unset build_list
		operande="Rebuild"; b=1
		for build in "bbswitch" "Bumblebee" "primus" "nvidia-installer"; do
			build_list+=("false")
			build_list+=("$b")
			build_list+=("$build")
			b=$[ $b+1 ]
		done
		menu_build=$(zenity --width=400 --height=300 --list --radiolist --hide-header \
			--title="Zenvidia" --text "$eN$G10$end" \
			--column "1" --column "2" --column "3" --separator=";" --hide-column=2 \
			"${build_list[@]}" false $b "$PM")
		if [ $? = 1 ]; then exit 0; fi
		case $menu_build in
			"1") git_src="bbswitch"; re_build ;;
			"2") git_src="Bumblebee"; re_build ;;
			"3") git_src="primus"; re_build ;;
			"4") git_src="nvidia-installer"; re_build ;;
			"$b") menu_modif ;;
		esac
	fi	
}
re_build(){
	menu_msg="$v\You're going to compile$end $j$git_src$end."
	zenity --width=450 --height=200 --title="Zenvidia" --list --radiolist --hide-header \
	--text "$menu_msg\n$v$ansCF$end" --column "1" --column "2" --separator=";" \
	true "$MM10" false "$MM"
	if [ $? = 1 ]; then base_menu; fi
	cd $optimus_src/$git_src
	b_text=" GIT : Rebuilding $git_src..."
	if [[ "$git_src" == "bbswitch" ]]; then git_build=bb_build
	elif [[ "$git_src" == "Bumblebee" ]]; then git_build=bumble_build
	elif [[ "$git_src" == "primus" ]]; then git_build=primus_build
	elif [[ "$git_src" == "nvidia-installer" ]]; then git_build=installer_build
	fi
	make clean
#	git pull
	${git_build}
}
primus_script(){
	printf "#!/bin/bash

# Readback-display synchronization method
# 0: no sync, 1: D lags behind one frame, 2: fully synced
 export PRIMUS_SYNC=\${PRIMUS_SYNC:-1}

# Verbosity level
# 0: only errors, 1: warnings (default), 2: profiling
 export PRIMUS_VERBOSE=\${PRIMUS_VERBOSE:2}

# Upload/display method
# 0: autodetect, 1: textures, 2: PBO/glDrawPixels (needs Mesa-10.1+)
# export PRIMUS_UPLOAD=\${PRIMUS_UPLOAD:-0}

# Approximate sleep ratio in the readback thread, percent
 export PRIMUS_SLEEP=\${PRIMUS_SLEEP:-90}

# Secondary display
 export PRIMUS_DISPLAY=\${PRIMUS_DISPLAY:-:8}

# \"Accelerating\" libGL
# \$LIB will be interpreted by the dynamic linker
 export PRIMUS_libGLa=\${PRIMUS_libGLa:-'$croot/nvidia/\$LIB/libGL.so.1'}

# \"Displaying\" libGL
 export PRIMUS_libGLd=\${PRIMUS_libGLd:-'/usr/\$LIB/libGL.so.1'}
# export PRIMUS_libGLd=\${PRIMUS_libGLd:-'$croot/primus/\$LIB/libGL.so.1'}

# Directory containing primus libGL
 PRIMUS_libGL=\${PRIMUS_libGL:-$croot/primus/\'\$LIB\'}

# On some distributions, e.g. on Ubuntu, libnvidia-tls.so is not available
# in default search paths.  Add its path manually after the primus library
 PRIMUS_libGL=\${PRIMUS_libGL}:$croot/nvidia/$master$ELF_32:$croot/nvidia/$master$ELF_64

# Mesa drivers need a few symbols to be visible
 export PRIMUS_LOAD_GLOBAL=\${PRIMUS_LOAD_GLOBAL:-'libglapi.so.0'}

# Need functions from primus libGL to take precedence
export LD_LIBRARY_PATH=\${PRIMUS_libGL}\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}

# And go!
exec \"\$@\"" > $nvdir/primusrun
	chmod 755 $nvdir/primusrun
	cp -f $nvdir/primusrun $tool_dir/bin
}

driver_conf(){
	# link driver for multi driver config
	kern_dir=$KERNEL
	echo "# DRIVER : Rename and backup driver..."; echo "$n"; n=$[ $n+4 ]
	if [ -f $kernel_path/nvidia-modeset.ko ]; then
		/usr/sbin/modprobe -r nvidia-modeset nvidia	
	else
		/usr/sbin/modprobe -r nvidia
	fi
	if [ -f $kernel_path/nvidia.ko ]; then
		# Case : install without dkms process
		cd $kernel_path
		mkdir -p $croot_all/$kernel
		if [ -f $kernel_path/nvidia.ko ]; then
			cp -f ./nvidia.ko $croot_all/$kern_dir/
			if [ -f nvidia-uvm.ko ]; then
				cp -f ./nvidia-uvm.ko $croot_all/$kern_dir/
			fi
			if [ -f nvidia-modeset.ko ]; then
				cp -f ./nvidia-modeset.ko $croot_all/$kern_dir/
			fi
			if [ -f nvidia-drm.ko ]; then
				cp -f ./nvidia-drm.ko $croot_all/$kern_dir/
			fi
			echo "# driver : Driver install & backup success."; sleep 1
			echo "$n"; n=$[ $n+4 ]
			/usr/sbin/depmod -a
		else
			echo "# Optimus : ERROR "; sleep 1; echo "$n"; n=$[ $n+4 ]
			zenity --width=450 --title="Zenvidia" --error \
			--text="$j\Driver $version install abort$end$v.\nExit to main menu.$end"
			base_menu
		fi
	else
		# Case : install with dkms process
		dkms_kernel=/lib/modules/$kern_dir/extra
		cd $dkms_kernel
		mkdir -p $dkms_kernel
		if [ -f $dkms_kernel/nvidia.ko ]; then
			cp -f ./nvidia.ko $croot_all/$kern_dir/
			if [ -f nvidia-uvm.ko ]; then
				cp -f ./nvidia-uvm.ko $croot_all/$kern_dir/
			fi
			if [ -f nvidia-modeset.ko ]; then
				cp -f ./nvidia-modeset.ko $croot_all/$kern_dir/
			fi
			echo "# DRIVER : Driver install & backup success."; sleep 1
			echo "$n"; n=$[ $n+4 ]
			/usr/sbin/depmod -a
		else
			echo "# DRIVER : ERROR "; sleep 1; echo "$n"; n=$[ $n+4 ]
			zenity --width=450 --title="Zenvidia" --error \
			--text="$j\Driver $version install abort$end$v.\nExit to main menu.$end"
			base_menu
		fi
	fi
}
## VIRTUALIZER CONFIGURATION PART
bumblebee_conf(){
	# consider bumblebee is already installed in /opt and bin in /usr/local
	conf_dir=$tool_dir/etc/bumblebee
	echo "# Optimus : Configure Bumblelbee service..."; n=$[ $n+1 ]; echo "$n"
	cd $conf_dir
	printf "[bumblebeed]
VirtualDisplay=:8
KeepUnusedXServer=false
ServerGroup=bumblebee
TurnCardOffAtExit=false
NoEcoModeOverride=false
Driver=nvidia
[optirun]
Bridge=auto
PrimusLibraryPath=$croot/primus/$master$ELF_64:$croot/primus/$master$ELF_32
VGLTransport=proxy
AllowFallbackToIGC=false
[driver-nvidia]
#KernelDriver=nvidia.$new_version
#Module=nvidia.$new_version
KernelDriver=nvidia
Module=nvidia
PMMethod=auto
LibraryPath=$croot/nvidia.$new_version/$master$ELF_32:$croot/nvidia.$new_version/$master$ELF_64
XorgModulePath=$croot/nvidia.$new_version/xorg/modules,/usr/lib$ELF_TYPE/xorg/modules
XorgConfFile=$conf_dir/xorg.conf.nvidia.$new_version
[driver-nouveau]
KernelDriver=nouveau
PMMethod=auto
XorgConfFile=$conf_dir/xorg.conf.nouveau
\n" > bumblebee.$new_version
	ln -sf ./bumblebee.$new_version ./bumblebee.conf	
}
xorg_conf(){
	sec_layout(){
		printf "Section \"ServerLayout\"
	Identifier	\"Layout0\"
#	Screen	0	\"Screen0\" 0 0
	Option	\"AutoAddDevices\" \"false\"
	Option	\"AutoAddGPU\" \"false\"
EndSection
Section \"ServerFlags\"
	Option	\"Xinerama\" \"0\"
	AllowMouseOpenFail # allows the server to start up even if the mouse does not work
EndSection
\n" > xorg.conf.nvidia.$new_version
	}
	sec_files(){
		printf "Section \"Files\"
#	ModulePath \"$croot/nvidia.$new_version/$master$ELF_64\"
#	ModulePath \"$croot/nvidia.$new_version/$master$ELF_32\"
	ModulePath \"$croot/nvidia.$new_version/xorg/modules\"
	ModulePath \"usr/$master$ELF_64/xorg/modules\"
EndSection
Section \"Module\"
	Load \"dbe\"
	Load \"extmod\"
	Load \"type1\"
	Load \"freetype\"
	Load \"glx\"
	Load \"evdev\"
EndSection
\n" >> xorg.conf.nvidia.$new_version
	}
	sec_device(){
		for e in $pci_dev_nb; do
		pci_slot=$(printf "${slot[$e]}"| sed -n "s/\./:/p")
		if [[ $(printf "${dev[$e]}"|grep "GeForce\|Quadro\|NVS\|Tesla\|GRID") != '' ]]; then
		printf "Section \"Device\"
	Identifier	\"Device${nm[$e]}\"
	Driver		\"nvidia\"
	VendorName	\"${vnd[$e]}\"
	BusID		\"PCI:$pci_slot\"
\n" >> xorg.conf.nvidia.$new_version
		fi
		done
	}
	sec_option(){
		printf "\tOption	\"DPMS\"
	Option	\"NoLogo\" \"true\"
	Option	\"UseEDID\" \"false\"
	Option	\"ProbeAllGpus\" \"false\"
	Option	\"UseDisplayDevice\" \"none\"
#	Option	\"ConnectedMonitor\" \"DFP\"
#	Option	\"DynamicTwinView\" \"false\"
#	Option	\"AddARGBGLXVisuals\"
#	Option	\"SLI\" \"Off\"
#	Option	\"MultiGPU\" \"Off\"
#	Option	\"BaseMosaic\" \"off\"
#	Option	\"UseEdidDpi\" \"false\"
#	Option	\"Coolbits\" \"8\"
#	Option	\"AllowGLXWithComposite\" \"true\"
#	Option	\"TripleBuffer\" \"true\"
#	Option	\"RenderAccel\" \"true\"
#	Option	\"DPI\" \"96\"
EndSection
\n" >> xorg.conf.nvidia.$new_version
	}
	# TODO > OPTIONAL
	screen_opt(){
		printf "Option	\"Stereo\" \"0\"
	Option	\"nvidiaXineramaInfoOrder\" \"DFP-${nm[0]}\"
#	Option	\"metamodes\" \"DVI-I-1: nvidia-auto-select +0+0, HDMI-0: nvidia-auto-select +1920+180\"
#	Option	\"SLI\" \"Off\"
#	Option	\"MultiGPU\" \"Off\"
#	Option	\"BaseMosaic\" \"off\"
#	Option	\"AddARGBGLXVisuals\" \"true\"

#	Option	\"Coolbits\" \"8\"
#	Option	\"AllowGLXWithComposite\" \"true\"
#	Option	\"TripleBuffer\" \"true\"
#	Option	\"RenderAccel\" \"true\"
\n" >> xorg.conf.nvidia.$new_version
	}
	# TODO > OPTIONAL
	screen_dsp(){
		printf "\tSubSection \"Display\"
	Depth	24
EndSubSection\n" >> xorg.conf.nvidia.$new_version
	}
	sec_screen(){
		printf "Section \"Screen\"
    Identifier	\"Screen${nm[0]}\"
    Device		\"Device${nm[0]}\"
    Monitor		\"Monitor${nm[0]}\"
    DefaultDepth	24
\n" >> xorg.conf.nvidia.$new_version
    	screen_opt
    	screen_dsp
		printf "EndSection
\n" >> xorg.conf.nvidia.$new_version
	}
	
	## TODO : implement modsettings config
	if [ $optimus = 1 ]; then
		conf_dir=$tool_dir/etc/bumblebee
	else
		conf_dir=/etc/X11
	fi
	cd $conf_dir
	sec_layout
	if [ $optimus = 0 ]; then
		sec_files
	fi
#	for e in $pci_dev_nb; do
	sec_device
	sec_option
#	sec_screen
	if [ $optimus = 0 ]; then
		ln -sf ./xorg.conf.nvidia.$new_version ./xorg.conf
	else
		ln -sf ./xorg.conf.nvidia.$new_version ./xorg.conf.nvidia
	fi
}
## TODO > standalone install auto config
if_blacklist(){
## TODO
	if [[ $(cat /etc/modprobe.d/blacklist.conf | grep "nouveau") == '' ]]; then
		printf "blacklist nouveau" >> /etc/modprobe.d/blacklist.conf
	fi
#	mv /boot/initramfs-$(uname -r).img /boot/initramfs-$(uname -r)-nouveau.img
#	dracut /boot/initramfs-$(uname -r).img $(uname -r)
	if [[ $(cat /etc/group | grep -o "bumblebee") == '' ]]; then
		groupadd bumblebee
		usermod -a -G bumblebee $USER
	fi
	if [[ $(cat /etc/group | grep -o "bumblebee") == '' ]]; then
		cp $nvdir/systemd/bumblebeed.service /lib/systemd/system/ 
		systemctl enable bumblebeed.service
	fi
	if [[ $(cat /proc/version | grep -o "red hat\|Red Hat") != '' ]]; then
		/usr/bin/systemctl restart bumblebeed.service
	else
		/usr/bin/service restart bumblebeed
	fi
#	GRUB_CMDLINE_LINUX="rd.md=0 rd.lvm=0 rd.dm=0 SYSFONT=True  KEYTABLE=fr rd.luks=0 LANG=fr_FR.UTF-8 rhgb quiet rd.blacklist=nouveau"
#	grub2-mkconfig -o /boot/grub2/grub.cfg
}
## OPTIONAL
fix_broken_Xlibs(){
	if [ $(cat /proc/version | grep -o "[Rr]ed [Hh]at") != '' ]; then
	$PKG_INSTALLER $pkg_opts reinstall libX11 mesa-libEGL mesa-libGL mesa-libGLES mesa-libGLU mesa-dri-drivers
	elif [ $(cat /proc/version | grep -o "[Dd]ebian\|[Uu]buntu") != '' ]; then
	$PKG_INSTALLER $pkg_opts reinstall libX11-6 mesa-utlis mesa-vdpau-drivers libgl2-mesa-glx libglapi-mesa libgl2-mesa-dri libglu2-mesa libegl2-mesa libgles2-mesa
	fi 
}

post_install(){
	## FIXME libwfb for optimus & debian link ##
	echo "# Post install routines..."; echo "$n"; n=$[ $n+4 ]
	if [[ -d $croot_32 || -d $croot_64 ]]; then
#		cp -f $croot_32/lib/vdpau/* /usr/lib/vdpau
#		if [ -d /usr/lib$ELF_TYPE ]; then
#			cp -f $croot_64/lib$ELF_TYPE/vdpau/* /usr/lib$ELF_TYPE/vdpau
#		fi
#		cd ../bak
#		for baklibs in "$master$ELF_32" "$master$ELF_64"; do
#			for Xlibs in $(ls -1 $baklibs ); do
#				if [ ! -d $baklibs/$Xlibs ]; then
#					if [ ! -h $baklibs/$Xlibs ]; then 
#					[ -f $baklibs/$Xlibs ]||cp -u $baklibs/$Xlibs /usr/$baklibs/$Xlibs
#					fi
#				else
#					[ -d $baklibs/$Xlibs ]||cp -Rud $baklibs/$Xlibs /usr/$baklibs/$Xlibs
#				fi
#			done
#		done
		if [ $optimus = 1 ]; then
			echo "# Optimus : Configure and reload Bumblebee, if present..."; sleep 1
			echo "$n"; n=$[ $n+4 ]
#			if [ ! -d $croot/nvidia.$new_version ]; then
#				mv -f $croot/$predifined_dir $croot/nvidia.$new_version
#			fi
#			cd $croot
#			if [[ ! -f $croot/nvidia.$new_version ]]; then
#				ln -sf -T ./nvidia.$new_version ./nvidia
#			fi
			if [ -e $xorg_dir/modules/libwfb.so ]; then
				mv -f $xorg_dir/modules/libwfb.so $xorg_dir/modules/libwfb.so.orig
				ln -sf /usr/lib$ELF_TYPE/xorg/modules/libwfb.so $xorg/modules/libwfb.so
			fi
			[ -d $croot/nvidia.$new_version ]|| mv -f $croot/$predifined_dir $croot/nvidia.$new_version
			cd $croot
			[ -f $croot/nvidia.$new_version ]|| ln -sf -T ./nvidia.$new_version ./nvidia
			optimus_src_ctrl; echo "$n"; n=$[ $n+4 ]
			driver_conf; echo "$n"; n=$[ $n+4 ]
			bumblebee_conf; echo "$n"; n=$[ $n+2 ]
			## TODO 
			# [ mod_setting = 1 ]&& mod_setting_conf
			xorg_conf; echo "$n"; n=$[ $n+2 ]
			echo "# Optimus : Start or Restart Optimus service..."; sleep 1
			echo "$n"; n=$[ $n+4 ]
			if [[ $(cat /proc/version | grep -o "[Rr]ed [Hh]at") != '' ]]; then
				/usr/bin/systemctl restart bumblebeed.service
			else
				/usr/bin/service restart bumblebeed
			fi
			cd $nvdir
		fi
		if [ $optimus = 0 ]; then
			## TODO prepare xorg conf
			## TODO ldconfig nvidia libs
			driver_conf
			
			xorg_conf
		fi
	fi
	if [ -e $nvlog/install.log ]; then cp -f $nvlog/install.log $nvlog/install-$new_version.log; fi
	echo "# Fixing broken libs if needeed..."; echo "$n"; n=$[ $n+4 ]
	cd $install_dir
	for lib_X in "$master$ELF_32 $master$ELF_64"; do
		for old_lib in {fbc,cfg,gtk2,gtk3}; do
			if [ -s $install_dir/$lib_X/libnvidia-$old_lib.so.$old_version ]; then
				rm -f $install_dir/$lib_X/libnvidia-$old_lib.so.$old_version
			fi
		done
	done
	cd $nvtmp
	extracted=NVIDIA-Linux-$ARCH-$new_version
	if [ -d $extracted ]; then
		if [ -d $nvtmp/$extracted/32 ]; then
			cp -f $extracted/libnvidia-fbc.so.$new_version $install_dir/$master$ELF_32/
			cd $install_dir/$master$ELF_32/
			ln -sf libnvidia-fbc.so.$new_version libnvidia-fbc.so.1
			ln -sf libnvidia-fbc.so.1 libnvidia-fbc.so
			cd $nvtmp
		fi
		for links in {fbc,cfg,gtk2,gtk3}; do
			[ -s $install_dir/$master$ELF_64/libnvidia-$links.$new_version ]|| \
			cp -f $extracted/libnvidia-$links.so.$new_version $install_dir/$master$ELF_64/
			cd $install_dir/$master$ELF_64/
			ln -sf libnvidia-$links.so.$new_version libnvidia-$links.so.1
			ln -sf libnvidia-$links.so.1 libnvidia-$links.so
			cd $nvtmp
		done
	fi
	/usr/sbin/ldconfig
	echo "$n"; n=$[ $n+4 ]
	if [ ! -h /usr/share/nvidia ]; then
		rm -f /usr/share/nvidia
		ln -sf -T $install_dir/share/nvidia /usr/share/nvidia
	fi
}
make_lib_list(){
	## 	FIXME ##
#	libclass
	if [[ $ELF_TYPE == 64 ]]; then
		## FIXME for debian ##
		LIB_32=$master$ELF_32
		LIB_64=$master$ELF_64
	else
		LIB_32=lib
		LIB_64=lib
	fi
	
	for LIB_X in $LIB_32 $LIB_64 ; do
#		for lib_l in {libGL,libEGL,libEGLS,libOpenCL,libX11,libX11-xcb} ; do
#		if [[ $(printf "$lib_l"| grep "libX11") != '' ]]; then
#			[ -e /usr/$LIB_X/$lib_l.so.6 ]&& cp -ud /usr/$LIB_X/$lib_l.* $nvdir/bak/$LIB_X/
#		else
#			[ -e /usr/$LIB_X/$lib_l.so ]&& cp -ud /usr/$LIB_X/$lib_l.* $nvdir/bak/$LIB_X/
#		fi
		[ -e /usr/$LIB_X/libGL.so ]&& cp -ud /usr/$LIB_X/libGL.* $nvdir/bak/$LIB_X/
		[ -e /usr/$LIB_X/libEGL.so ]&& cp -ud /usr/$LIB_X/libEGL.* $nvdir/bak/$LIB_X/
		[ -e /usr/$LIB_X/libEGLS.so ]&& cp -ud /usr/$LIB_X/libEGLS.* $nvdir/bak/$LIB_X/
		[ -e /usr/$LIB_X/libOpenCL.so ]&& cp -ud /usr/$LIB_X/libOpenCL.* $nvdir/bak/$LIB_X/
		[ -e /usr/$LIB_X/libX11.so.6 ]&& cp -ud /usr/$LIB_X/libX11.* $nvdir/bak/$LIB_X/
		[ -e /usr/$LIB_X/libX11-xcb.so.1 ]&& cp -ud /usr/$LIB_X/libX11-xcb.* $nvdir/bak/$LIB_X/
		[ -h /usr/$LIB_X/libX11.so ]|| ln -sf ./libX11.so.6 ./libX11.so 
		if [ $LIB_X == $LIB_64 ]; then
			[ -e /usr/$LIB_X/libvdpau.so ]&& cp -ud /usr/$LIB_X/libvdpau.* $nvdir/bak/$LIB_X/
			[ -e /usr/$LIB_X/libwfb.so ]&& cp -ud /usr/$LIB_X/xorg/modules/libwfb.so $nvdir/bak/$LIB_X/xorg/modules/
			[ -e /usr/$LIB_X/xorg/modules/extensions/libglx.so ]&& cp -ud /usr/$LIB_X/xorg/modules/extensions/libglx.so $nvdir/bak/$LIB_X/xorg/modules/extensions/
			[ -e /usr/$LIB_X/xorg/modules/libwfb.so ]&& cp -ud /usr/$LIB_X/xorg/modules/libwfb.so $nvdir/bak/$LIB_X/xorg/modules/
			[ -d /usr/$LIB_X/vdpau ]&& cp -ud /usr/$LIB_X/vdpau/* $nvdir/bak/$LIB_X/vdpau/
#		[ -d /usr/$LIB_X/xorg/modules ]&& cp -ud /usr/$LIB_64/xorg/modules* $nvdir/bak/$LIB_64/xorg/
		fi
		cd $nvdir/bak/$LIB_X
		[ -h /usr/$LIB_X/libX11.so ]|| ln -sf ./libX11.so.6 ./libX11.so
		cd $nvdir
	done
}

### INSTALLATION
old_kernel(){
	if [ $cuda = 0 ]; then
		nv_list="nvidia nvidia-modeset nvidia-drm"
	else
		nv_list="nvidia nvidia-uvm nvidia-modeset nvidia-drm"
	fi
	for nvname in $nv_list; do
		old_driver=$($d_modinfo -F version /lib/modules/$previous_kernel/extra/$nvname.ko)
		if [ -s /lib/modules/$previous_kernel/extra/$nvname.ko ]; then
			[ -s $croot/nvidia.$old_driver/$previous_kernel/$nvname.ko ]|| \
			cp /lib/modules/$previous_kernel/extra/$nvname.ko \
			$croot/$nvname.$old_driver/$previous_kernel/
		fi
#		if [ -s $croot/$nvname.$old_driver/$previous_kernel/$nvname.ko ]; then
#			[ -h $croot/$nvname.$old_driver/$previous_kernel/$nvname.ko ]|| \
#			cp /lib/modules/$previous_kernel/extra/$nvname.ko \
#			$croot/$nvname.$old_driver/$previous_kernel/
#		fi
	done
}
clean_previous(){
		echo "# Backing up old kernel driver..."
		previous_kernel=$(ls -1 /lib/modules | sed -n '/'$(uname -r)'/{g;1!p};h')
		if [ -s /lib/modules/$previous_kernel/extra/nvidia.ko ]; then
			old_kernel
		fi
}
nv_cmd_install_libs(){
	
#	-b --no-sigwinch-workaround --no-distro-scripts $no_check \	
#	--x-prefix=$xorg_dir --x-module-path=$xorg_dir/modules --opengl-prefix=$croot_all \
#	sh $driverun -a $quiet -z -Z --no-x-check --ui=none $unified \
#	--kernel-source-path=$kernel_src --kernel-install-path=$kernel_path  --no-abi-note \
#	sh $driverun -s -z -N --no-x-check \
	cd $nvtmp/NVIDIA-Linux-$ARCH-$new_version
	no_check='--no-check-for-alternate-installs'
	if [ $use_indirect = 1 ]; then add_glvnd='--install-libglvnd --glvnd-glx-client'; else add_glvnd='';fi
#	$nocheck --no-kernel-module --no-opengl-files --skip-module-unload \
#	--no-recursion --opengl-headers --install-libglvnd --glvnd-glx-client --force-libglx-indirect \
	$install_bin -s -z -N --no-x-check \
	$nocheck --no-kernel-module --skip-module-unload \
	--no-recursion --opengl-headers $add_glvnd \
	--install-compat32-libs --compat32-prefix=$croot_all \
	--x-prefix=$xorg_dir --x-module-path=$xorg_dir/modules --opengl-prefix=$croot_all \
	--utility-prefix=$tool_dir --utility-libdir=$tool_dir/$LIB_64 \
	$docs $profile $SIGN_S $SElinux $temp --log-file-name=$lib_logfile
}
nv_cmd_try_legacy_first(){
	cd $nvtmp/NVIDIA-Linux-$ARCH-$new_version
	echo "# Trying compil from LEGACY BUILD directory..."; sleep 1
	no_check='--no-check-for-alternate-installs'
	if [ $cuda = 0 ]; then unified="--no-unified-memory"; else unified=''; fi
#	if [ $use_indirect = 1 ]; then add_glvnd='--install-libglvnd --glvnd-glx-client'; else add_glvnd='';fi
	if [ $use_dkms = 1 ]; then dkms="--dkms"; else dkms=''; fi
	$install_bin -s -z -N --no-x-check $unified $dkms -K -b $no_check \
	--skip-module-unload \
	--kernel-source-path=$kernel_src --kernel-install-path=$kernel_path \
	$SIGN_S $SElinux $temp --log-file-name=$driver_logfile
	depmod -a
}
nv_cmd_install_driver(){
	driver_level=$(printf "$new_version"|cut -d. -f1)
	nv_cmd_dkms_conf
	nv_cmd_try_legacy_first
	if [ ! -s $kernel_path/nvidia.ko ]|| \
	[[ $($d_modinfo -F version nvidia) != $new_version ]]; then
		[ -d /usr/src/nvidia-$new_version ]||mkdir -p /usr/src/nvidia-$new_version
		cp -Rf $nvtmp/NVIDIA-Linux-$ARCH-$new_version/kernel/* /usr/src/nvidia-$new_version
		if [ $use_dkms = 1 ]; then
			if [ -d $nvtmp/NVIDIA-Linux-$ARCH-$new_version/kernel ]; then
				if [[ $(cat /usr/src/nvidia-$new_version/dkms.conf|grep -o "$new_version") == '' ]]; then
					nv_cmd_dkms_conf
#					cp -f $nvtmp/NVIDIA-Linux-$ARCH-$new_version/kernel/dkms.conf /usr/src/nvidia-$new_version/
				fi
				# Compil and install DKMS modules
				echo "# Add DKMS modules to DKMS directory..."; sleep 1
				/usr/sbin/dkms add -m nvidia/$new_version -k $KERNEL -c /usr/src/nvidia-$new_version/dkms.conf
				echo "# Build DKMS modules..."; sleep 1
				/usr/sbin/dkms build -m nvidia/$new_version -k $KERNEL -c /usr/src/nvidia-$new_version/dkms.conf
				echo "# Install DKMS modules to KERNEL PATH..."; sleep 1
				/usr/sbin/dkms install -m nvidia/$new_version -k $KERNEL -c /usr/src/nvidia-$new_version/dkms.conf
				# In case of modules compil errors, force it from source
				if [ ! -s $kernel_path/nvidia.ko ]|| \
				[[ $($d_modinfo -F version nvidia) != $new_version ]]; then
					echo "# DKMS compilation ERROR !!"; sleep 2 
					echo "# Force MODULES compilation from source..."; sleep 1
					nv_cmd_make_src
				fi
			fi
		fi
		if [ $use_dkms = 0 ]; then
			echo "# Nvidia MODULES compilation..."; sleep 1 
			nv_cmd_make_src
		fi
	fi
	if [ $driver_level -ge 355 ]; then
		$nvtmp/NVIDIA-Linux-$ARCH-$new_version/nvidia-modprobe -u -m
	else
		$nvtmp/NVIDIA-Linux-$ARCH-$new_version/nvidia-modprobe -u
	fi
}
nv_cmd_dkms_conf (){
#	if [[ $(printf "$new_version") ]]; then 
	if [[ $new_version ]]; then 
		version=$new_version
	else
		version=$version
	fi
	[ -d /usr/src/nvidia-$version ]||mkdir -p /usr/src/nvidia-$version
#	[[ $(printf "$driver_level") ]]|| driver_level=$(printf "$version"|cut -d. -f1)
	[[ $driver_level ]]|| driver_level=$(printf "$version"|cut -d. -f1)
	# Create DKMS conf in case of buggy one
	echo "# Create DKMS conf file..."; sleep 1 
	if [ $driver_level -le 355 ]; then
	printf "PACKAGE_NAME=\"nvidia\"
PACKAGE_VERSION=\"$version\"
AUTOINSTALL=\"yes\"

MAKE[0]=\"\'make\' -j\`nproc\` NV_EXCLUDE_BUILD_MODULES=\'__EXCLUDE_MODULES\' KERNEL_UNAME=\${kernelver} modules\"
CLEAN=\"\'make\' clean\"

BUILT_MODULE_NAME[0]=\"\${PACKAGE_NAME}\"
DEST_MODULE_LOCATION[0]=\"/extra\"\n" > /usr/src/nvidia-$version/dkms.conf
#DEST_MODULE_LOCATION[0]=\"/extra\"\n" > $nvtmp/NVIDIA-Linux-$ARCH-$new_version/kernel/dkms.conf
		if [ $cuda = 1 ]; then
			printf "BUILT_MODULE_NAME[1]=\"\${PACKAGE_NAME}-uvm\"
BUILT_MODULE_LOCATION[1]=\"uvm/\"
DEST_MODULE_LOCATION[1]=\"/extra\"\n" >> /usr/src/nvidia-$version/dkms.conf
#DEST_MODULE_LOCATION[1]=\"/extra\"\n" >> $nvtmp/NVIDIA-Linux-$ARCH-$new_version/kernel/dkms.conf
		fi
	fi
	if [ $driver_level -gt 355 ]; then
		printf "PACKAGE_NAME=\"nvidia\"
PACKAGE_VERSION=\"$version\"
AUTOINSTALL=\"yes\"

MAKE[0]=\"\'make\' -j\`nproc\` NV_EXCLUDE_BUILD_MODULES=\'__EXCLUDE_MODULES\' KERNEL_UNAME=\${kernelver} modules\"

BUILT_MODULE_NAME[0]=\"\${PACKAGE_NAME}\"
DEST_MODULE_LOCATION[0]=\"/extra\"\n" > /usr/src/nvidia-$version/dkms.conf
#DEST_MODULE_LOCATION[0]=\"/extra\"\n" > $nvtmp/NVIDIA-Linux-$ARCH-$new_version/kernel/dkms.conf
		if [ $cuda = 1 ]; then
			printf "BUILT_MODULE_NAME[1]=\"\${PACKAGE_NAME}-uvm\"
BUILT_MODULE_LOCATION[1]=\"uvm/\"
DEST_MODULE_LOCATION[1]=\"/extra\"\n" >> /usr/src/nvidia-$version/dkms.conf
#DEST_MODULE_LOCATION[1]=\"/extra\"\n" >> $nvtmp/NVIDIA-Linux-$ARCH-$new_version/kernel/dkms.conf
		fi
		if [ $cuda = 1 ]; then n1=2 ;else n1=1; fi
		printf "BUILT_MODULE_NAME[$n1]=\"\${PACKAGE_NAME}-modeset\"
DEST_MODULE_LOCATION[$n1]=\"/extra\"\n" >> /usr/src/nvidia-$version/dkms.conf
#DEST_MODULE_LOCATION[$n1]=\"/extra\"\n" >> $nvtmp/NVIDIA-Linux-$ARCH-$new_version/kernel/dkms.conf
	fi
	if [ $driver_level -ge 364 ]; then
		if [ $cuda = 1 ]; then n2=3 ;else n2=2; fi
		printf "BUILT_MODULE_NAME[$n2]=\"\${PACKAGE_NAME}-drm\"
DEST_MODULE_LOCATION[$n2]=\"/extra\"\n" >> /usr/src/nvidia-$version/dkms.conf 
#DEST_MODULE_LOCATION[$n2]=\"/extra\"\n" >> $nvtmp/NVIDIA-Linux-$ARCH-$new_version/kernel/dkms.conf
	fi
}
nv_cmd_install_gl(){ ## NOT USED : RESERVED ##
	driver_level=$(printf "$new_version"|cut -d. -f1)
	cd $nvtmp/NVIDIA-Linux-$ARCH-$new_version
#	GLlib_list="libEGL.so" "libEGL_" "libGLESv1" "libGLESv2" "libGL.so." "libOpenGL." "libnvidia-egl" \ 
#"libnvidia-glcore." "libnvidia-glsi." "libnvidia-tls." "libvdpau." "libvdpau-trace"
	if [[ $driver_level -gt 355 ]]; then
		#indirect
		if [ $use_indirect = 1 ]; then
#			GLlib_list="libEGL.so,libGLESv1_CM.,libGLESv2.,libGL.so.1,libOpenGL.,libGLX.,libnvidia-egl,libnvidia-glcore.,libnvidia-glsi.,libnvidia-tls."
			GLlib_list="libEGL.so,libGLESv1_CM\.,libGLESv2\.,libGL.so.1,libOpenGL.,libGLX\.,libnvidia-tls."
		else
		#direct
#			GLlib_list="libEGL_,libGLESv1_CM_,libGLESv2_,libGL.so.$driver_level.,libOpenGL.,libGLX_,libnvidia-egl,libnvidia-glcore.,libnvidia-glsi.,libnvidia-tls."
			GLlib_list="libEGL_,libGLESv1_CM_,libGLESv2_,libGL.so.$driver_level.,libOpenGL.,libGLX_,libnvidia-tls."
		fi
	else
#		GLlib_list="libEGL.so,libEGL_,libGLESv1,libGLESv2,libGL.so.,libOpenGL.,libnvidia-egl,libnvidia-glcore.,libnvidia-glsi.,libnvidia-tls.,libvdpau.,libvdpau-trace."
		GLlib_list="libEGL.so,libEGL_,libGLESv1,libGLESv2,libGL.so.,libOpenGL.,libvdpau.,libvdpau-trace."
	fi
	for lib_0 in "$LIB_32" "$LIB_64"; do
		if [ "$lib_0" == "$LIB_32" ]; then nv_src="32/"; else nv_src=""; fi
		cp -f $nv_src\libEGL* $croot_all/$lib_0/
		cp -f $nv_src\libGL* $croot_all/$lib_0/
		cp -f $nv_src\libOpenGL* $croot_all/$lib_0/
		cp -f $nv_src\libnvidia-{egl*,gl*,tls*,} $croot_all/$lib_0/
		cp -f $nv_src\libvdpau{.so*,_tr*}* $croot_all/$lib_0/
		cp -Rf $nv_src\tls/ $croot_all/$lib_0/
		cd $croot_all/$lib_0
#		for nv_lnk in "$GLlib_list" ; do
		for nv_lnk in $(printf "$GLlib_list"| tr "," "\n") ; do
			nv_lnk_from=$(ls -1 |grep "$nv_lnk")
			nv_lnk_to=$(printf "$nv_lnk_from"|sed -n "s/\..*$//p")
			if [[ $(printf "$nv_lnk_to"|grep "GLX\|GLES") != '' ]]; then
				[[ '$nv_lnk_to' == 'libGLESv1_CM' ]]&& nv_lnk_to=libGLESv1_CM
				[[ '$nv_lnk_to' == 'libGLESv2' ]]&& nv_lnk_to=libGLESv2
				[[ '$nv_lnk_to' == 'libGLX' ]]&& nv_lnk_to=libGLX
			fi
			[ -e $nv_lnk_from ] && ln -sf ./$nv_lnk_from ./$nv_lnk_to.so.1
			[ -e $nv_lnk_to.so.1 ] && ln -sf ./$nv_lnk_to.so.1 ./$nv_lnk_to.so
		done
		cd $nvtmp/NVIDIA-Linux-$ARCH-$new_version
	done
	# ensure /etc/nvidia is set
	mkdir -p /etc/OpenCL/vendors
	printf "$croot_all/$LIB_64/nvidia.$new_version/libnvidia-opencl.so.1\n" > /etc/OpenCL/vendors/nvidia.icd
	if [ $optimus = 1 ]; then
		nv_cmd_install_glx
	fi
}
nv_cmd_install_glx(){
	## FIXME : do the nvidia modules stay load after X servre crash ?
	[ -d $xorg_dir/modules/extensions/ ]|| mkdir -p $xorg_dir/modules/extensions/
	cp -f libglx.so.$new_version $xorg_dir/modules/extensions/
	cd $xorg_dir/modules/extensions/
	ln -sf libglx.so.$new_version libglx.so
}

nv_cmd_update(){
	install_bin="./nvidia-installer"
	driver_logfile=$nvlog/$new_version-$KERNEL.log
	if [ $use_dkms = 1 ]; then
		if [[ $(cat /usr/src/nvidia-$version/dkms.conf|grep -o "$version") == '' ]]; then
			nv_cmd_dkms_conf
			cp -f $nvtmp/NVIDIA-Linux-$ARCH-$new_version/kernel/dkms.conf /usr/src/nvidia-$new_version/
		fi
	fi
	nv_cmd_try_legacy_first
	if [ ! -s $kernel_path/nvidia.ko ]|| \
	[[ $($d_modinfo -F version nvidia) != $new_version ]]; then
		if [ $use_dkms = 1 ]; then			
	#		if [ ! -d /var/lib/dkms/nvidia/$version/$(uname -r) ]; then
			if [ ! -d /var/lib/dkms/nvidia/$version ]; then
				echo "# Add DKMS modules to DKMS directory..."; sleep 1
				/usr/sbin/dkms add -m nvidia/$version -k $KERNEL -c /usr/src/nvidia-$version/dkms.conf
			fi	
			echo "# Build DKMS modules..."; sleep 1
			/usr/sbin/dkms build -m nvidia/$version -k $KERNEL -c /usr/src/nvidia-$version/dkms.conf
			echo "# Install DKMS modules to KERNEL PATH..."; sleep 1
			/usr/sbin/dkms install -m nvidia/$new_version -k $KERNEL -c /usr/src/nvidia-$version/dkms.conf
			if [ ! -e $kernel_path/nvidia.ko ]|| \
			[[ $($d_modinfo -F version nvidia) != $version ]]; then
				echo "# DKMS compilation ERROR !!"; sleep 2 
				echo "# Force MODULES compilation from source..."; sleep 1
				nv_cmd_make_src
			fi
		else
			if [ $use_dkms = 0 ]; then
				echo "# Nvidia MODULES compilation..."; sleep 1 
				nv_cmd_make_src
			fi
		fi
	fi
}
nv_cmd_make_src (){
	if [[ $(printf "$new_version") != '' ]]; then version=$new_version; fi
		[ $driver_level != '' ]|| driver_level=$(printf "$version"|cut -d. -f1)
	if [ -d /usr/src/nvidia-$version ]; then
		cd /usr/src/nvidia-$version
		make clean; make
		if [ $driver_level -lt 355 ]; then
			cd uvm/; make clean; make; cd ../
		fi
		if [ -s nvidia.ko ]; then cp -f nvidia.ko $kernel_path/; fi
		if [ -s nvidia-uvm.ko ]; then cp -f nvidia-uvm.ko $kernel_path/; fi
		if [ -s uvm/nvidia-uvm.ko ]; then cp -f uvm/nvidia-uvm.ko $kernel_path/; fi
		if [ -s nvidia-modeset.ko ]; then cp -f nvidia-modeset.ko $kernel_path/; fi
		if [ -s nvidia-drm.ko ]; then cp -f nvidia-drm.ko $kernel_path/; fi
		/usr/sbin/depmod -a
		/usr/sbin/ldconfig
	fi
#			if [ -s $kernel_path/nvidia.ko ]; then
#				mkdir -p $croot/nvidia.$version/$(uname -r)
#				cp -f $kernel_path/nvidia.ko $croot/nvidia.$version/$(uname -r)/
#			fi
}
nv_cmd_uninstall(){	
	( $tool_dir/bin/nvidia-installer --uninstall -s --no-x-check $temp $logfile \
	-b --no-sigwinch-workaround --no-distro-scripts $no_check --no-nvidia-modprobe
	) | zenity --width=450 --title="Zenvidia" --progress --pulsate --auto-close \
	--text="$v$m_01_22...$end"
}
## INSTALL MODULE AND LIBRARIES PROCESS
# MAIN
install_drv(){
	zenity --height=200 --title="Zenvidia" --list --radiolist --hide-header \
	--text "$menu_msg\n$v$msg219c$end $j$new_version$end $v$msg219d$end $j$board$end.
\n$v$ansCF$end" --column "1" --column "2" --separator=";" true "$_0a" false "$MM"
	if [ $? = 1 ]; then base_menu; fi
	# backup driver repository (shits happens!)
#	if [ -d $croot/nvidia.$new_version ]||[ -d $croot/nvidia.$old_version ]; then
#		if [ -d $croot/nvidia.$new_version ]; then
#			cp -f $croot/nvidia.$new_version $croot/nvidia.$new_version.bak
#		fioptimus=
		if [ -d $croot/nvidia.$old_version ]; then
			mv -f $croot/nvidia.$old_version $croot/nvidia.$old_version.bak
		fi
#	fi
	# nvidia-installer options
	KERNEL=$(uname -r)

	lib_logfile=$nvlog/install-$new_version.log
	driver_logfile=$nvlog/$new_version-$KERNEL.log
	# other vars
	dkms_kernel=/lib/modules/$KERNEL/extra
	if [ -s $driverun ] ; then
	(	sleep 1
		n=4
		echo "# Making original libglx backup..."; echo "$n"; n=$[ $n+4 ]
		if [ ! -d $nvdir/bak ]; then
			mkdir -p $nvdir/bak/$master$ELF_32 \
			$nvdir/bak/$master$ELF_64 $nvdir/bak/$master$ELF_64/vdpau \
			$nvdir/bak/lib$ELF_TYPE/xorg/modules/extensions
		fi
		make_lib_list; sleep 1
		# making installation directories in case installer doesn't find them
		[ -d $croot_64 ] || ( mkdir -p $croot_32 $croot_64 $xorg_dir )	
		# remove previous driver, because of "registered driver install break", if any
		clean_previous
		echo "# $msg301"; sleep 1; echo "$n"; n=$[ $n+4 ]
#		installer_build
		# choose between installer bianaries
#		if [[ $($tool_dir/bin/nvidia-installer -v | awk '{print $3}'|sed -n '2p') != $new_version ]]; then
			install_bin="./nvidia-installer"
#		else
#			install_bin="$tool_dir/bin/nvidia-installer"
#		fi
		# nv_cmd processes (install without X crash )
		echo "# Package conpil and install"; sleep 1
		# install driver first, then control if everything ok
		(nv_cmd_install_driver
		)| zenity --width=450 --title="Zenvidia" --progress --pulsate --auto-close \
		--text="$v\DRIVER$end : Install driver and dkms modules."
		sleep 1; echo "$n"; n=$[ $n+4 ]
		# install default lib with nvidia-installer	
		(nv_cmd_install_libs
		)| zenity --width=450 --title="Zenvidia" --progress --pulsate --auto-close \
		--text="$v\LIBRARIES$end : Extract and install default nvidia libs..."
		sleep 1; echo "$n"; n=$[ $n+4 ]
		# Copy GL libs manually to prevent GLX X server crash
#		(nv_cmd_install_gl
#		)| zenity --width=450 --title="Zenvidia" --progress --pulsate --auto-close \
#		--text="$v\OPENGL$end : Install OpenGL librairies..."
#		sleep 1; echo "$n"; n=$[ $n+4 ]

		
#		if [[ $(cat $driver_logfile | grep -o "ERROR") != '' ]]; then
#			if [[ $($d_modinfo -F version nvidia ) != "$new_version" ]]; then
#				if [[ $(cat $driver_logfile | grep "Installation has failed.") != '' ]]; then
#					zenity --width=450 --title="Zenvidia" --error \
#					--text="$vB\DRIVER INSTALL ABORT ABNORMALY$end\n$v\check $(echo "$driver_logfile" | sed -n 's/^.*=//p').$end"
#				fi
#				rm -f $buildtmp/template-*
#				exit 0
#			fi
#		fi
#		sleep 1; echo "$n"; n=$[ $n+4 ]
		
		if [ -f $kernel_path/nvidia.ko ]||[ -f /lib/modules/$KERNEL/extra/nvidia.ko ]; then
			if [[ $($d_modinfo -F version nvidia ) != $new_version ]]; then
				if [[ $(cat $driver_logfile | grep "NVIDIA init module failed!") != '' ]]; then
					rm -f $buildtmp/template-*
#					zenity --title="Zenvidia" --error --no-wrap \ 
#					--text="$v\DRIVER INIT ABORT ABNORMALY.\ncheck $(echo "$driver_logfile" | sed -n 's/^.*=//p').$end"
#					exit 0
				fi
#			else
#				zenity --title="Zenvidia" --info --no-wrap \
#				--text="$j$msg302$end" ; sleep 1
			fi
		else
			zenity --width=450 --title="Zenvidia" --error --no-wrap \
			--text="$j\NO DRIVER FOUND IN KERNEL PATH$end$v.\nCheck $(echo "$logfile" | sed -n 's/^.*=//p').$end"
			exit 0
		fi
		
		cd $nvtmp
		if [ -s $nvtmp/NVIDIA-Linux-$ARCH-$new_version/nvidia-installer ]; then 
			echo "# backup Nvidia-Installer to $nvdir"; sleep 1
			echo "$n"; n=$[ $n+4 ]
			cp -f NVIDIA-Linux-$ARCH-$new_version/nvidia-installer $nvdir
			sleep 1
		else
			zenity --width=450 --title="Zenvidia" --error --no-wrap \
			--text="$vB\Nvidia-Installer not found$end$v.\nAbort and back to main.$end"
			exit 0
			base_menu
		fi
		mod_version=$($d_modinfo -F version nvidia)
		if [[ $mod_version != $new_version ]]; then
			echo "# WARNING : nvidia-installer didn't match new $version module. TRYING TO FIX"
			sleep 1
		else
			echo "# Update new driver list to log..."; sleep 1; echo "$n"; n=$[ $n+4 ]
			printf "$new_version" > $nvdir/version.txt
			echo "# Update compatibility data files..."; sleep 1; echo "$n"; n=$[ $n+4 ]
			cat NVIDIA-Linux-$ARCH-$new_version/README.txt | sed -n '/A1. N*/,/Below are the legacy GPU/p' > $nvdir/supported.txt
			cat NVIDIA-Linux-$ARCH-$new_version/README.txt | sed -n '/The 304.xx/,/The 173.14.xx/p' > $nvdir/supported.304.xx
			cat NVIDIA-Linux-$ARCH-$new_version/README.txt | sed -n '/The 173.14.xx/,/The 96.43.xx/p' > $nvdir/supported.173.14.xx
			cat NVIDIA-Linux-$ARCH-$new_version/README.txt | sed -n '/The 96.43.xx/,/The 71.86.xx/p' > $nvdir/supported.96.43.xx
			cat NVIDIA-Linux-$ARCH-$new_version/README.txt | sed -n '/The 71.86.xx/,/Appendix B./p' > $nvdir/supported.71.86.xx
		fi
#		driver_version=$(cat $nvdir/version.txt)
		if [ ! -f $nvdl/nv-update-$new_version ] ; then
			cp -f $driverun $nvdl/nv-update-$new_version
			if [[ -f $nvdl/nv-update-$new_version ]] ; then
				echo "# $msg303 $new_version $msg305."; sleep 1; echo "$n"; n=$[ $n+4 ]
				echo "# $msg304."; sleep 1; echo "$n"; n=$[ $n+4 ]
			else
				zenity --width=450 --title="Zenvidia" --error --no-wrap \
				--text="\n$v $msg303$j $new_version$v $msg306."
			fi
		else
			echo "# nv-update-$new_version already present in path, skip."; sleep 1
			echo "$n"; n=$[ $n+4 ]
		fi
		## NEXT ##
		post_install
		#remave temp dir content
#		mv -f version.txt ../
#		rm -rf $nvtmp/*
		echo "100"; sleep 2
		if [ $optimus = 0 ]; then
			zenity --width=450 --title="Zenvidia" --warning \
			--text="$vB\BE AWARE$end$v because of a GLX load issue,\nXserver will probably crash after libGLX install.$end"
			(nv_cmd_install_glx &
			 sleep 1
			)| zenity --width=450 --title="Zenvidia" --progress --pulsate --auto-close \
			--text="$v\Install GLX librairies...$end"
		fi
#		) | zenity --width=450 --title="Zenvidia" --progress --pulsate --auto-close
		) | zenity --width=450 --title="Zenvidia" --progress --percentage=1 --auto-close
		zenity --title="Zenvidia" --info --no-wrap \
		--text="$vB$msg302$end"
		if [ $? = 0 ]; then base_menu; fi
		base_menu
	else
		zenity --width=450 --title="Zenvidia" --error \
		--text="$v$msg310$end\n$v$msg311$end$y\http://www.nvidia.fr/Download/Find.aspx?lang=en$end\n$v $msg316, $v$msg311$end$y ftp://download.nvidia.com/XFree86/$end"
		if [ $? = 0 ]; then base_menu; fi
	fi
}

upgrade_new_kernel(){
	up_version=$(cat $nvdir/version.txt)
	ls_kern=$(ls -1 /boot| grep -v "rescue"| grep "vmlinuz"| sed -n 's/^[[:alpha:]]*-//p')
	for linuz in ${ls_kern}; do
		kern_list+=("false")
		kern_list+=("$linuz")
	done
	NEW_KERNEL=$(zenity --height=300 --title="Zenvidia" --list --radiolist --hide-header \
	--text "$menu_msg\n$v$m_02_07$end $j$up_version$end $v$m_02_08$end $j$board$end.
\n$v$m_02_09$end" --column "1" --column "2" --separator=";" "${kern_list[@]}" false "$MM"
	if [ $? = 1 ]; then base_menu; fi)
	upgrade_kernel
}
upgrade_kernel(){
#	kernel_path=/lib/modules/$(uname -r)/misc/video
	if_optimus
	if [[ $(echo $NEW_KERNEL) != '' ]];then
		KERNEL=$NEW_KERNEL
	else
		KERNEL=$(uname -r)
	fi
	if [ $upgrade_new = 0 ]; then
		kernels="-K"
		kernel_path="/lib/modules/$KERNEL/extra/"
		kernel_src="/usr/src$alt/$KERNEL"
	else 
		kernels="-K"
	fi
	drv_release=$(ls $nvdl/ | grep "$version")
	zenity --width=450 --title="Zenvidia" --question \
	--text="$v$m_02_01$end $j$KERNEL$end:\n$v$drv_install_msg$end.\n$v$m_02_03$end" \
	--ok-label="$CC" --cancel-label="$MM"
	if [ $? = 1 ]; then base_menu; fi
	
	( echo "# $m_02_01 $KERNEL ..."
	cd $nvdl/
	nv_cmd_update
	if [ ! -f $kernel_path/nvidia.ko ]; then
		zenity --width=450 --title="Zenvidia" --error \
		--text="$j INSTALL ABORT ABNORMALY, check $(echo "$logfile" | sed -n 's/^.*=//p')$end."
		exit 0
	else
		echo "# $m_02_04" ; sleep 1
		if [ -x $install_dir/bin/optirun ]; then
			new_version=$version
			driver_conf
			echo "# $m_02_05."; sleep 1
			if [[ $(cat /proc/version | grep -o "[Rr]ed [Hh]at") != '' ]]; then
				/usr/bin/systemctl restart bumblebeed.service
			else
				/usr/bin/service restart bumblebeed
			fi
		fi
		echo "# $m_02_06" ; sleep 1
	fi
	) | zenity --width=450 --title="Zenvidia" --progress --pulsate --auto-close
	if [ -e $nvlog/install.log ]; then cp -f $nvlog/install.log $nvlog/update-$KERNEL.log; fi
	base_menu
}

## INSTALL MODE DIRECTORY OPTIONS 
extract_build(){
	mkdir -p $nvtmp
	mkdir -p $buildtmp
#	if [ ! -d $nvtmp/NVIDIA-Linux-$ARCH-* ]; then
	cd $nvtmp
	[ ! -d NVIDIA-Linux-$ARCH-* ]|| rm -Rf NVIDIA-Linux-$ARCH-*
	(	sh $driverun -x 
		sleep 1
	) | zenity --width=450 --title="Zenvidia" --progress --pulsate --auto-close \
	--text="$v$m_02_10...$end"
	if [ -s NVIDIA-Linux-$ARCH-*/nvidia-installer ] ; then
		cp -f NVIDIA-Linux-$ARCH-*/nvidia-installer .
		new_version=$(cat NVIDIA-Linux-$ARCH-*/.manifest | sed -n '2p')
		printf "$new_version\n" > $nvdir/new_version.txt		
		if [[ $(cat $nvdir/version.txt) ]]&&[[ $(cat $nvdir/version.txt) != $new_version ]]; then
			old_version=$(cat version.txt)
			printf "$old_version\n" > $nvdir/old_version.txt
		else
			old_version='none'
		fi
	else
		zenity --width=450 --title="Zenvidia" --error \
		--text="$j $m_02_11$end,$v $m_02_12$end."
		exit 0
	fi
	cd $nvdir
#	fi
}
# OPTIMUS PRESENCE CONTROL
if_optimus(){
		[ $if_update = 0 ]&& extract_build
		[ $if_update = 1 ]&& new_version=$version
#		[ $upgrade_new -gt 0 ]&& new_version=$version
		predifine=3
#		optimus=0
#		croot=$croot
		predifined_dir=nvidia.$new_version
		croot_all=$croot/$predifined_dir
		croot_32=$croot/$predifined_dir/$master$ELF_32
		croot_64=$croot/$predifined_dir/$master$ELF_64
		xorg_dir=$croot/$predifined_dir/xorg
#		tool_dir=/usr/local
		kernel=$(uname -r)
		kernel_path=/lib/modules/$(uname -r)/extra
#		kernel_src=/usr/src/$(uname -r)
		if [ $if_update = 0 ]; then
			for i in "$croot/$predifined_dir $croot_32 $croot_64 $xorg_dir"; do
				mkdir -p $i
			done
			cd $croot
			## create distro xorg lib dirs symlink in case compiler doesn't find them
			ln -sf -T /usr/$master$ELF_32 $xorg_dir/$master$ELF_32
			ln -sf -T /usr/$master$ELF_64 $xorg_dir/$master$ELF_64
			cd $nvdl
		fi
		drv_install_msg="$v$m_02_13.$end"		
}
# DISTRO REPO DRIVER
if_legacy(){
	[ $if_update = 0 ]&& extract_build
	[ $if_update = 1 ]&& new_version=$version
	predifine=2
	#croot_32=/usr/lib/$predifined_dir
	croot=/usr
	predifined_dir="nvidia-current"
	croot_64=$croot/$master$ELF_64/$predifined_dir
	croot_32=$croot/$master$ELF_32/$predifined_dir
	croot_all=$croot_64
	xorg_dir=$croot/xorg
	tool_dir=/usr
	kernel_path=/lib/modules/$(uname -r)/extra
#	kernel_src=/usr/src/$(uname -r)
	if [ $if_update = 0 ]; then
		mkdir -p $croot_64
		if [ -e /usr/$master$ELF_64 ]; then
			#mkdir -p $croot_64/bin
			mkdir -p $croot_64/xorg/modules
			mkdir -p /usr/$master$ELF_64/vdpau
		else
			croot_64=$croot_32
			mkdir -p $croot_32/xorg/modules
			mkdir -p /usr/$master$ELF_32/vdpau
		fi
	fi
	drv_install_msg="$v$m_02_14.$end"
}
# PROPRIATARY DRIVER CLASSIC INSTALL
if_private(){
	[ $if_update = 0 ]&& extract_build
	[ $if_update = 1 ]&& new_version=$version
	predifine=1
#	kernel_src=/usr/src/$(uname -r)
	predifined_dir=nvidia.$new_version
	croot_all=$croot/$predifined_dir
	croot_32=$croot/$predifined_dir/$master$ELF_32
	croot_64=$croot/$predifined_dir/$master$ELF_64
	xorg_dir=$croot/$predifined_dir/xorg
#	tool_dir=/usr/local
	kernel=$(uname -r)
	kernel_path=/lib/modules/$(uname -r)/extra
#	kernel_src=/usr/src/$(uname -r)
	if [ $if_update = 0 ]; then
		for i in "$croot/$predifined_dir $croot_32 $croot_64 $xorg_dir"; do
			mkdir -p $i
		done
		cd $croot
		## create distro xorg lib dirs symlink in case compiler doesn't find them
		ln -sf -T /usr/$master$ELF_32 $xorg_dir/$master$ELF_32
		ln -sf -T /usr/$master$ELF_64 $xorg_dir/$master$ELF_64
		cd $nvdl
	fi
	drv_install_msg="$v$m_02_15.$end"		
}
install_dir_sel(){
	A1="$m_01_22"
	A2="$m_01_23"
	A3="$m_01_24"
	dir_cmd=$(zenity --width=450 --height=300 --title="Zenvidia" --list --radiolist \
	--text="$v$m_01_25\n$m_01_26 $croot/$predifined_dir.$end" \
	--hide-header --column "1" --column "2" --column "3" --separator=";" --hide-column=2 \
	false 1 " $A1" false 2 " $A2" false 3 " $A3" false 4 "$MM")
	if [ $? = 1 ]; then exit 0; fi
	case $dir_cmd in
		"1") if_private; optimus=0 ;;
		"2") if_legacy; optimus=0 ;;
		"3") optimus=1
			if [ -x $install_dir/bin/optirun ]; then
				if_optimus
				install_msg="$m_01_27$end"
			else
				install_msg="$j\ATTENTION$end$v$m_01_28$end"
				if [[ $? == 1 ]]; then
					optimus_src_ctrl
				else
					exit 0
				fi
			fi
		;;
		"4") base_menu ;;
	esac
	install_drv
}
### FROM A USER DIRECTORY INSTALL FUNCTION.
from_directory(){
	nv_dir(){
		table_opts='--column \"1\" --column \"2\" --separator=\";\"'
		cd $nvdl; n=1
		for local_drv in $(ls -1 $nvdl); do
			list_drv+=("false")
#			list_drv+=("$n")
			list_drv+=(" $local_drv")
#			n=$[ $n+1 ]
		done
		drv_pick=$(zenity --width=450 --height=400 --title="Zenvidia" $zen_opts \
		--text="$v$m_01_05 $nvdl :$end"\
		$table_opts ${list_drv[@]} false "$R")
		if [ $? = 1 ]; then base_menu; fi
		if [[ "$drv_pick" == "$R" ]]; then from_directory; fi
		driverun=$nvdl/$drv_pick
	}
	home_dir(){
		cd /home
		driverun=$(zenity --width=450 --height=400 --title="Zenvidia" --file-selection \
		--filename="/home/$user/$w_01" --file-filter=".run" --text="$v$m_01_06$j $homerep$end")
		if [ $? = 1 ]; then base_menu; fi
		chmod a+x $driverun
	}
	A="$m_01_03"
	B="$m_01_04"
	zen_opts='--list --radiolist --hide-header'
	table_opts='--column "1" --column "2" --column "3" --separator=";" --hide-column=2'
	n=1
	from_cmd=$(zenity --width=450 --height=400 --title="Zenvidia" $zen_opts \
	--text="$v $m_01_01$end\n$j$(printf "$(ls $nvdl|sed -n 's/^/\t - /p')")$end\n$v$m_01_02$end" \
	$table_opts false 1 "$A" false 2 "$B" false 3 "$PM" )
	if [ $? = 1 ]; then base_menu; fi
	case $from_cmd in
		"1") nv_dir; install_dir_sel ;;
		"2") home_dir; install_dir_sel ;;
		"3") menu_install ;;
	esac
}

# check aviable updates
check_update(){
	( lftp -c "anon; cd ftp://$nvidia_ftp-$ARCH/ ; ls > $nvtmp/drvlist ; cat latest.txt > $nvtmp/last_update "
	) | zenity width=400 --title="Zenvidia" --progress --pulsate --auto-close \
	--text="$v$m_01_07$end"
	LAST_IN=$version
	LAST_DRV=$(cat $nvtmp/last_update | awk '{ print $1 }')
	LAST_BETA=$(cat $nvtmp/drvlist | awk '{ print $9 }' | sort -gr | sed -n 1p)
	# compatibilty control
	if [[ $LAST_DRV == $LAST_BETA ]] ; then
			DIFF_list=$LAST_DRV
	else
#			DIFF_list=$(echo -e "$LAST_DRV\n$LAST_BETA")
			DIFF_list="$LAST_DRV $LAST_BETA"
	fi
	TF=1; w_height=355
	for DRV in $DIFF_list; do
		(wget -q -O $nvtmp/compat.$TF \
		ftp://$nvidia_ftp-$ARCH/$DRV/README/supportedchips.html
		sleep 1
		)| zenity width=400 --title="Zenvidia" --progress --pulsate \
		--auto-close --text="$v$m_01_08$end ($DRV)..."
	for e in $pci_dev_nb; do
		DEV_filter=$(cat $nvtmp/compat.$TF|sed -n "/devid${slot_id[$e]}\"/,/^.*<td>/{n;p}")
		DEV_nm=$(printf "$DEV_filter"|sed -n '1p'|sed -n 's/<[^>]*//g;s/>//g;p')
		VDPAU=$(printf "$DEV_filter"|sed -n '$p'|sed -n 's/<[^>]*//g;s/>//g;p')
		if [ "$DEV_nm" == "${dev[$e]}" ]; then
			if [ $VDPAU != '' ]; then 
				COMP_V=0
				comp_v="(VDPAU class $VDPAU)"
			else
				COMP_V=1
				comp_v=""	
			fi
			COMP_B=0
			comp_b="$m_01_10. $comp_v"
			comp_c="$v$m_01_11$end"
			comp_check=0
		else
			COMP_B=1
			COMP_V=1
			comp_b="$vB$m_01_09$end"
			comp_c="$v$m_01_12$end"
			comp_check=1
			comp_v=""	
		fi
		if [ "$DEV_nm" == "${dev[$e]}" ]; then
			COMP_L+=("$j${dev[$e]}$end $v($DRV), $comp_b$end\n$j$DRV$end $comp_c")
			w_height=$(($w_height+30))
		fi
	done
		((TF++))
	done
	ifs=$IFS
	IFS="
	
"
	compat_msg="${COMP_L[*]}\n"
	IFS=$ifs
	win_update
}
win_update(){
	if [[ $(ls -1 $nvdl/ | grep "$LAST_DRV\|$LAST_BETA") != '' ]]; then
		if [ -e $nvdl/nv-update-$LAST_DRV ]; then
			if [[ $LAST_IN == $LAST_DRV ]]; then set_in="($m_01_18)"; fi
			start_msg="$j$LAST_DRV$end$vB $m_01_14a $m_01_16.$end$v$set_in$end"
			up_check=0
			end_msg=$m_01_17
			if [ $LAST_BETA != '' ]; then
					more_msg="\n$j$LAST_BETA$end$vB $m_01_14b $m_01_16.$end"
					end_msg="\n$m_01_13"
					w_height=$(($w_height+65))
					up_check=1
			fi
		elif [ -e $nvdl/nv-update-$LAST_BETA ]; then
			if [[ $LAST_IN == $LAST_BETA ]]; then set_in="($m_01_18)"; fi
			start_msg="$j$LAST_BETA$end$vB $m_01_14a $m_01_16.$end$v$set_in$end"
			end_msg="$m_01_17"
			up_check=0
			if [ $LAST_DRV != '' ]; then
					more_msg="\n$j$LAST_DRV$end$vB $m_01_14b $m_01_16.$end"
					end_msg="\n$m_01_13"
					w_height=$(($w_height+65))
					up_check=1
			fi
		fi
		if [ -e $nvdl/nv-update-$LAST_DRV ]&&[ -e $nvdl/nv-update-$LAST_BETA ]; then
			if [[ $LAST_DRV == $LAST_BETA ]]; then
				start_msg="$j$LAST_DRV$end$vB, $m_01_14c $m_01_16.$end"
			else
				if [[ $LAST_IN == $LAST_DRV||$LAST_BETA ]]; then
					set_in="($LAST_IN $m_01_18)"
				fi
				start_msg="\n$v$m_01_14c $m_01_16 $set_in.$end"
			fi
			more_msg=''
			up_check=0
			end_msg="$m_01_17"
		fi		
		extra_msg="\n$start_msg$more_msg\n$v$end_msg$end"
	else
		extra_msg="\n$v$m_01_13$end"
	fi
	if [ $up_check = 0 ]; then
		w_height=300
		zen_opts='--info --window-icon=swiss_knife.png'
		table_opts=''
		list_opts=''
	elif [ $up_check = 1 ]; then
		# 395
#		w_height=365
		zen_opts='--list --radiolist --hide-header'
		table_opts='--column "1" --column "2" --column "3" --separator=";" --hide-column=2'
		list_opts="false 1 $_01 false 2 $_06 false 3"
	#		if [ $TF -ge 2 ]; then
	#		qst_msg="\n$v$m_01_13$end"
	#		fi
	elif [ $up_check = 2 ]; then
		w_height=300
		zen_opts="--question --ok-label=$_01 --cancel-label=$_07"
		table_opts=''
		list_opts=''
		extra_msg="\n$v$m_01_13$end"
	fi
	sel_cmd=$(zenity --width=450 --height=$w_height --title="Zenvidia" $zen_opts \
	--text="$eN$m_01_19$end\n
$v $msg_0_01$end\t\t\t$j$LAST_IN$end
$v $m_01_20$end\t\t\t$j$LAST_DRV$end
$v $m_01_21$end\t\t\t$j$LAST_BETA$end\n
$compat_msg$extra_msg" $table_opts $list_opts "$R" )
	if [ $? = 0 ]; then
		if [ $up_check != 0 ]; then
			if [ $up_check = 1 ]; then
				case $sel_cmd in
					"1") from_net ;;
					"2") download_only ;;
					"3") base_menu ;;
				esac
			elif [ $up_check = 2 ]; then
				from_net
			fi 	
		elif [ $up_check = 0 ]; then
			base_menu
		fi
	elif [ $? = 1 ]; then exit 0
	fi
		
}
download_menu(){
	unset DM_list
	dn=1
	if [ $if_update = 1 ]; then
		D1=" $LAST_DRV ($msg413a)"
		D2=" $LAST_BETA ($msg413b)"
	else
		D1=" $LAST_DRV ($msg413a)"
		D2=" $LAST_BETA ($msg413b)"
		D3=" $msg419 ($msg413c)"
	fi
	for drv_ld in {"$D1","$D2","$D3"}; do
		if [[ "$drv_ld" != '' ]]; then
			DM_list+=("false")
			DM_list+=("$dn")
			DM_list+=("$drv_ld")
			((dn++))
		fi
	done		
	dl_cmd=$(zenity --width=450 --height=300 --title="Zenvidia" --list --radiolist \
	--text="$v$msg413$end" --hide-header \
	--column "1" --column "2" --column "3" --separator=";" --hide-column=2 \
	"${DM_list[@]}" false $dn "$MM" )
	if [ $? = 1 ]; then exit 0; fi
	if [ $if_update = 1 ]; then
		case $dl_cmd in
			"1")
				LAST_PACK=$LAST_DRV; last_pack
			;;
			"2")
				LAST_PACK=$LAST_BETA; last_pack
			;;
			"$dn")
				base_menu
			;;
		esac
	else
		case $dl_cmd in
			"1")
				LAST_PACK=$LAST_DRV; last_pack
			;;
			"2")
				LAST_PACK=$LAST_BETA; last_pack
			;;
			"3")
				package_list; LAST_PACK=$PICK_DRV; last_pack
			;;
			"$dn")
				base_menu
			;;
		esac
	fi
	
}
download_only(){
	if [ -e $nvdir/nvidia-installer ] ; then
		cd $nvupdate
		download_menu
		if [ -f $nvupdate/$run_pack ]; then
			zenity --info --title="Zenvidia" --no-wrap \
			--text="$v $msg415c$end $j$LAST_PACK$end $v$msg415d.\n$MM$end"
			mv -f $nvupdate/$run_pack $nvdl/nv-update-$LAST_PACK
			chmod 755 $nvdl/nv-update-$LAST_PACK
			base_menu
		else
			zenity --width=450  --title="Zenvidia" --error \
			--text="$v $msg415c$end $j$LAST_PACK$end $v$msg415e.\n $msg406$end $j$run_pack$end $v$msg407.\n$MM.$end"	
			base_menu
		fi
	else
		zenity --width=450 --title="Zenvidia" --error --text="$v$msg416.\n$MM$end"
		base_menu
	fi
}
### UPDATE FUNCTION, FROM INTERNET.
package_list(){
	pck_drv=$(tac $nvtmp/drvlist | sed -n "s/^.*\ //p" | sed -n "/^3\|^2/p")
	for line in $pck_drv; do
		drv_list+=("$line")
	done
#	PICK_DRV=$(zenity --width=450  --height=300 --title="Zenvidia" \
#	--entry --text "Driver list" --entry-text="${drv_list[@]}")
	PICK_DRV=$(zenity --width=450  --height=300 --title="Zenvidia" --list --radiolist \
	--text "Driver list" --hide-header --column "1" --column "2" --separator=";" \
	"${drv_list[@]}")
	if [ $? = 1 ]; then exit 0; fi
}
last_pack(){
	download_cmd(){
		wget -c -o $nvtmp/dl.log ftp://$nvidia_ftp-$ARCH/$LAST_PACK/$run_pack $nvupdate/ &
		dl_pid=$(pgrep wget)
		sleep $dl_delay
	}
	track(){
		for percent in $(tail -n20 $nvtmp/dl.log); do
			percent=$(tac $nvtmp/dl.log | grep "\%" | sed -n "s/^.*\. //;s/\%.*$//;s/^.*\ //g;p"|sed -n 2p)
			weight=$(tac $nvtmp/dl.log | grep "\%" | awk '{print $1}'| sed -n 1p)
			speed=$(tac $nvtmp/dl.log | awk '{print $8}'| sed -n 2p)
			left=$(tac $nvtmp/dl.log | awk '{print $9}'| sed -n 2p)
			echo "# ($percent %) $weight downloaded at $speed/s, time left : $left"; sleep 1
			echo "$percent" ; sleep 1
#			if [[ $(printf "$speed"|grep -o "K\|M") != '' ]]; then
				local_0=$(stat -c "%s" $nvupdate/$run_pack)
#			else
#				if [ $speed != '' ]; then
#					local_0=$(printf "$speed"|sed -n 's/\[\|\]//g;p')
#				else
#					local_0=$(stat -c "%s" $run_pack)
#				fi
#			fi
			if [ $percent = 99 ]; then
				if [ $local_0 = $remote ]; then
					echo "# $w_02 terminé (100 %)."; sleep 3
					echo "100"
				fi
			fi
		done
	}
	( lftp -c "anon; cd ftp://download.nvidia.com/XFree86/Linux-$ARCH/$LAST_PACK/ ; ls > $nvtmp/bug_list ; quit" ; sleep 2
	) | zenity --width=450 --progress --pulsate --auto-close --text="$v$msg405$end"
	if [ "$(cat $nvtmp/bug_list | grep -w "$LAST_PCK")" != '' ] ; then
		RUN_PACK=$(cat $nvtmp/bug_list | sed -n "s/^.*\ //p"|grep -w "$LAST_PACK"|sed -n "/.run$/p")
	fi
#	n=1
	unset drv_list
	for line in $RUN_PACK; do
		drv_list+=("false")
#		drv_list+=("$n")
		drv_list+=("$line")
#		n=$[ $n+1 ]
	done
	run_pack=$(zenity --width=450 --height=300 --title="Zenvidia" --list \
	--text="$v$m_01_40$end" --radiolist --hide-header \
	--column "1" --column "2" "${drv_list[@]}" --separator=";")
	if [ $? = 1 ]; then exit 0; fi
	remote=$(cat $nvtmp/bug_list | grep -w "$run_pack"|sed -n "/.run$/p"|awk '{print $5}')
	(
	sleep 1
	echo "Préparation..."; sleep 1
	download_cmd
	echo "# $w_02 $run_pack"
#	progress=`tail -n 20 $nvtmp/dl.log | grep "\%" | sed -n "s/^.*\. //p"`
	sleep 1
	track
	[ $remote = $local_0 ]|| (kill -s 15 $dl_pid; download_cmd; track)
	) | zenity --width=450 --progress --percentage=0 --auto-close \
	--text="$v Recherche de $run_pack...$end" --title="$msg415a $LAST_PACK"
	rm -f $nvtmp/dl.log
#	if [ -s $nvupdate/$run_pack ]; then
#		
#		local1=$(stat -c "%s" $nvupdate/$run_pack)
#		[ $remote = $local1 ]|| \
#		( zenity --width=450 --error --text="$v$msg415b$end" ; rm -f $nvtmp/dl.log ; last_pack )
#	fi
}
from_net(){
# download functions
	if [ -e $nvdir/nvidia-installer ] ; then
		cd $nvupdate
		download_menu
		driverun=$nvdl/nv-update-$LAST_PACK
		install_dir_sel
		#rm -f $nvtmp/drvlist $nvtmp/last_up
	else
		zenity --width=450 --title="Zenvidia" --error --text="$v$msg416.\n$MM$end"
		base_menu
	fi
}

drivercall(){ ls $nvtmp | grep "$version"; }
### RESTART X SESSION
drv_load(){
    /sbin/modprobe -r nvidia
    /sbin/depmod -a
    /sbin/modprobe nvidia
}
drv_unload(){
	/sbin/modprobe -r nvidia
}
### UNINSTALL fUnction
#uninstall(){
#	echo -e "$v $qst002 $j$qst001$v :"
#	echo -e "\n$v ==>$j \c"
#	read -n 1 yn
#	if [ "$yn" == "$qst004" ] ; then
#		
#		echo -e "\n$r --->$y     $msg531$r     $y\r"
#		cd $nvdir
#		nv_cmd_uninstall
#		echo -e "\f$v $msg532 \n" ; sleep 2
#		menu
#	else
#		menu_install
#	fi
#}

## EDITION
edit_script_conf(){
	edit_script=$(zenity --width=500 --height=400 --title="Zenvidia" --text-info \
	--editable --text="$v\Edit script config file$end" --filename="$script_conf" \
	--checkbox="Confirm to overwrite" )
#	exit_stat=$?
	if [[ $(printf "$edit_script"| sed -n '1p') != '' ]]; then
		printf "$edit_script" > $script_conf
	fi
#	if [ $exit_stat = 0 ]; then menu_manage
#	elif [ $exit_stat = 1 ]; then exit 0
#	fi
	menu_modif
}
edit_xorg_conf(){
	if [ -x $tool_dir/bin/optirun ]; then
		xorg_cfg=$tool_dir/etc/bumblebee/xorg.conf.nvidia
	else
		xorg_cfg=/etc/X11/xorg.conf
	fi
	edit_xorg=$(zenity --width=500 --height=400 --title="Zenvidia" --text-info --editable \
	--text="$v\Edit xorg config file$end" --filename="$xorg_cfg" \
	--checkbox="Confirm to overwrite" )
	if [[ $(printf "$edit_xorg"| sed -n '1p') != '' ]]; then
		printf "$edit_xorg" > $xorg_cfg
	fi
#	if [ $? = 0 ]; then menu_manage
#	elif [ $? = 1 ]; then exit 0
#	fi
	menu_modif
}
read_help(){
	zenity --width=500 --height=400 --title="Zenvidia" --text-info \
	--text="$v\Help files for senvidia$end" --filename=""
	menu_manage
}
read_nv_help(){
	zenity --width=700 --height=400 --title="Zenvidia" --text-info \
	--text="$v\Nvidia driver man page$end" --filename="$help_pages/README.txt"
	menu_manage
}
read_changelog(){
	zenity --width=600 --height=400 --title="Zenvidia" --text-info \
	--text="$v\Nvidia $version changelog$end" --filename="$help_pages/NVIDIA_Changelog"
	menu_manage
}
nv_config(){
	if [ -x $tool_dir/bin/optirun ]; then
		$SUd $def_user -c 'optirun -b none nvidia-settings -c :8'
	else
		$SUd $def_user -c "nvidia-settings"
	fi
	menu_modif
}

## START
lang_define(){
	## language pack
	if [[ $LG != '' ]];then
	PACK=$LG\_PACK
	. $locale$PACK
	else
		zenity --width=450 --title="Zenvidia" --warning \
		--text="$v\Langage pack not define.\nCheck script conf to fix.$end"
		exit 0
	fi
}
root_id(){
	if [[ $user != 'root' ]] ; then
		user_id
	fi
}
install_controls(){
	if [ -d $nvdir ] ; then
		mkdir -p $nvtar $buildtmp $nvtmp $nvlog $nvupdate $nvdl $locale
	fi
	nvdl_last=$(ls -1 $nvdl/|sed -n '$p')	
	if [[ $nvdl_last != '' ]] ; then
		for changes in $(ls -1 $nvdl ); do
			if [[ $(stat -c "%a" $nvdl/$changes) != 755 ]]; then
				chmod 755 $nvdl/$changes
			fi
		done
	fi
	dep_control
	if [ -d $install_dir/NVIDIA ] ; then
		dir_msg="$j $ansOK$end"
	else
		dir_msg="$j $ansNF\n$y$msg_00_07$end"
		install_dir=$(zenity --file-selection --directory \
		--text="$v$msg_00_07.\n$msg_00_08$end :")
		sed -ni "s/nvdir=\"\(.*\)\"/nvdir=\"$install_dir\/NVIDIA\"/i;p" $script_conf
		sed -ni "s/install_dir=\"\(.*\)\"/install_dir=\"$install_dir\"/i;p" $script_conf
		mkdir -p $nvtar $nvtmp $nvlog $nvupdate $nvdl $locale
	fi
}
### TERTIARY MENU
glx_test(){
	ifs=$IFS
	IFS="
"
	if [ -x $install_dir/bin/optirun ]; then
		test_v='optirun -b virtualgl'
		test_p='optirun -b primus'
		test_cmd="$G20 (virtualgl),$G21 (virtualgl),$G20 (primus),$G21 (primus),$PM"
	else
		test_x=''
		test_cmd="$G20,$G21,$PM"
	fi
	nt=1
	unset test_list
	for xtest in $(printf "$test_cmd"| tr "," "\n"); do
		test_list+=("false")
		test_list+=("$nt")
		test_list+=("$xtest")
		nt=$[ $nt+1 ]
	done
	
#	unset menu_list
#	n=1
#	for mtest in "$(printf "$test_cmd"|tr "," "\n")"; do	
#		
#		n=$[ $n+1 ]
#	done
	menu_test=$(zenity --width=400 --height=300 --list --radiolist --hide-header \
	--title="Zenvidia" --text "$eN$G10$end" \
	--column "1" --column "2" --column "3" --separator=";" --hide-column=2 \
	"${test_list[@]}" )
	if [ $? = 1 ]; then exit 0; fi
	g='\e[1;32m'
	x_opt="-sb -b 5 -bg black -bd green -bw 0 -title Zenvidia_Gears"
	if [ -x $install_dir/bin/optirun ]; then
		if [[ $menu_test = 1 || $menu_test = 2 ]]; then test_x="$test_v"
		elif [[ $menu_test = 3 || $menu_test = 4 ]]; then test_x="$test_p"
		fi
	else test_x=""
	fi
	IFS=$ifs
	case $menu_test in
		"1") xterm $x_opt -e "printf \"$g Press [ctrl+c] to end test.\n\"; \
		$test_x glxgears"; glx_test ;;
		"2") $test_x glxspheres; glx_test ;;
		"3") xterm $x_opt -e "printf \"$g Press [ctrl+c] to end test.\n\"; \
		$test_x glxgears"; glx_test ;;
		"4") $test_x glxspheres; glx_test ;;
		"$nt") menu_manage ;;
	esac
	
	if [[ $menu_test = $[ $nt-1 ] ]]; then
		menu_manage
#	else
#		glx_test
	fi
}
manage_pcks(){
	menu_packs=$(zenity --width=400 --height=300 --list \
	--radiolist --hide-header --title="Zenvidia" \
	--text "$eN$G9$end" \
	--column "1" --column "2" --column "3" --separator=";" --hide-column=2 \
	false 1 "$G9a" false 2 "$G9b" false 3 "$PM" )
	if [ $? = 1 ]; then exit 0; fi
	case $menu_packs in
		"1") remove_pcks ;;
		"2") backup_pcks ;;
		"3") menu_modif ;;
	esac
}
remove_pcks(){
	# list package in release directory
	unset packs_list
	for pack in $(ls -1 $nvdl); do
		packs_list+=("false")
		packs_list+=("$pack")
	done
	rm_packs=$(zenity --width=400 --height=300 --list \
	--radiolist --hide-header --title="Zenvidia (remove)" \
	--text "$eN$G9a$end" \
	--column "1" --column "2" --separator=";" \
	"${packs_list[@]}" )
	if [ $? = 1 ]; then exit 0; fi
	pack_repo=$(printf "$rm_packs"|sed -n "s/^.*-//g;p")
	zenity --width=450 --title="Zenvidia ($G9a)" --question \
	--text="$v$G9d $rm_packs.\n$G9g$end" \
	--ok-label="$CC" --cancel-label="$R"
	if [ $? = 0 ]; then
		if [ -d $croot/nvidia.$pack_repo ]; then
			zenity --width=450 --title="Zenvidia ($G9a)" --question \
			--text="$v$G9f $croot.\n$G9g$end"
			if [ $? = 1 ]; then
				rm -Rf $croot/nvidia.$$pack_repo
			fi
		fi
		rm -f $nvdl/$rm_packs
		manage_pcks
	else
		manage_pcks
	fi
}
backup_pcks(){
	# list package in release directory
	unset drive_list
	croot_repo=$(ls -1 $croot| grep "nvidia.[[:digit:]]" | grep -v ".bak")
	for drive in $croot_repo; do
		drive_list+=("false")
		drive_list+=("$drive")
	done
	drive_packs=$(zenity --width=400 --height=300 --list \
	--radiolist --hide-header --title="Zenvidia (backup)" \
	--text "$eN$G9b$end" --column "1" --column "2" --separator=";" \
	"${drive_list[@]}" )
	if [ $? = 1 ]; then exit 0; fi
	zenity --width=450 --title="Zenvidia ($G9b)" --question \
	--text="$v$G9e $drive_packs ?\n$G9g$end" \
	--ok-label="$CC" --cancel-label="$R"
	if [ $? = 0 ]; then
		mod_src=/lib/modules/$(uname -r)/extra
		ko_version=$($d_modinfo -F version nvidia)
		ko_repo=$(printf "$drive_packs"|sed -n "s/nvidia.//p")
		drv_id=$ko_repo
		if [[ $ko_version == $ko_repo ]]; then
			[ -d $croot/$drive_packs/$(uname -r) ]|| mkdir -p $croot/$drive_packs/$(uname -r)
			[ -s $mod_src/nvidia.ko ]&& cp -f $mod_src/nvidia.ko $croot/$drive_packs/$(uname -r)/
			[ -s $mod_src/nvidia-uvm.ko ]&& cp -f $mod_src/nvidia-uvm.ko $croot/$drive_packs/$(uname -r)/
		fi
		cp -Rf $croot/$drive_packs $croot/$drive_packs.bak	
		if [ -d /usr/src/nvidia-$drv_id ]; then
			mkdir -p $croot/$drive_packs.bak/usr/src
			cp -Rf /usr/src/nvidia-$drv_id $croot/$drive_packs.bak/usr/src/
		fi
		if [ -d /var/lib/dkms/nvidia/$drv_id ]; then
			mkdir -p $croot/$drive_packs.bak/var/lib/dkms/nvidia/
			cp -Rf /var/lib/dkms/nvidia/$drv_id \
			$croot/$drive_packs.bak/var/lib/dkms/nvidia/
		fi
		if [[ $(ls -1 $install_dir/$master$ELF_32/libnvidia-*|sed -n '1p') != '' ]]; then
			mkdir -p $croot/$drive_packs$install_dir/$master$ELF_32
			cp -d $install_dir/$master$ELF_32/libnvidia-* $croot/$drive_packs.bak$install_dir/$master$ELF_32/
		fi
		if [[ $(ls -1 $install_dir/$master$ELF_64/libnvidia-*|sed -n '1p') != '' ]]; then
			mkdir -p $croot/$drive_packs$install_dir/$master$ELF_64
			cp -d $install_dir/$master$ELF_64/libnvidia-* $croot/$drive_packs.bak$install_dir/$master$ELF_64/
		fi
		if [ $ko_version != $ko_repo ]; then
			zenity --width=450 --title="Zenvidia ($G9b)" --question \
			--text="$v$G9h ?\n$G9g$end"
			if [ $? = 0 ]; then
				rm -Rf $croot/$drive_packs
			fi
		fi
		manage_pcks
	else
		manage_pcks
	fi
}
## TODO ##
#restore_pcks(){
#	
#}

### SUB MENU
menu_install(){
	menu_inst=$(zenity --width=400 --height=300 --list \
	--radiolist --hide-header --title="Zenvidia" \
	--text "$eN$_01$end" \
	--column "1" --column "2" --column "3" --separator=";" --hide-column=2 \
	false 1 "$_1a" false 2 "$_1b" false 3 "$_1c" false 4 "$_1d" false 5 "$MM" )
	if [ $? = 1 ]; then exit 0; fi
	case $menu_inst in
		"1") menu_msg="$vB$msg_1_01$end"; from_directory ;;
		"2") menu_msg="$vB$msg_1_02$end"; up_check=2; check_update ;;
		"3") menu_msg="$vB$msg_1_03$end"; build_all; base_menu	;;
		"4") menu_msg="$vB$msg_1_04$end"; nv_cmd_uninstall; base_menu ;;
		"5") base_menu ;;
	esac
}
menu_update(){
	nu=1
	if [ $use_dkms = 0 ]; then up_cmd_list="$_2a (dkms)","$_2a (force)","$_2b (dkms)",$_2c,$_2d
	else up_cmd_list=$_2a,$_2b,$_2c,$_2d
	fi
	unset up_list
#	for up_cmd in "$_2a" "$_2b" "$_2a (dkms)" "$_2b (dkms)" "$_2c" "$_2d"; do
	ifs=$IFS
	IFS="
	"
	for up_cmd in $(echo -e "$up_cmd_list"|tr "," "\n"); do
		up_list+=("false")
		up_list+=("$nu")
		up_list+=("$up_cmd")
		nu=$[ $nu+1 ]
	done 
	IFS=$ifs
	menu_upd=$(zenity --width=400 --height=300 --list \
	--radiolist --hide-header --title="Zenvidia" \
	--text "$eN$_02$end" \
	--column "1" --column "2" --column "3" --separator=";" --hide-column=2 \
	"${up_list[@]}" false $nu "$MM" )
	if [ $? = 1 ]; then exit 0; fi
#	case $menu_upd in
#		"1") menu_msg="$v$msg_2_01$end"; upgrade_new=1; upgrade_kernel; base_menu ;;
#		"2") menu_msg="$v$msg_2_02$end"; upgrade_new=0; upgrade_new_kernel; base_menu ;;
#		"3") menu_msg="$v$msg_2_01 (dkms)$end"; upgrade_new=1
#			 use_dkms=0; upgrade_kernel; base_menu ;;
#		"4") menu_msg="$v$msg_2_02 (dkms)$end"; upgrade_new=0
#			 use_dkms=0; upgrade_new_kernel; base_menu ;;
#		"5") menu_msg="$v$msg_2_03$end"; optimus_src_ctrl; base_menu ;;
#		"6") menu_msg="$v$msg_2_04$end"; up_check=1; check_update  ;;
#		"7") base_menu ;;
		if [ $use_dkms = 0 ]; then
			case $menu_upd in
				"1") menu_msg="$v$msg_2_01 (dkms)$end"
					 upgrade_new=1; use_dkms=0; upgrade_kernel; base_menu ;;
				"2") menu_msg="$v$msg_2_01 (force)$end" 
					 upgrade_new=1; use_dkms=1; force=0; upgrade_kernel; base_menu ;;
				"3") menu_msg="$v$msg_2_02 (dkms)$end"
					 upgrade_new=0; use_dkms=0; upgrade_new_kernel; base_menu ;;
				"4") menu_msg="$v$msg_2_03$end"
					 optimus_src_ctrl; base_menu ;;
				"5") menu_msg="$v$msg_2_04$end"
					 up_check=1; check_update  ;;
				"6") base_menu ;;
			esac
		else
			case $menu_upd in
				"1") menu_msg="$v$msg_2_01$end"
					 upgrade_new=1; upgrade_kernel; base_menu ;;
				"2") menu_msg="$v$msg_2_02$end"
					 upgrade_new=0; upgrade_new_kernel; base_menu ;;
				"3") menu_msg="$v$msg_2_03$end"
					 optimus_src_ctrl; base_menu ;;
				"4") menu_msg="$v$msg_2_04$end"
					 up_check=1; check_update  ;;
				"5") base_menu ;;
			esac
		fi
#	esac
}
menu_modif(){
	nd=1
	unset mod_list
	for mod_cmd in "$_3a" "$_3b" "$_3c" "$_3d" "$_3e" ; do
		mod_list+=("false")
		mod_list+=("$nd")
		mod_list+=("$mod_cmd")
		nd=$[ $nd+1 ]
	done
	menu_mod=$(zenity --width=400 --height=300 --list \
	--radiolist --hide-header --title="Zenvidia" \
	--text "$eN$_03$end" \
	--column "1" --column "2" --column "3" --separator=";" --hide-column=2 \
	"${mod_list[@]}" false $nd "$MM")
	if [ $? = 1 ]; then exit 0; fi
	case $menu_mod in
		"1") edit_xorg_conf ;;
		"2") edit_script_conf ;;
		"3") nv_config ;;
		"4") manage_pcks ;;
		"5") optimus_source_rebuild ;;
		"$nd") base_menu ;;
	esac
}
menu_manage(){
	nm=1
	unset mng_list
	for mng_cmd in "$_4a" "$_4b ($version)" "$_4c ($version)" "$_4d"; do
		mng_list+=("false")
		mng_list+=("$nm")
		mng_list+=("$mng_cmd")
		nm=$[ $nm+1 ]
	done
	menu_mng=$(zenity --width=400 --height=300 --list \
	--radiolist --hide-header --title="Zenvidia" \
	--text "$eN$_04$end" \
	--column "1" --column "2" --column "3" --separator=";" --hide-column=2 \
	"${mng_list[@]}" false $nm "$MM")
#	false 1 "$G5" false 2 "$G6" false 3 "$G7" false 4 "$G8" false 5 "$G9" false 6 "$G" )
	if [ $? = 1 ]; then exit 0; fi
	case $menu_mng in
		"1") glx_test ;;
		"2") read_nv_help ;;
		"3") read_changelog ;;
		"4") read_help ;;
		"$nm") base_menu ;;
	esac
}
### MAIN MENUS
base_menu(){
	devices=$(
	for e in $pci_dev_nb; do
		echo -e "$v$msg_00_04 $[${nm[$e]}+1] :$end\t\t $j${dev[$e]}\t($(printf "${vnd[$e]}"|awk '{print $1}'))$end"
#		echo -e "$v$msg_00_04 $((${nm[$e]}+1)) :$end\t\t $j${dev[$e]}\t($(printf "${vnd[$e]}"|awk '{print $1}'))$end"
	done
	)	
	menu_cmd=$(zenity --height=550 --title="Zenvidia" --list --radiolist --hide-header \
	--text "$eN$msg_00_01$end\n
$v\n$msg_00_02$end\t\t $j$DISTRO$end
$v$msg_0_00$end\t\t $j$ARCH$end
$devices 
$v$msg_0_01$end\t $j$version$end
$v$msg_0_02$end\t\t $j$kernel_ver$end
$v$msg_0_03$end\t\t $j$GCC$end
$v$msg_0_04$end\t $j$NV_bin_ver$end\n
$v$msg_0_05 : $end$dir_msg
$v$msg_0_06 : $end $j$cnx_msg$end
\n$v$msg601$end" \
	--column "1" --column "2" --column "3" --separator=";" --hide-column=2 \
	false 1 "$_01" false 2 "$_02" false 3 "$_03" false 4 "$_04" )
	if [ $? = 1 ]; then exit 0; fi
	case $menu_cmd in
		"1") if_update=0; menu_install ;;
		"2") if_update=1; menu_update ;;
		"3") if_update=1; menu_modif ;;
		"4") if_update=1; menu_manage ;;
	esac
}

first_start(){
	### FIRST START
	root_id
	## Creation of necessary directories in case they aren't already there.:
#	distro
	version_id
	compil_vars
	install_controls
	driver_loaded
	connection_control
	base_menu
}
### SCRIPT INTRO
#if [[ $(cat $locale/script.conf| grep "LG=$LG") == '' ]]; then
if [[ $(cat $script_conf| grep "LG=$LG") == '' ]]; then
	echo -e "$r no language pack chosen\n EN = english\n FR = Français.$t"
	exit 0
else
	lang_define
fi

libclass; distro; ID ; arch ; first_start

exit 0

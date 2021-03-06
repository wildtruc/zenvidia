#! /bin/bash

#  Zenvidia
#  Sat Feb  6 16:58:20 2010
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

# defaults
#SHELL=/bin/bash
#PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin
#cd /

### VARS
## Master Vars.
install_dir=/usr/local						# default tools & system install directory
nvdir=$install_dir/NVIDIA						# default Zenvidia directory
conf_dir="$install_dir/NVIDIA"
#conf_dir="/usr/local/etc"						# default conf directory << TODO ?
conf_dir=$nvdir
basic_conf=$nvdir/basic.conf
script_conf=$nvdir/script.conf					# Zenvidia conf file
color_conf=$nvdir/color.conf					# Zenvidia UI font color file
croot="$install_dir/DRIVERS"					# language packs
locale="$nvdir/translations"					# language packs
nvtar="$nvdir/tgz"								# archies directory
nvtmp="$nvdir/temp"								# extract temp directory
buildtmp="$nvdir/build"							# build temp directory
nvlog="$nvdir/log"								# logs directory
nvdl="$nvdir/release"							# downlaod driver backups directory
nvupdate="$nvdir/update"						# update temp directory
nvbackup="$nvdir/backups"
logfile="--log-file-name=$nvlog/install.log"	# nvidia-installer options
temp="--tmpdir=$buildtmp"						# nvidia-installer option: install temp dir
dltemp="--tmpdir=$nvtmp"						# nvidia-installer option: update temp dir
kernel="--kernel-install-path"
help_pages="$install_dir/share/doc/NVIDIA_GLX-1.0"
docs="--documentation-prefix=$install_dir"
profile="--application-profile-path=$install_dir/share/nvidia"
reportlog=/tmp/nv_report.tmp
#kernel_src="--kernel-source-path"
xt_hold=0
xt_delay=4

################################################
## DEVELOPPEMENT only, DON'T EDIT OR UNCOMMENT'
#devel=/home/mike/Devel/NVIDIA/zenvidia
#script_conf=$devel/script.conf.devel
#basic_conf=$devel/basic.conf.devel
################################################

## configuration file
# zenity --width=250 --error --text=""
if [ ! -s $script_conf ]; then zenity --width=250 --error --icon-name=xkill --text="Script's config file missing."; exit 0; fi
. $script_conf
. $basic_conf
. $color_conf

#. $devel/color.conf
#locale=$devel/translations/

### FUNCTIONS
ID(){
## graphic cards id
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
	IFS=$(echo -en "\n\b")
	pci_dev="${pci_n[*]}"
	pci_dev_nb=$(printf "$pci_dev"|cut -d, -f1)
	IFS=$ifs
#	unset { dev_n,dev,slot,slot_id,vnd,vnd_id }
	unset dev_n dev slot slot_id vnd vnd_id
	for c in $pci_dev_nb; do
		var="${pci_n[$c]}"
		dev_n+=("$(printf "$var"|cut -d, -f1)")
		dev+=("$(printf "$var"|cut -d, -f6)")
		slot+=("$(printf "$var"|cut -d, -f2)")
		slot_id+=("$(printf "$var"|cut -d, -f3)")
		vnd+=("$(printf "$var"|cut -d, -f5)")
		vnd_id+=("$(printf "$var"|cut -d, -f4)")
	done
	board=$(printf "${pci_n[0]}"| cut -d, -f6)
}
distro_id(){
	unset distro_list
	if [ -f /proc/version ] ; then
		distro_list=( 'Ubuntu' 'Debian' 'Fedora' 'Red\ Hat' 'Mandriva' 'mageia' )
		for distro in "${distro_list[@]}" ; do
			proc_version=$(cat /proc/version | grep -c "$distro")
			if [ $proc_version -gt 0 ] ; then
				distro_version=$distro
				if [[ $(printf "$distro"| grep "\\ ") ]]; then
					plug_version=$(printf "$distro"| sed -n "s/\\\ /_/p").conf
				else
					plug_version=$distro.conf
				fi
			fi
		done
	fi
}
distro(){
	if [ -s $conf_dir/distro/$plug_version ]; then
		. $conf_dir/distro/$plug_version
	else
		zenity --width=250 --error --text="$j$msg_00_12$end\n$v(gcc,lftp,dkms,xterm)$end"
		exit 0
	fi
}
root_id(){
	distro_id
	distro
	if [[ $EUID -gt 0 ]] ; then
		if [ -f /proc/version ] ; then
			# if distro type is debian like, zenity password entry box is replace by gksu.
			if [ $dist_type = 0 ]; then
				if  [ $su_set = 1 ]; then
					$p_gksu $0
					exit 0
				else
					zenity --password --title="Zenvidia first start SuperUser password"| $SU_r $0
					exit 0
				fi
			else
	#			zenity --password --text="$v\Enter SuperUser password$end"| $SU_r /$EXEC$0
				zenity --password --title="Zenvidia (SuperUser password)"| $SU_r $0
				exit 0
			fi
		else
			zenity --width=450 --error --text="$v SORRY, CAN'T IDENTIFY DISTRO.\nPROMPT DIRECTLY AS SU\nAND TYPE $J sudo $(basename $0)$end$v FOR DEBIAN LIKE,\nOR$j su -c $(basename $0)$end$v FOR OTHER DISTRO.$end"
			exit 0
		fi
	else
		[[ $USER == $def_user ]]|| {
			if [ $(id -u -n) == $USER ]; then
				user_name=$(zenity --entry --text="Enter default user name" --entry-text="your user name")
				if [ $(cat /etc/passwd |grep -c $user_name) -eq 1 ]; then
					sed -i "s/def_user=.*$/def_user=$user_name/" $basic_conf
				fi
			fi
		}
		if [ $su_set ]&&[ $su_set = 0 ]; then
			if [ -s $conf_dir/distro/$plug_version ]; then
				sed -i "s/su_set=[0-9]/su_set=1/" $conf_dir/distro/$plug_version
			fi
		fi
	fi
}

# elf types
libclass(){
	# define distro base ELF type
	if [ $(uname -p |grep -c "64") -gt 0 ] ; then
		ELF_TYPE="64"
	else
		ELF_TYPE=""
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
# be sure that /usr/local/ for lib32 is in LD path
if [ $(ldconfig -p |grep -c "$install_dir/$master$ELF_32") -eq 0 ]; then
	printf "$install_dir/$master$ELF_32" > /etc/ld.so.conf.d/local-lib32.conf
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
	[ -x /usr/bin/lftp ]|| deplist+=("$p_lftp")
	[ -x /usr/bin/xterm ]|| deplist+=("$p_xterm")
	[ -x /usr/bin/make ]|| deplist+=("$p_gcc")
	[ -x /usr/bin/wget ]|| deplist+=("$p_wget")
	[ -x /usr/bin/git ]|| deplist+=("$p_git")
	[ -x /usr/sbin/dkms ]|| deplist+=("$p_dkms")
	if [ $dist_type -le 1 ]; then
		[ -d $kernel_src ]|| deplist+=("$p_kernel")
		[ -e /usr/include/ncurses/ncurses.h ]|| deplist+=("$p_ncurses")
		[ -e /usr/include/libkmod.h ]|| deplist+=("$p_kmod")
		[ -e /usr/include/pci/config.h ]|| deplist+=("$p_pciutils")
		[ -e /usr/include/pciaccess.h ]|| deplist+=("$p_libpciaccess")
		[ -e /usr/include/xorg/xorg-server.h ]|| deplist+=("$p_xorgdev")
	fi
	if [ $dist_type = 0 ]; then
		[ -x /usr/bin/gksu ]|| deplist+=("$p_gksu")
	fi
#	if [[ $(echo "${deplist[*]}") != '' ]] ; then
	if [[ "${deplist[*]}" ]] ; then
		zenity --question --text="$v Required dependencies are not met.\n You need to install them now ?$end" --ok-label="Install"
		if [ $? = 0 ]; then
			( 
			xterm $xt_options -e "$PKG_INSTALLER $pkg_opts$pkg_cmd ${deplist[*]}; printf \"$esc_message\"; sleep $xt_delay"
			) | zenity --progress --pulsate --auto-close --text="Installing missing dependencies..."
		else
			exit 0
		fi
	fi
}
connection_control(){
	cnx=$(ping -c2 nvidia.com)
	cnx=$?
	(	[[ $(ping -c2 nvidia.com) ]]|| (zenity --width=300 --error --text="$v$msg_00_11$end")
	) | zenity --width=450 --title="Zenvidia" --progress --pulsate --auto-close \
	--text="$v$msg_00_10...$end" 
	if [ $cnx = 0 ]; then cnx_msg="$ansOK"
	else cnx_msg=$ansNA
	fi
}

## gcc compatibility control
compil_vars(){
	if [ -s $tool_dir/bin/'nvidia-installer' ]; then
		NV_bin_ver=$(nvidia-installer -v | grep "nvidia-installer"|awk '{print $3}')
	else
		NV_bin_ver='none'
	fi
	if [[ $(gcc --version | grep "gcc") ]]; then
		GCC=$(gcc --version | grep "gcc" | sed -n "s/^.*) //p"| awk '{print $1}')
	else
		GCC='none'
	fi
	KERNEL=$(uname -r)
	OLD_KERNEL=$(ls -1 /lib/modules | sed -n '/'$KERNEL'/{g;1!p};h')
	# xterm default vars and messages.
	primary_dsp=$(xrandr --current| grep -w "connected"| grep primary)
	term_x_dsp=$(printf "$primary_dsp"| grep -o "[0-9]\{3,4\}[x]"|sed -n "s/x//p")
	[ $xt_hold = 0 ]|| x_hold=' -hold'
	if [ $xt_hold = 1 ]; then
		esc_message="$xB\n# Close xterm window to escape.\n$xN"
		x_hold=' -hold'
	else
		esc_message="$xB\n# Terminal will auto-close in $xt_delay seconds.\n$xN"
	fi
	xt_options=$xt_colors''$x_hold' -fn 8x13 -geometry 80x24+'$[ (($term_x_dsp-660)/2)$dock ]'+0'
}
# define installed driver version, if any
version_id(){
	version=$(cat $nvdir/version.txt)
	mod_version=$($d_modinfo -F version nvidia)
	ver_txt=$(printf "$version"|sed -n "s/\.//p")
	ver_mod=$(printf "$mod_version"|sed -n "s/\.//p")
	if [[ $version ]]; then
		if [[ $mod_version ]]; then
			if [[ $ver_mod -ge $ver_txt ]]; then
				version=$mod_version
			fi
		fi
	else
		version="undefined"
	fi			
}

nv_gen_keys(){ # <<< NOT USED
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
	/usr/bin/openssl req -x509 -new -nodes -utf8 -sha256 -days 36500 -batch \
	-config $nvdir/nv_ssl.conf -outform DER -out $nvdir/public_key.der \
	-out $nvdir/public_key.x509 -keyout $nvdir/private_key.priv
	if [ -e $nvdir/public_key.der ]; then
#		rm -f $nvdir/nv_ssl.conf
		# secure them
		chmod 600 $nvdir/public_key.der $nvdir/public_key.x509 $nvdir/private_key.priv
		# enroll keys in DER for UEFI
		mokutil --import $nvdir/public_key.der
		mv -f -t $kernel_src $nvdir/public_key.x509 $nvdir/private_key.priv
	fi
}

## VIRTUALIZER AND TOOLS BUILDING PART
notif_update(){
	[ -d /home/$def_user/tmp/$base_src/.git ]|| mkdir -p /home/$def_user/tmp/$base_src/.git/
	cp -Rfu $local_src/$base_src/.git /home/$def_user/tmp/$base_src/
	chown -R $def_user:$def_user /home/$def_user/tmp/$base_src
}
local_src_ctrl(){
#	() | zenity --width=450 --title="Zenvidia" --progress --pulsate --auto-close \
	# Full optimus control. Update or installing it if necessary
	if [ $install_type = 1 ]; then
		optimus_dependencies_ctrl 
		if [ $use_bumblebee = 1 ]; then
			if [ -x $opti_exec ]; then
				operande="$m_02_16"
			(	opti_list=( 'bbswitch' 'Bumblebee' 'primus')
				cmd_line="for git_src in \"${opti_list[@]}\"; do
					cd $local_src/$git_src
					build=$git_src
					echo \"$xB# GIT : $m_02_18 $git_src...$xN\" ; sleep 1
					git_build=$build\_build
					git fetch --dry-run &>$local_src/tmp.log
					if [[ $(cat $local_src/tmp.log|grep -c \"master\") -eq 1 ]]; then
						echo \"$xB# GIT : $m_02_20 $git_src...$xN\"
						make clean
						git pull ; ${git_build}
						sleep 1
						base_src=$build; notif_update
					else
						echo \"$xB# GIT : $git_src $m_02_19$xN\"; sleep 1
					fi	
				done
				printf \"$esc_message\"; sleep $xt_delay"
				xterm $xt_options -title Zenvidia_$operande -e "$cmd_line"
			) | zenity --width=450 --title="Zenvidia GIT source(updating)" --progress \
			--pulsate --auto-close --text="$y\GIT$end $v: $m_02_17.$end"
			
			else
				echo "# GIT : Installing Bumblebee and dependecies."
				build_all
			fi
			## Bumblebee report
#			report_log+=("$vB$m_04_05$end$gB $val_04_S$end> $m_04_05c $m_04_05b\n")
			printf "$vB$m_04_05$end$gB $val_04_S$end> $m_04_05c $m_04_05b\n" >> $reportlog
		else
			zenity --height=100 --info --icon-name=xkill --no-wrap --ok-label="$lab_06c" \
			--text="$(printf "$v$wrn_opti_01$end" "Bumblebee" "Prime" "1")"
			if [ $? = 0 ]; then base_menu; fi
		fi
	else
		zenity --height=100 --info --icon-name=swiss_knife --no-wrap \
		--text="$(printf "$v$wrn_opti_02$end" "Bumblebee")" --ok-label="$lab_06c"
		if [ $? = 0 ]; then base_menu; fi
	fi
}
optimus_dependencies_ctrl(){ #
	# optimus compiling dependecies check/install.
	unset pkg_list
#	xt_list(){
	[ -x /usr/bin/git ]|| pkg_list+=("$p_git")
	[ -e /usr/bin/autoconf ]|| pkg_list+=("$p_autoconf")
	[ -e /usr/include/gnu/stubs-32.h ]|| pkg_list+=("$p_glibc")
	if [ $dist_type -le 1 ]; then
		[ -e /usr/include/glib-2*/glib.h ]|| pkg_list+=("$p_glib2")
		[ -e /usr/include/bsd/bsd.h ]|| pkg_list+=("$p_libbsd")
		[ -e /usr/include/X11/X.h ]|| pkg_list+=("$p_libX11")
	fi
#	[ -e /usr/sbin/dkms ]|| pkg_list+=("$p_dkms")
#	}
#	xt_sub(){
#		xt_list
#		if [[ ${pkg_list[@]} != '' ]]; then
#			echo "$xB# $m_02_22 :$xN"
#			$PKG_INSTALLER $pkg_opts$pkg_cmd ${pkg_list[@]}
#			echo "$xB# $m_02_23.$xN"
#		else
#			echo "$xB# $m_02_23...$xN"
#		fi
#		printf "$esc_message"; sleep $xt_delay
#	}
	(	sleep 2
		if [[ ${pkg_list[@]} != '' ]]; then
			cmd_line="
			printf \"$xB# $m_02_22 :$xN\n\"
			$PKG_INSTALLER $pkg_opts$pkg_cmd ${pkg_list[@]}
			printf \"$xB# $m_02_23.$xN\n\"
			printf \"$esc_message\"; sleep $xt_delay"
			xterm $xt_options -title Zenvidia -e "$cmd_line"
		else
			echo "# $m_02_23."
		fi	
#		export -f xt_list
#		export -p xB xN m_02_22 m_02_23 PKG_INSTALLER pkg_opts pkg_cmd esc_message xt_delay
#		xterm $xt_options -title "Zenvidia dependencies" -e xt_sub
		echo "# $m_02_24."; sleep 2
	) | zenity --width=450 --title="Zenvidia" --progress --pulsate --auto-close \
	--text="$y\Optimus :$end$v $m_02_21.$end"
}
build_all(){
	# compile/recompile all missing/present optimus elements
	if [ $install_type = 1 ]; then
		if [ $use_bumblebee = 1 ]; then
			mkdir -p $local_src
			cd $local_src
			unset rebuild_list
			xt_sub(){
				xt_list
				for r_build in ${rebuild_list[@]}; do
					_name=$(printf "$r_build"|cut -d, -f1)
					_build=$(printf "$r_build"|cut -d, -f2)
					_git=$(printf "$r_build"|cut -d, -f3)
					printf "$xB\n# Cloning $_name from GIT :$xN\n\n"
					/usr/bin/git clone $_git
					printf "$xB\n# Building $_name :$xN\n\n"
					${_build}
					base_src=$_name
					notif_update
					sleep 2
				done
				printf "$esc_message"
				sleep $xt_delay
			}
			xt_list(){
				rebuild_list+=("bbswitch,bbswitch_build,$bbswitch_git")
				rebuild_list+=("Bumblebee,Bumblebee_build,$Bumblebee_git")
				rebuild_list+=("primus,primus_build,$primus_git")
			}
			( operande="Building"
			export -p bbswitch_git Bumblebee_git primus_git
			export -p xt_delay esc_message xB xN
			export -f xt_list bbswitch_build Bumblebee_build primus_build xt_sub notif_update
			echo "# GIT : $m_02_29..."; sleep 1
			xterm $xt_options -title "Zenvidia ($operande)" -e xt_sub	
	#		/usr/bin/git clone $bbswitch_git
	#		export -f bbswitch_build
	#		xterm $xt_options -title "Zenvidia ($operande)" -e bbswitch_build
	#		echo "$[ 100/3 ]"; sleep 1
	#		/usr/bin/git clone $Bumblebee_git
	#		Bumblebee_build
	#		echo "$[ 100/2 ]"; sleep 1
	#		/usr/bin/git clone $primus_git
	#		primus_build
	#		echo "100"
			echo "# GIT : $m_02_30."; sleep 1
			) | zenity --width=450 --title="Zenvidia ($operande)" --progress --pulsate \
			--auto-close --text="$y\GIT :$end$v $m_02_25...$end"
		else
			if [ -x $install_dir/bin/bumblebeed ]; then
			zenity --width=450 --title="Zenvidia ($operande)" --question --title="Zenvidia" \
			--text="$v$m_02_26\n$m_02_27.$end" --icon-name=swiss_knife \
			--ok-label="$m_02_28" --cancel-label="$MM"
			if [ $? = 0 ]; then local_src_ctrl; else base_menu; fi
			fi
		fi
	else
		if [ $install_type -ne 1 ]; then
			zenity --height=100 --info --no-wrap --icon-name=xkill \
			--label-ok="Got it !" --text="$v$wrn_02_25$end"
			if [ $? = 0 ]; then base_menu; fi
		fi
	fi
	
}
bbswitch_build(){
	if [ -d $local_src/bbswitch ]; then
		cd $local_src/bbswitch
		( echo "# GIT : $operande bbswitch driver..."
		cp -f Makefile Makefile.zen
		cp -f Makefile.dkms Makefile.dkms.zen
		sed -i "s/depmod/\/usr\/sbin\/depmod/" Makefile.zen
		sed -i "s/= dkms/= \/usr\/sbin\/dkms/" Makefile.dkms.zen
		sleep 1
		/usr/bin/make -f Makefile.zen; /usr/bin/make install; sleep 1
		/usr/bin/make -f Makefile.dkms.zen; /usr/bin/make install
		echo "# GIT : $operande bbswitch, done."; sleep 1
		) | zenity --width=450 --title="Zenvidia" --progress --pulsate --auto-close
	fi
	cd $nvdir
}
Bumblebee_build(){
	if [ -d $local_src/Bumblebee ]; then
		cd $local_src/Bumblebee
		( echo "# GIT : $operande bumblebee daemon..."
		if [ ! -x $local_src/Bumblebee/configure ]; then
			/usr/bin/autoreconf -fi
		fi
#		[[ $( $d_modinfo -F version nvidia ) == $version ]]|| \
		[[ $mod_version == $version ]]|| \
		version=$( $d_modinfo -F version nvidia )
		nvroot="nvidia"
		[ -d $xorg_dir ]|| xorg_dir=$croot/$nvroot/xorg
#		[[ $(printf "$xorg_dir") != "" ]]|| xorg_dir=$croot/$nvroot/xorg
		./configure --prefix=$tool_dir CONF_DRIVER=nvidia \
		CONF_DRIVER_MODULE_NVIDIA=nvidia \
		CONF_LDPATH_NVIDIA=$croot/$nvroot/$master$ELF_64:$croot/$nvroot/$master$ELF_32 \
		CONF_MODPATH_NVIDIA=$xorg_dir/modules,/usr/lib$ELF_TYPE/xorg/modules  
		/usr/bin/make 
		/usr/bin/make install
		echo "# GIT : $operande bumblebee, done."; sleep 1
		) | zenity --width=450 --title="Zenvidia" --progress --pulsate --auto-close
	fi
	if [ ! -e /usr/lib/systemd/system/bumblebeed$sys_c_ext ]; then
		echo "# GIT : Optimus : Copy bumblebee$sys_c_ext in systemd path."; sleep 1
		cp -f ./scripts/systemd/bumblebeed.* /usr/lib/systemd/system/
	fi
	if [[ $(ls -l $tool_dir/etc/bumblebee/bumblebee.conf| sed -n "s/^.*-> //p") != $version ]]; then
		cd $tool_dir/etc/bumblebee/
		ln -sf ./bumblebee.$version ./bumblebee.conf
		ln -sf ./xorg.conf.nvidia.$version ./xorg.conf.nvidia
	fi
	if [ $(cat /etc/group | grep -c "bumblebee") -eq 0 ]; then
		groupadd bumblebee
		usermod -a -G bumblebee $USER
	fi
	if [ $sys_old = 1 ]; then
		if [[ $($sys_c bumblebeed status | grep -o "inactive") != '' ]]; then
			echo "# Optimus : Enable bumblebee$sys_c_ext at boot start."; sleep 1
			$sys_c enable bumblebeed$sys_c_ext
			$sys_c bumblebeed start
		else
			$sys_c bumblebeed restart
		fi
	else
		if [[ $($sys_c status bumblebeed$sys_c_ext | grep -o "inactive") != '' ]]; then
			echo "# Optimus : Enable bumblebee$sys_c_ext at boot start."; sleep 1
			$sys_c enable bumblebeed$sys_c_ext
			$sys_c start bumblebeed$sys_c_ext
		else
			$sys_c restart bumblebeed$sys_c_ext
		fi
	fi
	cd $nvdir
}
primus_build(){
	if [ -d $local_src/primus ]; then
		# fix missing libX11.so link in lib32 if not present
		if [ $libx_fix = 1 ]; then
			[ -h /usr/$master$ELF_32/libX11.so ]|| \
			( cd /usr/$master$ELF_32; ln -sf ./libX11.so.6 ./libX11.so )
		fi
		cd $local_src/primus
		rm -rf lib/ lib64/
		( echo "# GIT : $operande primus libraries..."; sleep 1
		# patch primus makefile
		cp -f Makefile Makefile.zen
		sed -i "s/LIBDIR   ?= lib/LIBDIR   ?=$master$ELF_64/" Makefile.zen
		sed -i "s/PRIMUS_SYNC        ?= 0/PRIMUS_SYNC        ?= 1/" Makefile.zen
		sed -i "s/\/usr\/\$\$LIB\/nvidia/\/opt\/nvidia\/\$\$LIB/g" Makefile.zen
#		sed -i "s/\/usr\/\$\$LIB\/nvidia/\/opt\/nvidia\/\$\$LIB/" Makefile
		LIBDIR=$master$ELF_64 /usr/bin/make -f Makefile.zen
		CXX=g++\ -m32 LIBDIR=$master$ELF_32 /usr/bin/make -f Makefile.zen
		[ -d $croot/primus ]|| mkdir -p $croot/primus
		[ -d $croot/primus ]&& cp -Rf $croot/primus $croot/primus.bak
		cp -Rf ./$master$ELF_32 $croot/primus
		cp -Rf ./$master$ELF_64 $croot/primus
		) | zenity --width=450 --title="Zenvidia" --progress --pulsate --auto-close $b_text
		printf "# GIT : Creating primusrun script in $tool_dir...\n"; sleep 1
		primus_script
		printf "$xB# GIT : $operande primus done.$xN\n"; sleep 1
	fi
	cd $nvdir
}
primus_update(){
	if [ -d $local_src/primus ]; then
		if [ $(cat $local_src/primus/version.txt| grep -c "$new_version") -eq 0 ]; then
			echo "# GIT : Updating Bumblebee Primus to $new_version."; sleep 1
			cd $local_src/primus
			rm -rf lib/ lib64/	
			LIBDIR=$master$ELF_64 /usr/bin/make -f Makefile.zen
			CXX=g++\ -m32 LIBDIR=$master$ELF_32 /usr/bin/make -f Makefile.zen
			[ -d $croot/primus ]&& cp -Rf $croot/primus $croot/primus.bak
			cp -Rf ./$master$ELF_32 $croot/primus
			cp -Rf ./$master$ELF_64 $croot/primus
			echo "$n"; n=$[ $n+2 ]
			[ -f $local_src/primus/update.txt ]|| touch $local_src/primus/update.txt
			printf "$new_version" > $local_src/primus/update.txt
		fi
	fi	
}
installer_build(){
	( # Install or upgrade from source
	if [ $first_start = 0 ]; then
		if [ -d $local_src/nvidia-installer ]; then
			git fetch --dry-run &>$local_src/tmp.log
			fetch=$(cat $local_src/tmp.log|grep -c "master")
			cd $local_src/nvidia-installer
			echo "$xB# GIT : Controling nvidia-installer...$xN" ; sleep 1
			if [[ $operande = "Rebuild" ]]; then
				proc="Re-building"
#				cmd_line="printf \"# Downloading GIT repo :\n\n\"
#				[ $fetch = 0 ]|| git pull
#				printf \"# Installing to system :\n\n\"
#				make clean ; make ; make install ; $esc_message"
				## check git pull first
				[ $fetch = 0 ]|| git pull
				make clean
				make; make install
			else
				proc="Updating"
				if [ $fetch = 1 ]; then
#					cmd_line="printf \"# Checking GIT repo :\n\n\"
#					make clean ; git pull
#					printf \"# Installing new diffs :\n\n\"
#					make ; make install; $esc_message; sleep $xt_delay"
					printf "$xB# GIT : Updating nvidia-installer...$xN\n"
#					make clean
					git pull
					make ; make install
#					xterm $xt_options --title Compiling -e "$cmd_line" 
					sleep 2
					echo "$xB# GIT : $proc nvidia-installer done.$xN"; sleep 1
				else
					echo "$xB# GIT : Nvidia_installer is already up-to-date. Pass$xN"; sleep 1
				fi
			fi
			base_src='nvidia-installer'; notif_update			
		fi
	else
		proc="Installing"
		cmd_line="printf \"$xB# Downloading GIT repo :$xN\n\n\"
		git clone $nv_git
		cd $local_src/nvidia-installer
		[[ $(stat -c %a .git/objects/pack) == 777 ]]|| chmod a+w .git/objects/pack
		printf \"$xB# Installing to system :$xN\n\n\"
		make ; make install ; printf \"$esc_message\"; sleep $xt_delay"
		printf "# GIT : Donwloading nvidia-installer..." ; sleep 1
#		mkdir -p $local_src/nvidia-installer
		cd $local_src
#		git clone $nv_git
#		make ; make install	
		xterm $xt_options --title Compiling -e "$cmd_line" 
		printf "# GIT : $proc nvidia-installer done."; sleep 2
		base_src='nvidia-installer'
		notif_update	
	fi
	) | zenity --width=450 --title="Zenvidia" --progress --pulsate --auto-close \
	--text="$v\TOOLS :$end$j nvidia-installer$end$v build/rebuild$end"
}
optimus_source_rebuild(){
#	if [ -x $install_dir/bin/optirun ]; then
		unset rebuild_list build_list
		if [ $install_type = 1 ]; then
			rebuild_list=("bbswitch" "Bumblebee" "Primus" "Prime" "Nvidia-Installer" "$_5a")
		else
			rebuild_list=("Nvidia-Installer" "$_5a")
		fi
		operande="Rebuild"; b=1
		for build in "${rebuild_list[@]}"; do
			build_list+=("false")
			build_list+=("$b")
			build_list+=("$build")
			b=$[ $b+1 ]
		done
		menu_build=$(zenity --width=400 --height=300 --list --radiolist --hide-header \
			--title="Zenvidia" --text "$rBB$_3e$end" \
			--column "1" --column "2" --column "3" --separator=";" --hide-column=2 \
			"${build_list[@]}" false $b "$PM")
		if [ $? = 1 ]; then exit 0; fi
		if [ $install_type = 0 ]; then
			case $menu_build in
				"1") git_src="nvidia-installer"; re_build_menu ;;
				"2") dkms_rebuild; base_menu ;;
				"$b") menu_modif ;;
			esac
		else
			case $menu_build in
				"1") git_src="bbswitch"; re_build_menu ;;
				"2") git_src="Bumblebee"; re_build_menu ;;
				"3") git_src="primus"; re_build_menu ;;
				"4") git_src="nvidia-prime-select"; prime_build ;;
				"5") git_src="nvidia-installer"; re_build_menu ;;
				"6") dkms_rebuild; base_menu ;;
				"$b") menu_modif ;;
			esac
		fi
#	fi	
}
re_build_menu(){
	menu_msg="$v\You're going to compile$end $j$git_src$end."
	menu_re_build=$(zenity --width=450 --height=200 --title="Zenvidia" --list --radiolist --hide-header \
	--text "$menu_msg\n$v$ansWN$end" --column "1" --column "2" --column "3" --separator=";" \
	--hide-column 2 false 1 "$ansCF" false 2 "$PM")
	if [ $? = 1 ]; then base_menu; fi
	case $menu_re_build in
		"1") re_build ;;
		"2") optimus_source_rebuild ;;
	esac
}
re_build(){
	b_text="$xB GIT : Rebuilding $git_src...$xN"
	unset rebuild_list
	if [ $install_type = 1 ]; then
		rebuild_list=('bbswitch' 'Bumblebee' 'primus' 'nvidia_installer,installer')
	else
		rebuild_list=('nvidia_installer,installer')
	fi
	for rebuild in "${rebuild_list[@]}"; do
		if [ -d $local_src/$git_src ]; then
				cd $local_src/$git_src
			if [[ $(printf "$rebuild"|cut -d, -f2) ]]; then
				rebuild_nm=$(printf "$rebuild"|cut -d, -f2)
			else
				rebuild_nm=$rebuild
			fi
			if [[ "$git_src" == "$rebuild" ]]; then git_build=$rebuild_nm\_build; fi
			cmd_line="printf \"$b_text\n\n\"; make clean; ${git_build}
			printf \"$esc_message\"; sleep $xt_delay"
			xterm $xt_options -title "$git_src re-build" -e "$cmd_line"
		else
			zenity --height=100 --info --icon-name=swiss_knife --no-wrap \
			--text="$(printf "$v$wrn_03e$end" "$git_src")" --label-ok="$lab_03e"
			if [ $? = 1 ]; then base_menu; fi
		fi
	done
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
prime_src_ctrl(){
	if [ $install_type = 1 ]; then
		optimus_dependencies_ctrl
		if [ $use_bumblebee = 0 ]; then
			if [ -x usr/sbin/nvidia-prime-select ]; then
				operande="$m_02_16"
				(	git_src='nvidia-prime-select'
					cd $local_src/$git_src
					echo "# GIT : $m_02_18 $git_src..." ; sleep 1
					git fetch --dry-run &>$local_src/tmp.log
					if [[ $(cat $local_src/tmp.log|grep -c "master") -eq 1 ]]; then
						echo "# GIT : $m_02_20 $git_src..."
						prime_build
						sleep 1
					else
						echo "# GIT : $git_src $m_02_19"; sleep 1
					fi
					sleep 1
				) | zenity --width=450 --title="Zenvidia ($operande)" --progress --pulsate \
				--auto-close --text="$y\GIT$end $v: $m_02_17.$end"
			else
				prime_build
			fi
			## Prime report
#			report_log+=("$vB$m_04_05$end$gB $val_04_S$end> $m_04_05c $m_04_05a\n")
			printf "$vB$m_04_05$end$gB $val_04_S$end> $m_04_05c $m_04_05a\n" >> $reportlog
		else
			zenity --height=100 --info --icon-name=xkill --no-wrap --ok-label="$lab_06c" \
			--text="$(printf "$v$wrn_opti_01$end" "Prime" "Bumblebee" "use_bumblebee")"
			if [ $? = 0 ]; then base_menu; fi
		fi
	else
		zenity --height=100 --info --icon-name=swiss_knife --no-wrap \
		--text="$(printf "$v$wrn_opti_02$end" "Prime")" --ok-label="$lab_06c"
		if [ $? = 0 ]; then base_menu; fi
	fi
}
prime_build(){
	( 
	if [ -d $local_src/nvidia-prime-select ]; then
		operande=Update
		cd $local_src/nvidia-prime-select
		echo "# GIT : $operande Prime..."
		git fetch --dry-run &>$local_src/tmp.log
		if [[ $(cat $local_src/tmp.log|grep -c "master") -eq 1 ]]; then
#		cmd_line="# $operande Prime from GIT source:\n
#		git pull
#		/usr/bin/make install
#		printf \"$esc_message\"
#		sleep $xt_delay"
		git pull
		/usr/bin/make install
		else
			echo "# GIT : Already Up-to-date. Skip"; sleep 2
		fi
		sleep 1
	else
		operande=Installing
		cd $local_src
		echo "# GIT : $operande Prime..."
#		cmd_line="# $operande Prime from GIT source repo:\n
#		git clone $prime_git
#		cd $local_src/nvidia-prime-select
#		/usr/bin/make install
#		printf \"$esc_message\"
#		sleep $xt_delay"
		git clone $prime_git
		cd $local_src/nvidia-prime-select
		chmod a+w .git/object/pack
		/usr/bin/make install
		sleep 1
	fi
	[ -d /home/$def_user/tmp/nvidia-prime-select/.git ]|| mkdir -p /home/$def_user/tmp/nvidia-prime-select/.git/
	cp -Rfu $local_src/nvidia-prime-select/.git /home/$def_user/tmp/nvidia-prime-select/
	chown -R $def_user:$def_user /home/$def_user/tmp/nvidia-prime-select
#	x_opt="$xt_options -title Zenvidia_Prime_$operande"
#	xterm $x_opt -e "$cmd_line"
	if [ $new_version ]; then version=$new_version; fi
	if [ -f /etc/nvidia-prime/xorg.conf.nvidia.$version ]; then
		if [ $(cat /etc/nvidia-prime/xorg.nvidia.conf| grep -c "$version") -eq 0 ]; then
			cd /etc/nvidia-prime
			cp -f ./xorg.conf.nvidia.$version ./xorg.nvidia.conf
		fi
	fi
	echo "# GIT : $operande prime, done."; sleep 1
	) | zenity --width=450 --title="Zenvidia" --progress --pulsate --auto-close
	cd $nvdir
}
dkms_rebuild(){
	force=1
	(	kernel_path=/lib/modules/$KERNEL/extra
		force_opt='--force'
		operande="Driver rebuilding"
		nv_build_dkms
	) | zenity --width=450 --title="Zenvidia" --text="Force dkms rebuild " --progress --pulsate --auto-close
	base_menu
}
zenvidia_update(){
	echo "# GIT : Zenvidia Update "
	( if [ -d $local_src/zenvidia ]; then
		cd $local_src/zenvidia
		echo "# GIT : Updating Zenvidia..."
		git fetch --dry-run &>$local_src/tmp.log
		
		fetch=$(cat $local_src/tmp.log|grep -c "master")
		cmd_line="
		if [ $fetch -eq 1 ]; then
			printf \"$xB# Proceeding to script update:$xN\n\n\"
			git pull
			make update; printf \"$esc_message\"; sleep $xt_delay
		else
			printf \"$xB# GIT : Zenvidia already up-to-date. Skipping...$xN\n\n\"
			printf \"$esc_message\"; sleep $xt_delay
		fi"
		xterm $xt_options -title Zenvidia_update -e "$cmd_line"
	else
		cd $local_src
		echo "# GIT : Cloning Zenvidia..."; sleep 3
		cmd_line="printf \"$xB# Cloning Zenvidia GIT repo:$xN\n\n\"
		git clone $zenvidia_git; cd zenvidia
		chmod a+w .git/object/pack
		printf \"\n$xB# Proceeding to script update:$xN\n\n\" 
		make update; printf \"$esc_message\"
		sleep $xt_delay"
		xterm $xt_options -title Zenvidia_update -e "$cmd_line"
	fi
	[ -d /home/$def_user/tmp/zenvidia/.git ]|| mkdir -p /home/$def_user/tmp/zenvidia/.git/
		cp -Rfu $local_src/zenvidia/.git /home/$def_user/tmp/zenvidia/
		chown -R $def_user:$def_user /home/$def_user/tmp/zenvidia
	) | zenity --width=450 --title="Zenvidia" --text="Zenvidia Update check..." --progress --pulsate --auto-close
}
## CONFIGURATION
## VIRTUALIZER CONFIGURATION PART
bumblebee_conf(){
	# consider bumblebee is already installed in /opt and bin in /usr/local
	x_conf_dir=$tool_dir/etc/bumblebee
	echo "# Optimus : Configure Bumblelbee service..."; n=$[ $n+1 ]; echo "$n"
	cd $x_conf_dir
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
XorgConfFile=$x_conf_dir/xorg.conf.nvidia.$new_version
[driver-nouveau]
KernelDriver=nouveau
PMMethod=auto
XorgConfFile=$x_conf_dir/xorg.conf.nouveau
\n" > bumblebee.$new_version
	ln -sf ./bumblebee.$new_version ./bumblebee.conf
	if [ -s $x_conf_dir/bumblebee.$old_version ]; then
		rm -f $x_conf_dir/{bumblebee,xorg.conf.nvidia}.$old_version
	fi
	# ensure /etc/nvidia is set properly connfigured for OpenCL
	mkdir -p /etc/OpenCL/vendors
	printf "$croot_all/$master$ELF_64/nvidia.$new_version/libnvidia-opencl.so.1\n" > /etc/OpenCL/vendors/nvidia.icd
}
xorg_conf(){
	sec_files(){
		if [[ $ELF_TYPE == 64 ]]; then
			ELF=$ELF_64
		else
			ELF=''
		fi
		printf "## xorg conf originaly created by $new_version nvidia installer.
## Edited automaticaly by Zenvidia > $(date +%D-%T)

Section \"Files\"
	ModulePath \"$croot/nvidia/xorg/modules\"
	ModulePath \"/usr/$master$ELF/xorg/modules\"
EndSection
\n" > xorg.conf.nvidia.$new_version
	}
	sec_module(){
		printf "Section \"Module\"
	Disable	\"glamoregl\"
	Load	\"modesetting\"
EndSection
" >> xorg.conf.nvidia.$new_version
	}
	sec_device(){
		for e in $pci_dev_nb; do
			if [ $install_type = 1 ]&&[ $use_bumblebee = 0 ]; then
				pci_slot='bus_id:0:0'
			else
				pci_slot=$(printf "${slot[$e]}"| sed -n "s/^0//;s/:0/:/;s/\./:/p")
			fi
			if [[ $(printf "${dev[$e]}"|grep "GeForce\|Quadro\|NVS\|Tesla\|GRID") != '' ]]; then
			printf "Section \"Device\"
	Identifier	\"Device${dev_n[$e]}\"
	Driver		\"nvidia\"
	VendorName	\"${vnd[$e]}\"
	BusID		\"PCI:$pci_slot\"
\n" >> xorg.conf.nvidia.$new_version
			fi
		done
	}
	sec_option_df(){
		printf "\tOption	\"NoLogo\" \"true\"
	Option	\"DPMS\"
	Option	\"UseEDID\" \"true\"
	Option	\"ProbeAllGpus\" \"false\"
#	Option	\"UseDisplayDevice\" \"none\"
#	Option	\"ConnectedMonitor\" \"DFP\"
#	Option	\"DynamicTwinView\" \"false\"
#	Option	\"AddARGBGLXVisuals\"
	Option	\"SLI\" \"Off\"
#	Option	\"MultiGPU\" \"Off\"
	Option	\"BaseMosaic\" \"off\"
#	Option	\"UseEdidDpi\" \"false\"
	Option	\"Coolbits\" \"8\"
#	Option	\"AllowGLXWithComposite\" \"true\"
#	Option	\"TripleBuffer\" \"true\"
	Option	\"Stereo\" \"0\"
	Option	\"RenderAccel\" \"true\"
	Option	\"DPI\" \"96 x 96\"
EndSection
\n" >> xorg.conf.nvidia.$new_version
	}
	sec_option_op(){
		printf "\tOption	\"NoLogo\" \"true\"
	Option	\"AllowEmptyInitialConfiguration\"
#	Option	\"UseEDID\" \"false\"
#	Option	\"ProbeAllGpus\" \"false\"
#	Option	\"UseDisplayDevice\" \"none\"
#	Option	\"ConnectedMonitor\" \"DFP\"
#	Option	\"DynamicTwinView\" \"false\"
#	Option	\"AddARGBGLXVisuals\"
	Option	\"SLI\" \"Off\"
#	Option	\"MultiGPU\" \"Off\"
#	Option	\"BaseMosaic\" \"off\"
#	Option	\"UseEdidDpi\" \"false\"
#	Option	\"Coolbits\" \"8\"
#	Option	\"AllowGLXWithComposite\" \"true\"
	Option	\"TripleBuffer\" \"true\"
#	Option	\"Stereo\" \"0\"
#	Option	\"RenderAccel\" \"true\"
	Option	\"DPI\" \"96 x 96\"
EndSection
\n" >> xorg.conf.nvidia.$new_version
	}
	sec_layout(){
		printf "Section \"ServerLayout\"
	Identifier	\"Layout0\"
#	Screen	0	\"Screen0\" 0 0
	Option	\"AutoAddDevices\" \"false\"
	Option	\"AutoAddGPU\" \"false\"
EndSection
X
Section \"ServerFlags\"
	Option	\"Xinerama\" \"0\"
	# allows the server to start up even if the mouse does not work
	AllowMouseOpenFail 
EndSection
\n" >> xorg.conf.nvidia.$new_version
	}
	screen_opt(){
		printf "Option	\"Stereo\" \"0\"
	Option	\"nvidiaXineramaInfoOrder\" \"DFP-${dev_n[0]}\"
#	Option	\"metamodes\" \"DVI-I-1: nvidia-auto-select +0+0, HDMI-0: nvidia-auto-select +1920+1080\"
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
	screen_dsp(){
		printf "\tSubSection \"Display\"
	Depth	24
EndSubSection\n" >> xorg.conf.nvidia.$new_version
	}
	sec_screen(){
		printf "Section \"Screen\"
    Identifier	\"Screen${dev_n[0]}\"
    Device		\"Device${dev_n[0]}\"
    Monitor		\"Monitor${dev_n[0]}\"
    DefaultDepth	24
\n" >> xorg.conf.nvidia.$new_version
    	screen_opt
    	screen_dsp
		printf "EndSection
\n" >> xorg.conf.nvidia.$new_version
	}
## xorg conf to file
	if [ $install_type = 1 ]; then
		if [ $use_bumblebee = 1 ]; then
			x_conf_dir=$tool_dir/etc/bumblebee
			cd $x_conf_dir
			sec_files
			sec_device
			sec_option_op
		elif [ $use_bumblebee = 0 ]; then
			x_conf_dir=/etc/nvidia-prime
			[ -d $x_conf_dir ]|| mkdir -p $x_conf_dir
			if [ -f $x_conf_dir/xorg.nvidia.conf ]; then
				mv -f $x_conf_dir/xorg.nvidia.conf $x_conf_dir/xorg.nvidia.conf.bak
			fi
			cd $x_conf_dir
			sec_files
			sec_module
			sec_device
			sec_option_op
		fi
	else
		x_conf_dir=/etc/X11
		cd $x_conf_dir
		sec_files
		sec_device
		sec_option_df
	fi
	if [ $install_type = 1 ];then
		if [ $use_bumblebee = 1 ]; then
			ln -sf ./xorg.conf.nvidia.$new_version ./xorg.conf.nvidia
		elif [ $use_bumblebee = 0 ]; then
			cp -f ./xorg.conf.nvidia.$new_version ./xorg.nvidia.conf
		fi
	else
		if [ $(diff -q ./xorg.conf.nvidia.$new_version ./xorg.conf  | grep -c ".*") -gt 0 ]; then
			if [ ! -e ./xorg.conf.nvidia ]; then
				if [ ./xorg.conf.nvidia.$old_version ]; then
					mv -f ./xorg.conf.nvidia.$old_version ./xorg.conf.nvidia
				fi
			fi
			diff -u ./xorg.conf.nvidia.$new_version ./xorg.conf.nvidia &>/tmp/nv_patch.diff
			patch -p0 -i /tmp/nv_patch.diff ./xorg.conf.nvidia.$new_version
			cp -f ./xorg.conf.nvidia.$new_version ./xorg.conf.nvidia
			ln -sf ./xorg.conf.nvidia ./xorg.conf
		fi
	fi
}

if_blacklist(){
#	if [[ $(cat /etc/modprobe.d/blacklist.conf | grep "nouveau") == '' ]]; then
	if [ $(cat /etc/modprobe.d/blacklist.conf | grep -c "nouveau") -eq 0 ]; then
		printf "blacklist nouveau" >> /etc/modprobe.d/blacklist.conf
		echo "# Updated blacklist for nouveau driver..."; echo "$n"; n=$[ $n+4 ]; sleep 2
	fi
#	nouveau_unset='nouveau.modeset=0 rd.driver.blacklist=nouveau pci=nocrs pci=realloc'
	nouveau_unset='nouveau.modeset=0 rd.driver.blacklist=nouveau'
	if [ $(cat $grub_dir/grub.cfg|grep -c "$nouveau_unset") -eq 0 ]; then
		sed -i "s/ ro rhgb / ro $nouveau_unset rhgb /" $grub_dir/grub.cfg
		echo "# Updated GRUB conf for nouveau driver blacklisting."; echo "$n"; n=$[ $n+4 ]; sleep 2
	fi
#	GRUB_CMDLINE_LINUX="rd.md=0 rd.lvm=0 rd.dm=0 SYSFONT=True  KEYTABLE=fr rd.luks=0 LANG=fr_FR.UTF-8 rhgb quiet rd.blacklist=nouveau"
#	grub2-mkconfig -o /boot/grub2/grub.cfg

# TODO ABI23 compatibility for Optimus VSYNC in modprobe.d
# sudo rmmod nvidia-drm; sudo modprobe nvidia-drm modeset=1
}
service_check(){
	if [ $sys_old = 1 ]; then
		if [ $dis_service ]; then
			v_pid=$($sys_c $dis_service status| grep "PID"| \
			perl -p -e "s|^.*: +([0-9]+).*$|\1|")
			if [ $v_pid ]; then
				$sys_c $dis_service stop
				$sys_c $dis_service disable
			fi
		fi
		$sys_c $sys_service restart
	else
		if [ $dis_service ]; then
			v_pid=$($sys_c status $dis_service.$sys_c_ext| grep "PID"| \
			perl -p -e "s|^.*: +([0-9]+).*$|\1|")
			if [ $v_pid ]; then
				$sys_c stop $dis_service$sys_c_ext
				$sys_c disable $dis_service$sys_c_ext
			fi
		fi
		$sys_c restart $sys_service$sys_c_ext
	fi
}
## AFTER INSTALL
post_install(){
	echo "# Post install routines..."; echo "$n"; n=$[ $n+4 ]
	if [ -d $croot_32 ]||[ -d $croot_64 ]; then
		# libnvidia-wfb.so not broken, but old xorg server only with no libwfb.so 
		if [ -e $xorg_dir/modules/libwfb.so ]; then
			mv -f $xorg_dir/modules/libwfb.so $xorg_dir/modules/libwfb.so.orig
			ln -sf /usr/$master$ELF_64/xorg/modules/libwfb.so $xorg_dir/modules/libwfb.so
		fi
		[ -d $croot/nvidia.$new_version ]|| mv -f $croot/$predifined_dir $croot/nvidia.$new_version
		cd $croot
		ln -sf -T ./nvidia.$new_version ./nvidia		
		if [ $install_type = 1 ]; then
			xorg_conf; echo "$n"; n=$[ $n+2 ]
			backup_driver; echo "$n"; n=$[ $n+4 ]
			# bumblebee
			if [ $use_bumblebee = 1 ]; then
				echo "# Optimus : Configure and load/reload Bumblebee..."; sleep 1
				echo "$n"; n=$[ $n+4 ]
				local_src_ctrl; echo "$n"; n=$[ $n+4 ]
				bumblebee_conf; echo "$n"; n=$[ $n+2 ]
				# update primus libGL to new driver libGL
				primus_update
				echo "# Optimus : Start or Restart Optimus service..."; sleep 1
				echo "$n"; n=$[ $n+4 ]
				sys_service='bumblebeed'
				dis_service='nvidia-prime'
				service_check
			# prime
			else
				echo "# Optimus : Configure and load/reload Prime..."; sleep 1
				echo "$n"; n=$[ $n+4 ]
				prime_src_ctrl; echo "$n"; n=$[ $n+4 ]
				echo "# Optimus : Start or Restart Prime service..."; sleep 1
				echo "$n"; n=$[ $n+4 ]
				sys_service='nvidia-prime'
				dis_service='bumblebeed'
				service_check
#				/usr/sbin/nvidia-prime-select nvidia
				sleep 1
				/usr/sbin/nvidia-prime-select nvidiaonly
				if [ ! -f /etc/nvidia-prime/library.conf ]; then
					touch /etc/nvidia-prime/library.conf
				fi
				unset elf_lib_list
				elf_lib_list=("$ELF_32,32" "$ELF_64,64")
				for nv_lib in "${elf_lib_list[@]}"; do
					_elf=$(printf "$nv_lib"|cut -d, -f2)
					_lib=$(printf "$nv_lib"|cut -d, -f1)
					if [ -d $croot_all/$master$_lib ]; then
						if [ $(cat /etc/nvidia-prime/library.conf| grep -c .) -eq 0 ]; then
							printf "nv_drv_$_elf=\'$croot_all/$master$_lib\'" \
							>> /etc/nvidia-prime/library.conf
						else
							perl -ni -pe "s|nv_drv_$_elf=.*$|nv_drv_$_elf='$croot_all/$master$_lib'|i" /etc/nvidia-prime/library.conf
						fi
					else
						zenity --width=450 --title="Zenvidia" --error --icon-name=xkill \
						--text="$vB Could not find$j $croot_all/$master$_lib$end.\nAbort.$end."
						if [ $? = 1 ]; then base_menu; else exit 0; fi
					fi
				done
				if [ $(cat /etc/nvidia-prime/library.conf| grep -c .) -eq 0 ]; then
					printf "nv_xorg_path=\'$croot_all/nvidia/xorg\'\nrc_dir=\'/etc/rc.d\'" \
					>> /etc/nvidia-prime/library.conf
				else
					perl -ni -pe "s|nv_xorg_path=.*$|nv_xorg_path='$croot_all/xorg'|i" \
					/etc/nvidia-prime/library.conf
					perl -ni -pe "s|rc_dir=.*$|rc_dir='/etc/rc.d'|i" \
					/etc/nvidia-prime/library.conf
				fi
				prime_msg="$prime_msg_01\n$prime_msg_03"
				prime_setup
			fi		
		else # [ $optimus = 0 ]
			xorg_conf
			backup_driver
			if [ ! -s /etc/ld.so.conf.d/nvidia-$master$ELF_TYPE ]; then
				unset elf_lib_list
				elf_lib_list=("$ELF_64" "$ELF_32")
				for nv_lib in "${elf_lib_list[@]}"; do
					ld_conf=$croot_all/$master$nv_lib
					[[ $nv_lib == 64 ]]|| nv_lib=32
					nv_lib_file='/etc/ld.so.conf.d/nvidia-'$master$nv_lib'.conf'
					printf "$ld_conf" > $nv_lib_file
				done
			fi
			ldconfig
		fi
		cd $nvdir
	fi
	if [ -e $nvlog/install.log ]; then cp -f $nvlog/install.log $nvlog/install-$new_version.log; fi
	echo "# Fixing broken libs if needed..."; echo "$n"; n=$[ $n+4 ]
	elf_lib=( "$master$ELF_32" "$master$ELF_64" )
	cd $install_dir
	for lib_X in "${elf_lib[@]}"; do
		for old_lib in {fbc,cfg,gtk2,gtk3}; do
			if [ -s $install_dir/$lib_X/libnvidia-$old_lib.so.$old_version ]; then
				rm -f $install_dir/$lib_X/libnvidia-$old_lib.so.$old_version
			fi
		done
	done
	cd $nvtmp
	## fix gui libraries install if broken
	extracted=NVIDIA-Linux-$ARCH-$new_version
	if [ -d $extracted ]; then
		## fix lib32 prefix libs 
		if [ -d $nvtmp/$extracted/32 ]; then
			[ -s $install_dir/$master$ELF_32/libnvidia-fbc.so.$new_version ]|| \
			( cp -f $extracted/libnvidia-fbc.so.$new_version $install_dir/$master$ELF_32/
			cd $install_dir/$master$ELF_32/
			ln -sf libnvidia-fbc.so.$new_version libnvidia-fbc.so.1
			ln -sf libnvidia-fbc.so.1 libnvidia-fbc.so
			cd $nvtmp
			)
		fi
		## fix lib64 prefix libs
		for links in {fbc,cfg,gtk2,gtk3}; do
			[ -s $install_dir/$master$ELF_64/libnvidia-$links.so.$new_version ]|| \
			( cp -f $extracted/libnvidia-$links.so.$new_version $install_dir/$master$ELF_64/
			cd $install_dir/$master$ELF_64/
			ln -sf libnvidia-$links.so.$new_version libnvidia-$links.so.1
			ln -sf libnvidia-$links.so.1 libnvidia-$links.so
			cd $nvtmp )
		done
		## it appears that gtk symlinks are not always correctly linked at install,
		## fix them if broken
		for links in {gtk2,gtk3}; do
			[ -h $install_dir/$master$ELF_64/libnvidia-$links.so.1 ]|| \
			( cd $install_dir/$master$ELF_64/
			ln -sf libnvidia-$links.so.$new_version libnvidia-$links.so.1
			ln -sf libnvidia-$links.so.1 libnvidia-$links.so
			cd $nvtmp )
		done
	fi
	## symlink libvdpau_nvidia to system
	for lib_V in "${elf_lib[@]}"; do
		link_v=$(ls -l /usr/$lib_V/vdpau/libvdpau_nvidia.so.1| sed -n "s/^.*-> //p")
		if [[ ! $(printf "$link_v"|grep -o "$new_version") ]]; then
			ln -sf $croot_all/$lib_V/vdpau/libvdpau_nvidia.so.$new_version /usr/$lib_V/vdpau/libvdpau_nvidia.so.1 
		fi
	done
	## link now all new libraries
	ldconfig	
	echo "$n"; n=$[ $n+4 ]
	if [ ! -h /usr/share/nvidia ]; then
		rm -f /usr/share/nvidia
		ln -sf -T $install_dir/share/nvidia /usr/share/nvidia
	fi
	if_blacklist
#	echo "# Blacklisting nouveau driver in grub if needed..."; echo "$n"; n=$[ $n+4 ]; sleep 2
}

### INSTALL
old_kernel(){
	if [ $cuda = 0 ]; then
		nv_list=( nvidia nvidia-modeset nvidia-drm )
	else
		nv_list=( nvidia nvidia-uvm nvidia-modeset nvidia-drm )
	fi
	for nvname in "$nv_list"; do
		old_driver=$($d_modinfo -F version /lib/modules/$OLD_KERNEL/extra/$nvname.ko)
		if [ -s /lib/modules/$OLD_KERNEL/extra/$nvname.ko ]; then
			[ -s $croot/nvidia.$old_driver/$OLD_KERNEL/$nvname.ko ]|| \
			cp /lib/modules/$OLD_KERNEL/extra/$nvname.ko \
			$croot/$nvname.$old_driver/$OLD_KERNEL/
		fi
	done
}
clean_previous(){
		echo "# Backing up old kernel driver..."
		if [ -s /lib/modules/$OLD_KERNEL/extra/nvidia.ko ]; then
			old_kernel
		fi
}
nv_cmd_try_legacy_first(){
	if [ ! $upgrade_other = '' ]; then 
		new_version=$version
		install_bin='./nvidia-installer'
	fi
	cd $nvtmp/NVIDIA-Linux-$ARCH-$new_version
	echo "# Trying compil from LEGACY BUILD directory..."; sleep 1
	no_check='--no-check-for-alternate-installs'
	[ $cuda = 1 ]|| unified="--no-unified-memory"
	[ $use_dkms = 0 ]|| dkms="--dkms"
	xterm $xt_options -title Zenvidia_Nvidia_Installer -e "
$install_bin -s -z -N --no-x-check $unified $dkms -K -b $no_check \
--skip-module-unload --no-distro-scripts \
--kernel-source-path=$kernel_src --kernel-install-path=$kernel_path \
$SIGN_S $SElinux $temp --log-file-name=$driver_logfile
depmod -a
printf \"$esc_message\"
sleep $xt_delay"
}
nv_cmd_install_driver(){
	# if this is a second attempt of installing drivers, test first the actual mod version
	# then send warn if it is already the updated one.
	if [[ $($d_modinfo -F version nvidia) != $new_version ]]; then
		[ $use_dkms = 0 ]|| nv_cmd_dkms_conf
		nv_cmd_try_legacy_first
		if [[ $($d_modinfo -F version nvidia) != $new_version ]]; then

			[ -d /usr/src/nvidia-$new_version ]||mkdir -p /usr/src/nvidia-$new_version
			cp -Rf $nvtmp/NVIDIA-Linux-$ARCH-$new_version/kernel/* /usr/src/nvidia-$new_version
			if [ $use_dkms = 1 ]; then
				if [ -d $nvtmp/NVIDIA-Linux-$ARCH-$new_version/kernel ]; then
					if [[ $(cat /usr/src/nvidia-$new_version/dkms.conf|grep -o "$new_version") == '' ]]; then
						nv_cmd_dkms_conf
					fi
					version=$new_version
					REPORT='DKMS '
					# Compil and install DKMS modules				
					nv_build_dkms
					# In case of modules compil errors, force it from source
					if [[ $($d_modinfo -F version nvidia) != $new_version ]]; then
						echo "# DKMS compilation ERROR !!"; sleep 2 
						echo "# Force MODULES compilation from source..."; sleep 1
						nv_cmd_make_src
					fi
				fi
			fi
			if [ $use_dkms = 0 ]; then
				echo "# Nvidia MODULES compilation..."; sleep 1 
				REPORT='SOURCE '
				nv_cmd_make_src
			fi
		fi
		if [ ! -f $kernel_path/nvidia.ko ]&&[[ ! $($d_modinfo -F version nvidia) ]]; then
			zenity --width=450 --title="Zenvidia" --error --icon-name=xkill \
			--text="$j INSTALL ABORT ABNORMALY, check $logfile$end."
			exit 0
		fi
	else
		# TODO > if driver auto remove on re-install, make a driver and dkms dir backup,
		# then, restore them at the end.
	#		if [ ]
		echo "# DRIVER ALREADY INSTALL, SKIPING THIS STEP."; sleep 2
	fi
	#	if [ $driver_level -ge 355 ]; then
#		$nvtmp/NVIDIA-Linux-$ARCH-$new_version/nvidia-modprobe -u -m
#	else
#		$nvtmp/NVIDIA-Linux-$ARCH-$new_version/nvidia-modprobe -u
#	fi
}
nv_cmd_update(){
	driver_logfile=$nvlog/$version-$KERNEL.log
	if [ $use_dkms = 1 ]; then
		if [[ ! $(cat /usr/src/nvidia-$version/dkms.conf|grep -o "$version") ]]; then
			nv_cmd_dkms_conf
			cp -f $nvtmp/NVIDIA-Linux-$ARCH-$version/kernel/dkms.conf /usr/src/nvidia-$version/
		fi
	fi
	nv_cmd_try_legacy_first
#	if [ ! -s $kernel_path/nvidia.ko ]|| \
	if [[ $upgrade_other = 1 || $($d_modinfo -F version nvidia) != $version ]]; then
		if [ $(cat $driver_logfile | grep "ERROR"| grep -c "nvidia-drm") -gt 0 ]; then
#			report_log+=("$vB$m_04_02$end$rB $val_04_A$end> $m_04_02b\n")
			printf "$vB$m_04_02$end$rB $val_04_A$end> $m_04_02b\n" >> $reportlog
		fi
		if [ $use_dkms = 1 ]; then
			force=0	
			nv_build_dkms
#			if [ ! -e $kernel_path/nvidia.ko ]|| \
			if [[ $($d_modinfo -F version nvidia) != $version ]]; then
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
nv_build_dkms(){
	if [ $force != 0 ]; then
		if [ -d /var/lib/dkms/nvidia/$version ]; then
			remove_dkms="/usr/sbin/dkms remove -m nvidia/$version -k $KERNEL"
		fi
	fi
	if [ ! -d /var/lib/dkms/nvidia/$version ]; then
		echo "# Add DKMS modules to DKMS directory..."; sleep 1
#		/usr/sbin/dkms add -m nvidia/$version -k $KERNEL -c /usr/src/nvidia-$version/dkms.conf
		add_message="printf \"$xB# Add DKMS modules to DKMS directory.\n$xN\""
		add_dkms="/usr/sbin/dkms add -m nvidia/$version -k $KERNEL"
	fi	
	echo "# Build & install DKMS modules..."; sleep 1
	xterm $xt_options -title Zenvidia_dkms_build -e "
printf \"$xB# Installing DKMS modules:\n\n$xN\"
$remove_dkms
$add_message
$add_dkms
printf \"$xB# Build $version DKMS modules:\n\n$xN\"
/usr/sbin/dkms --force install -m nvidia/$version -k $KERNEL
printf \"$esc_message\"
sleep $xt_delay"
	sleep 1
	if [ $($d_modinfo -F version nvidia |grep -c "$version") -eq 0 ];then
		cd /var/lib/dkms/nvidia/$version/$KERNEL/$ARCH/module
		if [ -s nvidia.ko ]; then cp -f nvidia.ko $kernel_path/; fi
		if [ -s nvidia-uvm.ko ]; then cp -f nvidia-uvm.ko $kernel_path/; fi
		if [ -s uvm/nvidia-uvm.ko ]; then cp -f uvm/nvidia-uvm.ko $kernel_path/; fi
		if [ -s nvidia-modeset.ko ]; then cp -f nvidia-modeset.ko $kernel_path/; fi
		if [ -s nvidia-drm.ko ]; then cp -f nvidia-drm.ko $kernel_path/; fi
		[ $kernel_path/nvidia.ko ]&& /usr/sbin/depmod -a
	else
		echo "# $operande done."; sleep 1
	fi
}
nv_cmd_make_src(){
	if [[ $(printf "$new_version") != '' ]]; then version=$new_version; fi
	[ $driver_level != '' ]|| driver_level=$(printf "$version"|cut -d. -f1)
	if [ -d /usr/src/nvidia-$version ]; then
		cd /usr/src/nvidia-$version
#		make clean; make
		make clean; xterm $xt_options -title Compiling -e "make; printf \"$esc_message\" ; sleep $xt_delay"
		if [ $driver_level -lt 355 ]; then
			cd uvm/; make clean; xterm $x_opt -e "make" ; cd ../
		fi
		if [ -s nvidia.ko ]; then cp -f nvidia.ko $kernel_path/; fi
		if [ -s nvidia-uvm.ko ]; then cp -f nvidia-uvm.ko $kernel_path/; fi
		if [ -s uvm/nvidia-uvm.ko ]; then cp -f uvm/nvidia-uvm.ko $kernel_path/; fi
		if [ -s nvidia-modeset.ko ]; then cp -f nvidia-modeset.ko $kernel_path/; fi
		if [ -s nvidia-drm.ko ]; then cp -f nvidia-drm.ko $kernel_path/; fi
		/usr/sbin/depmod -a
		/usr/sbin/ldconfig
	fi
}
nv_cmd_uninstall(){	
	( $tool_dir/bin/nvidia-installer --uninstall -s --no-x-check $temp $logfile \
	-b --no-sigwinch-workaround --no-distro-scripts $no_check --no-nvidia-modprobe
	) | zenity --width=450 --title="Zenvidia" --progress --pulsate --auto-close \
	--text="$v$m_01_70...$end"
}
nv_cmd_dkms_conf(){
	if [[ $new_version ]]; then 
		version=$new_version
	else
		version=$version
	fi
	[ -d /usr/src/nvidia-$version ]||mkdir -p /usr/src/nvidia-$version
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
		if [ $cuda = 1 ]; then
			printf "BUILT_MODULE_NAME[1]=\"\${PACKAGE_NAME}-uvm\"
BUILT_MODULE_LOCATION[1]=\"uvm/\"
DEST_MODULE_LOCATION[1]=\"/extra\"\n" >> /usr/src/nvidia-$version/dkms.conf
		fi
	fi
	if [ $driver_level -gt 355 ]; then
		printf "PACKAGE_NAME=\"nvidia\"
PACKAGE_VERSION=\"$version\"
AUTOINSTALL=\"yes\"

MAKE[0]=\"\'make\' -j\`nproc\` NV_EXCLUDE_BUILD_MODULES=\'__EXCLUDE_MODULES\' KERNEL_UNAME=\${kernelver} modules\"

BUILT_MODULE_NAME[0]=\"\${PACKAGE_NAME}\"
DEST_MODULE_LOCATION[0]=\"/extra\"\n" > /usr/src/nvidia-$version/dkms.conf
		if [ $cuda = 1 ]; then
			printf "BUILT_MODULE_NAME[1]=\"\${PACKAGE_NAME}-uvm\"
DEST_MODULE_LOCATION[1]=\"/extra\"\n" >> /usr/src/nvidia-$version/dkms.conf
		fi
		if [ $cuda = 1 ]; then n1=2 ;else n1=1; fi
		printf "BUILT_MODULE_NAME[$n1]=\"\${PACKAGE_NAME}-modeset\"
DEST_MODULE_LOCATION[$n1]=\"/extra\"\n" >> /usr/src/nvidia-$version/dkms.conf
	fi
	if [ $driver_level -ge 364 ]; then
		if [ $cuda = 1 ]; then n2=3 ;else n2=2; fi
		printf "BUILT_MODULE_NAME[$n2]=\"\${PACKAGE_NAME}-drm\"
DEST_MODULE_LOCATION[$n2]=\"/extra\"\n" >> /usr/src/nvidia-$version/dkms.conf 
	fi
	if [ -d $nvtmp/NVIDIA-Linux-$ARCH-$new_version/kernel/ ]; then
		cp -f /usr/src/nvidia-$version/dkms.conf $nvtmp/NVIDIA-Linux-$ARCH-$new_version/kernel/
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
	[ $use_indirect = 0 ]|| force_glvnd='--force-libglx-indirect'
	[ $use_glvnd = 0 ]|| add_glvnd='--install-libglvnd'
#	$nocheck --no-kernel-module --no-opengl-files --skip-module-unload \
#	--no-recursion --opengl-headers --install-libglvnd --glvnd-glx-client --force-libglx-indirect  --opengl-libdir=$master$ELF_64 \
#	--utility-prefix=$tool_dir --utility-libdir=$tool_dir/$master$ELF_64 \
	xterm $xt_options -title Zenvidia_install_libs -e "
	$install_bin -s -z -N --no-x-check --no-distro-scripts \
	$nocheck --no-kernel-module --skip-module-unload --no-recursion --opengl-headers \
	$add_glvnd $force_glvnd --install-compat32-libs --compat32-prefix=$croot_all \
	--x-prefix=/usr --x-library-path=$croot_all --x-module-path=$xorg_dir/modules \
	--opengl-prefix=$croot_all --utility-prefix=$tool_dir \
	$docs $profile $SIGN_S $SElinux $temp --log-file-name=$lib_logfile
	printf \"$esc_message\" ; sleep $xt_delay"
}

## INSTALL MODULE AND LIBRARIES PROCESS
# MAIN
install_drv(){
	confirm_msg="$menu_msg\n$v$m_03_69$end $j$new_version$end $v$m_03_70$end $j$board$end."
	val_confirm="$_01"
	val_back="$MM"
	val_exit="base_menu"
	val_title="Zenvidia"
	win_confirm
	## extract .run package for install processes
	[ -d $nvtmp/NVIDIA-Linux-$ARCH-$new_version ]|| extract_build	
	# nvidia-installer options
#	KERNEL=$kernel_ver
	lib_logfile=$nvlog/install-$new_version.log
	driver_logfile=$nvlog/$new_version-$KERNEL.log
	# other vars
	dkms_kernel=/lib/modules/$KERNEL/extra
	install_bin="./nvidia-installer"
	if [ -s $driverun ] ; then
	{	sleep 1
		n=4
		echo "# Backing up old driver, if any."; echo "$n"; n=$[ $n+4 ]
		# backup driver repository (shits happens!)
		if [ -d $croot/nvidia.$old_version ]; then
			bak_version=$old_version
			backup_old_version
			if [ -s $nvbackup/nvidia.$bak_version.tar.gz  ]; then
#			report_log+=("$vB$m_04_01$end$gB $val_04_P$end> $m_04_01a\n")
			printf "$vB$m_04_01$end$gB $val_04_P$end> $m_04_01a\n" > $reportlog
			else
#			report_log+=("$vB$bak_version $m_04_06:$end$gB $val_04_S$end> $m_04_01b\n")
			printf "$vB$bak_version $m_04_06$end$gB $val_04_S$end> $m_04_01b\n" > $reportlog
			fi
		else
#			report_log+=("$vB$m_04_01$end$gB $val_04_P$end> $m_04_01c\n")
			printf "$vB$m_04_01$end$gB $val_04_P$end> $m_04_01c\n" > $reportlog
		fi
		# making installation directories in case installer doesn't find them
		[ -d $croot_64 ] || ( mkdir -p $croot_32 $croot_64 $xorg_dir )	
		# remove previous driver, because of "registered driver install break", if any
#		clean_previous
		echo "# $m_03_60"; sleep 1; echo "$n"; n=$[ $n+4 ]
		## create base libs install directories
		for d in "$croot/$predifined_dir $croot_32 $croot_64 $xorg_dir"; do
			mkdir -p $d
		done
		cd $croot
		## FIXME create distro xorg libs dirs symlink in case compiler doesn't find them
#		ln -sf -T /usr/$master$ELF_32 $xorg_dir/$master$ELF_32
#		ln -sf -T /usr/$master$ELF_64 $xorg_dir/$master$ELF_64
#		cd $nvdl
		
		## install default libs with nvidia-installer	
		{ nv_cmd_install_libs
		} | zenity --width=450 --title="Zenvidia" --progress --pulsate --auto-close \
		--text="$v\LIBRARIES$end : Extract and install default nvidia libs..."
		sleep 1; echo "$n"; n=$[ $n+4 ]
		## report nvidia installer warning message
		if [ $(cat $lib_logfile| grep -c "WARNING") -gt 0 ]; then
			if [ $(cat $lib_logfile| grep "WARNING"| grep -c "libGL.so") -gt 0 ]; then
#				report_log+=("$vB$m_04_02$end$jB $val_04_N$end> $m_04_02a\n")
				printf "$vB$m_04_02$end$jB $val_04_N$end> $m_04_02a\n" >> $reportlog
			elif [ $(cat $lib_logfile| grep "WARNING"| grep -c "libglvnd") -gt 0 ]; then
#				report_log+=("$vB$m_04_02$end$jB $val_04_N$end> $m_04_02c\n")
				printf "$vB$m_04_02$end$jB $val_04_N$end> $m_04_02c\n" >> $reportlog
			fi
		fi
		## control if libraries are properly installed
		if [[ $(ls -1 $croot_64| grep -c ".*") -lt 40 ]]|| \
		[[ $(ls -1 $croot_32| grep -c ".*") -lt 40 ]]; then
			zenity --width=450 --title="Zenvidia" --error --no-wrap \
			--text="$vB\LIBS INSTALL CONTROL RETURN ERRORS.$end$v.\nCheck $lib_logfile for more details.$end"
			if [ $? = 0 ]; then base_menu; fi
		else
			printf "$vB$m_04_03$end$gB $val_04_S$end> $m_04_03a\n" >> $reportlog
		fi

		# nv_cmd processes (install without X crash )
		echo "# Package conpil and install"; sleep 1
		# install driver first, then control if everything ok
		{ nv_cmd_install_driver
		} | zenity --width=450 --title="Zenvidia" --progress --pulsate --auto-close \
		--text="$v\DRIVER$end : Install driver and/or dkms modules."
		sleep 1; echo "$n"; n=$[ $n+4 ]
		# default installer couldn't sometime work. Before going on and
		# simply exit, checking if install work-arround did its job.
#		mod_version=$($d_modinfo -F version nvidia)
		mod_version=$($d_modinfo -F version nvidia)
		if [ $(cat $driver_logfile| grep -c "ERROR") -gt 0 ]; then
			if [ $(cat $driver_logfile| grep "ERROR"| grep -c "Installation has failed") -gt 0 ]; then
				if [[ $($d_modinfo -F version nvidia) != $new_version ]]; then
					rm -f $buildtmp/template-*
					zenity --width=450 --title="Zenvidia" --error --no-wrap \
					--text="$vB\DRIVER LEGACY INSTALL SEND FATAL ERROR !$end\n\n$v\It probably mean it didn't compil properly with any work arround.$end" \
					--icon-name=xkill --ok-label="$MM"
					if [ $? = 1 ]; then base_menu; fi
				else
					if [ $(cat $driver_logfile | grep "ERROR"| grep -c "nvidia-drm") -gt 0 ]; then
						printf "$vB$m_04_02$end$rB $val_04_A$end> $m_04_02b\n" >> $reportlog
					fi
					printf "$vB$m_04_04$end$gB $val_04_S$end> $m_04_04a\n" >> $reportlog
				fi
			fi
		fi
		if [[ $($d_modinfo -F version nvidia) != $new_version ]]; then
			rm -f $buildtmp/template-*
		fi

		cd $nvtmp
		if [ -s $nvtmp/NVIDIA-Linux-$ARCH-$new_version/nvidia-installer ]; then 
			echo "# Backup new Nvidia-Installer to $nvdir"; sleep 1
			echo "$n"; n=$[ $n+4 ]
			cp -f NVIDIA-Linux-$ARCH-$new_version/nvidia-installer $nvdir
#			printf "$vB$m_04_02$end$gB $val_04_S$end> $m_04_04c\n")
			sleep 1
		else
			zenity --width=450 --title="Zenvidia" --error --no-wrap \
			--text="$vB\Nvidia-Installer not found$end$v.\nAbort and back to main.$end"
			sleep 2
			exit 0
			base_menu
		fi
		
		if [[ $($d_modinfo -F version nvidia) != $new_version ]]; then
			echo "# WARNING : nvidia-installer didn't match new $version module."
			sleep 1
		else
			echo "# Update new driver version..."; sleep 1; echo "$n"; n=$[ $n+4 ]
			printf "$new_version" > $nvdir/version.txt
			echo "# Update compatibility data files..."; sleep 1; echo "$n"; n=$[ $n+4 ]
			cat NVIDIA-Linux-$ARCH-$new_version/README.txt | sed -n '/A1. N*/,/Below are the legacy GPU/p' > $nvdir/supported.txt
			cat NVIDIA-Linux-$ARCH-$new_version/README.txt | sed -n '/The 304.xx/,/The 173.14.xx/p' > $nvdir/supported.304.xx
			cat NVIDIA-Linux-$ARCH-$new_version/README.txt | sed -n '/The 173.14.xx/,/The 96.43.xx/p' > $nvdir/supported.173.14.xx
			cat NVIDIA-Linux-$ARCH-$new_version/README.txt | sed -n '/The 96.43.xx/,/The 71.86.xx/p' > $nvdir/supported.96.43.xx
			cat NVIDIA-Linux-$ARCH-$new_version/README.txt | sed -n '/The 71.86.xx/,/Appendix B./p' > $nvdir/supported.71.86.xx
		fi
#		driver_version=$(cat $nvdir/version.txt)
		# Backup install binary in release archive
		if [ ! -f $nvdl/nv-update-$new_version ] ; then
			cp -f $driverun $nvdl/nv-update-$new_version
			if [[ -f $nvdl/nv-update-$new_version ]] ; then
				echo "# $m_03_61 $new_version $m_03_62."; sleep 1; echo "$n"; n=$[ $n+4 ]
				echo "# $m_03_63."; sleep 1; echo "$n"; n=$[ $n+4 ]
			else
				zenity --width=450 --title="Zenvidia" --error --no-wrap \
				--text="\n$v $m_03_61$j $new_version$v $m_03_64."
			fi
		else
			echo "# nv-update-$new_version already present in path, skip."; sleep 1
			echo "$n"; n=$[ $n+4 ]
		fi
#		printf "${report_log[*]}\n"
		# if all went fine, process to post install system conf.
		post_install
		echo "100"; sleep 2
		
		## basic install report.
		if [[ $mod_version == $new_version ]]; then
			if [ $(ls -1 $croot_64| grep -c ".*") -gt 40 ]|| \
			[ $(ls -1 $croot_32| grep -c ".*") -gt 40 ]; then	
				export report_log
				zenity --title="Zenvidia" --question --no-wrap --icon-name=swiss_knife \
				--text="$(printf "$rB$tit_03_65$end$v:\n $(cat $reportlog)\n\n$vB$rep_03_65\n$ansWN$end$end" "$new_version")" --ok-label="$lab_03_65a" --cancel-label="$lab_03_65b"
				if [ $? = 0 ]; then edit_xorg_conf; else base_menu; fi
			fi
		fi
		
		} | zenity --width=450 --title="Zenvidia" --progress --percentage=1 --auto-close
	else
		zenity --width=450 --title="Zenvidia" --error \
		--text="$v$m_03_66$end\n$v$m_03_65$end$y\http://www.nvidia.fr/Download/Find.aspx?lang=en$end\n$v $m_03_68, $v$m_03_67$end$y https://download.nvidia.com/XFree86/$end"
		if [ $? = 0 ]; then base_menu; fi
	fi
}

backup_driver(){
	# link driver for multi driver config
#	kern_dir=$KERNEL
	echo "# DRIVER : Rename and backup driver..."; echo "$n"; n=$[ $n+4 ]
	mods=( nvidia nvidia-uvm nvidia-modeset nvidia-drm )
	if [ -f $kernel_path/nvidia.ko ]; then
		# Case : install without dkms process
		cd $kernel_path
		mkdir -p $croot_all/$KERNEL
		if [ -s $kernel_path/nvidia.ko ]; then
			for mod in "${mods[@]}"; do
				[ $kernel_path/$mod.ko ]&& cp -f ./$mod.ko $croot_all/$KERNEL/
			done
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
backup_old_version(){
	[ -d $nvbackup ]|| mkdir -p $nvbackup
	if [ -d $croot/nvidia.$bak_version ]; then
		orig_dir=$croot/nvidia.$bak_version
#		bak_dir=$nvbackup/nvidia.$bak_version
		bak_dir=$nvtmp/nvidia.$bak_version
		mod_ver=$($d_modinfo -F version $orig_dir/$KERNEL/nvidia.ko )
		[ -d $orig_dir/$KERNEL ]|| mkdir -p $orig_dir/$KERNEL
		[[ $mod_ver ]]|| cp -f /lib/modules/$KERNEL/extra/nvidia* $orig_dir/$KERNEL/

		mkdir -p $bak_dir/{etc,usr/src,var/lib/dkms/nvidia,usr/local/{bin,share,$master$ELF_32,$master$ELF_64,etc/ld.so.conf.d}}
		if [[ $new_version ]];then
			mv -f $orig_dir/ $bak_dir/
		else
			mkdir -p $bak_dir
			cp -Rf $orig_dir $bak_dir/
		fi
		cp -Rf /var/lib/dkms/nvidia/$bak_version $bak_dir/var/lib/dkms/nvidia/
		cp -Rf /usr/src/nvidia-$bak_version $bak_dir/usr/src/
		cp -Rf /etc/{OpenCL,zenvidia} $bak_dir/etc/
		cp -Rf /usr/local/bin/nvidia-* $bak_dir/usr/local/bin/
		cp -Rf /usr/local/$master$ELF_64/libnvidia-{{cfg,fbc,gtk2,gtk3}.{so,so.1},*.$bak_version} $bak_dir/usr/local/$master$ELF_64/
		cp -Rf /usr/local/$master$ELF_32/libnvidia-{fbc{.so,.so.1},*.$bak_version} $bak_dir/usr/local/$master$ELF_32/
		cp -Rf /usr/local/share/nvidia $bak_dir/usr/local/share/
		if [ $(ls /etc/ld.so.conf.d/| grep -c "nvidia") -gt 0 ]; then
			mkdir -p $bak_dir/etc/ld.so.conf.d
			cp -Rf /etc/ld.so.conf.d/nvidia-* $bak_dir/etc/ld.so.conf.d/
		fi
		printf "$bak_version\n" > $bak_dir/version.txt
		
		cd $bak_dir/usr/local/$master$ELF_64/
		for links in {gtk2,gtk3}; do
			ln -sf libnvidia-$links.so.$bak_version libnvidia-$links.so.1
		done
		cd $nvtmp
		tar -zcf $nvbackup/nvidia.$bak_version.tar.gz nvidia.$bak_version
		rm -Rf $bak_dir
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
	[ $install_type = 1 ]&& if_optimus
	[ $install_type = 0 ]&& if_single
#	[ $install_type = 2 ]&& if_legacy
#	if [[ $(echo $NEW_KERNEL) != '' ]];then
	if [[ $NEW_KERNEL ]];then
		KERNEL=$NEW_KERNEL
	fi
#	else
#		KERNEL=$(uname -r)
#	fi
	if [ $upgrade_other = 1 ]; then
#		kernels="-K"
		kernel_path="/lib/modules/$KERNEL/extra/"
		kernel_src="/usr/src$alt/$KERNEL"
#		kernel=$KERNEL
	#	else 
#		kernels="-K"
	fi
	drv_release=$(ls $nvdl/ | grep "$version")
#	zenity --width=450 --title="Zenvidia" --question \
#	--text="$v$m_02_01$end $j$KERNEL$end:\n$v$drv_install_msg$end.\n$v$m_02_03$end" \
#	--ok-label="$CC" --cancel-label="$MM"
#	if [ $? = 1 ]; then base_menu; fi
	confirm_msg="$v$m_02_01$end $j$KERNEL$end:\n$v$drv_install_msg.$end" 
	val_title="Zenvidia"
	val_confirm="$CC"
	val_back="$MM"
	val_exit="base_menu"
	win_confirm
	( echo "# $m_02_01 $KERNEL ..."
	cd $nvdl/
	nv_cmd_update
	if [ ! -f $kernel_path/nvidia.ko ]; then
		zenity --width=450 --title="Zenvidia" --error \
		--text="$j INSTALL ABORT ABNORMALY, check $(echo "$logfile" | sed -n 's/^.*=//p')$end."
		exit 0
	fi
	if ( $install_type = 1 ); then
		if [ $use_bumblebee = 1 ]; then
			echo "# $m_02_03."; sleep 1
			sys_service='bumblebeed'
			dis_service=''
			service_check
#			if [ $sys_old = 1 ]; then
#				$sys_c bumblebeed restart
#			else 
#				$sys_c restart bumblebeed$sys_c_ext
#			fi
		fi
		echo "# $m_02_06" ; sleep 1
	fi
	new_version=$version
	backup_driver
	) | zenity --width=450 --title="Zenvidia" --progress --pulsate --auto-close
	if [ -e $nvlog/install.log ]; then cp -f $nvlog/install.log $nvlog/update-$KERNEL.log; fi
	base_menu
}

## INSTALL MODE DIRECTORY OPTIONS 
extract_build(){
	[ -d $nvtmp ]|| mkdir -p $nvtmp
	[ -d $buildtmp ]|| mkdir -p $buildtmp
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
			old_version=$(cat $nvdir/version.txt)
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
	if [ ! $driverun ]; then
		if [ $(printf "$LAST_PACK"| grep -c .) -gt 0 ]; then
			new_version=$LAST_PACK	
		else
			new_version=$version
		fi
	else
		if [ $(printf "$driverun"| grep -c "$version") -gt 0 ];then
			new_version=$version
		else
			new_version=$(printf "$driverun"| sed -n "s/^.*-//p")
		fi
	fi
	predifine=3
	predifined_dir=nvidia.$new_version
	croot_all=$croot/$predifined_dir
	croot_32=$croot/$predifined_dir/$master$ELF_32
	croot_64=$croot/$predifined_dir/$master$ELF_64
	xorg_dir=$croot/$predifined_dir/xorg
	kernel=$(uname -r)
	kernel_path=/lib/modules/$(uname -r)/extra
	[ $install_type = 1 ]|| sed -i "s/install_type=[0-9]/install_type=1/" $script_conf
	drv_install_msg="$v$m_02_13.$end"
}
# PROPRIATARY DRIVER CUSTOM INSTALL
if_single(){
#	[ $if_update = 1 ]&& new_version=$version
	
#	if [ $LAST_PACK ]; then new_version=$LAST_PACK; else new_version=$version; fi
#	if [ ! $driverun ]; then
#		if [ $LAST_PACK ]; then new_version=$LAST_PACK; else new_version=$version; fi
#	fi
	if [ ! $driverun ]; then
		if [ $(printf "$LAST_PACK"| grep -c .) -gt 0 ]; then
			new_version=$LAST_PACK	
		else
			new_version=$version
		fi
	else
		if [ $(printf "$driverun"| grep -c "$version") -gt 0 ];then
			new_version=$version
		else
			new_version=$(printf "$driverun"| sed -n "s/^.*-//p")
		fi
	fi
	predifine=1
	predifined_dir=nvidia.$new_version
	croot_all=$croot/$predifined_dir
	croot_32=$croot/$predifined_dir/$master$ELF_32
	croot_64=$croot/$predifined_dir/$master$ELF_64
	xorg_dir=$croot/$predifined_dir/xorg
	kernel=$(uname -r)
	kernel_path=/lib/modules/$(uname -r)/extra
	[ $install_type = 0 ]|| sed -i "s/install_type=[0-9]/install_type=0/" $script_conf
	drv_install_msg="$v$m_02_15.$end"
}

install_type_sel(){
	A1="$m_01_22"
#	A2="$m_01_23"
	A2="$m_01_24"
	dir_cmd=$(zenity --width=450 --height=300 --title="Zenvidia" --list --radiolist \
	--text="$v$m_01_25 :$end\n" \
	--hide-header --column "1" --column "2" --column "3" --separator=";" --hide-column=2 \
	false 1 "$A1" false 2 "$A2" false 3 "$MM")
#	false 1 " $A1" false 2 " $A2" false 3 " $A3" false 4 "$MM")
	if [ $? = 1 ]; then exit 0; fi

	case $dir_cmd in
		"1") if_single ;;
#		"2") if_legacy; optimus=0 ;;
		"2") from_menu_install=1
			menu_optimus
			if [ $use_bumblebee = 1 ]; then
				opti_exec=$install_dir/bin/optirun
				opti_ctrl=local_src_ctrl
				msg=$m_01_31
			else
				opti_exec=/usr/sbin/nvidia-prime-select
				opti_ctrl=prime_src_ctrl
				msg=$m_01_32
			fi
			if [ -x $opti_exec ]; then
				install_msg="$m_01_27a ($msg $m_01_27b)$end"
			else
				install_msg="$j\ATTENTION$end$v : $msg $m_01_28$end"
#				if [[ $? == 1 ]]; then
#					${opti_ctrl}
#				else
#					exit 0
#				fi
			fi
			if_optimus
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
		--text="$vB$m_01_05 $nvdl :$end"\
		$table_opts ${list_drv[@]} false "$PM")
		if [ $? = 1 ]; then base_menu; fi
		if [[ "$drv_pick" == "$PM" ]]; then from_directory; fi
		driverun=$nvdl/$drv_pick
		new_version=$(printf "$driverun"| sed -n "s/^.*-//g;p")
	}
	home_dir(){
		cd /home
		drv_pick=$(zenity --width=450 --height=400 --title="Zenvidia" --file-selection \
		--filename="/home/$user/$w_01" --file-filter=".run" --text="$vB$m_01_06$j $homerep$end")
		if [ $? = 1 ]; then base_menu; fi
		chmod a+x $drv_pick
		driverun=$drv_pick
		new_version=$(printf "$driverun"| sed -n "s/^.*-//g;p")
	}
	A="$m_01_03"
	B="$m_01_04"
	zen_opts='--list --radiolist --hide-header'
	table_opts='--column "1" --column "2" --column "3" --separator=";" --hide-column=2'
	n=1
	from_cmd=$(zenity --width=450 --height=400 --title="Zenvidia" $zen_opts \
	--text="$vB $m_01_01$end\n$j$(printf "$(ls $nvdl|sed -n 's/^/\t - /p')")$end\n$vB$m_01_02$end" \
	$table_opts false 1 "$A" false 2 "$B" false 3 "$PM" )
	if [ $? = 1 ]; then base_menu; fi
	case $from_cmd in
		"1") nv_dir; install_type_sel ;;
		"2") home_dir; install_type_sel ;;
		"3") menu_install ;;
	esac
}

# check aviable updates
check_update(){
	( 	wget -q -O $nvtmp/drvlist_0 https://$nvidia_ftp-$ARCH/
		cat $nvtmp/drvlist_0 |  egrep -o "href.*[0-9]+/'"| perl -pe "s/^.*\'(.*)\/\'/\1/p" > $nvtmp/drvlist
		rm $nvtmp/drvlist_0
		wget -q -O $nvtmp/last_update https://$nvidia_ftp-$ARCH/latest.txt
#	( lftp -c "anon; cd http://$nvidia_ftp-$ARCH/ ; ls > $nvtmp/drvlist ; cat latest.txt > $nvtmp/last_update "
	) | zenity width=400 --title="Zenvidia" --progress --pulsate --auto-close \
	--text="$v$m_01_07$end"
	LAST_IN=$version
	LAST_DRV=$(cat $nvtmp/last_update | awk '{ print $1 }')
#	LAST_BETA=$(cat $nvtmp/drvlist | awk '{ print $9 }' | sort -gr | sed -n 1p)
	LAST_BETA=$(tac $nvtmp/drvlist | sed -n 1p)
	# compatibilty control
	if [[ $LAST_DRV == $LAST_BETA ]] ; then
			DIFF_list=$LAST_DRV
	else
#			DIFF_list=$(echo -e "$LAST_DRV\n$LAST_BETA")
			DIFF_list="$LAST_DRV $LAST_BETA"
	fi
	TF=1; w_height=355
	for DRV in $DIFF_list; do
		(wget -q -O $nvtmp/vd_compat.$TF https://$nvidia_ftp-$ARCH/$DRV/README/supportedchips.html
		sleep 1
		)| zenity width=400 --title="Zenvidia" --progress --pulsate \
		--auto-close --text="$v$m_01_08$end ($DRV)..."
		cat $nvtmp/vd_compat.$TF | grep "<tr\|<td\|</tr>"| \
		perl -n -pe "s|(<(/\|)t[r,d](>\| id=\"))||,s|(\">\|</td>)\n|,|p" > $nvtmp/compat.$TF
#		perl -n -pe "s|(<tr>\|<tr id=\"\|<td>)||,s|(\">\|</td>)\n|,|;s|</tr>$||p" > $nvtmp/compat.$TF
		for e in $pci_dev_nb; do
#			DEV_filter=$(cat $nvtmp/compat.$TF|sed -n "/devid${slot_id[$e]}\"/,/^.*<td>/{n;p}")
#			DEV_nm=$(printf "$DEV_filter"|sed -n '1p'|sed -n 's/<[^>]*//g;s/>//g;p')
#			VDPAU=$(printf "$DEV_filter"|sed -n '$p'|sed -n 's/<[^>]*//g;s/>//g;p')
			DEV_slot=$(printf "${slot_id[$e]}"|sed -n "s/[a-z]./\U&/g;p")
			DEV_filter=$(cat $nvtmp/compat.$TF|grep "$DEV_slot")
			DEV_filter=$(printf "$DEV_filter"| grep "${dev[$e]}")
			DEV_nm=$(printf "$DEV_filter"|cut -d"," -f2)
			VDPAU=$(printf "$DEV_filter"|cut -d"," -f4)
#			if [ "$DEV_nm" == "${dev[$e]}" ]; then
			if [[ $DEV_filter ]]; then
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
			if [[ $DEV_filter ]]; then
				COMP_L+=("$j${dev[$e]}$end $v($DRV), $comp_b$end\n$j$DRV$end $comp_c")
				w_height=$(($w_height+30))
			fi
		done
		((TF++))
	done
	ifs=$IFS
	IFS=$(echo -en "\n\b")
	compat_msg="${COMP_L[*]}\n"
	IFS=$ifs
	win_update
}
win_update(){
	if [[ $(ls -1 $nvdl/ | grep "$LAST_DRV\|$LAST_BETA") != '' ]]; then
		if [ -e $nvdl/nv-update-$LAST_DRV ]; then
			if [[ $LAST_IN == $LAST_DRV ]]; then set_in=" ($m_01_18)"; fi
			start_msg="$j$LAST_DRV$end$vB $m_01_14a $m_01_16.$end$v$set_in$end"
			ui_mod=0
			end_msg=$m_01_17
			if [ $LAST_BETA != '' ]; then
					more_msg="\n$j$LAST_BETA$end$vB $m_01_14b $m_01_16.$end"
					end_msg="\n$m_01_13"
					w_height=$(($w_height+65))
					ui_mod=1
			fi
		elif [ -e $nvdl/nv-update-$LAST_BETA ]; then
			if [[ $LAST_IN == $LAST_BETA ]]; then set_in=" ($m_01_18)"; fi
			start_msg="$j$LAST_BETA$end$vB $m_01_14a $m_01_16.$end$v$set_in$end"
			end_msg="$m_01_17"
			ui_mod=0
			if [ $LAST_DRV != '' ]; then
					more_msg="\n$j$LAST_DRV$end$vB $m_01_14b $m_01_16.$end"
					end_msg="\n$m_01_13"
					w_height=$(($w_height+65))
					ui_mod=1
			fi
		fi
		if [ -e $nvdl/nv-update-$LAST_DRV ]&&[ -e $nvdl/nv-update-$LAST_BETA ]; then
			if [[ $LAST_DRV == $LAST_BETA ]]; then
				start_msg="$j$LAST_DRV$end$vB, $m_01_14c $m_01_16.$end"
			else
				if [[ $LAST_IN == $LAST_DRV||$LAST_BETA ]]; then
					set_in=" ($LAST_IN $m_01_18)"
				fi
				start_msg="\n$v$m_01_14c $m_01_16 $set_in.$end"
			fi
			more_msg=''
			ui_mod=0
			end_msg="$m_01_17"
		fi		
		extra_msg="\n$start_msg$more_msg\n$v$end_msg$end"
	else
		ui_mod=1	
		extra_msg="\n$v$m_01_13$end"
	fi
	if [ $ui_mod = 0 ]; then
		w_height=300
		zen_opts='--info --icon-name=swiss_knife '
		table_opts=''
		list_opts=''
	elif [ $ui_mod = 1 ]; then
		# 395
#		w_height=365
		zen_opts='--list --radiolist --hide-header'
		table_opts='--column "1" --column "2" --column "3" --separator=";" --hide-column=2'
		list_opts="false 1 $_01 false 2 $_06 false 3"
	#		if [ $TF -ge 2 ]; then
	#		qst_msg="\n$v$m_01_13$end"
	#		fi
	elif [ $ui_mod = 2 ]; then
		w_height=300
		zen_opts="--question --ok-label=$_01 --cancel-label=$R"
		table_opts=''
		list_opts=''
		extra_msg="\n$v$m_01_13$end"
	fi
	sel_cmd=$(zenity --width=450 --height=$w_height --title="Zenvidia" $zen_opts \
	--text="$rBB$m_01_19$end\n
$v $msg_0_01$end\t$j$LAST_IN$end
$v $m_01_20$end\t$j$LAST_DRV$end
$v $m_01_21$end\t$j$LAST_BETA$end\n
$compat_msg$extra_msg" $table_opts $list_opts "$R" )
	if [ $? = 0 ]; then
		if [ $ui_mod != 0 ]; then
			if [ $ui_mod = 1 ]; then
				case $sel_cmd in
					"1") from_net ;;
					"2") download_only ;;
					"3") base_menu ;;
				esac
			elif [ $ui_mod = 2 ]; then
				from_net
			fi 	
		elif [ $ui_mod = 0 ]; then
			base_menu
		fi
	elif [ $? = 1 ]; then
		base_menu
	fi
		
}
download_menu(){
	unset DM_list
	dn=1
	if [ $if_update = 1 ]; then
		D1="$LAST_DRV ($m_01_41)"
		D2="$LAST_BETA ($m_01_42)"
	else
		D1="$LAST_DRV ($m_01_41)"
		D2="$LAST_BETA ($m_01_42)"
		D3="$m_01_43a ($m_01_43b)"
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
	--text="$v$m_01_40$end" --hide-header \
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
	cd $nvupdate
	download_menu
	if [ -f $nvupdate/$run_pack ]; then
		zenity --info --title="Zenvidia" --no-wrap --icon-name=swiss_knife \
		--text="$v $m_01_46$end $j$LAST_PACK$end $v$m_01_47.\n$MM$end"
		mv -f $nvupdate/$run_pack $nvdl/nv-update-$LAST_PACK
		chmod 755 $nvdl/nv-update-$LAST_PACK
		base_menu
	else
		zenity --width=450  --title="Zenvidia" --error \
		--text="$v $m_01_46$end $j$LAST_PACK$end $v$m_01_48.\n $m_01_50$end $j$run_pack$end $v$m_01_51.\n$MM.$end"	
		base_menu
	fi
#		# TODO install from GIT, then back to download
}
### UPDATE FUNCTION, FROM INTERNET.
package_list(){
	unset drv_list
	pck_drv=$(tac $nvtmp/drvlist | sed -n "s/^.*\ //p" | sed -n "/^3\|^2/p")
	for line in $pck_drv; do
		drv_list+=("$line")
	done
#	PICK_DRV=$(zenity --width=450  --height=300 --title="Zenvidia" \
#	--entry --text "Driver list" --entry-text="${drv_list[@]}")
	PICK_DRV=$(zenity --width=450  --height=300 --title="Zenvidia" --list --radiolist \
	--text "$rBB$m_01_52$end" --hide-header --column "1" --column "2" --separator=";" \
	"${drv_list[@]}")
	if [ $? = 1 ]; then exit 0; fi
}
last_pack(){
	track(){
    # picked up & inspired by winetricks download progress commande:
    # Parse a percentage, a size, and a time into $1, $2 and $3
    # then use them to create the output line.
   	perl -p -e "$| = 1; s|^.* +([0-9]+%) +([0-9,.]+[GMKB]) +([0-9hms,.]+).*$|\1\n# $run_pack\t(\1): $m_01_54 \3\t\2\/s|"
	}
	download_cmd(){
		wget -c https://$nvidia_ftp-$ARCH/$LAST_PACK/$run_pack $nvupdate/ 2>&1
	}
#	( lftp -c "anon; cd https://download.nvidia.com/XFree86/Linux-$ARCH/$LAST_PACK/ ; ls > $nvtmp/bug_list ; quit" ; sleep 2
	( wget -q -O $nvtmp/bug_list_0 https://$nvidia_ftp-$ARCH/$LAST_PACK/
	cat $nvtmp/bug_list_0 | egrep -o "href='NVIDIA.*[0-9]+.*'"| perl -pe "s/^.*\'(.*)\'/\1/p" \
	> $nvtmp/selector
	sleep 2
	) | zenity --width=500 --progress --pulsate --auto-close --text="$v$m_01_55$end"
#	if [[ $(cat $nvtmp/selector | grep -w "$LAST_PACK") != '' ]] ; then
	if [ $(cat $nvtmp/selector | grep -c "$LAST_PACK") -gt 0 ] ; then
#		RUN_PACK=$(cat $nvtmp/selector | sed -n "s/^.*\ //p"|grep -w "$LAST_PACK"|sed -n "/.run$/p")
		RUN_PACK=$(cat $nvtmp/selector)
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
	( download_cmd | track
	) | zenity --width=500 --progress --auto-close --title="$m_01_44 $LAST_PACK"
	err=$?
    if test $err -gt 128; then
        if pid=`ps -A | grep ."wget" | awk '{print $1}'`; then
            echo User aborted download, killing wget
            kill $pid
        fi
    fi
    return $err
    _local=$(stat -c "%s" $nvupdate/$run_pack)
    _remote=$(cat $nvtmp/selector | grep -w "$run_pack"|sed -n "/.run$/p"|awk '{print $5}')
    [ $_remote = $_local ]|| { 
    zenity --height=100 --error --icon-name=xkill --no-wrap \
    --text="$v\Download unexpected termination.\nPlease restart driver download from $vB\Update$end menu$end" --ok-label="Oh! Fuck!"
    if [ $? = 0 ]; then base_menu; fi
    }
}
from_net(){
# download functions
		cd $nvupdate
		download_menu
		driverun=$nvdl/nv-update-$LAST_PACK
		if [ -f $nvupdate/$run_pack ]; then
			zenity --info --title="Zenvidia" --no-wrap --icon-name=swiss_knife \
			--text="$v $m_01_46$end $j$LAST_PACK$end $v$m_01_47.$end"
			mv -f $nvupdate/$run_pack $nvdl/nv-update-$LAST_PACK
			chmod 755 $nvdl/nv-update-$LAST_PACK
		fi
		install_type_sel
		#rm -f $nvtmp/drvlist $nvtmp/last_up
}
## TOOLS
win_confirm(){
	# popup confirmation window to be clomplete with the following vars:
	#	confirm_msg="" TEXT
	#	val_title="" TEXT
	#	val_confirm="" TEXT
	#	val_back="" TEXT
	#	val_exit="" EXIT CMD
	confirm_w=$(zenity --title="$val_title" --list --radiolist \
	--hide-header --text "$confirm_msg\n\n$v$m_01_13$end" --hide-column "2" --column "1" --column "2" \
	--column "3" --separator=";" false 1 "$val_confirm" false 2 "$val_back")
	if [ $? = 1 ]; then exit 0 ; fi
	case $confirm_w in "2") $val_exit;; esac
}
## REPAI TOOL
fix_broken_install(){
	confirm_msg="$vB$m_01_80$end"
	val_title="Zenvidia Repair"
	val_confirm="$m_01_83"
	val_back="$PM"
	val_exit="manage_pcks"
	win_confirm
	unset elf_lib_list msg
	elf_lib=("$ELF_64" "$ELF_32")
	if [ $install_type = 0 ]; then
		if [ ! -e /etc/ld.so.conf.d/nvidia-$master$ELF_TYPE.conf ]; then
			for nv_lib in "${elf_lib[@]}"; do
				ld_conf=$croot/nvidia/$master$nv_lib
				[[ $nv_lib == 64 ]]|| nv_lib=32
				nv_lib_file='/etc/ld.so.conf.d/nvidia-'$master$nv_lib'.conf'
				printf "$ld_conf" > $nv_lib_file
				msg+=("$v\Restored:$end $master$nv_lib NVIDIA libraries relink to /etc/ld.so.conf.d.\n")
			done
			ldconfig
		fi
	fi
	if [ ! -e /etc/X11/xorg.conf.nvidia.$version ]; then
		new_version=$version
		xorg_conf
		msg+=("$v\Restored:$end NVIDIA Xorg conf for $version driver re-installed in /etc/X11.\n")
	fi
	if [ ! -e /etc/OpenCL/vendors/nvidia.icd ]; then
		if [ $install_type = 0 ]; then
			opencl="libnvidia-opencl.so.1"
		else
			opencl="$croot/nvidia/$master$ELF_64/libnvidia-opencl.so.1"
		fi
		printf "$opencl\n" > /etc/OpenCL/vendors/nvidia.icd
		msg+=("$v\Restored:$end NVIDIA OpenCL relink to system /etc.\n")
	fi
	if [ ! -e /usr/$master$ELF_64/vdpau/libvdpau_nvidia.so.1 ]; then
		for lib_V in "${elf_lib[@]}"; do
			link_v=$(ls -l /usr/$master$lib_V/vdpau/libvdpau_nvidia.so.1| sed -n "s/^.*-> //p")
			if [[ ! $(printf "$link_v"|grep -o "$new_version") ]]; then
				ln -sf $croot/nvidia/$master$lib_V/vdpau/libvdpau_nvidia.so.$new_version /usr/$lib_V/vdpau/libvdpau_nvidia.so.1 
			fi
			msg+=("$v\Restored:$end NVIDIA vdpau libraries relink to /usr/$master$lib_V/vdapu.\n")
		done
		ldconfig
	fi
	if [ ! -e /lib/modules/$(uname -r)/extra/nvidia.ko ]; then
		if [ -d $croot/nvidia/$(uname -r) ]; then
			cp -f $croot/nvidia/$(uname -r)/* /lib/modules/$(uname -r)/extra/
		fi
		depmode -a
		msg+=("$v\Restored:$end NVIDIA $version drivers re-install in /lib/modules/$(uname).\n")
	fi
	if [ $(cat $grub_dir/grub.cfg|grep -c "rd.driver.blacklist=nouveau") -eq 0 ]; then
		if_blacklist
		msg+=("$v\Restored:$end Re-install Nouveau driver in blacklist and grub.cfg.")
	fi
	if [ $(printf "${msg[@]}"| grep -c "[a-z]") = 1 ]; then
		repair_msg="$vB$m_01_80$end" "$(printf " ${msg[*]}")"
	else
		repair_msg="$vB$m_01_82$end"
	fi
	zenity --width=450 --title="$val_title" --info \
		--no-wrap --icon-name=swiss_knife --text="$repair_msg"
		if [ $? = 0 ]; then base_menu ; fi 
}
## PACKAGE MANAGING
manage_pcks(){
	menu_packs=$(zenity --width=400 --height=300 --list \
	--radiolist --hide-header --title="Zenvidia" \
	--text "$rBB$_3d$end" \
	--column "1" --column "2" --column "3" --separator=";" --hide-column=2 \
	false 1 "$_6a" false 2 "$_6b" false 3 "$_6c" false 4 "$PM" )
	if [ $? = 1 ]; then exit 0; fi
	case $menu_packs in
		"1") remove_pcks ;;
		"2") backup_pcks ;;
		"3") restore_pcks ;;
		"4") menu_modif ;;
	esac
}
remove_pcks(){
	# list package in release directory
	unset rm_packs packs_list
	for pack in $(ls -1 $nvdl); do
		packs_list+=("false")
		packs_list+=("$pack")
	done
	rm_packs=$(zenity --width=400 --height=300 --list --multiple \
	--checklist --hide-header --title="Zenvidia (remove)" \
	--text "$rBB$_6a$end" \
	--column "1" --column "2" --separator=" " \
	"${packs_list[@]}" )
	if [ $? = 1 ]; then base_menu; fi
	sel_cnt=$(printf "$rm_packs"| grep -c " ")
	zenity --width=300 --title="Zenvidia ($_6a)" --icon-name=swiss_knife --question \
	--text="$vB$(printf "$_6d\n\n$_6g" "$rm_packs")$end" --ok-label="$CC" --cancel-label="$PM"
	if [ $? = 0 ]; then
		for vers in ${rm_packs[@]}; do
			pack_vers=$(printf "$vers"|sed -n "s/^.*-//g;p")
			vers_ref=$(printf "$pack_vers"|sed -n "s/\.//p")
			if [ -d $croot/nvidia.$pack_vers ]; then
				zenity --width=300 --title="Zenvidia ($_6a)" --question \
				--text="$v$_6f $croot ?\n$_6g$end"
				if [ $? = 0 ]; then
					if [[ $ver_pack = $ver_txt ]]; then
						zenity --height=100 --title="Zenvidia ($_6a)" --icon-name=xkill \
						--error --no-wrap --text="$v$(printf "$wrn_06f" "$pack_vers")$end" \
						--ok-label="$lab_06f"
					else
						rm -Rf $croot/nvidia.$pack_vers
						rm -f $nvdl/nv-update-$pack_vers
					fi
				fi
			else
				rm -f $nvdl/nv-update-$pack_vers
			fi
		done
		zenity --height=100 --title="Zenvidia ($_6a)" --icon-name=swiss_knife --info \
		--text="$vB$(printf "$inf_06a" "$rm_packs")$end" --no-wrap
		manage_pcks
	else
		manage_pcks
	fi
}
backup_restore(){
	# list package in release directory
	unset drive_list
#	croot_repo=$(ls -1 $nvbackup| grep "nvidia.[[:digit:]]" | grep -v ".bak")
	[ -d $nvbackup ]|| mkdir -p $nvbackup
	if [ $b_type = 0 ]; then
		croot_repo=$(ls -1 $croot | grep "nvidia.")
	else
#		croot_repo=$(ls -1 $nvbackup | grep "nvidia.")
		croot_repo=$(ls -1 $nvbackup | grep "nvidia."| sed -n "s/.tar.gz//p")
	fi
	for drive in $croot_repo; do
		drive_list+=("false")
		drive_list+=("$drive")
	done
	drive_packs=$(zenity --width=400 --height=300 --list \
	--radiolist --hide-header --title="Zenvidia ($b_mod)" \
	--text "$rBB$b_msg$end" --column "1" --column "2" --separator=";" \
	"${drive_list[@]}" )
	if [ $? = 1 ]; then base_menu; fi
}
backup_pcks(){
	b_mod='backup'
	b_msg="$_6b\n$v$m_01_75 $b_mod.$end"
	b_type=0
	backup_restore
	bak_version=$(printf "$drive_packs"|sed -n "s/nvidia.//p")
#	bak_version=$(printf "$drive_packs"|sed -n "s/nvidia.\([0-9]*\).tar.gz/\1/p")
	if [[ -d $nvbackup/nvidia.$bak_version ]]; then
		zenity --width=250 --height=100 --title="Zenvidia ($_6b)" --info --icon-name=swiss_knife \
		--no-wrap --text="$j$bak_version$end$v $m_01_70.$end"
		if [ $? = 0 ]; then manage_pcks ; fi
	else
		zenity --width=250 --height=100 --title="Zenvidia ($_6b)" --question \
		--text="$v$_6e $j$drive_packs$end ?\n$_6g$end" \
		--ok-label="$CC" --cancel-label="$R"
	fi
	if [ $? = 0 ]; then
		( backup_old_version; sleep 2 )| zenity --width=400 --title="Zenvidia $b_mod" \
		--progress --pulsate --auto-close --text="$v\Backing up $j$bak_version$end driver.$end"
		ko_version=$mod_version
		if [ $ko_version != $bak_version ]; then
			zenity --width=300 --height=100 --title="Zenvidia ($_6b)" --question \
			--text="$v$_6h ?\n$_6g$end"
			if [ $? = 0 ]; then
				rm -Rf $croot/$drive_packs
			fi
		fi
		manage_pcks
	else
		manage_pcks
	fi
}
restore_pcks(){
	b_mod='restore'
	b_msg="$_6c\n$v$m_01_75 $b_mod.$end"
	b_type=1
	backup_restore
#	res_version=$(printf "$drive_packs"|sed -n "s/nvidia.//p")
	res_version=$(printf "$drive_packs"|sed -n "s/nvidia.\([0-9]*\)/\1/p")
	ver_res=$(printf "$res_version"| sed -n "s/\.//p")
#	res_version=$(printf "$drive_packs"|sed -n "s/nvidia.//;s/.bak$//p")
	if [ ! -d $croot/$drive_packs ]; then
		unset bk_list
#		mkdir -p $croot/nvidia.$res_version
		bk_list=(
			"nvidia.$res_version/$(uname -r)/*,/lib/modules/$(uname -r)/extra/,-f,depmod -a"
			"version.txt,$nvdir/,-f"
			"etc/,/,-Rf"
			"usr/,/,-Rf"
			"var/,/,-Rf"			
			"nvidia.$res_version,$croot/,-Rf"
		)
		confirm_msg=$(printf "$v$m_01_76$end." "$res_version" "$version")
		val_title="Zenvidia $b_mod"
		val_confirm="$m_01_77"
		val_back="$PM"
		val_exit="manage_pcks"
		win_confirm
		tar -zxf $nvbackup/nvidia.$res_version.tar.gz -C $nvtmp/
		(	for restor in "${bk_list[@]}"; do
				input=$(printf "$restor"| cut -d, -f1)
				output=$(printf "$restor"| cut -d, -f2)
				c_opt=$(printf "$restor"| cut -d, -f3)
				c_ext=$(printf "$restor"| cut -d, -f4)
#				cp $c_opt $nvbackup/$drive_packs/$input $output
				cp $c_opt $nvtmp/$drive_packs/$input $output
				$c_ext
			done
			cd $croot/
			ln -sf -T ./nvidia.$res_version ./nvidia
			## remove /opt/nvidia.prev_version for compatibility future restore purpose
			rm -Rf ./nvidia.$version
			## fix symlinks if necessary
			for lib_elf in {$master$ELF_32,$master$ELF_64}; do
				for links in {cfg,fbc,gtk2,gtk3}; do
					if [ $(ls -1 /usr/local/$lib_elf/libnvidia-$links.so.$res_version| \
					grep -c .) -gt 0 ]; then
						if [ $(ls -l /usr/local/$lib_elf/libnvidia-$links.so.1| \
						grep -c "$res_version" ) -eq 0 ]; then
							if [ -h /usr/local/$lib_elf/libnvidia-$links.so.1 ]; then
								rm -f /usr/local/$lib_elf/libnvidia-$links.so.1
							fi
							cd /usr/local/$lib_elf/
							ln -sf libnvidia-$links.so.$res_version libnvidia-$links.so.1
							ln -sf libnvidia-$links.so.1 libnvidia-$links.so
						fi
						if [ -s /usr/local/$lib_elf/libnvidia-$links.so.$version ]; then
							rm -f /usr/local/$lib_elf/libnvidia-$links.so.$version
						fi
					fi
				done
				if [ $(ls -l /usr/$lib_elf/vdpau/libvdpau_nvidia.so.1| \
				grep -c "$res_version" ) -eq 0 ]; then
					if [ -h /usr/$lib_elf/vdpau/libvdpau_nvidia.so.1 ]; then
						rm -f /usr/$lib_elf/vdpau/libvdpau_nvidia.so.1
					fi
					ln -sf $croot/nvidia.$res_version/$lib_elf/vdpau/libvdpau_nvidia.so.$res_version \
					/usr/$lib_elf/vdpau/libvdpau_nvidia.so.1 
				fi
			done
			ldconfig
		)| zenity --width=400 --title="Zenvidia $b_mod" --progress --pulsate --auto-close \
		--text="$(printf "$v$m_01_78$end" "$res_version")"
		rm -Rf $nvtmp/nvidia.$res_version
		if [ $(ls -1 /opt/nvidia.$res_version/| grep -c "$(uname -r)") -eq 0 ]; then
			confirm_msg=$(printf "$v$m_01_79$end." "$res_version")
			val_title="Zenvidia $b_mod"
			val_confirm="$m_01_80"
			val_back="$PM"
			val_exit="manage_pcks"
			win_confirm
			( version=$res_version 
#				upgrade_kernel
			if [ $use_dkms = 1 ]; then
				force=0
				nv_build_dkms 
			else
				nv_cmd_make_src
			fi
#			KERNEL=
			croot_all=$croot/nvidia.$res_version
			kernel_path=/lib/modules/$KERNEL/extra
			backup_driver
			)| zenity --width=450 --title="Zenvidia" --progress --pulsate --auto-close \
			--text="$v Restore modules missing. Building new ones...$end"
		fi
	else
		# current version overwrite ALERT message
		if [[ $ver_res -eq $ver_mod ]]; then
			warning_msg=$(printf "$vB$wrn_06c.$end" "$res_version")
			zenity ---error --title="Zenvidia $b_mod" --icon-name=xkill \
			--text="$warning_msg" --no-wrap --ok-label="$lab_06c"
			manage_pcks
		fi
	fi
	manage_pcks
}

## EDITION TOOLS
edit_script_conf(){
	edit_script=$(zenity --width=500 --height=400 --title="Zenvidia" --text-info \
	--editable --text="$v$m_01_58$end" --filename="$basic_conf" \
	--checkbox="$m_01_59" )
#	exit_stat=$?
	if [[ $(printf "$edit_script"| sed -n '1p') != '' ]]; then
		printf "$edit_script\n" > $basic_conf
	fi
#	if [ $exit_stat = 0 ]; then menu_manage
#	elif [ $exit_stat = 1 ]; then exit 0
#	fi
	menu_modif
}
edit_xorg_conf(){
	if [ $install_type = 1 ]; then
		if [ $use_bumblebee = 1 ]; then
			xorg_cfg=$tool_dir/etc/bumblebee/xorg.conf.nvidia
		elif [ $use_bumblebee = 0 ]; then
			xorg_cfg=/etc/nvidia-prime/xorg.nvidia.conf
		fi
	else
		xorg_cfg=/etc/X11/xorg.conf
	fi
	edit_xorg=$(zenity --width=500 --height=400 --title="Zenvidia" --text-info --editable \
	--text="$v\Edit xorg config file$end" --filename="$xorg_cfg" \
	--checkbox="Confirm to overwrite" )
	if [[ $(printf "$edit_xorg"| sed -n '1p') != '' ]]; then
		printf "$edit_xorg\n" > $xorg_cfg
	fi
#	if [ $? = 0 ]; then menu_manage
#	elif [ $? = 1 ]; then exit 0
#	fi
	menu_modif
}
read_help(){
	zenity --width=500 --height=400 --title="Zenvidia" --text-info \
	--text="$v\Help files for zenvidia$end" --filename="$nvdir/README.md"
	menu_manage
}
read_nv_help(){
	zenity --width=700 --height=400 --title="Zenvidia" --text-info \
	--text="$v$m_01_62$end" --filename="$help_pages/README.txt"
	menu_manage
}
read_changelog(){
	zenity --width=600 --height=400 --title="Zenvidia" --text-info \
	--text="$v$m_01_63 ($version)$end" --filename="$help_pages/NVIDIA_Changelog"
	menu_manage
}
nv_config(){
	if [ $use_bumblebee = 1 ]; then
		$SU_u $def_user -c 'optirun -b none nvidia-settings -c :8'
	else
		$SU_u $def_user -c "nvidia-settings"
	fi
	menu_modif
}
zen_notif_setup(){
	setup_validation(){
		zenity --height=100 --title="Zenvidia notification" --question --no-wrap \
		--icon-name=swiss_knife --text="$vB$(printf "$wrn_notif_01" "$_notif")$end" \
		--cancel-label="$PM"
		if [ $? = 1 ]; then menu_modif; fi
		sed -i "s/Exec=zen_notify.sh -[a-z]$/Exec=zen_notify.sh $_set/" $desk_file
		base_menu
	}
	desk_file=/home/$USER/.config/autostart/zen_notify.desktop
	unset setup_list setup_option c_set_list
	setup_option=(
	"$menu_notif_01;$m_notif_01;n"
	"$menu_notif_02;$m_notif_02;z"
	"$menu_notif_03;$m_notif_03;a"
	)
	if [ $hlp_txt = 1 ]; then
		hlp_tip="\n$hlp_notif"
		w_height='--height=350'
	else
		hlp_tip=''
		w_height='--height=300'
	fi
	st=1
	c_set_opt=$(cat $desk_file |grep "Exec"| perl -p -e "s|^.*-+([a-z])|\1|")
	for n_set in "${setup_option[@]}"; do
		m_set=$(printf "$n_set"|cut -d';' -f1)
		c_set=$(printf "$n_set"|cut -d';' -f2)
		o_set=$(printf "$n_set"|cut -d';' -f3)
		setup_list+=("false")
		setup_list+=("$st")
		setup_list+=("$m_set")
		if [[ $o_set == $c_set_opt ]]; then c_set_cnf=$c_set; fi
		st=$[ $st+1 ]
	done
	menu_notif=$(zenity --width=400 $w_height --list --radiolist --hide-header \
	--title="Zenvidia notification" \
	--text "$rBB$_3g$end$vB\n$(printf "$notif_msg" "$c_set_cnf")$hlp_tip$end" \
	--column "1" --column "2" --column "3" --hide-column=2 \
	"${setup_list[@]}" false $st "$PM")
	if [ $? = 1 ]; then base_menu; fi
	case $menu_notif in
		"1") _set='-n'; _notif="$m_notif_01" ;;
		"2") _set='-z'; _notif="$m_notif_02" ;;
		"3") _set='-a'; _notif="$m_notif_03" ;;
		"$st") menu_modif ;;
	esac
	setup_validation
}
prime_setup(){
	setup_prime(){
		prime_setcmd(){
		for pset in "${_pset[@]}"; do
			/usr/sbin/nvidia-prime-select $pset
		done
		}
		if [ $from_menu_install = 0 ]; then
		b_cancel="--cancel-label=$PM"
		w_type='--question'
		else
			b_cancel='--ok-label=Setup'
			w_type='--info'
		fi
		zenity --height=100 --title="Zenvidia prime setup" $w_type --no-wrap \
		--icon-name=swiss_knife --text="$vB$(printf "$wrn_prime_01$wrn_prime_02" "$_prime")$end" \
		"$b_cancel"
		ext1=$?
		if [ $from_menu_install = 0 ]; then
			if [ $ext1 = 1 ]; then menu_modif; fi
			prime_setcmd
			base_menu
		else
			prime_setcmd
		fi
	}
	unset setup_list setup_option _pset
	setup_option=(
	"$menu_prime_01;$m_prime_01;intel;/etc/X11/xinit/xinitrc.d/intel"
	"$menu_prime_02;$m_prime_02;nvidia;/etc/X11/xinit/xinitrc.d/nvidia"
	"$menu_prime_03;$m_prime_03;nvidia;/etc/rc.d/rc.nvidia"
	)
	pt=1
	for p_set in "${setup_option[@]}"; do
		pp_set=$(printf "$p_set"|cut -d';' -f1)
		pc_set=$(printf "$p_set"|cut -d';' -f3)
		pc_msg=$(printf "$p_set"|cut -d';' -f2)
		pc_file=$(printf "$p_set"|cut -d';' -f4)
		setup_list+=("false")
		setup_list+=("$pt")
		setup_list+=("$pp_set")
		if [ $(ls -1 $pc_file| grep -c "$pc_set" ) -eq 1 ]; then
			current_set=$pc_msg
		fi
		pt=$[ $pt+1 ]
	done
	if [ $from_menu_install = 0 ]; then
		prime_msg="$prime_msg_01\n$(printf "$prime_msg_02" "$current_set")"
		case_exit="false $pt \'$PM\'"
	fi
	menu_prime=$(zenity --width=400 --height=300 --list --radiolist --hide-header \
	--title="Zenvidia prime setup" --text "$rBB$_3h$end$v$prime_msg$end" \
	--column "1" --column "2" --column "3" --separator=";" --hide-column=2 \
	"${setup_list[@]}" false $pt "$PM")
	ext0=$?
	if [ $from_menu_install = 0 ]; then
		if [ $ext0 = 1 ]; then base_menu; fi
		case $menu_prime in
			"1") _pset=( "intel"); _prime="$m_prime_01" ;;
			"2") _pset=( "nvidia" ); _prime="$m_prime_02" ;;
			"3") _pset=( "nvidia" "nvidiaonly" ); _prime="$m_prime_03" ;;
			"$pt") menu_modif ;;
		esac
	else
		case $menu_prime in
			"1") _pset=( "intel"); _prime="$m_prime_01" ;;
			"2") _pset=( "nvidia" ); _prime="$m_prime_02" ;;
			"3") _pset=( "nvidia" "nvidiaonly" ); _prime="$m_prime_03" ;;
		esac
	fi
	setup_prime
}
## Define language at script init
lang_define(){
	## language pack
	if [[ $LG != '' ]];then
	PACK=$LG\_PACK
	. $locale/$PACK
	else
		zenity --width=450 --title="Zenvidia" --warning \
		--text="$v\Langage pack not define.\nCheck script conf to fix.$end"
		exit 0
	fi
}
### TERTIARY MENU
glx_test(){
	unset test_list
	unset test_cmd
	if [ $use_bumblebee = 1 ]; then
		test_v='optirun -b virtualgl'
		test_p='optirun -b primus'
		test_cmd=( "$_7a (virtualgl)" "$_7b (virtualgl)" "$_7a (primus)" "$_7b (primus)" )
	else
		test_x=''
		test_cmd=( "$_7a" "$_7b" )
	fi
	nt=1
	for xtest in "${test_cmd[@]}"; do
		test_list+=("false")
		test_list+=("$nt")
		test_list+=("$xtest")
		nt=$[ $nt+1 ]
	done
	
	menu_test=$(zenity --width=400 --height=300 --list --radiolist --hide-header \
	--title="Zenvidia" --text "$rBB$_4a$end" \
	--column "1" --column "2" --column "3" --separator=";" --hide-column=2 \
	"${test_list[@]}" false $nt "$MM")
	if [ $? = 1 ]; then exit 0; fi
	g='\e[1;32m'
#	x_opt="-sb -b 5 -bg black -bd green -bw 0 -title Zenvidia_Gears"
	if [ $use_bumblebee = 1 ]; then
		if [[ $menu_test = 1 || $menu_test = 2 ]]; then test_x="$test_v"
		elif [[ $menu_test = 3 || $menu_test = 4 ]]; then test_x="$test_p"
		fi
	else
		test_x=''
	fi
	if [ $use_bumblebee = 1 ]; then
		case $menu_test in
			"1") xterm $x_opt -e "printf \"$g$m_01_64.\n\n\"; $test_x glxgears"; glx_test ;;
			"2") $test_x glxspheres; glx_test ;;
			"3") xterm $x_opt -e "printf \"$g$m_01_64.\n\n\"; $test_x glxgears"; glx_test ;;
			"4") $test_x glxspheres; glx_test ;;
			"$nt") base_menu ;;
		esac
	else
		case $menu_test in
			"1") xterm $xt_options -title Test -e "printf \"$m_01_64.\n\n\"; glxgears"; glx_test ;;
			"2") glxspheres; glx_test ;;
			"$nt") base_menu ;;
		esac
	fi
#"1") xterm $x_opt -e "printf \"$g$m_01_64.\n\n\"; glxgears"; glx_test ;;
}
menu_optimus(){
#	opti_msg="\n$vB\Two solutions:$end$v
#\t- Application intergrated with Bumblebee.
#\t- One GPU at a time with Prime.$end"
	opti_msg=$msg_3_03
	menu_opti=$(zenity --width=400 --height=300 --list \
	--radiolist --hide-header --title="Zenvidia" \
	--text "$rBB\Optimus$end\n$opti_msg" \
	--column "1" --column "2" --column "3" --separator=";" --hide-column=2 \
	false 1 " Bumblebee" false 2 " Prime" false 5 "$PM" )
	if [ $? = 1 ]; then exit 0; fi
	if [ $from_menu_install = 1 ]; then
		case $menu_opti in
			"1") menu_msg="$vB$msg_3_01$end" 
			if [ $use_bumblebee != 1 ]; then
				sed -i "s/use_bumblebee=[0-9]/use_bumblebee=1/" $script_conf 
				use_bumblebee=1
			fi
			;;
			"2") menu_msg="$vB$msg_3_02$end"
			if [ $use_bumblebee != 0 ]; then
				sed -i "s/use_bumblebee=[0-9]/use_bumblebee=0/" $script_conf 
				use_bumblebee=0
			fi
			;;
		esac
	else  # from_menu_install = 0
		case $menu_opti in
			"1") menu_msg="$vB$msg_3_01$end"; build_all; base_menu ;; #  use_bumblebee=1;
			"2") menu_msg="$vB$msg_3_02$end"; prime_build; base_menu ;; #  use_bumblebee=0;
	#		"3") menu_install ;;
			"3") exit 1 ;;
		esac
	fi
}
### SUB MENU
menu_install(){
	unset install_list ins_cmd ins_list
	if [ $hlp_txt = 1 ]; then
		if [ $install_type = 0 ]; then hlp_tip="\n$hlp_01b"
		else hlp_tip="\n$hlp_01b\n$hlp_01c"; fi
		w_height='--height=300'
	else
		hlp_tip="\n$hlp_01a"
		w_height='--height=450'
	fi
	if [ $install_type = 0 ]; then
		install_list=("$_1a" "$_1b")
	else install_list=("$_1a" "$_1b" "$_1c"); fi
	n=1
	for ins_cmd in "${install_list[@]}"; do
		ins_list+=("false")
		ins_list+=("$n")
		ins_list+=("$ins_cmd")
		n=$[ $n+1 ]
	done 
	menu_inst=$(zenity --width=400 $w_height --list \
	--radiolist --hide-header --title="Zenvidia" \
	--text "$rBB$_01$end$v$hlp_tip$end" \
	--column "1" --column "2" --column "3" --separator=";" --hide-column=2 \
	"${ins_list[@]}" false $n "$MM" )
#	false 1 "$_1a" false 2 "$_1b" false 3 "$_1c" false 4 "$_1d" false 5 "$MM" )
	if [ $? = 1 ]; then exit 0; fi
	if [ $install_type = 0 ]; then
		case $menu_inst in
			"1") menu_msg="$vB$msg_1_01$end"; force=0; from_directory ;;
			"2") menu_msg="$vB$msg_1_02$end"; ui_mod=2; force=0; check_update ;;
	#		"4") menu_msg="$vB$msg_1_04$end"; nv_cmd_uninstall; base_menu ;;
			"$n") base_menu ;;
		esac
	else
		case $menu_inst in
			"1") menu_msg="$vB$msg_1_01$end"; force=0; from_directory ;;
			"2") menu_msg="$vB$msg_1_02$end"; ui_mod=2; force=0; check_update ;;
	#		"3") menu_msg="$vB$msg_1_03$end"; build_all; base_menu	;;
			"3") menu_msg="$vB$msg_1_03$end"; force=0; menu_optimus; base_menu ;;
	#		"4") menu_msg="$vB$msg_1_04$end"; nv_cmd_uninstall; base_menu ;;
			"$n") base_menu ;;
		esac
	fi
}
menu_update(){
	if [ $hlp_txt = 1 ]; then
		w_height='--height=650'
	else
		hlp_tip=''
		w_height='--height=300'
	fi
	nu=1
#	if [ $use_dkms = 1 ]; then up_cmd_list="$_2a (dkms)","$_2a (force)","$_2b (dkms)",$_2c,$_2d,$_2e
#	else up_cmd_list=$_2a,$_2b,$_2c,$_2e
#	if [ $use_dkms = 1 ]; then
#		if [ $install_type = 0 ]; then
#			up_cmd_list=("$_2e" "$_2a (dkms)" "$_2a (force)" "$_2b (dkms)" "$_2f")
#		else
#			up_cmd_list=("$_2e" "$_2a (dkms)" "$_2a (force)" "$_2b (dkms)" "$_2f" "$_2c" "$_2d")
#		fi
#		if [ $hlp_txt = 0 ]; then hlp_tip="\n$hlp_02a"
#		else hlp_tip="\n$hlp_02b\n$hlp_02e$hlp_02a\n$hlp_02c"; fi
#	else
#		if [ $install_type = 0 ]; then
#			up_cmd_list=("$_2e" "$_2a" "$_2b" "$_2f")
#		else
#			up_cmd_list=("$_2e" "$_2a" "$_2b" "$_2f" "$_2c" "$_2d")
#		fi
#		if [ $hlp_txt = 0 ]; then hlp_tip="\n$hlp_02a"
#		else hlp_tip="\n$hlp_02b\n$hlp_02e$hlp_02b\n$hlp_02c"; fi
#	fi
	if [ $hlp_txt = 0 ]; then hlp_tip="\n$hlp_02A"; fi
	if [ $install_type = 0 ]; then
		if [ $use_dkms = 1 ]; then
			up_cmd_list=("$_2e" "$_2a (dkms)" "$_2a (force)" "$_2b (dkms)" "$_2f")	
			if [ $hlp_txt = 1 ]; then hlp_tip="\n$hlp_02B\n$hlp_02a\n$hlp_02c"; fi
		else
			up_cmd_list=("$_2e" "$_2a" "$_2b" "$_2f")
			if [ $hlp_txt = 1 ]; then hlp_tip="\n$hlp_02B\n$hlp_02b\n$hlp_02c"; fi
		fi
	else
		if [ $use_dkms = 1 ]; then
			up_cmd_list=("$_2e" "$_2a (dkms)" "$_2a (force)" "$_2b (dkms)" "$_2f" "$_2c" "$_2d")
			if [ $hlp_txt = 1 ]; then hlp_tip="\n$hlp_02B\n$hlp_02a\n$hlp_02c\n$hlp_02d"; fi
		else
			up_cmd_list=("$_2e" "$_2a" "$_2b" "$_2f" "$_2c" "$_2d")
			if [ $hlp_txt = 1 ]; then hlp_tip="\n$hlp_02B\n$hlp_02b\n$hlp_02c\n$hlp_02d"; fi
		fi
	fi
	
	unset up_list
#	for up_cmd in "$_2a" "$_2b" "$_2a (dkms)" "$_2b (dkms)" "$_2c" "$_2d"; do
#	ifs=$IFS
#	IFS=$(echo -en "\n\b")
#	for up_cmd in $(echo -e "$up_cmd_list"|tr "," "\n"); do
	for up_cmd in "${up_cmd_list[@]}"; do
		up_list+=("false")
		up_list+=("$nu")
		up_list+=("$up_cmd")
		nu=$[ $nu+1 ]
	done 
#	IFS=$ifs
	menu_upd=$(zenity --width=400 $w_height --list \
	--radiolist --hide-header --title="Zenvidia" \
	--text "$rBB$_02$end$v$hlp_tip$end" \
	--column "1" --column "2" --column "3" --separator=";" --hide-column=2 \
	"${up_list[@]}" false $nu "$MM" )
	if [ $? = 1 ]; then exit 0; fi
#	case $menu_upd in
#		"1") menu_msg="$v$msg_2_01$end"; upgrade_other=0; upgrade_kernel; base_menu ;;
#		"2") menu_msg="$v$msg_2_02$end"; upgrade_other=1; upgrade_new_kernel; base_menu ;;
#		"3") menu_msg="$v$msg_2_01 (dkms)$end"; upgrade_other=0
#			 use_dkms=0; upgrade_kernel; base_menu ;;
#		"4") menu_msg="$v$msg_2_02 (dkms)$end"; upgrade_other=1
#			 use_dkms=0; upgrade_new_kernel; base_menu ;;
#		"5") menu_msg="$v$msg_2_03$end"; local_src_ctrl; base_menu ;;
#		"6") menu_msg="$v$msg_2_04$end"; ui_mod=1; check_update  ;;
#		"7") base_menu ;;
		if [ $use_dkms = 1 ]; then
			if [ $install_type = 0 ]; then
				case $menu_upd in
					"1") menu_msg="$v$msg_2_06$end"
						 ui_mod=1; check_update ;;
					"2") menu_msg="$v$msg_2_01 (dkms)$end"
						 upgrade_other=0; use_dkms=1; upgrade_kernel; base_menu ;;
					"3") menu_msg="$v$msg_2_01 (force)$end" 
						 upgrade_other=0; use_dkms=0; upgrade_kernel; base_menu ;;
					"4") menu_msg="$v$msg_2_02 (dkms)$end"
						 upgrade_other=1; use_dkms=1; upgrade_new_kernel; base_menu ;;
					"5") menu_msg="$v$msg_2_05$end"
						 zenvidia_update; base_menu ;;
					"$nu") base_menu ;;
				esac
			else
				case $menu_upd in
					"1") menu_msg="$v$msg_2_06$end"
						 ui_mod=1; check_update ;;
					"2") menu_msg="$v$msg_2_01 (dkms)$end"
						 upgrade_other=0; use_dkms=1; upgrade_kernel; base_menu ;;
					"3") menu_msg="$v$msg_2_01 (force)$end" 
						 upgrade_other=0; use_dkms=0; upgrade_kernel; base_menu ;;
					"4") menu_msg="$v$msg_2_02 (dkms)$end"
						 upgrade_other=1; use_dkms=1; upgrade_new_kernel; base_menu ;;
					"5") menu_msg="$v$msg_2_05$end"
						 zenvidia_update; base_menu ;;
					"6") menu_msg="$v$msg_2_03$end"
						 local_src_ctrl; base_menu ;;
					"7") menu_msg="$v$msg_2_04$end"
						 prime_src_ctrl; base_menu ;;
					"$nu") base_menu ;;
				esac
			fi
		else # use_dkms = 0
			if [ $install_type = 0 ];then
				case $menu_upd in
					"1") menu_msg="$v$msg_2_06$end"
						 ui_mod=1; check_update  ;;
					"2") menu_msg="$v$msg_2_01$end"
						 upgrade_other=0; upgrade_kernel; base_menu ;;
					"3") menu_msg="$v$msg_2_02$end"
						 upgrade_other=1; upgrade_new_kernel; base_menu ;;
					"4") menu_msg="$v$msg_2_05$end"
						 zenvidia_update; base_menu ;;
					"$nu") base_menu ;;
				esac
			else
				case $menu_upd in
					"1") menu_msg="$v$msg_2_06$end"
						 ui_mod=1; check_update  ;;
					"2") menu_msg="$v$msg_2_01$end"
						 upgrade_other=0; upgrade_kernel; base_menu ;;
					"3") menu_msg="$v$msg_2_02$end"
						 upgrade_other=1; upgrade_new_kernel; base_menu ;;
					"4") menu_msg="$v$msg_2_05$end"
						 zenvidia_update; base_menu ;;
					"5") menu_msg="$v$msg_2_03$end"
						 local_src_ctrl; base_menu ;;
					"6") menu_msg="$v$msg_2_04$end"
						 prime_src_ctrl; base_menu ;;
					"$nu") base_menu ;;
				esac
			fi
		fi
#	esac
}
menu_modif(){
	if [ $hlp_txt = 1 ]; then
		if [ $install_type = 0 ]; then hlp_tip="\n$hlp_03b"
		else hlp_tip="\n$hlp_03b\n$hlp_03c"; fi
		w_height='--height=750'
	else
		hlp_tip="\n$hlp_03a"
		w_height='--height=300'
	fi
	nd=1
	if [ $install_type = 0 ] ;then
		mod_menu_list=("$_3a" "$_3b" "$_3c" "$_3d" "$_3e" "$_3f" "$_3g")
	else
		mod_menu_list=("$_3a" "$_3b" "$_3c" "$_3d" "$_3e" "$_3f" "$_3g" "$_3h")
	fi
	unset mod_list
	for mod_cmd in "${mod_menu_list[@]}" ; do
		mod_list+=("false")
		mod_list+=("$nd")
		mod_list+=("$mod_cmd")
		nd=$[ $nd+1 ]
	done
	menu_mod=$(zenity --width=400 $w_height --list \
	--radiolist --hide-header --title="Zenvidia" \
	--text "$rBB$_03$end$v$hlp_tip$end" \
	--column "1" --column "2" --column "3" --separator=";" --hide-column=2 \
	"${mod_list[@]}" false $nd "$MM")
	if [ $? = 1 ]; then exit 0; fi
	if [ $install_type = 0 ]; then
		case $menu_mod in
			"1") edit_xorg_conf ;;
			"2") edit_script_conf ;;
			"3") nv_config ;;
			"4") manage_pcks ;;
			"5") optimus_source_rebuild ;;
			"6") fix_broken_install ;;
			"7") zen_notif_setup ;;
			"$nd") base_menu ;;
		esac
	else
		case $menu_mod in
			"1") edit_xorg_conf ;;
			"2") edit_script_conf ;;
			"3") nv_config ;;
			"4") manage_pcks ;;
			"5") optimus_source_rebuild ;;
			"6") fix_broken_install ;;
			"7") zen_notif_setup ;;
			"8") from_menu_install=0; prime_setup ;;
			"$nd") base_menu ;;
		esac
	fi
}
menu_manage(){
	if [ $hlp_txt = 1 ]; then
		hlp_tip="\n$hlp_04b"
		w_height='--height=500'
	else
		hlp_tip="\n$hlp_04a"
		w_height='--height=300'
	fi
	nm=1
	unset mng_list
	for mng_cmd in "$_4a" "$_4b ($version)" "$_4c ($version)" "$_4d"; do
		mng_list+=("false")
		mng_list+=("$nm")
		mng_list+=("$mng_cmd")
		nm=$[ $nm+1 ]
	done
	menu_mng=$(zenity --width=400 $w_height --list \
	--radiolist --hide-header --title="Zenvidia" \
	--text "$rBB$_04$end$v$hlp_tip$end" \
	--column "1" --column "2" --column "3" --separator=";" --hide-column=2 \
	"${mng_list[@]}" false $nm "$MM")
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
		printf "$vB$msg_00_04$end $j${dev[$e]}\t($(printf "${vnd[$e]}"|awk '{print $1}'))$end\n" $((${dev_n[$e]}+1))
	done
	)
	# remove deplist list in case of relaunching first because an update asking to
	unset deplist
	w_height=450
	[ $hlp_txt = 0 ]|| { hlp_wrn="$hlp_tip_txt"; w_height=$(($w_height+50)); }	
	menu_cmd=$(zenity --height=$w_height --title="Zenvidia" --list --radiolist --hide-header \
	--text "$rBB$msg_00_01$end
$vB\n$msg_00_02$end $j$DISTRO$end
$vB$msg_0_00$end $j$ARCH$end
$devices 
$vB$msg_0_01$end $j$version$end
$vB$msg_0_02$end $j$KERNEL$end
$vB$msg_0_03$end $j$GCC$end
$vB$msg_0_04$end $j$NV_bin_ver$end\n
$v$msg_0_05 : $end$dir_msg
$v$msg_00_06 : $end $j$cnx_msg$end
\n$v$hlp_wrn$ansWN$end" \
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
install_controls(){
	# check nvidia dir presence
	if [ -d $install_dir/NVIDIA ] ; then
		dir_msg="$j $ansOK$end"
	else		
		dir_msg="$j $ansNF\n$y$msg_00_07$end"
		zenity --width=400 --error --no-wrap --title="Zenvidia" \
		--text="$dir_msg"
	fi
	# check/change run packages permission
	nvdl_last=$(ls -1 $nvdl/|sed -n '$p')
	if [ -s $nvdl/$nvdl_last ] ; then
		for changes in $(ls -1 $nvdl ); do
			if [[ $(stat -c "%a" $nvdl/$changes) != 755 ]]; then
				chmod 755 $nvdl/$changes
			fi
		done
	fi
}
first_start_cmd(){
	### FIRST START
	unset dir_list
	dir_list=("$buildtmp" "$nvtmp" "$nvlog" "$nvupdate" "$nvdl" "$locale")
	for i_dir in "${dir_list[@]}"; do
		[ -d $i_dir ]|| mkdir -p $i_dir
	done
	dep_control
	[ -s $tool_dir/bin/nvidia-installer ]|| installer_build
	sed -i "s/first_start=1/first_start=0/" $script_conf
	# check nvidia dir is correctly created
	if [ -d $install_dir/NVIDIA ] ; then
		dir_msg="$j $ansOK$end"
	else		
		dir_msg="$j $ansNF\n$y$msg_00_07$end"
		zenity --width=400 --error --no-wrap --title="Zenvidia" \
		--text="$dir_msg"
	fi
	connection_control
	base_menu
}
start_cmd(){
	install_controls
	connection_control
	base_menu
}

### SCRIPT INTRO
#if [[ $(cat $locale/script.conf| grep "LG=$LG") == '' ]]; then
if [[ $(cat $basic_conf| grep "LG=$LG") == '' ]]; then
	echo -e "$r no language pack chosen\n EN = english\n FR = Français.$t"
	exit 0
else
	lang_define
fi

# INITIALS checks
compil_vars
libclass
	#root_id # << distro_id < distro
version_id
ID
arch
if [ $first_start = 1 ]; then
	first_start_cmd
else
	start_cmd
fi
exit 0

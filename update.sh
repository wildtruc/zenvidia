#! /bin/bash

# this script is used both by the Makefile and by zenvidia to update itself.

install_dir=/usr/local
nvdir=$install_dir/NVIDIA
color_conf=$nvdir/color.conf

[ -d $nvdir ]|| exit 0

# update script config
if [ -s $nvdir/script.conf ]; then
	script_conf=$nvdir/script.conf
	basic_conf=$nvdir/basic.conf
	color_conf=$nvdir/color.conf
else
	script_conf=./script.conf
	basic_conf=./basic.conf
	color_conf=./color.conf
fi
[ -s $script_conf ]|| exit 0
. $script_conf
. $color_conf

unset conf_list shell_list up_list
# update conf 
conf_list=("$script_conf" "$basic_conf" "$color_conf")
for conf in "${conf_list[@]}"; do
	c_old=$conf
	c_new=$(printf "$conf"|sed -n "s/^.*\///p")
	c_orig=$(stat -c "%Y" $c_old)
	c_update=$(stat -c "%Y" ./$c_new)
	if [ $c_update -ne $c_orig ]; then
		diff -u $c_old $c_new &>/tmp/nv_patch.diff
		if [[ $conf != $basic_conf ]]; then
			if [ $(cat /tmp/nv_patch.diff | grep -c "+") -gt 0 ]; then
				printf "\n$xB# Diff in $c_old:\n>>$xN Applying $c_new diff patch.\n\n"
				patch -stp0 -i /tmp/nv_patch.diff $c_old
			fi
		else
			cat /tmp/nv_patch.diff|grep "^[+\|-]\(\w\{1\}\|#\)" &>/tmp/nv_diff.tmp
			diff_list=$(cat /tmp/nv_diff.tmp|grep "^[+]\(\w\{1\}\|#\)")
			ifs=$IFS
			IFS=$(echo -en "\n\b")
			for c_list in $diff_list; do
				diff_new=$(printf "$c_list"| grep "+"| sed -n "s/+//p")
				diff_count=$(cat /tmp/nv_diff.tmp| grep -B 1 "$c_list"| grep -c "-")			
				diff_old=$(cat /tmp/nv_diff.tmp| grep -B 1 "$c_list"| grep "-"| sed -n "s/-//p")
				if [ $diff_count -eq 0 ]; then
					printf "\n$xB# Diff in $c_old:\n>>$xN $c_list.\n\n"
					printf "$diff_new\n" >> $c_old
				fi
			done
			IFS=$ifs
		fi
	fi
done

if [ $first_start = 0 ]; then
	sed -i "s/first_start=1/first_start=0/i" $nvdir/script.conf
fi
# update zenvidia shell & associates
shell_list=('zenvidia.sh' 'zen_notify.sh')
for shell in "${shell_list[@]}"; do
	d_orig=$(stat -c "%Y" $install_dir/bin/$shell)
	d_update=$(stat -c "%Y" ./$shell)
	if [ $d_update -ne $d_orig ]; then
		printf "\n$xB# New script version >>$xN Updating $shell.\n\n"
		cp -f ./$shell $install_dir/bin/
	fi
done
# update distro plugins and translations
# useless
#up_list=( 'distro' 'translations' )
#for up_dir in "${up_list[@]}"; do
#	ls_dir=$(ls -1 $up_dir )
#	for w_dif in $ls_dir; do
#		w_orig=$(stat -c "%Y" $nvdir/$up_dir/$w_dif)
#		w_update=$(stat -c "%Y" ./$up_dir/$w_dif)
#		if [ $w_update -ne $w_orig ]||[ ! -f $nvdir/$up_dir/$w_dif ]; then
#			printf "\n$xB# New $up_dir version >>$xN Updating $w_dif.\n\n"
#			cp -f ./$up_dir/$w_dif $nvdir/$up_dir/
#		fi
#	done
#done
# update misc
# update zenvidia help file
[ -s ./HELP.md ]&& cp -f ./HELP.md $nvdir/
exit 0

#! /bin/bash

# this script is used both by the Makefile and by zenvidia to update itself.

install_dir=/usr/local
nvdir=$install_dir/NVIDIA
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

unset conf_list shell_list up_list
# update conf 
conf_list=("$script_conf" "$basic_conf" "$color_conf")
for conf in "${conf_list[@]}"; do
	c_old=$conf
	c_new=$(printf "$conf"|sed -n "s/^.*\///p")
	c_orig=$(stat -c "%Y" $c_old)
	c_update=$(stat -c "%Y" ./$c_new)
	if [ $c_update -ne $c_orig ]; then
		diff $c_new $c_old | grep "<\|>" &>/tmp/nv_diff.log
		ifs=$IFS
		IFS=$(echo -en "\n\b")
		diff_list=$(cat /tmp/nv_diff.log|grep "<")
		for c_list in $diff_list; do
			diff_count=$(cat /tmp/nv_diff.log| grep -A 1 "$c_list"| grep -c ">")
			if [ $diff_count -eq 1 ]; then
				diff_old=$(cat /tmp/nv_diff.log| grep -A 1 "$c_list"| grep ">"| sed -n "s/> //p")
				diff_new=$(printf "$c_list"| grep "<"| sed -n "s/< //p")
				sed -i "s/$diff_old/$diff_new/" $c_old
			else
				if [[ $conf == $basic_conf ]]; then
					printf "\n# Diff in $c_new:\n> $c_list.\n\n"
					printf "$c_list\n"| sed -n "s/< //p" >> $c_old
				fi
			fi
		done
		IFS=$ifs
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
		cp -f ./$shell $install_dir/bin/
	fi
done
#update distro plugins and translations
up_list=( 'distro' 'translations' )
for up_dir in "${up_list[@]}"; do
	ls_dir=$(ls -1 $up_dir )
	for w_dif in $ls_dir; do
		w_orig=$(stat -c "%Y" $nvdir/$up_dir/$w_dif)
		w_update=$(stat -c "%Y" ./$up_dir/$w_dif)
		if [ $w_update -ne $w_orig ]||[ ! -f $nvdir/$up_dir/$w_dif ]; then
			cp -f ./$up_dir/$w_dif $nvdir/$up_dir/
		fi
	done
done
# update zenvidia help file
[ -s ./HELP.md ]&& cp -f ./HELP.md $nvdir/
exit 0

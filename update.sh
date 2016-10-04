#! /bin/bash

# this script is used both by the Makefile and by zenvidia to update itself.

install_dir=/usr/local
nvdir=$install_dir/NVIDIA
[ -d $nvdir ]|| exit 0

# update script config
if [ -s $nvdir/script.conf ]; then
	script_conf=$nvdir/script.conf
	basic_conf=$nvdir/basic.conf
else
	script_conf=./script.conf
	basic_conf=./basic.conf
fi
[ -s $script_conf ]|| exit 0
. $script_conf

unset conf_list shell_list up_list
# update basic and script conf 
conf_list=("$script_conf" "$basic_conf")
for conf in "${conf_list[@]}"; do
	c_old=$conf
	c_new=$(printf "$conf"|sed -n "s/^.*\///p")
	c_orig=$(stat -c "%s" $c_old)
	c_update=$(stat -c "%s" ./$c_new)
	if [ $c_update -gt $c_orig ]; then
		diff $c_new $c_old | grep "<\|>" &>/tmp/nv_diff.log
		ifs=$IFS
		IFS=$(echo -en "\n\b")
		diff_list=$(cat /tmp/nv_diff.log|grep "<")
		for c_list in $diff_list; do
			diff_count=$(cat /tmp/nv_diff.log| grep -A 1 "$c_list"| grep -c ">")
			if [ $diff_count -eq 0 ]; then
				printf "\n# Diff of $diff_count in $c_new to be updated.\n\n"
				printf "$c_list\n"| sed -n "s/< //p" >> $c_old
			fi
		done
		IFS=$ifs
		if [[ $conf == $script_conf ]]; then
			printf "# Replacing $conf by new version."
			cp -f $conf $nvdir/
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
	if [ $d_update -gt $d_orig ]; then
		cp -f ./$shell $install_dir/bin/
	fi
done
#update distro plugins and translations
up_list=( 'distro' 'translations' )
for up_dir in "${up_list[@]}"; do
	ls_dir=$(ls -1 $up_dir )
	for w_dif in $ls_dir; do
		w_orig=$(stat -c "%s" $nvdir/$up_dir/$w_dif)
		w_update=$(stat -c "%s" ./$up_dir/$w_dif)
		if [ $w_update -gt $w_orig ]||[ ! -f $nvdir/$up_dir/$w_dif ]; then
			cp -f ./$up_dir/$w_dif $nvdir/$up_dir/
		fi
	done
done
# update zenvidia help file
[ -s ./HELP.md ]&& cp -f ./HELP.md $nvdir/
exit 0

#! /bin/bash

# this script is used both by the Makefile and by zenvidia to update itself.

install_dir=/usr/local
nvdir=$install_dir/NVIDIA
[ -d $nvdir ]|| exit 0

# update script config
if [ -s $nvdir/script.conf ]; then
	script_conf=$nvdir/script.conf
else
	script_conf=./script.conf
fi
[ -s $script_conf ]|| exit 0
. $script_conf
cp -f ./script.conf $nvdir/
if [ $first_start = 0 ]; then
	sed -i "s/first_start=1/first_start=0/i" $nvdir/script.conf
fi
# update zenvidia shell & associates
shell_list=('zenvidia.sh' 'zen_notify.sh')
for shell in "${shell_list[@]}"; do
	d_orig=$(stat -c "%Y" $install_dir/$shell)
	d_update=$(stat -c "%Y" ./$shell)
	if [ $d_update -gt $d_orig ]; then
		cp -f ./$shell $install_dir/
	fi
done
#update distro plugins and translations
up_list=( 'distro' 'translations' )
for up_dir in "${up_list[@]}"; do
	ls_dir=$(ls -1 $up_dir )
	for w_dif in "$ls_dir"; do
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

#! /bin/bash

# this script is used both by the Makefile and by zenvidia to update itself.

install_prefix=/usr/local
nvdir=$install_prefix/NVIDIA
nvconf=$install_prefix/etc/zenvidia

## migrate conf files to local/etc (reserve beore code review).
#if [[ -s $nvdir/script.conf ]]; then
#	mv -f -t $nvconf $nvdir/{script,basic,color}.conf 
#fi

script_conf=$nvdir/script.conf
basic_conf=$nvdir/basic.conf
color_conf=$nvdir/color.conf
[[ -s $script_conf ]]|| exit 0
. $script_conf
. $color_conf

## create temporary files.
nv_patch=$(mktemp --tmpdir nv_patch-XXXX)
nv_diff=$(mktemp --tmpdir nv_patch-XXXX)
# update conf without remove user's changes.
conf_list=("$script_conf" "$basic_conf" "$color_conf")
for conf in "${conf_list[@]}"; do
	c_old=$conf
	c_new=$(printf "$conf"|sed -n "s/^.*\///p")
	c_orig=$(stat -c "%Y" $c_old)
	c_update=$(stat -c "%Y" ./$c_new)
	if [ $c_update -ne $c_orig ]; then
		diff -u $c_old $c_new &>$nv_patch
		if [[ $conf != $basic_conf ]]; then
			if [ $(cat $nv_patch | grep -c "+") -gt 0 ]; then
				echo -e "$xB# Diff in $c_old:\n>>$xN Applying $c_new diff patch.\n"
				patch -stp0 -i $nv_patch $c_old
			fi
		else
			cat $nv_patch|grep "^[+\|-]\(\w\{1\}\|#\)" &>$nv_diff
			diff_list=$(cat $nv_diff|grep "^[+]\(\w\{1\}\|#\)")
			ifs=$IFS
			IFS=$(echo -en "\n\b")
			for c_list in $diff_list; do
				diff_new=$(printf "$c_list"| grep "+"| sed -n "s/+//p")
				diff_count=$(cat $nv_diff| grep -B 1 "$c_list"| grep -c "-")			
				diff_old=$(cat $nv_diff| grep -B 1 "$c_list"| grep "-"| sed -n "s/-//p")
				if [ $diff_count -eq 0 ]; then
					echo -e "$xB# Diff in $c_old:\n>>$xN $c_list.\n"
					printf "$diff_new\n" >> $c_old
				fi
			done
			IFS=$ifs
		fi
	fi
done
if [ $first_start = 0 ]; then
	sed -i "s/first_start=1/first_start=0/i" $script_conf
fi
## update zenvidia help file
#[ -s ./HELP.md ]&& cp -f ./HELP.md $nvdir/
exit 0

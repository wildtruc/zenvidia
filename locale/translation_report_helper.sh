#!/bin/bash

# this script is made to help translators to manage
# report translation process in order to manage tab
# with languages.

LANG_ID=fr_FR

export TEXTDOMAIN=zenvidia
export TEXTDOMAINDIR=./${LANG_ID}/LC_MESSAGES

zen_colors(){
# 	main='#0D900D'
# 	main='#26A269'
# 	title='#FF3300'
# 	sub='#FF6800'
# 	log_msg='#4AC6F5'
# 	log_grn='#1DCC1B'
# 	log_warn='#FF6800'
# 	log_err='#FF3300'
# 	font0='Noto Sans Regular'
# 	size0='10'
# 	font1='Noto Sans Regular'
# 	size1='16'

# pango colors
end='</span>'
v='<span color="'$main'" weight="normal" font="'$size0'" font_family="'$font0'">'		#green
j='<span color="'$sub'">'		#orange
y='<span color="'$log_msg'">'		#blue
r='<span color="'$log_err'">'
# big red orange title
rBB='<span color="'$title'" weight="bold" font="20" font_family="'$font1'">'
# Big
bf='<span font="'$size1'">'
nf='<span font="'$size0'">'
mf='<span font="'$(($size0+2))'">'
sf='<span font="'$(($size0-2))'">'
# Bold
vB='<span color="'$main'" weight="bold" font="'$size0'" font_family="'$font0'">'
yB='<span color="'$log_msg'" weight="bold" font_family="'$font0'">'
jB='<span color="'$log_warn'" weight="bold" font_family="'$font0'">'
gB='<span color="'$log_grn'" weight="bold" font_family="'$font0'">'
rB='<span color="'$log_err'" weight="bold" font_family="'$font0'">'
#vB='<span color=\"#005400\" weight=\"bold\">'
ge='<span color="#68686F">'
nr='<span color="#000000">'
# ges='<span color="#68686F" font="'$size0'">'
icon_stock=/usr/local/share/pixmaps
img_zen_desktop=$icon_stock/swiss_knife.png
}
install_report_log(){
	rep_msg=$"$( cat <<-RPT
	${v}<b><big><i>Congratulations !</i></big></b>${end}
	<b>${j}$(new_version)${end} ${v}driver is now succefully installed${end}</b>.

	${v}You may now configure your ${j}xorg.conf${end} file to fit with your current default display before restarting
	your computer with the new installed drivers.
	You may also do it later if you like, but it's not really recommanded.

	What do you want to do ?${end}
	RPT
	)"
	yad --title="Zenvidia" --window-icon=$img_zen_desktop --width=500 --borders=20 --center \
	--text=$"${j}${bf}Install Report${end}${end}${v}\n\n $(cat <<< ${report_log[*]})${end}\n$rep_msg" \
	--button=$"edit later"'!zen-undo:1' --button=$"edit now"'!zen-warning:0'
}
report_test(){ # report log supp.
	unset lib_x
	lib_x=( lib64 lib32 )
	new_version='515.xx'
	bak_version='500.xx'
	old_lib_version='500.xx'
	open_drv=1
	use_open=0
	show_dkms=' (dkms)'
# 	show_dkms=' (from source)'
	KERNEL=$(uname -r)

	fixed_lib_log=({allocator,fbc,cfg,gtk2,gtk3,vulkan-producer})
	elf_x='x86_64'
	if [ ${#fixed_lib_log[*]} -gt 0 ]; then
			fixed_lib_log+=($", links updated $elf_x")
	fi
	if [ $use_open -eq 1 ]; then append=$"open driver loaded"; else append=$"close source loaded"; fi
	######
	report_log+=($"${vB}Previous version:\t\t${end}${gB} passed\t${end}> ${y}previously backed up${end}\n")
	report_log+=($"${vB}Previous version:\t\t${end}${gB} success\t${end}> ${y}$bak_version normal backup process${end}\n")
	report_log+=($"${vB}Previous version:\t\t${end}${jB} warning\t${end}> ${y}no directory to archive.${end}\n")

	report_log+=($"${vB}Driver build$show_dkms:\t\t${end}${gB} success\t${end}> ${y}Installation complete with no error${end}\n")
	report_log+=($"${vB}Driver build:\t\t\t${end}${rB} failure\t${end}> ${y}ERROR, 'make' exit with 'failed' state${end}\n")
	report_log+=($"\t\t\t\t${gB} kernel option ${end}>${y} Kernel $KERNEL is REALTIME${end}.\n")
	report_log+=($"${vB}Open Driver:\t\t\t${end}$gB compiled\t${end}>${y} $append${end}\n")

	report_log+=($"${vB}Nvidia-installer:\t\t${end}${jB} no effect\t${end}> ${y}WARNING on missing /usr/lib(32/64)/LibGL.so link,\n\t\t\t\t\t\t    LibGL.so is already link in default nvidia's libraies directory${end}.\n")
	report_log+=($"\t\t\t\t${jB} no effect\t${end}> ${y}WARNING missing libglvnd developpement files.${end}\n")

	report_log+=($"${vB}Libraries install:\t\t${end}${gB} success\t${end}> ${y}normal install process${end}.\n")
	report_log+=($"\t\t\t\t${gB} libwfb\t${end}> ${y}link to system${end}.\n")
	for line in ${fixed_lib_log[*]}; do
		report_log+=($"\t\t\t\t${gB} lib fix\t${end}> ${y}${fixed_lib_log[@]}${end}.\n")
	done
	report_log+=($"\t\t\t\t${gB} link fix\t${end}> ${y}${fixed_lib_log[@]}${end}.\n")
	report_log+=($"\t\t\t\t${gB} old version\t${end}> ${y}${old_lib_version} directory cleaned${end}.\n")
	report_log+=($"\t\t\t\t${gB} old source\t${end}> ${y}All ${old_lib_version} version cleaned${end}.\n")
	install_report_log
}
zen_colors
report_test

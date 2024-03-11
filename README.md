# Zenvidia
This is a bash/Yad(ex-zenity) script for managing **NVIDIA©** propriatary and open source drivers.

Actual version pretty name : **2.0**

---------------------------------------------------------------------------------------------------
## WARNINGS
**The Script has been tested under Fedora only. Almost all usual system sets are managed but some specifics per distro are not, users working on other distros may check distro conf manually until all this will automated.**

## Notice
Project not maintained as a project is usually maintain. No waranty support. Just as it is.
Update will be made only on my own bugs discovery or from fatal error send by users in **Discussion** threads.

Exchange are still open in this same Zenvidia's git **Discussion** section.

Wiki is out of date.

Base language is english.

---------------------------------------------------------------------------------------------------
## Important change log notes
v2.3.43 NOTES :
 - Nvidia-installer, no matter what, remove dkms used driver three in case of a libraries reinstall only, sometime in conjonction with installed kernel modules. There is too way to prevent this :
 1) Not allowed libraries reinstall.
 2) back up and restore dkms and modules.
 The first proposal is the simpliest, but there is cases where libraries reinstall could be necessary (files corruption, accidental lost, etc). at this point, it is chosen to privilege the solution 2, event if this is a bit loud. Fix will be ask to Nvidia's developper and will be hopefully heard.

v2.3.41 NOTES :
 - KDM add to drivers reload at session restart. It appears it is simply ... SDDM (yes, I didn't know).

v2.3.33 NOTES :
 - distro configuration file are removed from three.
 - If user needs to add some very specifics distro variables, system conf directory (ex. grub), he just have to edit distro.conf file as appropriate. All same for some specifics dependencies for his distro. Afterward relaunch Zenvidia to make the script install those dependencies (help comments inside config file).

v2.3.29 NOTES :
 - **WARNING** : After a tester feedback, it appears that user priviledges for local zenvidia's conf dir wasn't properly set. In cause, a script function moved too soon (distro config file future removal goal). This is fixed. User need to remove $HOME/.zenvidia directory and relaunch the script to fix.

v2.3.5 NOTES :
 - **Important fix** : Some function was unexpectdly remove and prevent to blacklist nouveau at driver fresh install. Dev's is still in cause :(.
 - This version wasn't expect so soon, but because of error, even if not fatal, upload it quickly was necessary.
 - More infos in path notes.

v2.2.7 NOTES :
 - 535.113.01 issue looks to be a simple bug and wasn't reproduced. Last warning was finally a false flag.
 - use_gzip config option has been added to base config file since driver backup container are auto select and made with XZ. Think to reconfigure your base conf file or add new conf line in the backup before restore it.(USER_HOME/.zenvidia/basic.conf~).

v2.2.4 NOTES :
 - Zenvidia can now reload drivers on session restart. This is `VERY EXPERIMANTAL` and only tested on LIGHTDM service event it could potentialy work on other display manager service.
 - **WARNING** : Be aware that 535.113.01 open-driver looks to have fatal issue when reloading this ways by loosing udev nvidia devices creation, so don't use this features with this driver open source version. So be careful, other drivers released in the future could potentially have the same issue.

v2.2.2 NOTES :
 - Huge mistakes were found and fix (nvidia-settings-rc.desktop, mainly), that prevence make install to execute properly.
 - Script has been test out of the box with a different end user dektop envirroment. There is apprently nott errors.
 - basic.conf is now a backup, please update it.

v2.2.0 NOTES :
 - Add a xorg config options GUI with options tips. There a bug in tips display coming from man page truncating text. Not clue at this point.
 - Introduce 545 serie percistenced GPU init service for open drivers and specific values for both drivers.
 - Restore backup archive can now overwrirte over itself.

v2.1.35 NOTES :
 - 'Make file update' command now make a backup of zenvidia's script and config. Same for user configs.
 - Yad last migration (except Xorg config for below reasons). Scripting is still under watch.
 - Next release will come with a extended Xorg configutor (old dream) needed for upcoming PRIME and OFFLOAD integration.

v2.1.34 NOTES :
 - URGENT FIX: Mistakes on last upoad. IFS restoration line for Yad process misplaced preventing some internal command to execute correcttly. My apologies.

v2.1.33 NOTES :
 - A Task bar notification menu with most used Zenvidia functions has been added. Hoping you'll find it usefull.

v2.1.24 NOTES :
 - Because of Zenity 3.92 (and at the moment also above) is meeting too mutch issues, it will gradually replace by Yad.
 - It looks like that nvidia-drm.modeset grub option set to 1 could fix tearing. This accordingly to **[this article](https://daanberg.net/en/kennisbank/linux-nvidia-tearing-fix/)** combine with v_sync enable in nvidia-setting fix that issue. Drm modeset config has been modify to override all default set if basic conf drm_modset=1 is set. Please, check it.
 - Accordingly, because some applications meet issues with antialliasing (like steam, cairo-dock, etc) and desktop session with v_sync, it is needed to set FSAA (antialliasing) and sync to vblank (yes) in nvidia-settings.
 - It appears that nvidia-settings rc file was not load at session start. 535.104 looks like fixing this issue, but by security we add a autostart desktop file to load the file whatever the situation. If you don't want this or if it creates issue, remove it from HOME/.config/autostart directory.

v2.1.15 NOTES :
 - BUG: Zenity continue to do weird thing, it appears it wont display long text in 'text-info' option and close some nvidia help chapters unexpectedly. No clue.

v2.1.11 NOTES :
 - The new version of zenity (v3.92.0) bring display issues that gtk theme look to not support. window's height and width have been updated to reflect previous and new version. User will probably need to modify fonts colors.
 - Because this is a fast fix, it may be possible that not all height and width have been updated.

v2.0.15 NOTES :
 - Drivers serie from and below 390 have some issue on loading because dev is not created. working in progress.
 - xterm compilation window has be moved to Yad log window.

v2.0.14 NOTES :
 - Add warning and auto drivers setting for Optimus in case of multi and non Nvidia devices detection. Default Basic conf has been change accordingly and zenvidia local config need to be update.

 **Remind you that a Optimus manager is required for prime, offload, etc.**

 To change local zenvidia config manually, add the lines below in `.zenvida/basic.conf` :
 ```
# Optimus modules preset setting : (1) or not (0)
opti_preset=0
# don't display Optimus modules setting messsage: (1) or not (0)
no_opti_warn=0
 ```

v2.0.12 NOTES :
 - When installing driver for old devices not supported by actual driver serie, in case of Optimus/Prime nothing is managed to warn or prepare for this type of device system; so be aware that it could break your xorg config if you install drivers for Optimus/Prime. Diging for a soft solution (my old laptop would be delighted).
 - It look like that the default font used in Zenvidia is not install by default in all distro (Google-Noto-Sans) and because of this, zenity doesn't display correctly tab and so on. Further research is need to fix this.

v2.0.9 zen_notif hopefully fixed with others anoying things (from 2023-01-18 Issue).

v2.0.8 introduced the option `exec_mod_tool` in basic config allowing when set to `0` to use initramfs tool for all install/upgrade/update processes. Set to `1`, only install/upgrade use it, other use modprobe relaod method. Default is :
```
# Use modules reload instead of initramfs tool (exec_mod_tool) : (1) or not (0)
exec_mod_tool=1
```


v2.0.5 unset DKMS `autoinstall all` to allow only the loaded driver (open or closed source) to be compile at kernel upgrade boot time. If you have some extra drivers to be also compiled at kernel upgrade, add in driver's DKMS config file `AUTOINSTALL=yes` (do not add AUTOINSTALL=no, it doesn't work and breaks dkms conf).


v2.0.5 FIX : Driver version 525.78.01 give error at nvidia-drm driver load with nvidia.drm-modeset=1 that starting plymouth splash screen. Option `drm_modset` has been introduced in basic config file to set/unset nvidia.drm-modeset in grub command line and could be manualy modified (.zenvidia/basic.conf). Default is :
```
# Activate plymouth splash screen (nvidia-drm.modeset) : (1) or not (0)
drm_modset=0
```

---------------------------------------------------------------------------------------------------
## Known issues
Driver version 525.78.01 give error at nvidia-drm driver load with nvidia.drm-modeset=1 (fix in v2.0.5).

---------------------------------------------------------------------------------------------------
## Main Features
 - Driver Install.
 - Driver or Modules update.
 - Configuration and Tools.
 - Help and Documentation.

## Sub Features by menu
### Driver install
 - from local package.
 - from a dowloaded package.
 - from NVIDIA server.

### Updates
 - driver updates check and install.
 - Modules update.
 - New kernel update.

### Configuration & Tools
 - Open driver switch tool (available when open_drv set to 1)
 - Prime display tool (available when detected)
 - Edit xorg configuration file.
 - Edit Zenvidia configuration file.
 - Edit font color config file.
 - Start Nvidia-Settings for default user.
 - Edit specifics distribution options and environment
 - Installed driver mangagement (remove, backups, restore).
 - Zenvidia notification config.

### Help & Documentation
No administrator priviledge required.
 - Nvidia driver manuel : Installed version driver manual with graphic chaptered index.
 - Nvidia driver Changelog : Installed version and general driver changelog with graphic chaptered index.
 - Zenvidia Changlog.
 - Zenvidia help text : Simple Zenvidia help text file display.
 - Zenvidia About text : About Zenvidia text file display.

---------------------------------------------------------------------------------------------------
## Configuration
Most part of Zenvidia is configurable.

Script automaticaly update many of them during execution or in game of Q&A.
Options could be manage through **Zenvidia** > **Configuration and Tools** menu.

---------------------------------------------------------------------------------------------------
## Install
### Zenvidia
This will install in default behaviour.

Choose a directory to clone repo and :

As normal user :
```sh
  git clone https://github.com/wildtruc/zenvidia.git
  cd zenvidia/
```
As superuser :
```sh
  # then :
  # to install to default :
  make install
  # to remove all :
  make uninstall
  # to remove safely (doesn't remove downloaded driver packages)
  make safeuninstall
  # to update (this including git update command) :
  make update
```
Then :
Through terminal command line for GUI.
```sh
	zen_start # (with administrator priviledge)
	zenvidia  # (with no priviledge)
```
or with desktop file from end user inface menu > settings > others menu.
```sh
	zenvidia (admin) # (with administrator priviledge)
	zenvidia (user)  # (with no priviledge)
```
Or by the desktop menu entry in Setting menu.
The GUI will ask you for admin/superuser password.

### Zen Notify
Zenvidia notify is taskbar notifier checking at user session boot time for driver updates.
It is installed at the same time as Zenvidia when launching `make install` command.

It comes with 2 options:
 - -z > check zenvidia script and nvidia drivers.
 - -n > check nvidia drivers only.

Default desktop entry file is set to ```-n```, you can manage options through **main menu > Configuration and Tools menu**.

---------------------------------------------------------------------------------------------------
## Usage
Most of the main functions are available from the desktop task bar menu entries. There not needs to use commande line or desktop manu entries.

### GUI
With **end user interface menu > system settings > others menu** (it could differ by distribution).

### Command line
Command line tool is only for rescue services, and need to be launch with Desktop manager disable. Desktop manager have to be shutdown with `systemcl disable [desktop-manager]` command (it doesn't really care in case of real rescue, DM is crashed anyway).

```zenvidia [command] [version]```

command are : _restore, rebuild, rescue, reinit_.

version is the desired driver version _(displayed with zenvidia command alone with X server off)_.

Note : the Grub starting menu option `nvidia-drm.modeset=1` activate the plymouth splash screen and some older distribution or Nvidia versions prevent switching to TTY console with Ctrl+Alt+F(x).
If set, it is mandatory to change this option to `0` and have a good access to TTY. In case of a real crash, it doesn't really care, but be aware that you will get acces to **one** TTY only.

---------------------------------------------------------------------------------------------------
## History
I started Zenvidia several years ago in a background of non existent Nvidia drivers managed by distros. I builded it with a light knowledge of bash code I was learning on the scratch and with the only goal of my own use.
I finally brought it to the community, with all my knowledge gaps, and maintained it for a couples of years until my health prevent me to go on.
I throw the sponge, hoping someone somewhere one day will continue or make a new one.

Despite my personal condition I went by time back in the code to add, change some little things because I was still using it, and despite the fact that my distro was delivering Nvidia drivers, Zenvidia was still more flexible.

Then, the 515 drivers series went out with the open source drivers. Yeah, it was cool, but as always Nvidia's old school linux drivers developpers put brut terminal only tools (I still love you guys! :yum: ), event not a possibility to test and switch back.
And as always, I decided to put that in Zenvidia.
Going back to Zenvidia bash code after a so long suspend was not a peace of cake and take me several months to understand the clean way to make a fast switch and even wash the code of all the useless things.

This finally done. Even if tested in almost all weirdest way ( I do very strange things some time) and there is still some [issues](#Known Issues) and I still doing stupid mistakes.
The code is not maintain in the classic way, just because of me, I just hope people will enjoy using it, because I don't think there's any equals in the whole linux community.

The script is think as Swiss knife.

---------------------------------------------------------------------------------------------------
## Licence
Zenvidia is published under GNU/GPL
-----------------------------------
Copyleft PirateProd - Licence GPL v.3

This program is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation; either version 2.1 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License along with main.c; if not, write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor Boston, MA 02110-1301,  USA

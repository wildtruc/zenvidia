# Zenvidia
This is a bash/zenity script for managing **NVIDIA©** propriatary and open source drivers.

Actual version pretty name : **2.0**

---------------------------------------------------------------------------------------------------
## WARNINGS
No Bumblebee/Prime support, see **[nvidia-prime-select](https://github.com/wildtruc/nvidia-prime-select)** for this. If it's not out of date.

**The Distro Configuration file has been testeed under Fedora only. Users working with other distros have to check distro conf manually.**

**This version brought many changes. Saved your confs, if any, and make a fresh install**.
Default install directory has been changed to /usr/local/zenvidia.

## Notice
Project not maintained. No waranty support. Just as it is.
Update will be made only on my own bugs discovery or from fatal error send by users in **Discussion** threads.

Exchange are still open in this ssame Zenvidia's git **Discussion** section.

Wiki is out of date.

Language is English only.

---------------------------------------------------------------------------------------------------
## Important change log notes
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

Script doesn't provide Nvidia driver uninstall process. May be later, after a long long rest.

I once meet a dkms issue on dkms install that didn't install ... nothing. State "unknown". It was hopfully fixed in v2.0.5.
If you meet this, quick solution is to use **Update driver only (dkms)** in **Update drivers and modules**.

Other method is to restart the PC and use in console TTY mode the rescue command line `zenvida rebuild [driver version]` after disabled in grub starting menu the value `nvidia-drm.modeset=1` to `0`.

See Changelog.txt for other changes and discovered issues.

---------------------------------------------------------------------------------------------------
## Features
### Driver install
 - from local package.
 - from a dowloaded package.
 - from NVIDIA server.

### Updates
 - driver updates check.
 - New kernel update (with dkms).

### Configuration & Tools
 - Open driver switch tool (available when open_drv set to 1)
 - Edit xorg.conf file.
 - Edit Zenvidia config file.
 - Edit font color config file.
 - Start Nvidia-Settings for default user.
 - Installed driver mangagement (remove, backups).
 - Zenvidia notification config.

### Help & Documentation
No administrator priviledge required.
 - Nvidia driver manuel : Installed version driver manual with graphic chaptered index.
 - Nvidia driver Changelog : Installed version and general driver changelog with graphic chaptered index.
 - Zenvidia help text : Simple Zenvidia help text file display.
 - Zenvidia About text : About Zenvidia text file display.

---------------------------------------------------------------------------------------------------
## Configuration
Most part of Zenvidia is configurable.

Script automaticaly update many of them during execution and game of Q&A.
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
  # to update :
  make update
```
And :
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
### GUI
In terminal :
 - ```zen_start``` (with administrator priviledge)
 - ```zenvidia``` (with no priviledge)

From desktop :

With **end user interface menu > settings > others menu**.

### Command line
Desktop manager have to be shutdown with `systemcl disable [desktop-manager]` command (it doesn't really care in case of real rescue, DM is crashed anyway).

Note : the Grub starting menu option `nvidia-drm.modeset=1` activate the plymouth splash screen and prevent switching to TTY console with Ctrl+Alt+F(x). If set, it is mandatory to change this option to `0` and have a good access to TTY. In case of a real crash, it doesn't really care, but be aware that you will get acces to **one** TTY only.

```zenvidia [command] [version]```

command are : _restore, rebuild, rescue, reinit_.

version is the desired driver version _(displayed with zenvidia command alone with X server off)_.

---------------------------------------------------------------------------------------------------
## History
I started Zenvidia several years ago in a background of non existent Nvidia drivers managed by distros. I builded it with a light knowledge of bash code I was learning on the scratch and with the only goal of my own use.
I finally brought it to the community, with all my knowledge gaps, and maintained it for a couples of years until my health prevent me to go on.
I throw the sponge, hoping someone somewhere one day will continue or make a new one.

Despite my personal condition I went by time back in the code to add, change some little things because I was still using it, and despite the fact that my distro was delivering Nvidia drivers, Zenvidia was still more flexible.

Then, the 515 drivers series went out with the open source drivers. Yeah, it was cool, but as always Nvidia's old school linux drivers developpers put brut terminal only tools (I still love you guys! :yum: ), event not a possibility to test and switch back.
And as always, I decided to put that in Zenvidia.
Going back to Zenvidia bash code after a so long suspend was not a peace of cake and take me at least 2 month to understand the clean way to make a fast switch and even wash the code of all the useless things.

Now it's done and tested in almost all weirdest way ( I do very strange things some time) and there is still some [issues](#Known Issues).
The code wont be maintain, just because of me, I just hope people will enjoy using it, because I don't think there's any equals in the whole linux community.

Note that the script even if it does less than before is doing more.

---------------------------------------------------------------------------------------------------
## Licence
Zenvidia is published under GNU/GPL
-----------------------------------
Copyleft PirateProd - Licence GPL v.3

This program is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation; either version 2.1 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License along with main.c; if not, write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor Boston, MA 02110-1301,  USA

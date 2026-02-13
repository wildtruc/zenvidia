# Zenvidia
This is a bash/Yad(ex-zenity) script for managing **NVIDIA©** proprietary and open source drivers.

Actual version pretty name : **2.0**

---------------------------------------------------------------------------------------------------
## Notice
Project not maintained as a project is usually maintain. No waranty support. Just as it is.
Update will be made only on my own bugs discovery or from fatal error send by users.

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
As **superuser** or with **sudo** in prefix :
```sh
  # then :
  # to install to default :
  INSTALL.sh install
  # to remove all :
  INSTALL.sh uninstall
  # to remove safely (doesn't remove downloaded driver packages)
  INSTALL.sh safeuninstall
  # to update (this including git update command) :
  INSTALL.sh update
```
Then restart the Destop manager to get the **task bar menu**.
Or : (outside restart)
Through terminal command line.
```sh
	zen_notify -n # (no priviledge required) Will start the notifier that will start the tray task menu.
	zen_start # (with polkit administrator priviledge) Will start zenvidia only.
```
### Zen Notify
Zenvidia notify is taskbar notifier checking at user session boot time for driver updates.
It is installed at the same time as Zenvidia.

It comes with 2 options:
 - -z > check zenvidia script and nvidia drivers.
 - -n > check nvidia drivers only.

Default desktop entry file is set to ```-n```, you can manage options through **main menu > Configuration and Tools menu**.

---------------------------------------------------------------------------------------------------
## Usage
Most of the main functions are available from the desktop task bar menu entries. There not needs to use commande line or desktop menu entries.

### From menu entry
With **end user interface menu > system settings > others menu** (it could differ by distribution) or task bar menu.

### Command line
Command line tool is only for rescue purposes, and need to be launch with Desktop manager disable. Desktop manager have to be shutdown with `systemcl disable [desktop-manager]` command (it doesn't really care in case of real rescue, DM is crashed anyway).

```zenvidia [command] [version]```

command are : _restore, rebuild, rescue, reinit_.

**version** is the desired driver version _(displayed with zenvidia command alone with X server off)_.

Note : the Grub starting menu option `nvidia-drm.modeset=1` activate the plymouth splash screen on some older distribution or Nvidia versions prevent switching to TTY console with Ctrl+Alt+F(x).
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

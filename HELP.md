## Usage
---------------------------------------------------------------------------------------------------
### GUI
Terminal command line for GUI.
```zen_start``` (with administrator priviledge)
```zenvidia``` (with no priviledge)
or with desktop file from end user inface menu > settings > others menu.
```zenvidia (admin)```(with administrator priviledge)
```zenvidia (user)```(with no priviledge)

### Command line
In case of a functional Xorg server, desktop manager have to be disabled in supersuer terminal with ```systemcl disable [desktop-manager]```, then ```systemcl stop [desktop-manager]``` commands.
Note : If nvidia-drm module option is set to 1 (use_drm=1), changing the Frame Buffer loading `nvidia-drm.modeset=1` to `0`
in grub boot commandline menu (press **e** to edit, then **Ctrl+x** or **F10** to launch).
Without this, you wont access the VT by Ctrl+Alt+F1 or F2.

```zenvidia [command] [version]```
**command** are :
 - **restore** : Restore a previously backed up \[version\].
 - **rebuild** : Rebuild \[version\] driver from DKMS tree.
 - **rescue** : Force \[version\] driver compilation from source for fast recovery.

**version** :
This is the driver version to manage
Backed up and installed versions are displayed with blank ```zenvidia``` command line alone.

---------------------------------------------------------------------------------------------------
## Features
### Driver install
 - **From local package**
   Direct installation from any local place.
 - **from NVIDIA server**
   Download directly and isntall.

### Updates
 - **driver updates check and install**
 (download/install).
 - **Update driver only (dkms)**
 Update driver for current kernel with dkms (default behaviour).
 - **Update driver only (force)**
 Update driver for current kernel using source dir only (forcing).
 - **Update driver for an other kernel**
 Update driver for an other kernel with DKMS.

### Configuration & Tools
**Open driver switch tool**
Allow to switch from open driver to proprietary and reversly. Administrator priviledge required.
It appears in menu list exclusibely if _open_drv_ var is set in Zenvidia config file.

**Edit xorg.conf file**
Allow to edit the system Xorg config file in 2 ways: Administrator priviledge required
 - The whole config in text mode.
 - Nvidia's config section option only in graphic mode.

**Edit Zenvidia config file**
Allow to edit Zenvidia general config file in graphic mode. No administrator priviledge required.
All Zenvida options are settable in differenbt ways, this is the place you can find open driver sets for example.
 - hold xterm display instead of delay.
 Default is none. (xt_hold=0)
 - extend the delay of xterm display went not hold (in seconds).
 Default 4 secondes. (xt_delay=4)
 - help tip: display in GUI help tips.
 Default, displayed. (hlp_txt=1)
 - force use of GL libraries direct or indirect: Default, none.
 To set exclusibely in certain circonstancies. (use_indirect=0)
 - force use of libglvnd: Default use.
 To unset exclusibely in certain circonstancies. (use_glvnd=1)
 - link wayland lib to system: This is only in test or in case Nvidia did not detect ayland during install.
 Default none. (wayland_link=0)
 - display first time modules build messsage: This is for first time sets of uvm and drm optionals modules.
 Default is display. (no_warn=0)
 - display first time alert open modules build messsage: This is for first time sets of open driver management.
 Defautl is display. (first_open=1)
 - use Optimus PRIME sync (nvidia-uvm) by default: This is fir laptop discret card management
 Default is none. (use_uvm=0)
 - use CUDA module (nvidia-drm) by default: This is for Direct Rendering Management.
 Default is none, but since 515 version series, default is use. (use_drm=1)
 - prevent GCC compilator version mismatch: In rare case, Nvidia-installer have GCC version mismatch.
 To set only in this particular condition. Default is none. (gcc_mismatch=0)
 - display open modules build messsage: At each installation/update, Zenvidia display an open modules building warning.
 You can't unset this behaviour here. (first_open=1)
 - compile open nvidia drivers: Setted to yes, compile only the open driver, but not use it.
 Default is none. (open_drv=0)
 - use open nvidia drivers: If set to "use", when previous var is set to "build", open driver is uses in place of proprietary.
 (use_open=0)

**Edit font color config file** (Gui with Yad).
Allow to edit Zenvidia font colors in 2 ways. No administrator priviledge required :
 - In full text (you need to know color code by your self)
 - With a graphic UI with Yad. Yad is automacaly install at first start with administrator priviledge.

**Start Nvidia-Settings**
Start Nvidia-settings with default user priviledges, the same as default user menu does. No administrator priviledge required.

**Installed driver management**
Packages manager.  Administrator priviledge required.
 - Remove useless dowloaded packages.
 - Perform a whole backup of the driver installation that could be immedialty restore either by the next Zenvidia menu line or by command line. Allow to manage backups also.
 - Restore backed up archives.

**Zenvidia notify config**
Zenvidia notify is taskbar notifier checking at user session boot time for driver updates. No administrator priviledge required
It comes with 2 options:
 - -z > check zenvidia script and nvidia drivers.
 - -n > check nvidia drivers only.

### Help & Documentation
No administrator priviledge required.

 - **Nvidia driver manuel** Installed version driver manual with graphic chaptered index.
 - **Nvidia driver Changelog** Installed version and general driver changelog with graphic chaptered index.
 - **Zenvidia help text** Simple Zenvidia help text file display.
 - **Zenvidia about** Simple Zenvidia about text file from README display.

---------------------------------------------------------------------------------------------------
## Licence
Zenvidia is published under GNU/GPL
-----------------------------------

Copyleft PirateProd - Licence GPL v.3

This program is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation; either version 2.1 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License along with main.c; if not, write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor Boston, MA 02110-1301,  USA



# Zenvidia
This is a bash/zenity script for managing **NVIDIA©** propriatary drivers.

## IMPORTANT NOTICE FOR V1.0
New major update before v1.0.
 - Upgraded to 390.xx new installer options.
 - **.sh** suffixes are removed.
 - Polkit Auth instead of su/sudo.
 - To update do ```sudo make install``` (see **News** below).
 - You will be automaticaly notified for next update. 

## History log
I'm not a "real" coder, my script syntax is often approximative and need a real improvement. So, all kind of help is welcome.

All of the originals developpement tests were made on a discret graphic card for **optimus** and **Bumblebee**. further experience on single GPU was recent and with **[FedoraPrime](https://github.com/bosim/FedoraPrime)** project and after with the fork I made for my very customized purpose, **[nvidia-prime-select](https://github.com/wildtruc/nvidia-prime-select)**. I have still now a laptop for Prime/Optimus tests, but my default desktop is with a single GPU card.

## Issues
Nvidia-installer refuse to execute because of nvidia-drm module loaded, the automatic script work-arround does the job.

After a long time of hard developpement, it seem to be stable. If you meet issues, just tell.

See **Wiki** for **Issues**, **Todo list** and **demands**.

------------
## News

*FIX UPDATE*: quick fix base on new nvidia-installer options that prevent 390.xx to be installed.
 - Some function could be broken like optimus git repos updates. Fixes are on going, but could take some time. Previuosly, basic git repos was hard linked to to the script, now it will detect in user path where are thoses repos for update, etc. All test are not done and there still many work to do.
 - Downloading old driver is currently broken.
 - Backup could meet some issues (didn't find the bug yet)
 - Prime is quickly adapt to new **[nvidia-prime-select](https://github.com/wildtruc/nvidia-prime-select)** major changes.
 - Bumblebee and others are redefined. You can meet issues because I have no more Bumblebleed install.
 - Authentification is now base on polkit.

I'm' thinking to a complete revision and rewrite, but not sure for now because of personnal issues.

Sorry for the inconvinience.

### Note:
It is better for these update to perform a 'make install', so, backup you basic.conf, script.conf, color.conf before (all are in /usr/local/NVIDIA).

------------

## Usage

### Driver install
  
 - from local package.
 - from a dowloaded package.
 - from NVIDIA© server.
 - Optimus installation from GIT (bumblebee and prime).
 
### Updates

 - driver updates check.
 - New kernel update (with dkms or not).
 - Optimus GIT sources update.

### Tools

 - Edit xorg.conf file (optimus auto detection).
 - Édit Zenvidia config file.
 - Start Nvidia-Settings (optimus auto detection).
 - Installed driver mangagement (remove, backups).
 - Re-compile some depencies (Bumblebee, etc).

### Tests and support

 - Test GLX.
 - Changelog and driver manual.

## Install
### Zenvidia
This will install in default behaviour with no possible custom ability.

Choose a directory to clone repo and :
```sh
  git clone https://github.com/wildtruc/zenvidia.git
  cd zenvidia/
  # then :
  # to install to default :
  make install
  # to remove all :
  make uninstall
  # to remove safely (doesn't remove downloaded driver packages)
  make safeuninstall
```
And :
```sh
  zenvidia.sh
```
Or by the desktop menu entry in Setting menu.

The script will ask you for admin/superuser password, depend fo which distro you are using.

### Zen Notify
Zenvidia notify is taskbar notifier checking at user session boot time for driver & other GIT repos updates.
It comes with 3 options:
 - -a > check all.
 - -z > check zenvidia script and nvidia drivers.
 - -n > check nvidia drivers only.

Default desktop entry file is set to ```-a```, you can manage options through Zenvidia > Tools.

The script is installed at the same time as Zenvidia when launching ```make install``` command.

### Zen Notify Standalone
(need to be rewrite)

Same as Zen Notify but working driver update check only.

Download from main repo 'zen_notify_standalone.sh', 'swiss_knife.png' image, autostart desktop file from the ```/desktop_files``` directory. Then to install, just do in a terminal in root/sudo mode:
```sh
	cp -f zen_notify_standalone.sh /usr/local/bin/
	cp -f swiss_knife.png /usr/local/pixmaps/
	cp -f zen_notify_standalone.desktop /home/(your user)/.config/autostart 
```

That's it.

## Configuration
Most part of the basic.conf file vars will be updated during the script execution.

You just have to adjust manually :
 - language setting (FR, EN, DE, IT, ES, etc.).
 - default user name: you can leave it at default, but you may change it to your defautl user if you find some issue with user name in your distro behaviour.
 - CUDA setting
 - DKMS setting
 - set Help Tips to 1 or 0, as you like.
 - xterm delay is the time terminal window will stay open.

```
# default desktop user id
def_user=$USER
# locale language for ui
LG=EN
# right/left cairo_dock reserved space, if any (ex: dock='-28')
# this is for centering xterm window correctly.
dock=''

## Basic config vars
# use CUDA module by default (1) or not (0)
cuda=1
# use dkms script by default (1) or not (0)
use_dkms=1
# force use of direct (0) or indirect (1) GL libs
use_indirect=0
# force use of libglvnd (1) or not (0)
use_glvnd=0
# driver install type:  optimus (1), single GPU (0) 
install_type=0
# optimus install type: prime (0), bumblebee (1) 
use_bumblebee=0
# to hold xterm instead of delay: delay (0), hold (1)
xt_hold=0
# extend the delay of xterm (in seconds): default '4'
xt_delay=4
# use help tip: yes (1), no (0)
hlp_txt=1
```

---------

## Licence

Zenvidia is published under GNU/GPL
-----------------------------------

Copyleft PirateProd - Licence GPL v.3

This program is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation; either version 2.1 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License along with main.c; if not, write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor Boston, MA 02110-1301,  USA



# Zenvidia
This is a bash/zenity script for managing **NVIDIA©** propriatary drivers.


## Issues
**v1.0.6**
Nvidia-installer refuse to execute because of nvidia-drm module loaded, this is a nvidia development issues. The only solution is to work-arround and the script does the job. As a result, zenvidia no longer uses nvidia-installer to install the drivers themselves.

DKMS refuses to install the drivers and can even report errors even if there are none and the drivers are compiled anyway. I don't know if this issue is exclusive to my desktop.

------------
## News
Bumblebee and prime support is still suspended. At the very most, it won't work, at the very least, it will crash your desktop. So, please, don't. ^^ (will be fixe in a near futrure, but it need deeper code review and it's beyond my present condition right now.)

For Prime in specific, you can always use zenvidia for an install on single hardware, then use **[nvidia-prime-select](https://github.com/wildtruc/nvidia-prime-select)** tool to config Prime. I can't tell if Ubuntu tools could be used to configure Prime afterward, the distro is problably using proper nvidia driver ubuntu's non-free repos for this and is not adapted to zenvidia particular sets. **[Nvidia-prime-select](https://github.com/wildtruc/nvidia-prime-select)** does. 

## Notice
I have severe heals issue and I don't really know if I could still manage my project alive. I will try to continue to fix bugs and Nvidia options updates, but i can't tell about the future. It's strongly recommanded to fork.

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



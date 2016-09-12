# Zenvidia
This is a bash/zenity script for managing **NVIDIA©** propriatary drivers.

##History log
I'm not a "real" coder, my script syntax is often approximative and need a real improvement. So, all kind of help is welcome.

All of the developpement test was made on a discret graphic card for **optimus** and **Bumblebee**. My only experience on single GPU is recent and only with **[FedoraPrime](https://github.com/bosim/FedoraPrime)** project and now with the fork I made for my very customized purpose, **[nvidia-prime-select](https://github.com/wildtruc/nvidia-prime-select)**.

Since I add recently Prime to zenvidia, I was expecting some X server crash, but nothing appened. The only issue I had, Nvidia-installer refused to execute because of nvidia-drm module loaded, it was finally installed by the automatics scripts work-arrounds.

This is a hard developpement, do not expect too much for now.

For now and because needed install.sh update, follows **#Install** section.

See **Wiki** for **Issues**, **Todo list** and **demands**.

------------

##Usage

###Driver install
  
 - from local package.
 - from a dowloaded package.
 - from NVIDIA© server.
 - Optimus installation from GIT (bumblebee and prime).
 
###Updates

 - driver updates check.
 - New kernel update (with dkms or not).
 - Optimus GIT sources update.

###Tools

 - Edit xorg.conf file (optimus auto detection).
 - Édit Zenvidia config file.
 - Start Nvidia-Settings (optimus auto detection).
 - Installed driver mangagement (remove, backups).
 - Re-compile some depencies (Bumblebee, etc).

###Tests and support

 - Test GLX.
 - Changelog and driver manual.

##Install
This will isntall in default behaviour with no possible custom place.

Choose a directory to repo and :
```sh
  git clone https://github.com/wildtruc/zenvidia.git
  cd zenvidia/
# then :
# to install to default :
make install
# to remove all :
make uninstall
# to remove safely (doesn't remove dowloaded driver packages)
make safeuninstall
```
And :
```sh
  zenvidia.sh
```

---------

##Licence

Zenvidia is published under GNU/GPL
-----------------------------------

Copyleft PirateProd - Licence GPL v.3

This program is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation; either version 2.1 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License along with main.c; if not, write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor Boston, MA 02110-1301,  USA



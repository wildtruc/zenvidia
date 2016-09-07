# Zenvidia
This is a bash/zenity script for managing **NVIDIA©** propriatary drivers.

History log
------------
I'm not a "real" coder, my script syntax is often approximative and need a real improvement. So, all kind of help is welcome.

All of the developpement test was made on a discret graphic card for **optimus** and **Bumblebee**. My only experience on single GPU is recent and only with **Fedora-Prime** project and now with the fork I made for my very customized purpose, **nvidia-prime-select**.

Since I add recently Prime to zenvidia, I was expecting some X server crash, but nothing appened. The only issue I had, Nvidia-installer refused to execute because of nvidia-drm module loaded, it was finally installed by the automatics scripts turn-arrounds.

This is a hard developpement, do not expect too much for now.

------------
Issues
============
 - Can't use nvidia-installer to install the driver and nvidia-installer send ERROR messsage. The script use its work-arround to solve that issue.
 - Because of the driver and libs custom install dirs nvidia-installer send WARNINGS when installing libs. Don't take care of it.
 - Don't use install.sh for now, it need an deep update before.
 - OpenCL file in /etc is not update correctly, will be fix soon.

TODO
=========
 - Write per distro plugin, they are inside the code for the moment, not a very good way.
 - Write color scheme outside the code, better way to customized gui colors.
 - Clean the code of old and now useless functions.
 - get user commments (hoping!)
 - rewrite install.sh or write a Makefile.
 - Add others languages packs (but need translators!).
 - learn english (sic)
 - taking some time to drink a beer with friends some day...
 

Usage
==============
Driver install
------------------------
  
 - from local package.
 - from a dowloaded package.
 - from NVIDIA© server.
 - Optimus installation from GIT (bumblebee and prime).

Updates
------------

 - driver updates check.
 - New kernel update (with dkms or not).
 - Optimus GIT sources update.

Tools
------

 - Edit xorg.conf file (optimus auto detection).
 - Édit Zenvidia config file.
 - Start Nvidia-Settings (optimus auto detection).
 - Installed driver mangagement (remove, backups).
 - Re-compile some depencies (Bumblebee, etc).

Tests and support
----------------

 - Test GLX.
 - Changelog and driver manual.
 
-------
Licence
=======
Zenvidia and Bashvidia are published under GNU/GPL
--------------------------------------------------

Copyleft PirateProd - Licence GPL v.3

This program is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation; either version 2.1 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License along with main.c; if not, write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor Boston, MA 02110-1301,  USA



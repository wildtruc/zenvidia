# Zenvidia
This is a bash/zenity script for managing **NVIDIA©** propriatary drivers.
Actual version pretty name : **2.0**

---------------------------------------------------------------------------------------------------
## ATTENTION ** 12/19/2022 **
**NEW 2.0 VERSION ON RAIL, DO NOT DOWNLOAD UNTIL THIS MESSAGE WILL BE REOMOVE.**
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
## WARNINGS
No Bumblebee/Prime support, see **[nvidia-prime-select](https://github.com/wildtruc/nvidia-prime-select)** for this. If it's not out of date.

**The Distro Configuration file has been testeed under Fedora only. Users working with other distros have to check distro conf manually.**

**This version brought many changes. Saved your confs, if any, and make a fresh isntall**. Default install directory has been changed to /usr/local/zenvidia.

## Notice
Project not maintained. No waranty support. Just as it is.
Dicussion is still open in Zenvidia's git **Discussion** section.
Wiki is out of date.
Language is English only.

---------------------------------------------------------------------------------------------------
## History
I started Zenvidia several years ago in a background of non existent Nvidia drivers managed by distros. I builded it with a light knowledge of bash code I was learning on the scratch and with the only goal of my own use.
I finally brought it to the community, with all my knowledge gaps, and maintained it for a couples of years until my health prevent me to go on.
I throw the sponge, hoping someone somewhere one day will continue or make a new one.

Despite my personal condition I went by time back in the code to add, change some little things because I was still using it, and despite the fact that my distro was delivering Nvidia drivers, Zenvidia was still more flexible and cool.

Then, the 515 drivers series went out with the open source drivers. Yeah, it was cool, but as always Nvidia's old school linux drivers developpers put brut terminal only tools, event not a posibility to test and switch back.
And as always, I decided to put that in Zenvidia.
Going back to Zenvidia bash code after a so long suspend was not a peace of cake and take me at least 2 month to understand the clean way to make a fast switch and even wash the code of all the useless things.

Now it's done and tested in almost all weirdest way ( I do very strange things some time).
The code wont be maintain, just because of me, I just hope people will enjoy using it, because I don't think there's any equals in the whole linux community.

Note that the script even if it does less than before is doing more.

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
It is installed at the same time as Zenvidia when launching ```make install``` command.
It comes with 2 options:
 - -z > check zenvidia script and nvidia drivers.
 - -n > check nvidia drivers only.

Default desktop entry file is set to ```-n```, you can manage options through **main menu > Configuration and Tools menu**.

---------------------------------------------------------------------------------------------------
## Usage
### GUI
In terminal :
```zen_start``` (with administrator priviledge)
```zenvidia``` (with no priviledge)
From desktop :
From **end user interface menu > settings > others menu**.

### Command line
Desktop manager have to be shutdown with ```systemcl disable [desktop-manager]``` command.
```zenvidia [command] [version]```
command are : _restore, rebuild, rescue_.
version is the desired driver version _(displayed with zenvidia command alone with X server off)_.
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
 - Edit xorg.conf file.
 - Edit Zenvidia config file.
 - Start Nvidia-Settings.
 - Installed driver mangagement (remove, backups).

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
Options could be manage through Zenvidia > Configuration and Tools menu.

---------------------------------------------------------------------------------------------------
## Licence
Zenvidia is published under GNU/GPL
-----------------------------------
Copyleft PirateProd - Licence GPL v.3

This program is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation; either version 2.1 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License along with main.c; if not, write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor Boston, MA 02110-1301,  USA

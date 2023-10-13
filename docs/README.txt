oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
 <b>## ZENVIDIA ##</b>
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
This is a bash/zenity script for managing NVIDIA© propriatary drivers.
Actual version pretty name : 2.0

oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
 <b># History</b>
<s>++++++++++++++++++++++++++++++++++++++++++++++++++++++++++</s>
I started Zenvidia several years ago in a background of non existent Nvidia drivers managed by distros.
I builded it with a light knowledge of bash code I was learning on the scratch and with the only goal
of my own use.
I finally brought it to the community, with all my knowledge gaps, and maintained it for a couples of years
until my health prevent me to go on.
I throw the sponge, hoping someone somewhere one day will continue or make a new one.

Despite my personal condition I went by time back in the code to add, change some little things because
I was still using it, and despite the fact that my distro was delivering Nvidia drivers,
Zenvidia was still more flexible and cool.

Then, the 515 drivers series went out with the open source drivers. Yeah, it was cool, but as always
Nvidia's old school linux drivers developpers put brut terminal only tools, event not a possibility to test
and switch back.
And as always, I decided to put that in Zenvidia.
Going back to Zenvidia bash code after a so long suspend was not a peace of cake and take me at least 2
month to understand the clean way to make a fast switch and even wash the code of all the useless things.

Now it's done and tested in almost all weirdest way (<i>I do very strange things some time</i>).
The code wont be maintain, just because of me, I just hope people will enjoy using it, because I don't think
there's any equals in the whole linux community.

Note that the script even if it does less than before is doing more.

oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
 <b># Features</b>
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
 <b>Driver install</b>
<s>++++++++++++++++++++++++++++++++++++++++++++++++++++++++++</s>
	- from local package.
	- from a dowloaded package.
	- from NVIDIA server.

 <b>Updates</b>
<s>++++++++++++++++++++++++++++++++++++++++++++++++++++++++++</s>
	- driver updates check.
	- New kernel update (with dkms).

 <b>Configuration & Tools</b>
<s>++++++++++++++++++++++++++++++++++++++++++++++++++++++++++</s>
	- Edit xorg.conf file.
	- Edit Zenvidia config file.
	- Start Nvidia-Settings.
	- Installed driver mangagement (remove, backups).

 <b>Help & Documentation</b>
<s>++++++++++++++++++++++++++++++++++++++++++++++++++++++++++</s>
	No administrator priviledge required.
	- Nvidia driver manuel
	  Installed version driver manual with graphic chaptered index.
	- Nvidia driver Changelog
	  Installed version and general driver changelog with graphic chaptered index.
	- Zenvidia help text
	  Simple Zenvidia help text file display.
	- Zenvidia About text
	  About Zenvidia text file display.

oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
 <b>Configuration</b>
<s>++++++++++++++++++++++++++++++++++++++++++++++++++++++++++</s>
Most part of Zenvidia is configurable.
Script automaticaly update many of them during execution and game of Q&A.
Options could be manage through Zenvidia > Configuration and Tools menu.

oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
 <b># Install</b>
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
 <b>Zenvidia</b>
<s>++++++++++++++++++++++++++++++++++++++++++++++++++++++++++</s>
This will install in default behaviour.
Choose a directory to clone repo and :
user terminal window :
	<i>git clone https://github.com/wildtruc/zenvidia.git</i>
	<i>cd zenvidia/</i>
then :
superuser terminal window :
	# to install to default :
	  <i>make install</i>
	# to remove all :
	  <i>make uninstall</i>
	# to remove safely (doesn't remove downloaded driver packages)
	  <i>make safeuninstall</i>
	# to update :
	  <i>make update</i>
And :
	<b>zen_start</b> (in a superuser terminal window)
Or by the desktop menu entry in Setting menu.
The GUI will ask you for admin/superuser password.

oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
 <b>Zen Notify</b>
<s>++++++++++++++++++++++++++++++++++++++++++++++++++++++++++</s>
Zenvidia notify is taskbar notifier checking at user session boot time for driver updates.
It is installed at the same time as Zenvidia when launching <b>make install</b> command.
It comes with 2 options:
	- <b>-z</b>  >  <i>check zenvidia script and nvidia drivers.</i>
	- <b>-n</b>  >  <i>check nvidia drivers only.</i>

Default desktop entry file is set to <b>-n</b>, you can manage options through <b>main menu</b> >
<b>Configuration and Tools</b> menu.

oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
 <b># Usage</b>
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
 <b>GUI</b>
<s>++++++++++++++++++++++++++++++++++++++++++++++++++++++++++</s>
From terminal :
	<b>zen_start</b> (termninal command with administrator priviledge)
	<b>zenvidia</b> (termianl command with no priviledge)
From end user interface menu > settings > others menu.

 <b>Command line</b>
<s>++++++++++++++++++++++++++++++++++++++++++++++++++++++++++</s>
Desktop manager have to be shutdown with systemcl disable <b>desktop-manager</b> command.
	<b>zenvidia [command] [version]</b>
command are : _restore, rebuild, rescue_.
version is the desired driver version <i>(displayed with zenvidia command alone with X server off)</i>.

oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
 <b># Licence</b>
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
 Zenvidia is published under GNU/GPL
<s>++++++++++++++++++++++++++++++++++++++++++++++++++++++++++</s>
Copyleft PirateProd - Licence GPL v.3

This program is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser
General Public License as published by the Free Software Foundation; either version 2.1 of the License,
or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even
the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General
Public License for more details.

You should have received a copy of the GNU Lesser General Public License along with main.c; if not, write
to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor Boston, MA 02110-1301,  USA

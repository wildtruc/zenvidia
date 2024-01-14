
 A. Creation from scratch (not using the translation.pot in the git repos) :

* Move to the zenvidia locale dir :
	cd locale/

* Create the gettex dump file from the bash executable or file :
	bash --dump-po-strings ../zenvidia > trans.pot

* Add the header at the top of the file :
msgid ""
msgstr ""
"Project-Id-Version: zenvidia-translation\n"
"POT-Creation-Date: 2023-12-02\n"
"PO-Revision-Date: 2023-12-02\n"
"Last-Translator: [translator or team] <translator@mail>\n"
"Language-Team: [language]>\n"
"Language: [system language ID]>\n"
"MIME-Version: 1.0\n"
"Content-Type: text/plain; charset=UTF-8\n"
"Content-Transfer-Encoding: 8bit\n"
#:

 B. Creation from the git repos translation.pot (above steps skipped) :

* Get your language ID :
	echo $LANG of echo $LC_MESSAGES (depends of your distro settings).

* Edit "Language: xxx>\n" and "Content-Type: text/plain; charset=xxx>\n" lines with the envirronement variable you got.
Example for fr_FR :
msgid ""
msgstr ""
"Project-Id-Version: zenvidia-translation\n"
"POT-Creation-Date: 2023-12-02 12:25+0200\n"
"PO-Revision-Date: 2023-12-03 12:25+0200\n"
"Last-Translator: @PirateProd <mymail@noneltd.net>\n"
"Language-Team: French>\n"
"Language: fr>\n"
"MIME-Version: 1.0\n"
"Content-Type: text/plain; charset=UTF-8\n"
"Content-Transfer-Encoding: 8bit\n"

* This base file done, make a PO copy named with your language ID.
	cp -f trans.pot [your lang ID].po

* Open the PO file in a editor and edit headers as appropriate, then make your translation.

* This step done, create the final MO file like the exemple below :
	msgfmt -vc -o fr_FR/LC_MESSAGES/zenvidia.mo fr_FR.po

* msgfmt will display duplicates line. Open the POT file in a editor and clean them.

 C . Submit your work to git repos :

Go to https://github.com/wildtruc/zenvidia/pulls

Send a "New pull request" with you file attach (you need a github account).
You can also send it through the Issue or the Discussion tabs.

Done

 D . Annexe - report log helper

"translation_report_helper.sh" is a bash script to help translators to manage tabs in end of install Reports Log windows.
It need to be launch inside the "locale" git local repos or from a copy the "locale" folder.

* Edit your LANG_ID setting in the top of the file.

* Launch the script to see the result of your reeport log translation until everyting is fine.
   bash ./translation_report_helper.sh

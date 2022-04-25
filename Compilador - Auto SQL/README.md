Compile AHK
===========

v0.9.2

Authors: denick, ladiko, flashkid, ruespe, darklight_tr, mercury233


Info
----

Compile AHK is a GUI based script that assists with compiling AutoHotkey scripts.

OS Support: Windows XP, Windows Vista, Windows 7

Tested On: Windows XP, Windows 7

Known Issues
------------

- This version of Compile AHK is intended for use with AutoHotkey_L v1.1.01.00 and higher.  For AutoHotkey Basic or AutoHotkey_L v1.1.00.01 and lower use Compile AHK v0.9.0.50/58.
- Icon files contained in very long directory paths will generate errors when they are selected.  This issue is under investigation.

Please report any issues you encounter here: https://github.com/imaginationac/compile-ahk/issues

License
-------

Originally declared just "open source", any new contributions will be considered public domain. If your jurisdiction does not recognize the concept of public domain, use the MIT License (see LICENSE for details).

Changelog
----------

### v0.9.2 (04/19/16)

####  Compile AHK Changes:

- Compiled with AutoHotkey_L v1.1.23.5.
- Added zh-cn translation.
- Added back UPX support, remove mpress.
- Updated ResHacker to 4.x.
- Changed language.ini to UTF-8.
- Removed icon 6 and 7 since they don't exist in AutoHotkeySC.bin any more.
- Fixed line feeding when saving ini in script.
- Fixed tooltip.

#### Setup Changes:

- Added back UPX, remove mpress.
- GoRC updated to v1.0.1.0.
- ResourceHacker updated to v4.2.5.146.


### v0.9.1.3 (11/18/13)

####  Compile AHK Changes:

- Renew "Created" date and Save settings in script checkboxes no longer overlap.  (Thanks to Drako for the report)
- Added Windows 8.x support.

#### Setup Changes:

- Added Windows 8.x support.


### v0.9.1.2 (10/20/13)

#### Compile AHK Changes:

- Compiled with AutoHotkey_L v1.1.13.01.

#### Setup Changes:

- Compiled with AutoHotkey_L v1.1.13.01.
- GoRC updated to v1.0.0.0.


### v0.9.1.1 (04/23/13) - Internal Release

#### Compile AHK Changes:

- Compiled with AutoHotkey_L v1.1.09.04.
- Fixed an issue where Compile AHK wouldn't start in newer versions of AutoHotkey_L.

#### Setup Changes:

- Compiled with AutoHotkey_L v1.1.09.04.
- MPRESS updated to v2.19.
- Fixed several issues where Setup would pick the incorrect path to the AutoHotkey folder on x64 systems.
- The Setup button now disables upon activation.


### v0.9.1 (10/01/11)

#### Compile AHK Changes:

- Removed password protection option as it is no longer supported by AutoHotkey_L v1.1.01.00 and higher.
- Removed NoDecompile option as it is not supported by AutoHotkey_L.
- Fixed an issue where the Compile AHK version in the title window would not display correctly.
- Set the default language in the language.ini file to en-us. (Previous default was de-de)
- Fixed a tab naming error in the language.ini file. (Resourcess is now Resources)
- Removed password protection and NoDecompile entries from the language.ini file.
- Compiled with AutoHotkey_L v1.1.03.00.
- Edited credits.

#### Setup Changes:

- Changed "essential component" text to "Required"
- Fixed GoRC URL. (Bad link)
- Corrected copyright information.
- Executable versions included in the setup are now shown on the initial GUI.
- GoRC updated to v0.90.5.
- ResHacker updated to v3.6.0.
- Added mpress.exe v2.18 to the setup.
- Added MPRESS copyright information and URL.
- Adjusted the spacing in the initial GUI.
- Added /nompress command line switch.
- Added mpress.exe checkbox to the selection GUI.

How to build
------------

### Depedencies

The following need to be downloaded & installed.

- [AutoHotkey](https://autohotkey.com/download/)
- [GoRC](http://www.godevtool.com/) - Freeware Resouce compiler
- [Resource Hacker](http://www.angusj.com/resourcehacker/) - Freeware Resource editor
- [UPX](http://upx.sourceforge.net/) - Freeware executable packer


1. Copy GoRC.exe, ResourceHacker.exe, and upx.exe into the project root directory.
2. Compile Compile_AHK.ahk with Compile_AHK.ahk.
3. Compile Compile_AHK_Setup.ahk with Compile_AHK.ahk.
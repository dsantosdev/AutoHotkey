if inc_res_hack
	Return
Global inc_res_hack = 1

Class Res_Hack {

	_Set_Version( File_Version, description="", internal_name="", copyrights="", scriptname="" )	{
		Global
		Local	s_CMD
			,	s_File_Version
			,	s_Product_Version
			,	s_Sc_File
			,	s_Script
	
		RegExReplace( File_Version, "\.",, pontos )
		IF( pontos = 2 )
			File_Version := "0." File_Version
	
		if( scriptname = "" )
			scriptname := SubStr( A_ScriptName, 1, -4 )
	
		AHK_VERSION	:=	A_AhkVersion

		FileDelete, C:\Users\dsantos\AppData\Local\Temp\AutoHotkey\Compiler\VersionInfo.res
		FileDelete, C:\Users\dsantos\AppData\Local\Temp\AutoHotkey\Compiler\VersionInfo.rc
		StringReplace,	s_File_Version,		File_Version ,	.,	`,, All
		StringReplace,	s_Product_Version,	AHK_VERSION,	.,	`,, All	;	ahk?
		
		FileAppend, 
		(
		1 VERSIONINFO
		FILEVERSION %s_File_Version%
		PRODUCTVERSION %s_Product_Version%
		FILEOS 0x4
		FILETYPE 0x1
		{
		BLOCK "StringFileInfo"
		{
				BLOCK "040904b0"
				{
					VALUE "CompanyName",		"Heimdall"
					VALUE "FileDescription",	"%description%"
					VALUE "FileVersion",		"%File_Version%"
					VALUE "InternalName",		"%internal_name%"
					VALUE "LegalCopyright",		"%copyrights%"
					VALUE "OriginalFilename",	"%ScriptName%"
					VALUE "ProductName",		"AutoHotkey"
					VALUE "ProductVersion",		"%AHK_VERSION%"
				}
		}
		BLOCK "VarFileInfo"
		{
			VALUE "Translation" , 0x0409 0x04B0
		}
		}
		), C:\Users\dsantos\AppData\Local\Temp\AutoHotkey\Compiler\VersionInfo.rc

		s_CMD := """C:\Users\dsantos\Desktop\AutoHotkey\Compilador - Auto SQL\GoRC.exe"""
				. " /r "
				. """C:\Users\dsantos\AppData\Local\Temp\AutoHotkey\Compiler\VersionInfo.rc"""
				. " >> "
				. """C:\Users\dsantos\AppData\Local\Temp\AutoHotkey\Compiler\GoRC.log"""
		RunWait, %ComSpec% /c "%s_CMD%" , , UseErrorLevel Hide

		s_Sc_File := "C:\Users\dsantos\AppData\Local\Temp\AutoHotkey\Compiler\ChangeVersionInfo.script"
		s_Script	:= "[FILENAMES]`n"
					. "Exe=C:\Users\dsantos\AppData\Local\Temp\AutoHotkey\Compiler\AutoHotkeySC.bin`n"
					. "SaveAs=C:\Users\dsantos\AppData\Local\Temp\AutoHotkey\Compiler\AutoHotkeySC.bin`n"
					. "Log=C:\Users\dsantos\AppData\Local\Temp\AutoHotkey\Compiler\ResHacker.log`n"
					. "[COMMANDS]`n"
		s_Script	:= s_Script . "-delete Versioninfo , 1 , 1033`n"
		s_Script	:= s_Script . "-addoverwrite ""C:\Users\dsantos\AppData\Local\Temp\AutoHotkey\Compiler\VersionInfo.res"" , Versioninfo , 1 , `n"
		FileDelete, %s_Sc_File%
		FileAppend, %s_Script% , %s_Sc_File%
		s_CMD2	:= """C:\Users\dsantos\Desktop\AutoHotkey\Compilador - Auto SQL\ResourceHacker.exe"""
				. " -script "
				. """" . s_Sc_File . """"

		RunWait,%	s_CMD2,, UseErrorLevel Hide

		FileSetTime,,C:\Users\dsantos\AppData\Local\Temp\AutoHotkey\Compiler\AutoHotkeySC.bin, M	;Is not set automatically
		FileDelete, C:\Users\dsantos\AppData\Local\Temp\AutoHotkey\Compiler\VersionInfo.res
		FileDelete, C:\Users\dsantos\AppData\Local\Temp\AutoHotkey\Compiler\ChangeVersionInfo.script
		FileDelete, C:\Users\dsantos\AppData\Local\Temp\AutoHotkey\Compiler\GoRC.log
		FileDelete, C:\Users\dsantos\AppData\Local\Temp\AutoHotkey\Compiler\ResHacker.log
		FileDelete, C:\Users\dsantos\AppData\Local\Temp\AutoHotkey\Compiler\VersionInfo.rc
		Return
	}

}
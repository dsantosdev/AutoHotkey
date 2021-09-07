/*
 * * * Compile_AHK SETTINGS BEGIN * * *

[AHK2EXE]
Exe_File=C:\Users\dsantos\Desktop\Executáveis\teste call.exe
Run_After=C:\Users\dsantos\Desktop\Executáveis\EXE2DB.exe
Created_Date=1
[VERSION]
Set_Version_Info=1
Company_Name=Heimdall
File_Version=1.2.3.4
Inc_File_Version=1
Product_Version=1.1.33.2
Set_AHK_Version=1

* * * Compile_AHK SETTINGS END * * *
*/


#SingleInstance, Force
SendMode Input
File_Obs = teste de observação multiline com tab
SetWorkingDir, %A_ScriptDir%
MsgBox
exitapp
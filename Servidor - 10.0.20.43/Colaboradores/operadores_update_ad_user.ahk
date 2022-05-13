File_Version=0.1.0
Save_To_Sql=1
;@Ahk2Exe-SetMainIcon C:\AHK\icones\pc.ico

;	Includes
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\alarm.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\array.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\auth.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\base64.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\cameras.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\convert.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\cor.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\date.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\dguard.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\file.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\folder.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\functions.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\gui.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\listview.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\mail.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\safe_data.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\sql.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\string.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\sync_data.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\telegram.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\timer.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\windows.ahk
;

/*	Bancos de Dados utilizados
	[ASM].[dbo].[_agentes_de_monitoramento]	-	Write
	[ASM].[dbo].[_colaboradores]			-	Read
*/

;	Configurações
	#NoTrayIcon
	if !A_Args[1]
		ExitApp
	nome	:=	A_Args[1]
	
	if A_IsCompiled
		ext	=	exe
	Else
		ext = ahk

;

;	Code
	for o in ComObjGet("winmgmts:").ExecQuery("Select status,Name From Win32_UserAccount WHERE FullName = '" nome "'" )
	{
		o_user	:=	o.Name
		o_ok	:=	o.status= "Ok"
							? "True"
							: "False"
		user_ad_i_or_u =
			(
				IF EXISTS(	SELECT		a.*
							FROM		[ASM].[dbo].[_agentes_de_monitoramento] a
							LEFT JOIN	[ASM].[dbo].[_colaboradores] b
							ON			a.[matricula] = b.[matricula]
							WHERE		b.[nome] = '%nome%' )
					UPDATE [ASM].[dbo].[_agentes_de_monitoramento]
						SET
							[login_ad]	= '%o_user%'
					FROM		[ASM].[dbo].[_agentes_de_monitoramento] a
					LEFT JOIN	[ASM].[dbo].[_colaboradores] b
					ON			a.[matricula] = b.[matricula]
					WHERE
						b.[nome] = '%nome%'
				ELSE
					INSERT INTO [ASM].[dbo].[_agentes_de_monitoramento]
						([matricula]
						,[login_ad]
						,[acesso_admin]	)
					VALUES
						((SELECT [matricula] FROM [ASM].[dbo].[_colaboradores] WHERE [Nome] = '%nome%' )
						,'%o_user%'
						,'0'	)
			)
			sql( user_ad_i_or_u, 3 )
			if	Sql_le
			{
				body	:=	"Erro ao atualizar o usuário do ad do colaborador: " nome "`nSISTEMA: " A_ScriptName "`nSQL Error:`n`n" SQL_LE "`nSQL Query:`n`n" SQL_LQ
				mail.new( "dsantos@cotrijal.com.br", "Erro Software", body )
				ExitApp
			}
	}
	ExitApp
;

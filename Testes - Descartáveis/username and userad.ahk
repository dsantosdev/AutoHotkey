	usuario = Dieisson silva dos santos
	ad := ComObjGet("winmgmts:").ExecQuery("Select * From Win32_UserAccount WHERE fullname = 'DIEISSON SILVA DOS SANTOS'" )
		MsgBox % 	ad.Count()
		; MsgBox % 	ad[1].Name



	; for o in ComObjGet("winmgmts:").ExecQuery("Select * From Win32_UserAccount where Name = '" userad "'" )
	; {
	; 	MsgBox %	"`n"
	; 			.	"`nNome Completo :`t"		o.FullName
	; 			.	"`nUsuário :`t`t"			o.Name
	; 			.	"`nEstado :`t`t"			o.status
	; }
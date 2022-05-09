if	inc_cameras
	Return

Global inc_cameras = 1
	;	Precisa o módulo functions
Class Cameras	{
	Mac( ip, model )	{
		;	Retorna o mac da câmera solicitada
		login	=	admin:tq8hSKWzy5A@
		URL := SubStr( model, 1, InStr( model, " " )-1 )	=	"Foscam"
															?	"http://" ip ":88/cgi-bin/CGIProxy.fcgi?cmd=getDevInfo&usr=admin&pwd=tq8hSKWzy5A"
			:	SubStr( model, 1, InStr( model, " " )-1 )	=	"Dahua"
															?	"http://" login ip "/cgi-bin/magicBox.cgi?action=getSerialNo"
			:	SubStr( model, 1, InStr( model, " " )-1 )	=	"Intelbras"
															?	"http://" login ip "/cgi-bin/magicBox.cgi?action=getSerialNo"
			:	SubStr( model, 1, InStr( model, " " )-1 )	=	"Samsung"
															?	"http://" login ip "/cgi-bin/about.cgi?msubmenu=about&action=view2"
			:	SubStr( model, 1, InStr( model, " " )-1 )	=	"hanwha"
															?	"http://" login ip "/stw-cgi/system.cgi?msubmenu=deviceinfo&action=view"
			:	SubStr( model, 1, InStr( model, " " )-1 )	=	"Sony"
															?	""
			:	SubStr( model, 1, InStr( model, " " )-1 )	=	"Hikvision"
															?	""
			:	""
		If	!URL
			Return "NULL"
		value	:=	http( URL,, 1 )

		if InStr( model, "Intelbras" ) || InStr( model, "Dahua" )
			Return StrRep( value,, "sn=", "`n", "`r", " " )
		Else if InStr( model, "Foscam" ) {
			Foscam := StrSplit( value, "`n" )
			Loop,%	Foscam.Count()
				if InStr( Foscam[A_Index], "<mac>" )
					Return StrRep( Foscam[A_Index],, "<mac>", "</mac>", "`n", "`r", " " )
		}
		Else if InStr( model, "Samsung" ) { 
			samsung := StrSplit( value, "`n" )
			Loop,%	samsung.Count()
				if InStr( samsung[A_Index], "Serial:" )
					Return StrRep( samsung[A_Index],"|", "Serial:", "`n", "`r", " " )
		}
		Else if InStr( model, "hanwha" )	{
			hanwha := StrSplit( value, "`n" )
			Loop,%	hanwha.Count()
				if InStr( hanwha[A_Index], "SerialNumber=" )
					Return StrRep( hanwha[A_Index],, "SerialNumber=", "`n", "`r", " " )
		}
		Else Return ""
	}

}
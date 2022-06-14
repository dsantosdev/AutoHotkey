File_Version=0.0.0
Save_To_Sql=0
;@Ahk2Exe-SetMainIcon C:\AHK\icones\pc.ico
#SingleInstance, Force
;	Includes
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\alarm.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\array.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\auth.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\base64.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\cameras.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\convert.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\cor.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\date.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\dguard.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\file.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\folder.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\functions.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\gui.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\listview.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\mail.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\safe_data.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\sql.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\string.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\sync_data.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\telegram.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\timer.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\windows.ahk
;

/*	Bancos de Dados utilizados

*/

;	Code
	MsgBox, , , NÃO EXECUTE SEM TER CERTEZA, UTILIZA DADOS DO BANCO DE DADOS PARA MIGRAÇÃO DOS NOMES E NÃO ATUALIZAÇÃO
	Return
	s	=
		(
			SELECT DISTINCT
				 c.[name]
				,c.[guid]
				,CASE
					WHEN	c.[id] IN ( '255' )			THEN 'NMT'
					WHEN	c.[id] IN ( '253' )			THEN 'EXP'
					WHEN	c.[id] IN ( '249' )			THEN 'NMT'
					WHEN	c.[id] IN ( '247' )			THEN 'NMT'
					WHEN	c.[id] IN ( '246' )			THEN 'VIV'
					WHEN	c.[id] IN ( '245','27' )	THEN 'PFU'
					WHEN	c.[id] IN ( '244' )			THEN 'TRR'
					WHEN	c.[id] IN ( '100' )			THEN 'NMT'
					WHEN	c.[id] IN ( '52' )
						AND	c.[name] LIKE 'SD | `%'		THEN 'NMT'
					WHEN c.[id] IN ( '46' )				THEN 'LAV'
					ELSE u.[sigla]
				END AS sigla
				,c.[server]
				,c.[ip]
			FROM
				[Dguard].[dbo].[cameras] c
			LEFT JOIN
				[Cotrijal].[dbo].[unidades] u
			ON
				CASE
					WHEN c.[id] IN ( '254','248' )	THEN '60'
					WHEN c.[id] IN ( '251' )		THEN '16'
					WHEN c.[id] IN ( '250' )		THEN '6'
					WHEN c.[id] IN ( '243' )		THEN '59'
					WHEN c.[id] IN ( '238' )		THEN '88'
					ELSE c.[id]
				END = u.[entreposto]
			--WHERE c.[server] = 1
			ORDER BY
				--c.[server], c.[name]
				3
		)
		cam_sql := sql( s, 3 )
	Loop, 4
		token_%A_Index% := Dguard.Token( "vdm0" A_index )
	Loop,%	cam_sql.Count()-1	{
		local	:= sigla := setor := new_name := ip := ""
		name	:= cam_sql[A_Index+1, 1],	guid := cam_sql[A_Index+1, 2],	sigla := cam_sql[A_Index+1, 3], server := cam_sql[A_Index+1, 4], ip := cam_sql[A_Index+1, 5]
		Gosub	parse_name
		OutputDebug, % "-" TRIM( new_name ) "-"
		comando := "PUT ""http://192.9.100.18" server ":8081/api/servers/%7B" guid "%7D"" -H ""accept: application/json"" -H ""Authorization: bearer " token_%server% """ -H ""Content-Type: application/json"" -d ""{ \""name\"": \""" unicode( TRIM( new_name ) ) "\""}"""
		retorno	:= Json( Dguard.Curly( comando ) )
		u =
			(
				UPDATE
					[Dguard].[dbo].[cameras]
				SET
					[name] = '%new_name%'
				WHERE
					[guid] = '%guid%'
			)
			sql( u, 3 )
	}
	; Clipboard := atualizar
	; Clipboard := saida
	; Clipboard := ao
	ExitApp
;

parse_name:
	nome :=	StrSplit( name, " | ")
	If	nome[1] = "UBS" {
		setor 	= [ UBS ]
		local	:=	nome[2]
		new_name:=	StrRep( sigla " " setor " " local,, "  : " )
		new_name:=	StrRep( new_name,, "  : " )
		new_name:=	StrRep( new_name,, "  : " )
		Return
	}
	If	nome[1] = "EXPO" {
		setor 	= [ EXP ]
		local	:=	nome[2]
		new_name:=	StrRep( sigla " " setor " " local,, "  : " )
		new_name:=	StrRep( new_name,, "  : " )
		new_name:=	StrRep( new_name,, "  : " )
		Return
	}

	If	nome[1] = "TRR" {
		setor 	= [ TRR ]
		local	:=	nome[2]
		new_name:=	StrRep( sigla " " setor " " local,, "  : " )
		new_name:=	StrRep( new_name,, "  : " )
		new_name:=	StrRep( new_name,, "  : " )
		Return
	}

	;	Balança
		If	InStr( nome[2], "Balança" ) || InStr( nome[2], "B." ) {
			setor	:=	"[ BAL ]"
			IF	InStr( nome[2], "B." )
			||	InStr( nome[2], " " ) {
				If	RegExMatch( nome[2], "\d" ) {
					num		:=	SubStr( nome[2], RegExMatch( nome[2], "\d" ), 2 )
					num_end	:=	StrRep( num,, " ", "0" )
				}
				Else
					num_end	=
				IF	InStr( nome[2], "balança" )
					local	:=	"Plataforma " num_end
				Else
					local	:=	StrReplace( StrReplace( StrReplace( nome[2], " " num ), num " " ), "B." ) " " num_end
			}
			Else
				local	=	Plataforma
		}
	;	Administrativo
		If	InStr( nome[2], "Administrativo" ) || InStr( nome[2], "A." ) {
			setor	:=	"[ ADM ]"
			IF	InStr( nome[2], "A." )
			||	InStr( nome[2], " " ) {
				If	RegExMatch( nome[2], "\d" ) {
					num		:=	SubStr( nome[2], RegExMatch( nome[2], "\d" ), 2 )
					num_end	:=	StrRep( num,, " ", "0" )
				}
				Else
					num_end	=
				local	:=	StrReplace( StrReplace( StrReplace( nome[2], " " num ), num " " ), "A." ) " " num_end
			}
			Else
				local	=	Escritório
		}
	;	Defensivos
		If	InStr( nome[2], "Defensivos" ) || InStr( nome[2], "D." ) {
			setor	:=	"[ DEF ]"
			IF	InStr( nome[2], "D." )
			||	InStr( nome[2], " " ) {
				If	RegExMatch( nome[2], "\d" ) {
					num		:=	SubStr( nome[2], RegExMatch( nome[2], "\d" ), 2 )
					num_end	:=	StrRep( num,, " ", "0" )
				}
				Else
					num_end	=
				If	InStr( nome[2], "CD" )
					setor	:=	"[ CDD ]"
				local	:=	StrReplace( StrReplace( StrReplace( StrReplace( nome[2], " " num ), num " " ), "D." ), "CD" ) " " num_end
			}
			Else
				local	=	Interna
		}
	;	Fertilizantes
		If	InStr( nome[2], "Fertilizantes" ) || InStr( nome[2], "F." ) {
			setor	:=	"[ FER ]"
			IF	InStr( nome[2], "F." )
			||	InStr( nome[2], " " ) {
				If	RegExMatch( nome[2], "\d" ) {
					num		:=	SubStr( nome[2], RegExMatch( nome[2], "\d" ), 2 )
					num_end	:=	StrRep( num,, " ", "0" )
				}
				Else
					num_end	=
				local	:=	StrReplace( StrReplace( StrReplace( nome[2], " " num ), num " " ), "F." ) " " num_end
			}
			Else
				local	=	Interna
		}
	;	Loja
		If	InStr( nome[2], "Loja" ) || InStr( nome[2], "L." ) {
			setor	:=	"[ LOJ ]"
			IF	InStr( nome[2], "L." )
			||	InStr( nome[2], " " ) {
				If	RegExMatch( nome[2], "\d" ) {
					num		:=	SubStr( nome[2], RegExMatch( nome[2], "\d" ), 2 )
					num_end	:=	StrRep( num,, " ", "0" )
				}
				Else
					num_end	=
				If	InStr( nome[2], "CD" )
					setor	:=	"[ CDL ]"
				local	:=	StrReplace( StrReplace( StrReplace( StrReplace( nome[2], " " num ), num " " ), "L." ), "CD" ) " " num_end
			}
			Else
				local	=	Interna
		}
	;	Mercado
		If	InStr( nome[2], "mercado" ) || InStr( nome[2], "M." ) {
			setor	:=	"[ SUP ]"
			IF	InStr( nome[2], "M." )
			||	InStr( nome[2], " " ) {
				num_end	=
				If	InStr( nome[2], "CD" )
					setor	:=	"[ CDS ]"
				local	:=	StrReplace( StrReplace( StrReplace( StrReplace( nome[2], " " num ), num " " ), "M." ), "CD" ) " " num_end
			}
			Else
				local	=	Interna
		}
	;	AFC
		If	InStr( nome[2], "AFC" ) {
			setor	:=	"[ AFC ]"
			If	RegExMatch( nome[2], "\d" ) {
				num		:=	SubStr( nome[2], RegExMatch( nome[2], "\d" ), 2 )
				num_end	:=	StrRep( num,, " ", "0" )
			}
			Else
				num_end	=
			local	:=	StrReplace( StrReplace( StrReplace( nome[2], " " num ), num " " ), "AFC" ) " " num_end
		}
	;	Transporte
		If	InStr( nome[2], "Transporte" ) || InStr( nome[2], "T." ) {
			setor	:=	"[ TRA ]"
			IF	InStr( nome[2], "T." )
			||	InStr( nome[2], " " ) {
				If	RegExMatch( nome[2], "\d" ) {
					num		:=	SubStr( nome[2], RegExMatch( nome[2], "\d" ), 2 )
					num_end	:=	StrRep( num,, " ", "0" )
				}
				Else
					num_end	=
				local	:=	StrReplace( StrReplace( StrReplace( nome[2], " " num ), num " " ), "T." ) " " num_end
			}
			Else
				local	=	Interna
		}
	;	Atacado
		If	InStr( nome[2], "At." ) {
			setor	:=	"[ ATA ]"
			IF	InStr( nome[2], "At." )
			||	InStr( nome[2], " " ) {
				If	RegExMatch( nome[2], "\d" ) {
					num		:=	SubStr( nome[2], RegExMatch( nome[2], "\d" ), 2 )
					num_end	:=	StrRep( num,, " ", "0" )
				}
				Else
					num_end	=
				local	:=	StrReplace( StrReplace( StrReplace( nome[2], " " num ), num " " ), "At." ) " " num_end
			}
			Else
				local	=	Interna
		}
	
	;	Acerto
		If	InStr( nome[2], "Acerto" ) {
			setor	:=	"[ ACE ]"
			IF	InStr( nome[2], "Acerto" )
			||	InStr( nome[2], " " ) {
				If	RegExMatch( nome[2], "\d" ) {
					num		:=	SubStr( nome[2], RegExMatch( nome[2], "\d" ), 2 )
					num_end	:=	StrRep( num,, " ", "0" )
				}
				Else
					num_end	=
				local	:=	StrReplace( StrReplace( StrReplace( nome[2], " " num ), num " " ), "Acerto" ) " " num_end
			}
			Else
				local	=	Interna
		}

	new_name:=	StrRep( sigla " " setor " " local,, "  : " )
	new_name:=	StrRep( new_name,, "  : " )
	new_name:=	StrRep( new_name,, "  : " )
	saida	.= ip "`t" new_name "`t" name "`n"
Return
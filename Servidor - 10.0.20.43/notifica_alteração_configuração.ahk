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
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\functions.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\gui.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\listview.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\mail.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\safe_data.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\sql.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\string.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\sync_data.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\telegram.ahk
	#Include C:\Users\dsantos\Desktop\AutoHotkey\class\timer.ahk
	; #Include C:\Users\dsantos\Desktop\AutoHotkey\class\windows.ahk
;

/*	Bancos de Dados utilizados
	[dguard].[dbo].[cameras]
*/

;	Configurações
; if (A_IsCompiled) {
	#NoTrayIcon
	#SingleInstance, Force
	teste = 
; }
;
http = http://admin:tq8hSKWzy5A@
;	Code
	;	Dahua e Intelbras
		s =
			(
				SELECT
					[name],														--	1
					[ip],														--	2
					[bitrate],													--	3
					[bitrate_type],												--	4
					[codec],													--	5
					[resolution],												--	6
					[fps],														--	7
					[motion_detection],											--	8
					[ivs],														--	9
					[video_quality],											--	10
					LEFT( [vendormodel], charindex(' ', [vendormodel] ) - 1) 	--	11
				FROM
					[Dguard].[dbo].[cameras]
				WHERE
					[vendormodel]
						LIKE 'dah`%'
				OR
					[vendormodel]
						LIKE 'intel`%'
				ORDER BY
					[Name]
			)
		s := sql( s, 3 )
		timer("start")
		Loop,%	s.Count()-1	{

			OutputDebug, % (s.Count()-1) - A_Index
			ip	:=	s[A_Index+1,2]
			; ip	:=	StrRep( s[A_Index+1,2],, "`n", "`r" )
			resolution:=BitRate:=bitrate_type:=codec:=FPS:=Quality:=motion_detection:=ivs:=""
			if !ping( ip )
				Continue
			;	Variaveis do banco sql para comparação
				if (ip = "192.9.100.230")
					OutputDebug, % "_" s[A_Index+1,9] "_"
				_name				:=	s[A_Index+1,1]
				_bitrate			:=	s[A_Index+1,3]
				_bitrate_type		:=	s[A_Index+1,4]
				_codec				:=	s[A_Index+1,5]
				_resolution			:=	s[A_Index+1,6]
				_fps				:=	s[A_Index+1,7]
				_motion_detection	:=	s[A_Index+1,8]
				_ivs				:=	s[A_Index+1,9]
				_quality			:=	s[A_Index+1,10]
				vendor				:=	s[A_Index+1,11]
			;

			r	:=	http( http ip "/cgi-bin/configManager.cgi?action=getConfig&name=Encode[0].MainFormat[0]",,1 )
			; OutputDebug, % r
			if StrLen( r ) = 0
				continue
			encode := StrSplit( r, "`n" )
			message	:= "[n][t] <b><u>[t]" _name "</u></b>[t][t][t][t]<a href=""" ip """>" ip "</a>"
			Loop,% encode.Count() {
				If		InStr( a:= StrRep( encode[A_index],, "table.", "`n", "`r" ), "Encode[0].MainFormat[0].Video.resolution=" ) {
					resolution	:= SubStr( a, InStr( a, "=" )+1  )
					If	( resolution != _resolution ) {
						Notify++
						message	.=	"[n]   ┌<b>Resolução</b>[n][t] └─ <code>" _resolution
								.	"</code>[t][t]➝[t][t]<code>" resolution " </code>"
					}
				}

				else If	InStr( a:= StrRep( encode[A_index],, "table.", "`n", "`r" ), "Encode[0].MainFormat[0].Video.BitRate=" ) {
					BitRate		:= SubStr( a, InStr( a, "=" )+1  )
					If	( BitRate != _BitRate ) {
						Notify++
						message	.=	"[n]   ┌<b>BitRate</b>[n][t] └─ <code>" _BitRate
								.	"</code>[t][t]➝[t][t]<code>" BitRate " </code>"
					}
				}

				else If	InStr( a:= StrRep( encode[A_index],, "table.", "`n", "`r" ), "Encode[0].MainFormat[0].Video.BitRateControl=" ) {
					bitrate_type:= SubStr( a, InStr( a, "=" )+1  )
					If	( bitrate_type != _bitrate_type ) {
						Notify++
						message	.=	"[n]   ┌<b>Tipo de BitRate</b>[n][t] └─ <code>" _bitrate_type
								.	"</code>[t][t]➝[t][t]<code>" bitrate_type " </code>"
					}
				}

				else If	InStr( a:= StrRep( encode[A_index],, "table.", "`n", "`r" ), "Encode[0].MainFormat[0].Video.Compression=" ) {
					codec		:= SubStr( a, InStr( a, "=" )+1  )
					If	( codec != _codec ) {
						Notify++
						message	.=	"[n]   ┌<b>Codec</b>[n][t] └─ <code>" _codec
								.	"</code>[t][t]➝[t][t]<code>" codec " </code>"
					}
				}

				else If	InStr( a:= StrRep( encode[A_index],, "table.", "`n", "`r" ), "Encode[0].MainFormat[0].Video.FPS=" ) {
					FPS			:= SubStr( a, InStr( a, "=" )+1  )
					If	( FPS != _FPS ) {
						Notify++
						message	.=	"[n]   ┌<b>FPS</b>[n][t] └─ <code>" _FPS
								.	"</code>[t][t]➝[t][t]<code>" FPS " </code>"
					}
				}

				else If	InStr( a:= StrRep( encode[A_index],, "table.", "`n", "`r" ), "Encode[0].MainFormat[0].Video.Quality=" ) {
					Quality		:= SubStr( a, InStr( a, "=" )+1  )
					If	( Quality != _Quality ) {
						Notify++
						message	.=	"[n]   ┌<b>Qualidade de Imagem</b>[n][t] └─ <code>" _Quality
								.	"</code>[t][t]➝[t][t]<code>" Quality " </code>"
					}
				}

			}
			;	Motion Detection
				r := http( http ip "/cgi-bin/configManager.cgi?action=getConfig&name=MotionDetect[0].Enable",,1 )
				motion_detection:= SubStr( StrRep( r,, "`n", "`r" ), InStr( r, "=" )+1  ) = "true" ? 1 : 0
				If	( motion_detection != _motion_detection ) {
					Notify++
					_md	:=	_motion_detection= 1 ? "Ativado" : "Desativado"
					md	:=	motion_detection = 1 ? "Ativado" : "Desativado"
					message	.=	"[n]   ┌<b>Detecção de Movimento</b>[n][t] └─ <code>" _md
							.	"</code>[t][t]➝[t][t]<code>" md " </code>"
				}
			; IVS
				No_ivs =
				Loop, 5	{
					class	:= http( http ip "/cgi-bin/configManager.cgi?action=getConfig&name=VideoAnalyseRule[0][" A_Index-1 "].Type",,1 )
					If (SubStr( class, 1, 5 ) = "Error" )	;	se retornar 5 error ou o tipo for diferente 5 vezes, não há linha de passagem
					||	SubStr( StrRep( class,, "`n", "`r" ), InStr( class, "=" )+1  ) != "CrossLineDetection"			 {
						no_ivs++
						Continue
					}
					else If ( SubStr( StrRep( class,, "`n", "`r" ), InStr( class, "=" )+1  ) = "CrossLineDetection") {
						Enabled	:=	http( http ip "/cgi-bin/configManager.cgi?action=getConfig&name=VideoAnalyseRule[0][" A_Index-1 "].Enable",,1 )
						IVS		:=	SubStr( StrRep( Enabled,, "`n", "`r" ), InStr( Enabled, "=" )+1  ) = "true" ? 1 : 0
						If	(ivs!= _ivs ) {
							Notify++
							_iv	:=	_ivs= 1 ? "Ativado" : "Desativado"
							iv	:=	ivs	= 1 ? "Ativado" : "Desativado"
							message	.=	"[n]   ┌<b>Linha de Passagem</b>[n][t] └─ <code>" _iv
									.	"</code>[t][t]➝[t][t]<code>" iv " </code>"
						}
						Break
					}
				}
				if ( no_ivs = 5 ) {
					IVS = 0
					If	(ivs!= _ivs ) {
						Notify++
						_iv	:=	_ivs= 1 ? "Ativado" : "Desativado"
						iv	:=	ivs	= 1 ? "Ativado" : "Desativado"
						message	.=	"[n]   ┌<b>Linha de Passagem</b>[n][t] └─ <code>" _iv
								.	"</code>[t][t]➝[t][t]<code>" iv " </code>"
					}
				}
			; msgbox %	ip				"`n`tResolution`t"
			; OutputDebug %	ip				"`n`tResolution`t"
			; 			.	resolution		"`n`tBitrate Tipo`t"
			; 			.	bitrate_type	"`n`tBitrate`t`t" 
			; 			.	BitRate			"`n`tCodec`t`t" 
			; 			.	codec			"`n`tFPS`t`t" 
			; 			.	FPS				"`n`tQuality`t`t" 
			; 			.	Quality			"`n`tIVS`t`t" 
			; 			.	ivs				"`n`tM. Detection`t" 
			; 			.	motion_detection "`n`tNo IVS`t`t"
			; 			.	no_ivs
			if	Notify {
				if	!teste
					telegram.SendMessage( message, "parse_mode=html", "chat_id=-1001160086708" )
				Else
					telegram.SendMessage( message, "parse_mode=html" )
				Notify = 0
			}

			u	=
				(
					UPDATE
						[Dguard].[dbo].[cameras]
					SET 
						[codec] = '%codec%'
						,[resolution] = '%resolution%'
						,[fps] = '%fps%'
						,[bitrate_type] = '%bitrate_type%'
						,[bitrate] = '%bitrate%'
						,[video_quality] = '%quality%'
						,[motion_detection] = %motion_detection%
						,[ivs] = %ivs%
					WHERE
						[ip] = '%ip%'
				)
			; sql( u, 3 )
			If	sql_le {
				MsgBox % sql_le "`n"  clipboard := sql_lq
				sql_le =
			}
		}
	;	Samsung
	EXITAPP	;	Não está pronto ainda
		s =
			(
				SELECT
					[name],														--	1
					[ip],														--	2
					[bitrate],													--	3
					[bitrate_type],												--	4
					[codec],													--	5
					[resolution],												--	6
					[fps],														--	7
					[motion_detection],											--	8
					[ivs],														--	9
					[video_quality],											--	10
					LEFT( [vendormodel], charindex(' ', [vendormodel] ) - 1) 	--	11
				FROM
					[Dguard].[dbo].[cameras]
				WHERE
					[vendormodel]
						LIKE 'samsung`%'
				ORDER BY
					[Name]
			)
		s := sql( s, 3 )
		timer("start")
		Loop,%	s.Count()-1	{
			OutputDebug, % (s.Count()-1) - A_Index
			ip	:=	s[A_Index+1,2]
			resolution:=BitRate:=bitrate_type:=codec:=FPS:=Quality:=motion_detection:=ivs:=""
			if !ping( ip ){
				Sleep, 1500
				if !ping( ip )
					Continue
			}
			;	Variaveis do banco sql para comparação
				_name				:=	s[A_Index+1,1]
				_bitrate			:=	s[A_Index+1,3]
				_bitrate_type		:=	s[A_Index+1,4]
				_codec				:=	s[A_Index+1,5]
				_resolution			:=	s[A_Index+1,6]
				_fps				:=	s[A_Index+1,7]
				_motion_detection	:=	s[A_Index+1,8]
				_ivs				:=	s[A_Index+1,9]
				_quality			:=	s[A_Index+1,10]
				vendor				:=	s[A_Index+1,11]
			;
			r	:=	http( http ip "/cgi-bin/basic.cgi?msubmenu=video&action=view3",,1 )
				If	!InStr( r, "profile_name:Monitoramento" )
					OutputDebug, % ip
			if StrLen( r ) = 0
				continue

			encode	:= StrSplit( r, "`n" )
			message	:= "[n][t] <b><u>[t]" _name "</u></b>[t][t][t][t]<a href=""" ip """>" ip "</a>"
			begin	= 
			Loop,% encode.Count() {
				If	InStr( a:= StrRep( encode[A_index],, "`n", "`r" ), "profile_no:2" ) {
					begin = 1
					Continue
				}
				Else If !begin {
					Continue
				}
				If	InStr( a:= StrRep( encode[A_index],, "`n", "`r" ), "h4_smart_codec:" )	;	end cam
					Break

				If	( InStr( a:= StrRep( encode[A_index],, "`n", "`r" ), "encoding_type:" ) ) {
					codec	:=	SubStr( a, InStr( a, ":" )+1 ) = 2 ? "H.264" : "MJPG"
					If	( codec != _codec ) {
						Notify++
						message	.=	"[n]   ┌<b>Codec</b>[n][t] └─ <code>" _codec
								.	"</code>[t][t]➝[t][t]<code>" codec " </code>"
					}
				}

				If	( InStr( a:= StrRep( encode[A_index],, "`n", "`r" ), "h4_width:" ) )
					r1	:=	SubStr( a, InStr( a, ":" )+1 )
				If	( InStr( a:= StrRep( encode[A_index],, "`n", "`r" ), "h4_height:" ) )
					r2	:=	SubStr( a, InStr( a, ":" )+1 )

				If	( InStr( a:= StrRep( encode[A_index],, "`n", "`r" ), "h4_frate:" ) ) {
					fps	:=	SubStr( a, InStr( a, ":" )+1 )
					If	( fps != _fps ) {
						Notify++
						message	.=	"[n]   ┌<b>FPS</b>[n][t] └─ <code>" _fps
								.	"</code>[t][t]➝[t][t]<code>" fps " </code>"
					}
				}

				If	( InStr( a:= StrRep( encode[A_index],, "`n", "`r" ), "h4_bit_control:" ) ) {
					bitrate_type	:=	SubStr( a, InStr( a, ":" )+1 ) = 1 ? "VBR" : "CBR"
					If	( bitrate_type != _bitrate_type ) {
						Notify++
						message	.=	"[n]   ┌<b>Tipo de BitRate</b>[n][t] └─ <code>" _bitrate_type
								.	"</code>[t][t]➝[t][t]<code>" bitrate_type " </code>"
					}
				}

				If	( InStr( a:= StrRep( encode[A_index],, "`n", "`r" ), "h4_bitrate:" ) ) {
					bitrate	:=	SubStr( a, InStr( a, ":" )+1 )
					If	( bitrate != _bitrate ) {
						Notify++
						message	.=	"[n]   ┌<b>BitRate</b>[n][t] └─ <code>" _bitrate
								.	"</code>[t][t]➝[t][t]<code>" bitrate " </code>"
					}
				}
			}

			resolution := r1 "x" r2
				If	( resolution != _resolution ) {
					Notify++
					message	.=	"[n]   ┌<b>Resolução</b>[n][t] └─ <code>" _resolution
							.	"</code>[t][t]➝[t][t]<code>" resolution " </code>"
				}

			; OutputDebug, %	_name "`t" ip
			; 			.	"`n-" _bitrate "-`t-" BitRate
			; 			.	"-`n-" _bitrate_type "-`t-" bitrate_type
			; 			.	"-`n-" _codec "-`t-" codec
			; 			.	"-`n-" _resolution "-`t-" resolution
			; 			.	"-`n-" _fps "-`t-" FPS
			; 			.	"-`n-" vendor

			if	Notify {
				if	!teste
					telegram.SendMessage( message, "parse_mode=html", "chat_id=-1001160086708" )
				Else
					telegram.SendMessage( message, "parse_mode=html" )
				message	=
				Notify	= 0
			}

			u	=
				(
					UPDATE
						[Dguard].[dbo].[cameras]
					SET 
						[codec]		= '%codec%'
						,[resolution]	= '%resolution%'
						,[fps]			= '%fps%'
						,[bitrate_type] = '%bitrate_type%'
						,[bitrate]		= '%bitrate%'
					WHERE
						[ip]			= '%ip%'
				)
			sql( u, 3 )
			If	sql_le {
				MsgBox % sql_le "`n"  clipboard := sql_lq
				sql_le =
			}
		}
	;
	msgbox % timer("Fim")
ExitApp

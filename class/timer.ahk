if	inc_timer
	Return
Global inc_timer = 1
; timer( "Inicio" )
; sleep, 1000
; timer( "Meio" )
; Sleep, 2000
; timer( "Meio2" )
; Sleep, 3000
; timer( "Meio3" )
; 	Sleep, 4000
; 	MsgBox % timer( "Fim" )	;	Tem que haver para retornar o relatório completo
; Return
ListLines, Off

timer( description = "Interval" )	{
	Global	timers

	timers .= description "|" A_Now "`n"
	if ( description = "Fim" )	{
		output := StrSplit( timers, "`n" )
		Loop,% output.count()-1 {
			set_return := StrSplit( output[ A_Index ], "|" )
			if ( A_Index = 1 ) {
				last_time	:= set_return[2]
				start_time	:= set_return[2]
				last_desc	:= set_return[1]
			}
			Else {
				out			.= "Tempo decorrido entre '" last_desc "' e '" set_return[1] "' foi de:`n`t" set_return[2] - last_time " segundo(s)`n`n"
				last_time	:= set_return[2]
				last_desc	:= set_return[1]
			}
		}
		out .= "Tempo TOTAL decorrido foi de:`n`t" last_time - start_time " segundo(s)."
		Return out

	}
	Return
}

ListLines, On
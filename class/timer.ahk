Global inc_timer = 1
; timer( "Inicio" )	;	Tem que haver
; sleep 1000
; timer( "Meio" )
; Sleep, 5000
; timer( "Meio2" )
; Sleep, 8000
; timer( "Meio3" )
	; Sleep, 10000
	; MsgBox % timer( "Fim" )	;	Tem que haver
; Return
ListLines, Off

timer( description = "Interval" )	{
	Global	timers

	timers .= description "|" A_Now "`n"
	if ( description = "Fim" )	{
		timers := SubStr( timers, 1, StrLen( timers ) - 1 )
		output := StrSplit( timers, "`n" )
		Loop,% output.count() {
			set_return := StrSplit( output[A_Index] , "|" )
			if ( A_Index = 1 ) {
				last_time	:= set_return[2]
				start_time	:= set_return[2]
				last_desc	:= set_return[1]
			}
			Else {
				out .= "Tempo decorrido entre '" last_desc "' e '" set_return[1] "' foi de:`n`t" set_return[2] - last_time " segundo(s)`n`n"
				last_time := set_return[2]
				last_desc := set_return[1]
			}
		}
		out .= "Tempo TOTAL decorrido foi de:`n`t" last_time - start_time " segundo(s)."
		Return out

	}
	Return
}

ListLines, On
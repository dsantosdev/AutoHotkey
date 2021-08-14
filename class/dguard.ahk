Class	dguard {

	Mover( win_id := "", win_title := "A" ) {
		if ( StrLen( win_id  ) = 0 )	{
			if ( StrLen( win_title ) > 1 )
				WinActivate,%	win_title
			win_id := WinActive( win_title )
		}
		SysGet, MonitorPrimary	,	MonitorPrimary
		SysGet, MonitorName		,	MonitorName		, %MonitorPrimary%
		SysGet, Monitor, Monitor,	%MonitorPrimary%
		OutputDebug % "Monitor:`t" MonitorPrimary "`n`nName:`t" MonitorName "`nX:`t" MonitorLeft "`nY:`t" MonitorTop "`nW:`t" MonitorRight-MonitorLeft "`nH`t" MonitorBottom-MonitorTop
		WinMove, ahk_id %win_id%, ,% MonitorLeft,% MonitorTop  ;,% MonitorRight-MonitorLeft,% MonitorBottom-MonitorTop
		return
	}

}
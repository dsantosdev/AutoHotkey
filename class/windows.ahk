Class	Windows	{

    Run( software )	{
        ; MsgBox % software
        path = "C:\Dguard Advanced\"
        copy = "\\fs\Departamentos\monitoramento\Monitoramento\Dieisson\SMK\"
        try
            Run,%   path software ".exe"
            catch	{
                FileCopy,%  copy software ".exe",% path software ".exe",   1
                Sleep,	500
                if ( errorlevel = 0 )
                    Run,%   path software ".exe"
            }
        }

	Users( where )	{
        if !where
            Return
        obj := ComObjGet( "winmgmts:{impersonationLevel=impersonate}!\\" . A_ComputerName . "\root\cimv2" )
        select = SELECT FullName FROM Win32_UserAccount WHERE Name = '%where%'
        query_results := obj.ExecQuery( select )._NewEnum
        While query_results[ property ]
            {
            ; OutputDebug % "Saida funcao - Usuario: " property["FullName"] " - " where
            Return property[ "FullName" ]
            }
    }

}

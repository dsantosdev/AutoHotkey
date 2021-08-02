Class	Windows	{

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

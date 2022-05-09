if	inc_alarm
	Return
global	inc_alarm = 1

Class	Alarm	{
	
	name( sensorNumber, idClient )				{
		if ( StrLen( sensorNumber ) = 1 )
			sensorNumber := "0" sensorNumber
		if ( StrLen( sensorNumber ) = 3 )
			sensorNumber := SubStr( sensorNumber, 2, 2)
		sensor   =
			(
			SELECT
				[Descricao]
			FROM
				[IrisSQL].[dbo].[Alarmes]
			WHERE
				[Alarme]	= 'E1300%sensorNumber%' AND
				[IdCliente]	= '%idClient%'
			)
		sensor := sql( sensor )															;	Descrio do sensor
		If ( StrLen( sensor[2,1] ) = 0 )																;	Se o tamanho da descrição for 0, define o nome como no cadastrada
			nomeSensor	=	ZONA NÃO CADASTRADA NO IRIS
		Else	{
			nmSensor	:=	StrSplit( sensor[2,1], " - " )
			nomeSensor2	:=	Format( "{:T}", nmSensor[2] )
			nomeSensor	:=	nmSensor[1] " - " nomeSensor2
		}
		return nomeSensor
	}

}
global	inc_folder = 1

Class	Folder	{
	
	Clear( dir )	{
		Loop %dir%\*.*, 2 
		{
			FileDelete,%	dir "\DVRWorkDirectory"
			FileDelete,%	A_LoopFileFullPath "\DVRWorkDirectory"
			Folder.Clear( A_LoopFileFullPath )
		}
		FileRemoveDir,%	A_LoopFileFullPath
		return
	}

}
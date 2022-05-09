if	inc_listview
	Return
Global inc_listview = 1

Class ListView {

	LV_AddIcon( hwnd, line, iSubItem, iImage ){
		VarSetCapacity(LVITEM, A_PtrSize == 8 ? 88 : 60, 0)
		LVM_SETITEM := 0x1006 , mask := 2   ; LVIF_IMAGE := 0x2
		line-- , iSubItem-- , iImage--		; Note first column (iSubItem) is #ZERO, hence adjustment
		NumPut(mask, LVITEM, 0, "UInt")
		NumPut(iItem, LVITEM, 4, "Int")
		NumPut(iSubItem, LVITEM, 8, "Int")
		NumPut(iImage, LVITEM, A_PtrSize == 8 ? 36 : 28, "Int")
		result := DllCall("SendMessageA", UInt, hwnd, UInt, LVM_SETITEM, UInt, 0, UInt, &LVITEM)
		return result
	}
}
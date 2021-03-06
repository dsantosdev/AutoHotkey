; Add your credentials here
botToken := "1510356494:AAFkppxELD9JISyZglP0r0c-Q3STc4tKTpo"
chatID := 1597053632
;------------------------------------------------
FileSelectFile, SelectedFile, 3, , Open an image file			; select an image from hard disk
msgbox % SendPhoto(botToken, chatID, Selectedfile) 	; send the image; use msgbox for checking the json response
ExitApp
; end of auto-execute section; the rest of the script are re-usable library functions
;----------------------------------------------------------------------------------------------------------------------------------
SendPhoto(token, chatID, file, caption := "" )		; you could add more options; compare the Telegram API docs
{
		url_str := "https://api.telegram.org/bot" token "/sendPhoto?caption=" caption
		objParam := {	 	"chat_id" : chatID																				
						, 	"photo" : [file]  }
		return UploadFormData(url_str, objParam)	
}
;---------------------------------------------
UploadFormData(url_str, objParam)									; Upload multipart/form-data
{
		CreateFormData(postData, hdr_ContentType, objParam)
		whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
		whr.Open("POST", url_str, true)
		whr.SetRequestHeader("Content-Type", hdr_ContentType)
				; whr.SetRequestHeader("User-Agent", "Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; rv:11.0) like Gecko")				; ???????
		whr.Option(6) := False ; No auto redirect
		whr.Send(postData)
		whr.WaitForResponse()
		json_resp := whr.ResponseText
		whr :=												; free COM object
		return json_resp							; will return a JSON string that contains, among many other things, the file_id of the uploaded file
}
;###################################################################################################################
/*
	CreateFormData - Creates "multipart/form-data" for http post

	Usage: CreateFormData(ByRef retData, ByRef retHeader, objParam)

		retData   - (out) Data used for HTTP POST.
		retHeader - (out) Content-Type header used for HTTP POST.
		objParam  - (in)  An object defines the form parameters.

		            To specify files, use array as the value. Example:
		                objParam := { "key1": "value1"
		                            , "upload[]": ["1.png", "2.png"] }

	Requirement: BinArr.ahk -- https://gist.github.com/tmplinshi/a97d9a99b9aa5a65fd20
	Version    : 1.20 / 2016-6-17 - Added CreateFormData_WinInet(), which can be used for VxE's HTTPRequest().
	             1.10 / 2015-6-23 - Fixed a bug
	             1.00 / 2015-5-14
*/

; Used for WinHttp.WinHttpRequest.5.1, Msxml2.XMLHTTP ...
CreateFormData(ByRef retData, ByRef retHeader, objParam) {
	New CreateFormData(retData, retHeader, objParam)
}

; Used for WinInet
CreateFormData_WinInet(ByRef retData, ByRef retHeader, objParam) {
	New CreateFormData(safeArr, retHeader, objParam)

	size := safeArr.MaxIndex() + 1
	VarSetCapacity(retData, size, 1)
	DllCall("oleaut32\SafeArrayAccessData", "ptr", ComObjValue(safeArr), "ptr*", pdata)
	DllCall("RtlMoveMemory", "ptr", &retData, "ptr", pdata, "ptr", size)
	DllCall("oleaut32\SafeArrayUnaccessData", "ptr", ComObjValue(safeArr))
}

Class CreateFormData {

	__New(ByRef retData, ByRef retHeader, objParam) {

		CRLF := "`r`n"

		Boundary := this.RandomBoundary()
		BoundaryLine := "------------------------------" . Boundary

		; Loop input paramters
		binArrs := []
		For k, v in objParam
		{
			If IsObject(v) {
				For i, FileName in v
				{
					str := BoundaryLine . CRLF
					     . "Content-Disposition: form-data; name=""" . k . """; filename=""" . FileName . """" . CRLF
					     . "Content-Type: " . this.MimeType(FileName) . CRLF . CRLF
					binArrs.Push( BinArr_FromString(str) )
					binArrs.Push( BinArr_FromFile(FileName) )
					binArrs.Push( BinArr_FromString(CRLF) )
				}
			} Else {
				str := BoundaryLine . CRLF
				     . "Content-Disposition: form-data; name=""" . k """" . CRLF . CRLF
				     . v . CRLF
				binArrs.Push( BinArr_FromString(str) )
			}
		}

		str := BoundaryLine . "--" . CRLF
		binArrs.Push( BinArr_FromString(str) )

		retData := BinArr_Join(binArrs*)
		retHeader := "multipart/form-data; boundary=----------------------------" . Boundary
	}

	RandomBoundary() {
		str := "0|1|2|3|4|5|6|7|8|9|a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z"
		Sort, str, D| Random
		str := StrReplace(str, "|")
		Return SubStr(str, 1, 12)
	}

	MimeType(FileName) {
		n := FileOpen(FileName, "r").ReadUInt()
		Return (n        = 0x474E5089) ? "image/png"
		     : (n        = 0x38464947) ? "image/gif"
		     : (n&0xFFFF = 0x4D42    ) ? "image/bmp"
		     : (n&0xFFFF = 0xD8FF    ) ? "image/jpeg"
		     : (n&0xFFFF = 0x4949    ) ? "image/tiff"
		     : (n&0xFFFF = 0x4D4D    ) ? "image/tiff"
		     : "application/octet-stream"
	}

}
;#############################################################################################################
; Update: 2015-6-4 - Added BinArr_ToFile()

BinArr_FromString(str) {
	oADO := ComObjCreate("ADODB.Stream")

	oADO.Type := 2 ; adTypeText
	oADO.Mode := 3 ; adModeReadWrite
	oADO.Open
	oADO.Charset := "UTF-8"
	oADO.WriteText(str)

	oADO.Position := 0
	oADO.Type := 1 ; adTypeBinary
	oADO.Position := 3 ; Skip UTF-8 BOM
	return oADO.Read, oADO.Close
}

BinArr_FromFile(FileName) {
	oADO := ComObjCreate("ADODB.Stream")

	oADO.Type := 1 ; adTypeBinary
	oADO.Open
	oADO.LoadFromFile(FileName)
	return oADO.Read, oADO.Close
}

BinArr_Join(Arrays*) {
	oADO := ComObjCreate("ADODB.Stream")

	oADO.Type := 1 ; adTypeBinary
	oADO.Mode := 3 ; adModeReadWrite
	oADO.Open
	For i, arr in Arrays
		oADO.Write(arr)
	oADO.Position := 0
	return oADO.Read, oADO.Close
}

BinArr_ToString(BinArr, Encoding := "UTF-8") {
	oADO := ComObjCreate("ADODB.Stream")

	oADO.Type := 1 ; adTypeBinary
	oADO.Mode := 3 ; adModeReadWrite
	oADO.Open
	oADO.Write(BinArr)

	oADO.Position := 0
	oADO.Type := 2 ; adTypeText
	oADO.Charset  := Encoding 
	return oADO.ReadText, oADO.Close
}

BinArr_ToFile(BinArr, FileName) {
	oADO := ComObjCreate("ADODB.Stream")

	oADO.Type := 1 ; adTypeBinary
	oADO.Open
	oADO.Write(BinArr)
	oADO.SaveToFile(FileName, 2)
	oADO.Close
}
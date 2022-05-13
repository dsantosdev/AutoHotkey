/* TheGood
Simple file functions

File_Open: Opens a file for subsequent operations
File_Read: Reads bytes from a file at the current file pointer and moves the file pointer forward by the number of bytes read
File_Write: Writes bytes to a file at the current file pointer and moves the file pointer forward by the number of bytes written
File_Pointer: Moves the file pointer to a specified position
File_Size: Returns the size of a file
File_Close: Closes a file
*/

/* sType = One of the following strings:
"READ" : Opens the file for reading
"WRITE" : Opens the file for writing
"READSEQ" : Opens the file for sequential reading (same as READ but offers better performance if reading will mainly be sequential)
sFile = File name to open
On success, returns the file handle
On failure, returns -1 with ErrorLevel = error code
*/
File_Open(sType, sFile) {

bRead := InStr(sType, "READ")
bSeq := sType = "READSEQ"

;Open the file for writing with GENERIC_WRITE/GENERIC_READ, NO SHARING/FILE_SHARE_READ & FILE_SHARE_WRITE, and OPEN_ALWAYS/OPEN_EXISTING, and FILE_FLAG_SEQUENTIAL_SCAN
hFile := DllCall("CreateFile", "str", sFile, "uint", bRead ? 0x80000000 : 0x40000000, "uint", bRead ? 3 : 0, "uint", 0, "uint", bRead ? 3 : 4, "uint", bSeq ? 0x08000000 : 0, "uint", 0)
If (hFile = -1 Or ErrorLevel) { ;Check for any error other than ERROR_FILE_EXISTS
ErrorLevel := ErrorLevel ? ErrorLevel : A_LastError
Return -1 ;Return INVALID_HANDLE_VALUE
} Else Return hFile
}

/* hFile = File handle
bData = Variable which will hold data read
iLength = Number of bytes to read; set to 0 to read to the end
On success, returns the number of bytes actually read
On failure, returns -1 with ErrorLevel = error code
*/
File_Read(hFile, ByRef bData, iLength = 0) {

;Check if we're reading up to the rest of the file
If Not iLength ;Set the length equal to the remaining part of the file
iLength := File_Size(hFile) - File_Pointer(hFile)

;Prep the variable
VarSetCapacity(bData, iLength, 0)

;Read the file
r := DllCall("ReadFile", "uint", hFile, "uint", &bData, "uint", iLength, "uint*", iLengthRead, "uint", 0)
If (Not r Or ErrorLevel) {
ErrorLevel := ErrorLevel ? ErrorLevel : A_LastError
Return -1
} Else Return iLengthRead
}

/* hFile = File handle
ptrData = Pointer to the data to write to the file
iLength = Number of bytes to write
On success, returns the number of bytes actually written
On failure, returns -1 with ErrorLevel = error code
*/
File_Write(hFile, ptrData, iLength) {

;Write to the file
r := DllCall("WriteFile", "uint", hFile, "uint", ptrData, "uint", iLength, "uint*", iLengthWritten, "uint", 0)
If (Not r Or ErrorLevel) {
ErrorLevel := ErrorLevel ? ErrorLevel : A_LastError
Return -1
} Else Return iLengthWritten
}

/* hFile = File handle
iOffset = Number of bytes to move the file pointer. If iMethod = -1, then
A positive iOffset moves the pointer forward from the beginning of the file.
A negative iOffset moves the pointer backwards from the end of the file.
Leave as 0 to return the current file pointer.
If iMethod <> -1, iOffset represents the number of bytes to move the file pointer using the selected method
iMethod = Leave as -1 for the movement to behave as described in iOffset's description
Otherwise, explicitly set to either "BEGINNING" (or 0), "CURRENT" (or 1), or "END" (or 2):
"BEGINNING" : Move starts from the beginning of the file. iOffset must be greater than or equal to 0.
"CURRENT" : Move starts from the current file pointer.
"END" : Move starts from the end of the file. iOffset must be less than or equal to 0.
On success, returns the new file pointer
On failure, returns -1 with ErrorLevel = error code
*/
File_Pointer(hFile, iOffset = 0, iMethod = -1) {

;Check if we're on auto
If (iMethod = -1) {

;Check if we should use FILE_BEGIN, FILE_CURRENT, or FILE_END
If (iOffset = 0)
iMethod := 1 ;We're just retrieving the current pointer. FILE_CURRENT
Else If (iOffset > 0)
iMethod := 0 ;We're moving from the beginning. FILE_BEGIN
Else If (iOffset < 0)
iMethod := 2 ;We're moving from the end. FILE_END
} Else If iMethod Is Not Integer
iMethod := (iMethod = "BEGINNING" ? 0 : (iMethod = "CURRENT" ? 1 : (iMethod = "END" ? 2 : 0)))

r := DllCall("SetFilePointerEx", "uint", hFile, "int64", iOffset, "int64*", iNewPointer, "uint", iMethod)
If (Not r Or ErrorLevel) {
ErrorLevel := ErrorLevel ? ErrorLevel : A_LastError
Return -1
} Else Return iNewPointer
}

/* hFile = File handle
On success, returns the file size
On failure, returns -1 with ErrorLevel = error code
*/
File_Size(hFile) {
r := DllCall("GetFileSizeEx", "uint", hFile, "int64*", iFileSize)
If (Not r Or ErrorLevel) {
ErrorLevel := ErrorLevel ? ErrorLevel : A_LastError
Return -1
} Else Return iFileSize
}

/* hFile = File handle
On success, returns True
On failure, returns False
*/
File_Close(hFile) {
If Not (r := DllCall("CloseHandle", "uint", hFile)) {
ErrorLevel := ErrorLevel ? ErrorLevel : A_LastError
Return False
} Return True
}
/*	Download for AHK_L x86/x64 Unicode

Examples:

Writing to a file:
;Make sure the file doesn't exist
FileDelete, %A_Temp%\File.dat

;Open the file for writing
hFile := File_Open("Write", A_Temp "\File.dat")
If (hFile = -1) {
MsgBox, % "Could not open the file! Error code = " ErrorLevel
ExitApp
}

;Write 3 bytes of 0xFF to the file
VarSetCapacity(bData, 3, 0xFF)
File_Write(hFile, &bData, 3)

;The file now contains FF FF FF

;Append 3 more bytes of 0xFE
VarSetCapacity(bData, 3, 0xFE)
File_Write(hFile, &bData, 3)

;The file now contains FF FF FF FE FE FE

;Put pointer back to the beginning
File_Pointer(hFile, 0, "Beginning")

;(Over)write the first two bytes with 0xFD
VarSetCapacity(bData, 2, 0xFD)
File_Write(hFile, &bData, 2)

;The file now contains FD FD FF FE FE FE

;Put pointer at the end of the file
File_Pointer(hFile, 0, "End")

;Append 3 bytes of 0xFC
VarSetCapacity(bData, 3, 0xFC)
File_Write(hFile, &bData, 3)

;The file now contains FD FD FF FE FE FE FC FC FC

;Close the file now
File_Close(hFile)Reading from a file (run this after running the first example):
;Open the file for reading
hFile := File_Open("Read", A_Temp "\File.dat")
If (hFile = -1) {
MsgBox, % "Could not open the file! Error code = " ErrorLevel
ExitApp
}

;Get file size
iSize := File_Size(hFile)
MsgBox, % "File size is " iSize " bytes."

;Read the whole file
iRead := File_Read(hFile, bData)
MsgBox, % "File data is: `n" Bin2Hex(&bData, iRead)

;Go back to the beginning of the file
File_Pointer(hFile, 0, "Beginning")

;Read the first 3 bytes only
iRead := File_Read(hFile, bData, 3)
MsgBox, % "First 3 bytes are: `n" Bin2Hex(&bData, iRead)

;Now read the rest of the file (i.e. from the 3rd byte to the end of the file)
iRead := File_Read(hFile, bData)
MsgBox, % "Remaining " iRead " bytes are: `n" Bin2Hex(&bData, iRead)

;We can close the file now
File_Close(hFile)

Return
*/
;By Laszlo
;http://www.autohotkey.com/forum/viewtopic.php?p=135402#135402
Bin2Hex(addr, len) {
Static fun
If (fun = "") {
h=8B54240C85D2568B7424087E3A53578B7C24148A07478AC8C0E90480F9090F97C3F6DB80E30702D980C330240F881E463C090F97C1F6D980E10702C880C130880E464A75CE5F5BC606005EC3
VarSetCapacity(fun, 76)
Loop 76
NumPut("0x" . SubStr(h, 2 * A_Index - 1, 2), fun, A_Index - 1, "Char")
}
VarSetCapacity(hex, 2 * len + 1)
DllCall(&fun, "uint", &hex, "uint", addr, "uint", len, "cdecl")
VarSetCapacity(hex, -1) ;update StrLen
Return hex
}
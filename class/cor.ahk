global	green2orange	:= [	"0x264653"
							,	"0x2a9d8f"
							,	"0xe9c46a"
							,	"0xf4a261"
							,	"0xe76f51"	]
	,	blue2ocean		:= [	"0x03045e"
							,	"0x023e8a"
							,	"0x0077b6"
							,	"0x0096c7"
							,	"0x00b4d8"	
							,	"0x48cae4"	
							,	"0x90e0ef"	
							,	"0xade8f4"	
							,	"0xcaf0f8"	]
	,	green2blue		:= [	"0x28ae19"
							,	"0x27a62b"
							,	"0x279e3d"
							,	"0x26964e"
							,	"0x268e60"
							,	"0x258772"
							,	"0x257f84"
							,	"0x247795"
							,	"0x246fa7"
							,	"0x2367b9"	]
	,	white2green		:= [	"0xd8f3dc"
							,	"0xb7e4c7"
							,	"0x95d5b2"
							,	"0x74c69d"
							,	"0x52b788"
							,	"0x40916c"
							,	"0x2d6a4f"
							,	"0x1b4332"
							,	"0x081c15"]
	,	purple2ocean	:= [	"0x7400b8"
							,	"0x6930c3"
							,	"0x5e60ce"
							,	"0x5390d9"
							,	"0x4ea8de"
							,	"0x48bfe3"
							,	"0x56cfe1"
							,	"0x64dfdf"
							,	"0x72efdd"
							,	"0x80ffdb"]
	,	fire2purple		:= [	"0xffbe0b"
							,	"0xfb5607"
							,	"0xff006e"
							,	"0x8338ec"
							,	"0x3a86ff"]
	,	fire			:= [	"0xff7b00"
							,	"0xff8800"
							,	"0xff9500"
							,	"0xffa200"
							,	"0xffaa00"
							,	"0xffb700"
							,	"0xffc300"
							,	"0xffd000"
							,	"0xffdd00"
							,	"0xffea00"	]
	,	red				:= [	"0x641220"
							,	"0x6e1423"
							,	"0x85182a"
							,	"0xa11d33"
							,	"0xa71e34"
							,	"0xb21e35"
							,	"0xbd1f36"
							,	"0xc71f37"
							,	"0xda1e37"
							,	"0xe01e37"]

	,	rainbow			:= [	"0x54478c"
							,	"0x2c699a"
							,	"0x048ba8"
							,	"0x0db39e"
							,	"0x16db93"
							,	"0x83e377"
							,	"0xb9e769"
							,	"0xefea5a"
							,	"0xf1c453"
							,	"0xf29e4c"	]
	,	pink			:= [	"0xff0a54"
							,	"0xff477e"
							,	"0xff5c8a"
							,	"0xff7096"
							,	"0xff85a1"
							,	"0xff99ac"
							,	"0xfbb1bd"
							,	"0xf9bec7"
							,	"0xf7cad0"
							,	"0xfae0e4"	]
	,	greenlime		:= [	"0x004b23"
							,	"0x006400"
							,	"0x007200"
							,	"0x008000"
							,	"0x38b000"
							,	"0x70e000"
							,	"0x9ef01a"
							,	"0xccff33"	]
	,	blue			:= [	"0x00a6fb"
							,	"0x0582ca"
							,	"0x006494"
							,	"0x003554"
							,	"0x051923"	]
	,	lightblue		:= [	"0x3fc1c0"
							,	"0x20bac5"
							,	"0x00b2ca"
							,	"0x04a6c2"
							,	"0x0899ba"
							,	"0x0f80aa"
							,	"0x16679a"
							,	"0x1a5b92"
							,	"0x1c558e"
							,	"0x1d4e89"	]
	,	darkgreen2purple:= [	"0x006466"
							,	"0x065a60"
							,	"0x0b525b"
							,	"0x144552"
							,	"0x1b3a4b"
							,	"0x212f45"
							,	"0x272640"
							,	"0x312244"
							,	"0x3e1f47"
							,	"0x4d194d"	]
	,	burning			:= [	"0x03071e"
							,	"0x370617"
							,	"0x6a040f"
							,	"0x9d0208"
							,	"0xd00000"
							,	"0xdc2f02"
							,	"0xe85d04"
							,	"0xf48c06"
							,	"0xfaa307"
							,	"0xffba08"	]
	,	baby			:= [	"0xffcbf2"
							,	"0xf3c4fb"
							,	"0xecbcfd"
							,	"0xe5b3fe"
							,	"0xe2afff"
							,	"0xdeaaff"
							,	"0xd8bbff"
							,	"0xd0d1ff"
							,	"0xc8e7ff"
							,	"0xc0fdff"	]
;	END of GLOBALS

Class	Cor	{

	Gradiente( HWND, oColors, oPositions = "", D = 0, GC = 0, BW = 0, BH = 0 ) {
		; ======================================================================================================================
			; Function:		LinearGradient
			;				Creates a linear gradient bitmap for a GUI Picture control. 
			; AHK-Version:	1.1.05.00 U32
			; OS-Versions:	Win Vista 32
			; Author:		just me
			; Parameter:	HWND		-	Control's HWND
			;				oColors		-	Array of integer RGB color values
			;								At least two colors must be passed, the start and the target color for the gradient
			; (Optional)	oPositions	-	Array containing the relative positions of the color values as floating-point values 
			;								between 0.0 (start) and 1.0 (end) in ascending order
			;								Default: "" (or any non-object value)
			;
			; Colors are divided automatically according to the number of colors.
			;				D			-	Direction:
			;								0 = horizontal
			;								1 = vertical
			;								2 = diagonal (upper-left -> lower-right)
			;								3 = diagonal (upper-right -> lower-left)
			;								Default: 0
			;				GC			-	Gamma Correction:
			;								0 = no
			;								1 = yes
			;								Default: 0
			;				BW			-	Brush width in pixel
			;								Default: 0 = control's width
			;				BH			-	Brush height in pixel
			;								Default: 0 = control's height
		; ======================================================================================================================
	
		; Windows Constants
			Static SS_BITMAP	:= 0xE
			Static SS_ICON		:= 0x3
			Static STM_SETIMAGE	:= 0x172
			Static IMAGE_BITMAP	:= 0x0
		;

		; Check Parameters
			If		!IsObject( oColors )
				||	( oColors.Count()	<	2	) {
				ErrorLevel := "Invalid parameter oColors!"
				Return False
			}
			IC	:=	oColors.Count()
			If	IsObject( oPositions ) {
				If ( oPositions.Count() <> IC ) {
					ErrorLevel := "Invalid parameter oPositions!"
					Return False
				}
			}
			Else {
				oPositions := [0.0]
				P := 1.0 / ( IC - 1 )
				Loop, % ( IC - 2 )
					oPositions.Insert( P * A_Index )
				oPositions.Insert(1.0)
			}
		;

		; Check HWND
			WinGetClass, Class, ahk_id %HWND%
			If ( Class != "Static" ) {
				ErrorLevel := "Class " . Class . " is not supported!"
				Return False
			}
		;

		; Check the availability of GDIPlus
			If !DllCall( "GetModuleHandle", "Str", "Gdiplus" )
				hGDIP := DllCall( "LoadLibrary", "Str", "Gdiplus" )
			VarSetCapacity( SI, 16, 0 )
			Numput( 1, SI, "UInt" )
			DllCall( "Gdiplus.dll\GdiplusStartup", "PtrP", pToken, "Ptr", &SI, "Ptr", 0 )
			If ( !pToken ) {
				ErrorLevel := "GDIPlus could not be started!`nCheck the availability of GDIPlus on your system, please!"
				Return False
			}
		;

		; Get client rectangle
			VarSetCapacity( RECT, 16, 0 )
			DllCall( "User32.dll\GetClientRect", "Ptr", HWND, "Ptr", &RECT )
			W := NumGet( RECT, 8, "Int" )
			H := NumGet( RECT, 12, "Int" )
		;
	
		; Set default parameter values
			If D Not In 0,1,2,3
				D := 0
			If GC Not In 0,1
				GC := 0
			If BW Not Between 1 And W
				BW := W
			If BH Not Between 1 And H
				BH := H
		;

		; Create a GDI+ bitmap
			DllCall( "Gdiplus.dll\GdipCreateBitmapFromScan0", "Int", W, "Int", H, "Int", 0
					, "Int", 0x26200A, "Ptr", 0, "PtrP", pBitmap )
		;

		; Create a pointer to the corresponding graphic object
			DllCall( "Gdiplus.dll\GdipGetImageGraphicsContext", "Ptr", pBitmap, "PtrP", pGraphics )
		;

		; Fill the bitmap with a linear gradient
			; RECTF structure for line brush
				VarSetCapacity( RECTF, 16, 0 )
				NumPut( BW, RECTF,  8, "Float" )
				NumPut( BH, RECTF, 12, "Float" )
			; Create a linear gradient brush
				DllCall( "Gdiplus.dll\GdipCreateLineBrushFromRect", "Ptr", &RECTF
						, "Int", 0, "Int", 0, "Int", D, "Int", 0, "PtrP", pBrush )
			; Set gamma correction
				DllCall( "Gdiplus.dll\GdipSetLineGammaCorrection", "Ptr", pBrush, "Int", GC )
			; Set line preset blend colors ...
				VarSetCapacity( COLORS, IC * 4, 0 )
				O := -4
				For I, V In oColors 
					NumPut( V | 0xFF000000, COLORS, O += 4, "UInt" )
		; ... and positions
			VarSetCapacity( POSITIONS, IC * 4, 0 )
			O := -4
			For I, V In oPositions
				NumPut( V, POSITIONS, O += 4, "Float" )
			DllCall( "Gdiplus.dll\GdipSetLinePresetBlend", "Ptr", pBrush, "Ptr", &COLORS, "Ptr", &POSITIONS, "Int", IC )
		; Fill the bitmap
			DllCall( "Gdiplus.dll\GdipFillRectangle", "Ptr", pGraphics, "Ptr", pBrush
					, "Float", 0, "Float", 0, "Float", W, "Float", H )
		;

		; Create HBITMAP from bitmap
			DllCall( "Gdiplus.dll\GdipCreateHBITMAPFromBitmap", "Ptr", pBitmap, "PtrP", hBitmap, "Int", 0X00FFFFFF )
		;

		; Free resources
			DllCall( "Gdiplus.dll\GdipDisposeImage", "Ptr", pBitmap )
			DllCall( "Gdiplus.dll\GdipDeleteBrush", "Ptr", pBrush )
			DllCall( "Gdiplus.dll\GdipDeleteGraphics", "Ptr", pGraphics )
		; Shutdown GDI+
			DllCall( "Gdiplus.dll\GdiplusShutdown", "Ptr", pToken )
			If ( hGDIP )
				DllCall("FreeLibrary", "Ptr", hGDIP )
		;

		; Set control styles
			Control, Style, -%SS_ICON%, , ahk_id %HWND%
			Control, Style, +%SS_BITMAP%, , ahk_id %HWND%
		; Assign the bitmap
			SendMessage, STM_SETIMAGE, IMAGE_BITMAP, hBitmap, , ahk_id %HWND%
		; Done!
			DllCall( "Gdi32.dll\DeleteObject", "Ptr", hBitmap )
			Return True
	}
	
}
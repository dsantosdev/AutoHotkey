OnMessage(0x0100, "WM_KEYDOWN")
OnMessage(0x0101, "WM_KEYUP")

Gui, +HwndhGui
Gui, Color, 0
Gui, Add, Text, cWhite, Type key to get params:
Gui, Font, s18 w900
Gui, Add, Edit, xm w130 h50 vEdit hWndEdit +Center ReadOnly cRed
Gui, Font, s9 w400



Gui, Add, Text,   xm   y+10        cWhite    , PostMessage Test
Gui, Add, Text,   xm   y+10        cWhite    , Msg:
Gui, Add, Edit,   x+10 yp h18 w50  vsmsg     , 0x100
Gui, Add, Text,   x+10 yp          cWhite    , wParam
Gui, Add, Edit,   x+10 yp h18 w50  vswParam  ,
Gui, Add, Text,   x+10 yp          cWhite    , lParam
Gui, Add, Edit,   x+10 yp h18 w50  vslParam  ,
Gui, Add, Button, x+10 yp h18 cWhite gSend, Send



Gui, Add, Text, xm   y170 cWhite +Border +Center Section w150, WM_KEYDOWN
Gui, Add, Text, xm   y+10 cWhite              , Key pressed:
Gui, Add, Text, x100 yp   cGreen vKey w100    ,
Gui, Add, Text, xm   y+10 cWhite              , wParam:
Gui, Add, Text, x100 yp   cGreen vwParam w100 ,
Gui, Add, Text, xm   y+10 cWhite              , lParam:
Gui, Add, Text, x100 yp   cGreen vlParam w100 ,



Gui, Add, Text, x+10 ys cWhite  +Border +Center w150, WM_KEYUP
Gui, Add, Text, x210 y+10 cWhite              , Key pressed:
Gui, Add, Text, x300 yp   cGreen vKey2 w100   ,
Gui, Add, Text, x210 y+10 cWhite              , wParam:
Gui, Add, Text, x300 yp   cGreen vwParam2 w100,
Gui, Add, Text, x210 y+10 cWhite              , lParam:
Gui, Add, Text, x300 yp   cGreen vlParam2 w100,



Gui, Show, w400 h300, PostMsg
Return

Send() {
   Global hGui

   GuiControlGet, msg   ,, smsg
   GuiControlGet, wParam,, swParam
   GuiControlGet, lParam,, slParam

   PostMessage, %msg%, %wParam%, %lParam%,, ahk_id %hGui%
}

WM_KEYDOWN(wParam, lParam, Msg, Hwnd) {
   Global hGui
   GuiControlGet, Edit, hWnd, Edit

   If (hWnd = Edit) or (hWnd = hGui) {
      wParam2   := Format("{:#x}", wParam)
      Key        = vk%wParam2%
      Key       := GetKeyName(Key)

      GuiControl,, Edit, %Key%
      GuiControl,, Key, %Key%
      GuiControl,, wParam, %wParam%
      GuiControl,, lParam, %lParam%
   }
}

WM_KEYUP(wParam, lParam, Msg, Hwnd) {
   Global hGui
   GuiControlGet, Edit, hWnd, Edit

   If (hWnd = Edit) or (hWnd = hGui) {

      wParam2   := Format("{:#x}", wParam)
      Key        = vk%wParam2%
      Key       := GetKeyName(Key)
      FileAppend, Key: %Key%`n`n,*

      GuiControl,, Key2, %Key%
      GuiControl,, wParam2, %wParam%
      GuiControl,, lParam2, %lParam%
   }
}
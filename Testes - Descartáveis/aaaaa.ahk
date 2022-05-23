Gui, Add, Text,					x10		y10	w50		h20		0x1000	Center							,	DH
Gui, Add, DropDownList,	x90		y10	w50		h20									R20	,	HDC|IPC
Gui, Add, DropDownList,	x150	y10	w50		h20									R20	,	E|EB|EBW|EW|HD|HDB|HDBW|HDEW|HDP|HDPW|HDW|HF|HFS|HFW|HMW|HUM|MDW|MF|MFW
Gui, Add, DropDownList,	x210	y10	w50		h20									R20	,	1|2|3|4|5|7/8|8
Gui, Add, DropDownList,	x270	y10	w50		h20									R20	,	0|1|2|3|5|6|8|12|16|32
Gui, Add, DropDownList,	x330	y10	w50		h20									R20	,	0|1|2|3|4|5|6|7|8|9
Gui, Add, DropDownList,	x390	y10	w50		h20									R20	,	0|1|2|3|9
Gui, Add, DropDownList,	x450	y10	w50		h20									R20	,	B|C|D|E|EM|F|G|H|K|M|R|R1|S|S1|T|T1|TM|X
Gui, Add, DropDownList,	x510	y10	w50		h20									R20	,	N|P
Gui, Add, DropDownList,	x590	y10	w50		h20									R20	,	3D|4G|A|A2|A2|AS|ATC|AW|BV|D2|DAQ|DT|E|F|FD|FR|H|HT|I|IRA|IRE6|Ix|JM|L1/L2/L3/L4/L5|LED|LI|M/M12|ME|MF|N2|NF|NI|PC|PD|PT|PV|S|SA|SDI|SFC|SL|SVAC|T|U|UWB|VF|VM12/HM12|VS|W|WG|Z
Gui, Add, Text,					x10		y40	w630	h330 	0x1000	Center
Gui, Show,  , 	Dahua Models
return

GuiClose:
ExitApp



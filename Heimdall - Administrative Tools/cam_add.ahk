;@Ahk2Exe-SetMainIcon	C:\Seventh\Backup\ico\2LembEdit.ico
/*
BD = MotionDetection
*/
soft=gerenciamento
#IfWinActive,	Inserir Câmeras
#Include	..\Libs\_.ahk
;{	Autenticação
global	user
if(A_UserName!="dsantos")	{
	Autenticar.LoginAD()
	}	else	{
		autenticou=1	
		user=dsantos
	}
	SetTimer,	inicia, 100
	return
	inicia:
		if(InStr(autenticou,"1")=0)	{
			return
		}
		SetTimer,	inicia,	Off	;}
		GuiConfig.Cores("cameras")
		Gui,	cameras:Default
		Gui,	cameras:Font,	Bold cWhite
		Gui,	cameras:Add,	Text,	Section																																		,	IP (APENAS os números)
		Gui,	cameras:Add,	Text,																																						,	Nome da Câmera CONFORME no D-Guard
		Gui,	cameras:Add,	Text,																																						,	Operador
		Gui,	cameras:Add,	Text,																																						,	Sinistro
		Gui,	cameras:Add,	Text,																																						,	Modelo
		Gui,	cameras:Font
		Gui,	cameras:Add,	Edit,						ys-5		w25					vip1		Limit3		Center	Number	gcount1
		Gui,	cameras:Add,	Edit,			xp+30	yp		w25					vip2		Limit3		Center	Number	gcount2
		Gui,	cameras:Add,	Edit,			xp+30	yp		w25					vip3		Limit3		Center	Number	gcount3
		Gui,	cameras:Add,	Edit,			xp+30	yp		w25					vip4		Limit3		Center	Number	gcount4
		Gui,	cameras:Add,	Edit,			xp-90	yp+26	w115				vnome		
		Gui,	cameras:Add,	DropDownList,	R7			w115				voperador	AltSubmit													,	||Operador 1|Operador 2|Operador 3|Operador 4|Operador 5|Facilitador
		Gui,	cameras:Add,	DropDownList,	R8			w115				vsinistro																			,	||Operador 1|Operador 2|Operador 3|Operador 4|Operador 5
		Gui,	cameras:Add,	DropDownList,	R8			w115				vmodelo																			,	||Dahua|Foscam|Hanwha|Hikvision|Intelbras|Samsung|Sony
		Gui,	cameras:Add,	GroupBox,	xm					w510	h115
		Gui,	cameras:Add,	ListView,		xp+5	yp+10	w500	h100						Grid																,	IP|Nome|Operador|Modelo|Sinistro
		Gui,	cameras:Add,	GroupBox,	xs						w500	h40
		Gui,	cameras:Font,	Bold
		Gui,	cameras:Add,	Button,		xp+5	yp+10																					g_Limpa_Campos	,	Limpar Campos
		Gui,	cameras:Add,	Button,		xp+100																							g_Verifica_Insere	,	Inserir
		Gui,	cameras:Font
		Gui, cameras:Show,	, Inserir Câmeras
		LV_ModifyCol(1,100)
		LV_ModifyCol(2,150)
		LV_ModifyCol(3,150)
		LV_ModifyCol(4,75)
	return
	count1:	;{
		Gui,	cameras:Submit,	NoHide
		if(StrLen(ip1)=3)
			GuiControl,	cameras:Focus,	ip2
	return	;}
	count2:	;{
		Gui,	cameras:Submit,	NoHide
		if(StrLen(ip2)=3)
			GuiControl,	cameras:Focus,	ip3
	return	;}
	count3:	;{
		Gui,	cameras:Submit,	NoHide
		if(StrLen(ip3)=3)
			GuiControl,	cameras:Focus,	ip4
	return	;}
	count4:	;{
		Gui,	cameras:Submit,	NoHide
		if(StrLen(ip4)=3)	{
			;~ gosub	buscar_dados
			GuiControl,	cameras:Focus,	nome
		}
	return	;}
	_Limpa_Campos:	;{
		LV_Delete()
		GuiControl,	,	ip1
		GuiControl,	,	ip2
		GuiControl,	,	ip3
		GuiControl,	,	ip4
		GuiControl,	,	nome
		GuiControl,	Choose,	operador,	1
		GuiControl,	Choose,	modelo,	1
		GuiControl,	Choose,	Sinistro,	1
	return
	;}
	_Verifica_Insere:	;{
		Gui,	cameras:Submit,	NoHide
		if(A_UserName!="dsantos")	{
			if(operador=1)	{
				operador=
			}
			else	{
				operador--
			}
			if((StrLen(ip1)=0 or StrLen(ip2)=0 or StrLen(ip3)=0 or StrLen(ip4)=0) or StrLen(nome)=0 or StrLen(modelo)=0 or StrLen(operador)=0 or StrLen(Sinistro)=0)	{
				MsgBox Faltando dados para inserir a câmera.`nVerifique os dados e tente novamente.
				return
			}
		}
		LV_Delete()
		ip:=ip1 "."	ip2 "."	ip3 "."	ip4
		nome:=StrReplace(nome,"|","-")
		Sinistro:=SubStr(Sinistro,-0)
		verifica=SELECT * FROM [MotionDetection].[dbo].[Cameras] WHERE ([ip] = '%ip%' or [nome] = '%nome%') and LEN(nome)>'3'
		executa:=adosql(verifica,3)
		if(executa.Count()-1>0)	{
			Loop,	%	executa.Count()-1
				LV_Add("",executa[A_Index+1,1],executa[A_Index+1,2],"Operador " executa[A_Index+1,6],executa[A_Index+1,8])
			MsgBox Câmera e/ou IP já cadastrado no sistema.`nVerifique na lista.
		}
		else	{
			query=INSERT INTO [MotionDetection].[dbo].[Cameras] ([ip],[nome] ,[Setor],[modelo],[operador],[alteracoes],[em_sinistro]) VALUES ('%ip%','%nome%','%operador%','%modelo%','%user%','Cadastrado Câmera Nova','%Sinistro%')
			adosql(query,3)
			l:="INSERT INTO [ASM].[dbo].[_log_sistema] ([gerado],[software],[ip],[cmp1],[cmp2],[cmp3]) VALUES ('"	agora()	"','Câmera cadastradada','"	A_IPAddress1	"','"	StrReplace(query,"'","```") "','Inserção de Câmera Nova','"	user	"')"
			adosql(l,3)
			exibe=SELECT * FROM [MotionDetection].[dbo].[Cameras] WHERE [ip] like '%ip1%.%ip2%.%ip3%`%'
			executa:=adosql(exibe,3)
			Loop,	%	executa.Count()-1
				LV_Add("",executa[A_Index+1,1],executa[A_Index+1,2],"Operador " executa[A_Index+1,6],executa[A_Index+1,8],executa[A_Index+1,14])
		}
	return
	;}
	up:	;{
	return	;}
	camerasGuiClose:	;{
	ExitApp	;}
$PBExportHeader$w_power_chrome.srw
$PBExportComments$Power Chrome - main page
forward
global type w_power_chrome from window
end type
type st_vbar from statictext within w_power_chrome
end type
type cb_btn6 from picturebutton within w_power_chrome
end type
type pb_run from picturebutton within w_power_chrome
end type
type cb_btn5 from picturebutton within w_power_chrome
end type
type cb_btn4 from picturebutton within w_power_chrome
end type
type cb_btn3 from picturebutton within w_power_chrome
end type
type cb_btn2 from picturebutton within w_power_chrome
end type
type cb_btn1 from picturebutton within w_power_chrome
end type
type st_console from multilineedit within w_power_chrome
end type
type st_status from statictext within w_power_chrome
end type
type wb_main from u_web_browser within w_power_chrome
end type
type st_input from multilineedit within w_power_chrome
end type
end forward

global type w_power_chrome from window
integer width = 4146
integer height = 1956
boolean titlebar = true
boolean controlmenu = true
boolean minbox = true
boolean maxbox = true
boolean resizable = true
windowstate windowstate = maximized!
long backcolor = 67108864
string icon = "ApplicationIcon2!"
boolean center = true
event ue_button ( string as_text )
event type string ue_console ( string as_parm )
event ue_mode ( )
st_vbar st_vbar
cb_btn6 cb_btn6
pb_run pb_run
cb_btn5 cb_btn5
cb_btn4 cb_btn4
cb_btn3 cb_btn3
cb_btn2 cb_btn2
cb_btn1 cb_btn1
st_console st_console
st_status st_status
wb_main wb_main
st_input st_input
end type
global w_power_chrome w_power_chrome

type variables
boolean ib_forceclose = false
string is_result



end variables

event ue_button(string as_text);// special function for mini buttons
if upper(as_text)='BACK' then	
	wb_main.GoBack()
elseif upper(as_text)='FORWARD' then
	wb_main.GoForward()
elseif upper(as_text)='REFRESH' then
	wb_main.refresh()
elseif upper(as_text)='ABOUT' then
	open(w_about)
elseif upper(as_text)='LOGIN' then
	open(w_login)
elseif upper(as_text)='CONSOLE' then
	event ue_console('')
else
	
	wb_main.of_eval_javascript(as_text)
	
end if

end event

event type string ue_console(string as_parm);long i, ll_width
string ls_text = ''
	
// set console visibility
if as_parm = 'hide' then 	
	st_console.visible = false
elseif as_parm = 'show' then 	
	st_console.visible = true	
elseif right(as_parm,2) = 'px' then
	ll_width = long( left(as_parm,len(as_parm) -2) )
	st_console.width = PixelsToUnits( ll_width, XPixelsToUnits! )
	st_console.visible = true	
elseif trim(as_parm)>' ' then
	return wb_main.event ue_message( 'console?' + as_parm )
else	
	st_console.visible = NOT st_console.visible
end if	

// close console
if not st_console.visible then
	st_console.visible = false
	st_input.visible = false
	pb_run.visible = false	
	triggerevent('resize')
	return '0'
end if

// open console	
st_console.visible = true
st_input.visible = true
st_input.setfocus()
pb_run.visible = true
triggerevent('resize')
	
return string( UnitsToPixels( st_console.width, XUnitsToPixels! ) )

end event

on w_power_chrome.create
this.st_vbar=create st_vbar
this.cb_btn6=create cb_btn6
this.pb_run=create pb_run
this.cb_btn5=create cb_btn5
this.cb_btn4=create cb_btn4
this.cb_btn3=create cb_btn3
this.cb_btn2=create cb_btn2
this.cb_btn1=create cb_btn1
this.st_console=create st_console
this.st_status=create st_status
this.wb_main=create wb_main
this.st_input=create st_input
this.Control[]={this.st_vbar,&
this.cb_btn6,&
this.pb_run,&
this.cb_btn5,&
this.cb_btn4,&
this.cb_btn3,&
this.cb_btn2,&
this.cb_btn1,&
this.st_console,&
this.st_status,&
this.wb_main,&
this.st_input}
end on

on w_power_chrome.destroy
destroy(this.st_vbar)
destroy(this.cb_btn6)
destroy(this.pb_run)
destroy(this.cb_btn5)
destroy(this.cb_btn4)
destroy(this.cb_btn3)
destroy(this.cb_btn2)
destroy(this.cb_btn1)
destroy(this.st_console)
destroy(this.st_status)
destroy(this.wb_main)
destroy(this.st_input)
end on

event resize;//  status / microhelp bar
st_status.y = this.height - 230
st_status.width = this.width - 60

// web browser
if st_status.visible then
	wb_main.height = this.height - st_status.height - 150
else
	wb_main.height = this.height - 120
end if

wb_main.width = this.width - 80

// handle buttons in statusbar
cb_btn6.move( this.width - 730, st_status.y - 10 )
cb_btn5.move( this.width - 620, st_status.y - 10 )
cb_btn4.move( this.width - 510, st_status.y - 10 )
cb_btn3.move( this.width - 400, st_status.y - 10 )
cb_btn2.move( this.width - 290, st_status.y - 10 )
cb_btn1.move( this.width - 180, st_status.y - 10 )

// handle console if visible
if st_console.visible then
	pb_run.x = this.width - 200
	st_console.x = this.width - st_console.width - 64
	st_console.height = wb_main.height - 160
	st_input.x = st_console.x
	st_input.width = st_console.width - 150
	st_input.selecttext( 1, 999 )
	wb_main.width = this.width - st_console.width - 94
end if

// vertical bar 
st_vbar.move( st_console.x - 12, st_console.y )
st_vbar.resize( 12, st_console.height )
st_vbar.visible = st_console.visible
end event

event open;//# Main screen of PowerChrome. 
//#
//# 2022/11/07: Revise from Powerpage.w_power_page
//#=========================================================

this.icon = profilestring(gnv_app.is_ini, 'system', 'icon', '' )

st_status.backcolor = long(profilestring(gnv_app.is_ini, 'browser', 'status.backcolor', '67108864' ))
st_status.textcolor = long(profilestring(gnv_app.is_ini, 'browser', 'status.textcolor', '0' ))

string ls_xpos, ls_ypos, ls_width, ls_height, ls_value

// position, size
ls_xpos = profilestring(gnv_app.is_ini, 'browser', 'left', '' )
ls_ypos = profilestring(gnv_app.is_ini, 'browser', 'top', '' )
ls_width = profilestring(gnv_app.is_ini, 'browser', 'width', '' )
ls_height = profilestring(gnv_app.is_ini, 'browser', 'height', '' )

if ls_xpos>'' then this.x = PixelsToUnits ( long(ls_xpos), XPixelsToUnits! )
if ls_ypos>'' then this.y = PixelsToUnits ( long(ls_ypos), YPixelsToUnits! )

if ls_width>'' then 
	this.WindowState = normal!
	this.width = PixelsToUnits ( long(ls_width), XPixelsToUnits! )
end if

if ls_height>'' then 
	this.WindowState = normal!
	this.height = PixelsToUnits ( long(ls_height), YPixelsToUnits! )
end if

// if set xpos/ypos, then donot center window
if ls_xpos>'' or ls_ypos>'' then this.center=false

// set console
ls_value = profilestring(gnv_app.is_ini, 'system', 'console', '' )
if ls_value>'' then event ue_console(ls_value)

// go to url
gnv_app.of_watch( '[debug]', 'stringparm=' + message.stringparm )
wb_main.navigate( gnv_app.of_url_format(message.stringparm) ) 



end event

event closequery;//# call html.event onPageClose() before close
//#
//# 	[no, false]: stop closing window
//# 	[yes, true]: close immediatelly
//# 	[message]: prompt message for confirmation
//#==========================================================================
if ib_forceclose then return

is_result = wb_main.of_eval_javascript('onPageClose()')

// if return no/false, stop closing window
if is_result = 'no' or is_result = 'false' then
	
	return 1
	
// if NOT return 'yes/true', show as message for confirmation
elseif is_result<> 'yes' and is_result<>'true' and is_result>' ' then
	
	if messagebox( this.title, is_result, question!, yesno! ) = 2 then
		return 1
	end if
	
end if

end event

type st_vbar from statictext within w_power_chrome
event ue_lbuttondown pbm_lbuttondown
event ue_lbuttonup pbm_lbuttonup
event ue_mousemove pbm_mousemove
integer x = 2437
integer y = 992
integer width = 110
integer height = 296
integer textsize = -12
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string pointer = "SizeWE!"
long textcolor = 33554432
long backcolor = 67108864
boolean focusrectangle = false
end type

event ue_lbuttondown;
this.border = true

end event

event ue_lbuttonup;
this.border = false

end event

event ue_mousemove;// register mouse position
if not this.border then return

// move and resize controls
this.x += xpos

wb_main.width += xpos

st_console.x 	  += xpos
st_console.width -= xpos

st_input.x 	  	  += xpos
st_input.width	  -= xpos


end event

type cb_btn6 from picturebutton within w_power_chrome
boolean visible = false
integer x = 2757
integer y = 1500
integer width = 110
integer height = 96
integer taborder = 80
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
boolean flatstyle = true
boolean originalsize = true
boolean map3dcolors = true
string powertiptext = "Console"
end type

type pb_run from picturebutton within w_power_chrome
boolean visible = false
integer x = 3982
integer y = 16
integer width = 110
integer height = 96
integer taborder = 80
integer textsize = -12
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
boolean default = true
boolean flatstyle = true
boolean originalsize = true
string picturename = "Run1!"
alignment htextalign = left!
boolean map3dcolors = true
string powertiptext = "Console"
end type

event clicked;string ls_result, ls_text
long	ll_root, i

// clear console content
if lower(trim(st_input.text)) = 'clear' then
	st_console.text = ''
	return
end if

// load microhelp hisotry
if lower(trim(st_input.text)) = 'history' then
	for i = 1 to gnv_app.ii_microcount
		ls_text += gnv_app.is_microhelp[i] + '~r~n'
	next
	st_console.text = ls_text
	return
end if

// execute input expression
gnv_app.of_console('~r~n>> ' + st_input.text )

ls_result = wb_main.of_eval_javascript( 'JSON.stringify(' + st_input.text + ')' )

gnv_app.of_console('~r~n=> ' + gnv_app.of_default(ls_result,'null') )

st_input.selecttext( 1, 999 )
st_input.setfocus()


end event

type cb_btn5 from picturebutton within w_power_chrome
string tag = "console"
boolean visible = false
integer x = 2907
integer y = 1504
integer width = 110
integer height = 96
integer taborder = 70
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
boolean flatstyle = true
boolean originalsize = true
boolean map3dcolors = true
string powertiptext = "Console"
end type

event clicked;parent.event ue_button(this.tag)
end event

type cb_btn4 from picturebutton within w_power_chrome
string tag = "edit"
boolean visible = false
integer x = 3040
integer y = 1504
integer width = 110
integer height = 96
integer taborder = 60
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
boolean flatstyle = true
boolean originalsize = true
boolean map3dcolors = true
string powertiptext = "Edit"
end type

event clicked;parent.event ue_button(this.tag)
end event

type cb_btn3 from picturebutton within w_power_chrome
boolean visible = false
integer x = 3173
integer y = 1500
integer width = 110
integer height = 96
integer taborder = 50
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
boolean flatstyle = true
boolean originalsize = true
string picturename = "Synchronizer1!"
boolean map3dcolors = true
string powertiptext = "Refresh"
end type

event clicked;parent.event ue_button(this.tag)
end event

type cb_btn2 from picturebutton within w_power_chrome
boolean visible = false
integer x = 3310
integer y = 1500
integer width = 110
integer height = 96
integer taborder = 40
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
boolean flatstyle = true
boolean originalsize = true
string picturename = "Prior3!"
boolean map3dcolors = true
string powertiptext = "Back"
end type

event clicked;parent.event ue_button(this.tag)
end event

type cb_btn1 from picturebutton within w_power_chrome
string tag = "about"
boolean visible = false
integer x = 3438
integer y = 1504
integer width = 110
integer height = 96
integer taborder = 30
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
boolean flatstyle = true
boolean originalsize = true
string picturename = "Uncomment!"
boolean map3dcolors = true
string powertiptext = "About"
end type

event clicked;parent.event ue_button(this.tag)
end event

type st_console from multilineedit within w_power_chrome
boolean visible = false
integer x = 2263
integer y = 140
integer width = 1815
integer height = 756
integer taborder = 20
integer textsize = -10
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
boolean vscrollbar = true
borderstyle borderstyle = stylelowered!
end type

type st_status from statictext within w_power_chrome
integer x = 18
integer y = 1516
integer width = 2848
integer height = 76
integer textsize = -10
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 134217752
string text = "none"
boolean focusrectangle = false
end type

type wb_main from u_web_browser within w_power_chrome
integer x = 14
integer width = 2235
integer height = 1268
end type

event titletextchanged;call super::titletextchanged;parent.title = titletext
end event

event pdfprintfinished;call super::pdfprintfinished;//if gnv_app.is_app_mode = 'save' then close(parent)
end event

event ue_unknown;//# Handle unknown commands. 
//#=======================================================================

gnv_app.of_watch( '[api]', 'ext-command=' +as_cmd )

is_command = as_cmd
is_action = lower( of_gettoken( as_cmd, '?' ) )
as_cmd = trim(as_cmd)

//## [window position] position?top=&left=&width=&height='
if is_action = 'position' then
	
   if lower(as_cmd)='max' or lower(as_cmd)='maximized' then
	   parent.windowstate = maximized!
	else	
		parent.windowstate = normal!
		parent.x = PixelsToUnits ( long(of_get_parm(as_cmd,'left',is_null)), XPixelsToUnits! )
		parent.y = PixelsToUnits ( long(of_get_parm(as_cmd,'top',is_null)), YPixelsToUnits! )
		parent.width = PixelsToUnits ( long(of_get_parm(as_cmd,'width',is_null)), XPixelsToUnits! )
		parent.height = PixelsToUnits ( long(of_get_parm(as_cmd,'height',is_null)), YPixelsToUnits! )
	end if
	
	return as_cmd
	
end if

//## [close window] close
if is_action = 'close' then 
	ib_forceclose = true
	close(parent)
   return ''
end if

//### [mini buttons] minibutton?clear
if is_action = 'minibutton' then
	
	if lower(as_cmd) = 'clear' then
		cb_btn1.visible = false
		cb_btn2.visible = false
		cb_btn3.visible = false
		cb_btn4.visible = false
		cb_btn5.visible = false
		cb_btn6.visible = false
		return 'clear'
	end if
	
	picturebutton lpb_mini
	
	if not cb_btn1.visible then
		lpb_mini = cb_btn1
	elseif not cb_btn2.visible then
		lpb_mini = cb_btn2
	elseif not cb_btn3.visible then
		lpb_mini = cb_btn3
	elseif not cb_btn4.visible then
		lpb_mini = cb_btn4
	elseif not cb_btn5.visible then
		lpb_mini = cb_btn5
	elseif not cb_btn6.visible then
		lpb_mini = cb_btn6
	else
		return ''
	end if
	
	lpb_mini.visible = true
	lpb_mini.picturename = of_get_parm( as_cmd, 'icon', '' )
	lpb_mini.powertiptext = of_get_parm( as_cmd, 'title', '' )
	lpb_mini.tag = of_get_parm( as_cmd, 'script', '' )
	return lpb_mini.tag

end if

//### [window console] console?open|show|hide|close|toggle|999px
if is_action = 'console' then return parent.event ue_console(as_cmd)

//### [secret key] secret?keystring
if is_action = 'secret' then return gnv_app.of_encryption(as_cmd)




//### prompt for unknown command 
messagebox( 'warning', 'unknown command: ' + is_command )

return '-1'

end event

event ue_pageready;call super::ue_pageready;// normal mode, call window.onPageReady()
wb_main.of_eval_javascript('onPageReady()')


end event

type st_input from multilineedit within w_power_chrome
boolean visible = false
integer x = 2263
integer y = 8
integer width = 1705
integer height = 108
integer taborder = 10
integer textsize = -10
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
string text = "clear"
boolean autohscroll = true
borderstyle borderstyle = stylelowered!
end type


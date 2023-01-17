$PBExportHeader$w_power_kiosk.srw
$PBExportComments$Power Chrome - Fullscreen, kiosk mode
forward
global type w_power_kiosk from window
end type
type wb_main from u_web_browser within w_power_kiosk
end type
end forward

global type w_power_kiosk from window
integer width = 2441
integer height = 1436
boolean border = false
windowtype windowtype = popup!
windowstate windowstate = maximized!
long backcolor = 67108864
string icon = "AppIcon!"
integer animationtime = 100
wb_main wb_main
end type
global w_power_kiosk w_power_kiosk

on w_power_kiosk.create
this.wb_main=create wb_main
this.Control[]={this.wb_main}
end on

on w_power_kiosk.destroy
destroy(this.wb_main)
end on

event open;//# PowerChrome - fullscreen, kiosk mode
//#=========================================================

gnv_app.of_watch( '[debug]', 'stringparm=' + message.stringparm )

wb_main.navigate( gnv_app.of_url_format(message.stringparm) ) 



end event

event resize;
wb_main.move( 0, 0 )

wb_main.width  = this.width - 2
wb_main.height = this.height - 2
end event

type wb_main from u_web_browser within w_power_kiosk
integer x = 41
integer y = 44
integer width = 1339
integer height = 932
boolean popupwindow = false
boolean contextmenu = false
boolean border = false
borderstyle borderstyle = StyleBox!
end type

event ue_pageready;call super::ue_pageready;// normal mode, call window.onPageReady()
wb_main.of_eval_javascript('onPageReady()')


end event


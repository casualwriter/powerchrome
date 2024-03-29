$PBExportHeader$w_power_dialog.srw
$PBExportComments$Power Chrome - dialog with multi-functions
forward
global type w_power_dialog from window
end type
type wb_dialog from u_web_browser within w_power_dialog
end type
end forward

global type w_power_dialog from window
integer width = 3776
integer height = 1776
boolean titlebar = true
boolean controlmenu = true
windowtype windowtype = response!
long backcolor = 67108864
string icon = "AppIcon!"
boolean center = true
wb_dialog wb_dialog
end type
global w_power_dialog w_power_dialog

type variables
string  is_url, is_mode, is_select, is_file, is_return, is_script
integer ii_delay
end variables

on w_power_dialog.create
this.wb_dialog=create wb_dialog
this.Control[]={this.wb_dialog}
end on

on w_power_dialog.destroy
destroy(this.wb_dialog)
end on

event resize;wb_dialog.move ( 4, 4 )
wb_dialog.height = newheight - 8
wb_dialog.width = newwidth - 8


end event

event open;//# Open web page in dialog, for multiple purpose
//#
//#  1. Open url by parameter. //url=?&top=80&left=200&width=1024&height=700
//#  2. save url to pdf file   //url=?&save={output.pdf}&mode={hide}
//#  3. save url to html file  //url=?&save={output.html}&select={css}&delay={ms}
//#  4. return selected html   //url={link}&select={css}&delay={ms}&mode={hide}
//#  5. import js file         //url={link}&import={lib.js}&mode={hide}
//#  6. inject javascript      //url={link}&script={javascript}
//#
//# Log: 
//#   2022/11/24, basic features
//#   2022/11/25, support mode=hide|min|max, import={lib.js}, script={javascript}
//#=========================================================================================

string ls_silent, ls_xpos, ls_ypos, ls_width, ls_height, ls_url, ls_import
long ll_file

gnv_app.of_watch( '[api]', 'w_power_dialog: ' + message.stringparm)

// get parameters
is_url    = wb_dialog.of_get_parm( message.stringparm, 'url', '' )
is_mode   = wb_dialog.of_get_parm( message.stringparm, 'mode', '' )
is_file   = wb_dialog.of_get_parm( message.stringparm, 'save', '' )
is_select = wb_dialog.of_get_parm( message.stringparm, 'select', '' )
ii_delay  = long(wb_dialog.of_get_parm( message.stringparm, 'delay', '100' ) )

// handle import js file, or inject javascript
is_script = wb_dialog.of_get_parm( message.stringparm, 'script', '' )
ls_import = wb_dialog.of_get_parm( message.stringparm, 'import', '' )

if ls_import>' ' then
	ll_file = fileopen( ls_import, TextMode!, Read! )
	
	if ll_file > 0 then
		filereadex( ll_file, is_script )
		fileclose(ll_file)
	end if
end if	

// position, size
if is_mode = 'min' then
	this.windowState = minimized!
elseif is_mode = 'max' then
	this.windowState = maximized!	
elseif is_mode = 'hide' and is_file>' ' then
	this.visible = false
end if

ls_xpos   = wb_dialog.of_get_parm( message.stringparm, 'left', '' )
ls_ypos   = wb_dialog.of_get_parm( message.stringparm, 'top', '' )
ls_width  = wb_dialog.of_get_parm( message.stringparm, 'width', '' )
ls_height = wb_dialog.of_get_parm( message.stringparm, 'height', '' )
	
if ls_xpos>' ' then this.x = PixelsToUnits ( long(ls_xpos), XPixelsToUnits! )
if ls_ypos>' ' then this.y = PixelsToUnits ( long(ls_ypos), YPixelsToUnits! )
if ls_width>' ' then this.width = PixelsToUnits ( long(ls_width), XPixelsToUnits! )
if ls_height>' ' then this.height = PixelsToUnits ( long(ls_height), YPixelsToUnits! )

this.center = (ls_xpos='' and ls_ypos='')

// go to url
gnv_app.of_watch( '[debug]', 'url=' + is_url +', mode=' + is_mode )

if pos(is_url,'~n') > 0 then
	wb_dialog.navigate( 'about:blank#' ) 
else	
	wb_dialog.navigate( gnv_app.of_url_format(is_url) ) 
end if


end event

type wb_dialog from u_web_browser within w_power_dialog
integer x = 480
integer y = 188
integer width = 2619
integer height = 1200
boolean popupwindow = false
boolean contextmenu = false
borderstyle borderstyle = stylebox!
end type

event titletextchanged;call super::titletextchanged;parent.title = titletext
end event

event ue_pageready;call super::ue_pageready;string ls_html
long   ll_file, ll_rtn

// save to PDF file
if lower(right(is_file,4)) =  '.pdf' then

	this.of_sleepms( ii_delay )

	if long(event ue_interface( 'saveas?' + is_file )) < 0 then
		closewithreturn( parent, '[error] save to ' + is_file + ' failed!' )
	end if
	
	return
	
end if

// save to html file.
if is_file > ' ' then
	
	this.of_sleepms( ii_delay )
	
	ls_html = this.of_eval_javascript( 'pb.html("' + is_select + '")' )
	
	ll_file = fileopen( is_file, TextMode!, Write!, LockReadWrite!, Replace!, EncodingUTF8! )
	ll_rtn  = filewriteex( ll_file, ls_html )
	fileclose(ll_file)
	
	closewithreturn(parent, is_file )
	return
	
// select html source
elseif is_select > ' ' then
	
	this.of_sleepms( ii_delay )
	
	ls_html = this.of_eval_javascript( 'pb.html("' + is_select + '")' )
	
	closewithreturn(parent, ls_html )
	return
	
end if	
	
// render HTML if url is html code (multiple line)
if pos( is_url, '~n' ) > 0 then
	ls_html = gnv_app.of_replaceall( gnv_app.of_replaceall( is_url, "'", "\'" ), '~n', '\n' )
	gnv_app.of_microhelp( "document.body.innerHTML = '" + ls_html + '"' )
	wb_dialog.EvaluateJavascriptSync( "document.body.innerHTML = '" + ls_html + "' " )
end if

// normal mode, execute javascript
if is_script> ' ' then
	wb_dialog.EvaluateJavascriptSync(is_script)
end if	

// normal mode, call window.onPageReady()
wb_dialog.EvaluateJavascriptSync('onPageReady()')

end event

event pdfprintfinished;call super::pdfprintfinished;// close if save to pdf
if lower(right(is_file,4))='.pdf' then 
	closewithreturn(parent, is_file )
end if
end event

event ue_unknown;string ls_xpos, ls_ypos, ls_width, ls_height

gnv_app.of_watch( '[api]', 'ext-command=' +as_cmd )

is_command = as_cmd
is_action = lower( of_gettoken( as_cmd, '?' ) )
as_cmd = trim(as_cmd)

//## [window position] position?top=&left=&width=&height='
if is_action = 'position' then
	
   if lower(as_cmd)='max' or lower(as_cmd)='maximized' then
	   parent.windowstate = maximized!
		return as_cmd
	end if
	
	ls_xpos = of_get_parm(as_cmd,'left',is_null)
	ls_ypos = of_get_parm(as_cmd,'top',is_null)
	ls_width = of_get_parm(as_cmd,'width',is_null)
	ls_height = of_get_parm(as_cmd,'height',is_null)
	
	parent.x = PixelsToUnits ( long(ls_xpos), XPixelsToUnits! )
	parent.y = PixelsToUnits ( long(ls_ypos), YPixelsToUnits! )
	parent.width = PixelsToUnits ( long(ls_width), XPixelsToUnits! )
	parent.height = PixelsToUnits ( long(ls_height), YPixelsToUnits! )
	
	parent.center = ( isnull(ls_xpos) and isnull(ls_ypos) )
	parent.windowstate = normal!
	
	return as_cmd	
	
end if

//## [close window] close?returnString
if is_action = 'close' then
	if as_cmd>'' then 
		closewithreturn(parent, as_cmd)
	else	 
		close(parent)
	end if
	return 'dialog closed'
end if


end event

event navigationprogressindex;// initial interface (execute powerchrome.js) when page loaded
string ls_result, ls_error
long ll_rtn

if progressindex = 100 and is_current_url <> is_ready_url then

	this.RegisterEvent ( 'ue_interface' ) 
	this.RegisterEvent ( 'ue_message' ) 

	is_ready_url = is_current_url
  
	ll_rtn = this.EvaluateJavascriptSync ( gnv_app.is_api_script, ls_result, ls_error ) 
	
	if ll_rtn > 0 then
		gnv_app.of_microhelp( 'interface ready. ' + of_json_value(ls_result) )
	else
		gnv_app.of_microhelp( 'load interface failed. rtn='+ string(ll_rtn) + ', err=' + ls_error )
	end if
	
	post event ue_pageready()
	
end if





end event


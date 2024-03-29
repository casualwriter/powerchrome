$PBExportHeader$u_web_browser.sru
$PBExportComments$ancester of web-browser object (CEF)
forward
global type u_web_browser from webbrowser
end type
end forward

global type u_web_browser from webbrowser
integer width = 2094
integer height = 1288
boolean popupwindow = false
event type string ue_database ( string as_cmd )
event type string ue_filesystem ( string as_cmd )
event type string ue_interface ( string as_cmd )
event type string ue_message ( string as_msg )
event type string ue_httprequest ( string as_cmd )
event type string ue_shell ( string as_cmd )
event type string ue_unknown ( string as_cmd )
event ue_pageready ( )
end type
global u_web_browser u_web_browser

type prototypes
FUNCTION boolean SetForegroundWindow( long hWnd ) LIBRARY "USER32"
FUNCTION boolean SetCursorPos(int cx, int cy)  LIBRARY "User32.dll"

FUNCTION long ShellExecute (long hwnd, string lpOperation, string lpFile, string lpParameters,  string lpDirectory, integer nShowCmd ) LIBRARY "shell32" ALIAS FOR ShellExecuteW



end prototypes

type variables
OleObject  iole_wsh
CoderObject inv_coder
JsonParser inv_JsonParser
HttpClient inv_HttpClient

string is_ready_url = 'about:blank'
string is_command, is_callback, is_action, is_null
string is_title, is_current_url


end variables

forward prototypes
public function string of_eval_javascript (string as_script)
public function string of_gettoken (ref string as_parm, string as_token)
public function string of_get_keyword (string as_text, string as_key, string as_delim, string as_default)
public function string of_replaceall (string as_text, string as_old, string as_new)
public function integer of_wsh_run (string as_run, integer ai_opt, boolean ab_wait)
public function string of_default (string as_string, string as_default)
public function string of_get_parm (string as_url, string as_name, string as_default)
public function integer of_sendkeys (string as_keys)
public function boolean of_db_connect (integer ai_retry)
public function string of_db_query (string as_sql)
public function string of_property (string as_cmd)
public function string of_session (string as_cmd)
public function string of_get_set_ppty (string as_action, ref string as_ppty, string as_value)
public function string of_db_table (string as_sql)
public function string of_db_execute (string as_sql)
public function integer of_sleepms (integer ai_ms)
public function string of_json_value (string as_result)
public function string of_str_format (string as_str)
end prototypes

event type string ue_database(string as_cmd);//#================================================================================
//# database interface (connect db, commit, rollback, query, execute, etc..)
//#
//# log
//# 	2022/11/15, ck, handle database interface. rewrite
//#================================================================================

string ls_parm, ls_sql

is_action = lower( of_gettoken( as_cmd, '?' ) )

//### db-select?sql
if is_action = 'db-select'  or is_action = 'db-query'  then
	gnv_app.of_watch( '[sql]', 'query sql=' + as_cmd )
	return of_db_query( as_cmd )
elseif is_action = 'db-table'  then
	gnv_app.of_watch( '[sql]', 'table sql=' + as_cmd )
	return of_db_table( as_cmd )
elseif is_action = 'db-execute'  then
	gnv_app.of_watch( '[sql]', 'execute sql=' + as_cmd )
	return of_db_execute( as_cmd )
end if
	

//### db-connect?dbms=&servername=&logid=&logpass=&dbparm=
if is_action = 'db-connect'  then
	sqlca.DBMS 			= upper( of_get_parm( as_cmd, 'dbms', 'ODBC' ) )
	sqlca.ServerName 	= gnv_app.of_get_string( of_get_parm( as_cmd, 'servername', '' ) )
	sqlca.LogId 		= gnv_app.of_get_string( of_get_parm( as_cmd, 'logid', '' ) )
	sqlca.LogPass 		= gnv_app.of_get_string( of_get_parm( as_cmd, 'logpass', '' ) )
	sqlca.DBParm 		= gnv_app.of_get_string( of_get_parm( as_cmd, 'dbparm', '' ) )
	sqlca.autocommit	= FALSE
   gnv_app.of_watch( '[debug]', sqlca.DBMS + ': ' + sqlca.ServerName )
	
	DISCONNECT USING SQLCA;
   CONNECT USING SQLCA;

	return '{ "status":'+string(sqlca.sqlcode) + ', "dbHandle":'+string(sqlca.dbhandle()) + &
	       ', "sqlerrtext":"' + of_str_format(sqlca.sqlerrtext) + '" }'

end if

//### db-disconnect, db-beconnect, db-commit, db-rollback
if is_action = 'db-disconnect'  then
   DISCONNECT USING SQLCA;
elseif is_action = 'db-beconnect'  then
	if sqlca.dbhandle()<=0 then 
	   CONNECT USING SQLCA;
	end if	
elseif is_action = 'db-commit'  then
   COMMIT USING SQLCA;
elseif is_action = 'db-rollback'  then
   ROLLBACK USING SQLCA;
else
	return '[error] unknown database command: '+is_command
end if

return '{ "status":'+string(sqlca.sqlcode) + ', "dbHandle":'+string(sqlca.dbhandle()) + &
       ', "sqlerrtext":"' + of_str_format(sqlca.sqlerrtext) + '" }'


end event

event type string ue_filesystem(string as_cmd);//#========================================================================
//# file-exists?{filename}
//# file-read?{filename}
//# file-append?name={FileName}&text={text}
//# file-write?name={FileName}&text={text}
//#
//# log
//# 	2022/11/10, ck, handle interface command for filesystem
//#========================================================================

is_action = lower( of_gettoken( as_cmd, '?' ) )

// file function support
long ll_file, ll_rtn
string ls_result, ls_name, ls_text, ls_path, ls_file, ls_filter

//### file-exists?{filename}
if is_action = 'file-exists' then
	if fileexists( of_get_parm( as_cmd, 'name', as_cmd ) ) then
		return 'true'
	else
		return 'false'
	end if
end if

//### file-read?{filename}
if is_action = 'file-read' then
	ls_name = of_get_parm( as_cmd, 'name', as_cmd )
	ll_file = fileopen( ls_name, TextMode!, Read! )
	if ll_file<=0 then return ''
	
	filereadex( ll_file, ls_result )
	fileclose(ll_file)
	return ls_result	
end if

//### file-append?name={FileName}&text={text}
//### file-write?name={FileName}&text={text}
if is_action='file-append' or is_action='file-write' then
	
	ls_name = of_get_parm( as_cmd, 'name', is_null )
	ls_text = of_get_parm( as_cmd, 'text', '' )
	
	if is_action='file-write' then
		//filedelete(ls_name)
		ll_file = fileopen( ls_name, TextMode!, Write!, LockReadWrite!, Replace!, EncodingUTF8! )
	else
		ll_file = fileopen( ls_name, TextMode!, Write!, LockReadWrite!, Append! )
	end if
	
	if ll_file<=0 then string(ll_file)
	
	if filewriteex( ll_file, ls_text ) < 0 then
		fileclose(ll_file)
		return '{ "status": -1, "message":"failed to write file ' + of_replaceall(ls_name,'\','\\') + '" } '
	end if
	
	fileclose(ll_file)
	return string(len(ls_text))

end if

//## file-delete?{FileName}
if is_action = 'file-delete' then
	if filedelete( of_get_parm( as_cmd, 'name', as_cmd ) ) then
		return  'true'
	else
		return 'false'
	end if
end if

//## file-move?source={FileName}&target={targetFile}
if is_action='file-move' then
	ls_name = of_get_parm( as_cmd, 'source', '' )
	ls_text = of_get_parm( as_cmd, 'target', '' )	
	return string( FileMove ( ls_name, ls_text ) )
end if

//## file-copy?source={FileName}&target={targetFile}
if is_action = 'file-copy' then
	ls_name = of_get_parm( as_cmd, 'source', '' )
	ls_text = of_get_parm( as_cmd, 'target', '' )	
	return string( FileCopy ( ls_name, ls_text, true ) )
end if


//## file-save-dialog?ext={extension}&path={folder}&title={title}
if is_action='file-save-dialog' then
	
	ls_text = of_get_parm( as_cmd, 'title', 'Save File' )	
	ls_path = of_get_parm( as_cmd, 'path', '' )	
	ls_filter = of_get_parm( as_cmd, 'filter', '' )
	ll_rtn = GetFileSaveName ( ls_text, ls_path, ls_file, '', ls_filter )
	
	if ll_rtn > 0 then 
		return of_replaceall( '{ "status": 1, "path":"' + ls_path + '", "file":"' + ls_file + '" } ', '\', '\\' )
	else
		return '{ "status": ' + of_default(string(ll_rtn),'null') + ' } '
	end if
	
end if		

//## file-open-dialog?ext={extension}&path={folder}&title={title}
if is_action='file-open-dialog' then
	
	ls_text = of_get_parm( as_cmd, 'title', 'Save File' )	
	ls_path = of_get_parm( as_cmd, 'path', '' )	
	ls_filter  = of_get_parm( as_cmd, 'filter', '' )
	ll_rtn = GetFileOpenName ( ls_text, ls_path, ls_file, '', ls_filter )
	
	if ll_rtn >0 then 
		return of_replaceall( '{ "status": 1, "path":"' + ls_path + '", "file":"' + ls_file + '" } ', '\', '\\' )
	else
		return '{ "status": ' + of_default(string(ll_rtn),'null') + ' } '
	end if
	
end if	

//## folder/directory functions
if is_action = 'dir-current' then
	return GetCurrentDirectory()
elseif is_action = 'dir-exists' then 
	if DirectoryExists (as_cmd) then return 'true' else return 'false'
elseif is_action = 'dir-change' then 
	ll_rtn = ChangeDirectory(as_cmd)
	return GetCurrentDirectory()
elseif is_action = 'dir-select' then
	ll_rtn = GetFolder ( as_cmd, ls_path )
	return of_default(ls_path, 'null')
elseif is_action = 'dir-create' then
	return string( createDirectory(as_cmd) )
elseif is_action='dir-delete' then
	return string( RemoveDirectory(as_cmd) )
end if

messagebox( 'warning', 'unknown file command: ' + as_cmd )

return of_replaceall( '{ "status":-1, "message":"unknown file command ' + as_cmd + '" }', '\', '\\' )


end event

event type string ue_interface(string as_cmd);//# WebBrowser Interface,  interpret command string, by the systax 
//# 	command := {action}?parameter
//# 	command := name1=parm1&name2=parm2
//#=====================================================================================
string ls_parm, ls_name, ls_result
long 	ll_rtn, ll_file
window lw_win

//## handle interface command
gnv_app.of_watch( '[api]', 'command=' +as_cmd )

is_command = as_cmd
is_action = lower( of_gettoken( as_cmd, '?' ) )
as_cmd = trim(as_cmd)

//## route to related event ue_database / ue_filesystem
if left(is_action,3)='db-' then return event ue_database(is_command)
if left(is_action,4)='dir-' then return event ue_filesystem(is_command)
if left(is_action,5)='file-' then return event ue_filesystem(is_command)
if left(is_action,5)='http-' then return event ue_httprequest(is_command)
if is_action='run' then return event ue_shell(is_command)
if is_action='shell' then return event ue_shell(is_command)
if is_action='sendkeys' then return event ue_shell(is_command)
	
//## [get/set property] property?name=value
if is_action = 'property' then return of_property(as_cmd)
if is_action = 'session' then	return of_session(as_cmd)

// [sleep in ms] sleep?2500
if is_action = 'sleep' then return string(of_sleepms(integer(as_cmd)))

//### [Open PowerDialog] popup?url={link}&width=1024&height=768&save={output.html}&select={css}
if is_action = 'popup' then
   openwithparm( w_power_dialog, as_cmd )
	return message.stringparm
end if

//## [print web page] print, printsetup
if is_action = 'print' then 
	return string( this.print() )
elseif is_action = 'printsetup' then
	return string( printsetup() )
end if

// save as PDF / HTML
if is_action = 'saveas' then

	ls_name = of_get_parm( as_cmd, 'file', as_cmd )
	
	if right(lower(as_cmd), 4) = '.pdf' then
		return string( PrintAsPDF(ls_name) )
	end if
	
	ll_file = fileopen( ls_name, LineMode!, Write!, LockWrite!, Replace!, EncodingUTF8! )
	
	if ll_file <= 0 then 
		return '[error] Cannot open file ' + ls_name
	else
		ll_rtn = filewriteex( ll_file, this.GetSource() )
		fileclose(ll_file)
		return string(ll_rtn)
	end if
	
end if

//## [call pb response window] window?name=winName&parm=?
if is_action = 'window' then
	
	ls_name = of_get_parm( as_cmd, 'name', is_null )
	ls_parm = of_get_parm( as_cmd, 'parm', is_null )
	setnull(message.stringparm)
	
	gnv_app.of_watch( '[debug]', 'window='+ls_name + ', parm=' + of_default(ls_parm,'null') )
	
	if trim(ls_parm)>'' then
		ll_rtn = openwithparm( lw_win, ls_parm, ls_name )	
	elseif isnull(ls_name) then 		
		ll_rtn = open( lw_win, as_cmd )	// cater window?winName
	else	
		ll_rtn = open( lw_win, ls_name )	
	end if
	
	if message.stringparm > '' then
		return message.stringparm
	else
		return string(ll_rtn)
	end if
	
end if

//## [call pb extent function] function?name={funcName}&parm={parameter}
if is_action = 'extfunc' then
	
	ls_name = of_get_parm( as_cmd, 'name', is_null )
	ls_parm = of_get_parm( as_cmd, 'parm', is_null )
	
	TRY	
		ls_result = dynamic f_extfunc(ls_name, ls_parm)
	CATCH (runtimeerror er)
		ls_result = '{ "status":-1, "message":"failed to call function ' + ls_name + '(), ' + er.text + '" }'
	END TRY	
	
	return ls_result
	
end if


// route to event ue_unkown() for further handling
return event ue_unknown(is_command)





end event

event type string ue_message(string as_msg);string ls_type, ls_opt, ls_title, ls_text

ls_type = lower( of_gettoken( as_msg, '?' ) )

//### message box
if ls_type = 'msgbox' then
	
	ls_opt = lower(of_get_parm( as_msg, 'options', 'ok' ))
	ls_title =  of_get_parm( as_msg, 'title', is_title )
	ls_text = of_get_parm( as_msg, 'text', as_msg )
	
	if ls_opt = 'yn' or ls_opt = 'yes,no' then
		return string( messagebox( ls_title, ls_text, question!, YesNo!, 1 ) )
	elseif ls_opt = 'ync' or ls_opt = 'yes,no,cancel' then
		return string( messagebox( ls_title, ls_text, question!, YesNoCancel! ) )
	elseif ls_opt = 'oc' or ls_opt = 'ok,cancel' then
		return string( messagebox( ls_title, ls_text, question!, OKCancel! ) )
	elseif ls_opt = 'rc' or ls_opt = 'retry,cancel' then
		return string( messagebox( ls_title, ls_text, Exclamation!, RetryCancel! ) )
	elseif ls_opt = 'arc' or ls_opt = 'abort,retry,cancel' then
		return string( messagebox( ls_title, ls_text, Exclamation!, AbortRetryIgnore! ) )
	else
		return string( messagebox( ls_title, ls_text, information!, ok! ) )
	end if
	
end if

//### status (microhlep), console, alert
if ls_type = 'status' then
	gnv_app.of_microhelp( as_msg )
elseif ls_type = 'console' then
	gnv_app.of_console( as_msg )
elseif ls_type = 'alert' then
	messagebox( is_title, as_msg )
else
	return '[error] unknown message type: ' + ls_type
end if

return as_msg

end event

event type string ue_httprequest(string as_cmd);//#========================================================================
//# handle interface command for httpRequest
//#
//# log
//# 	2022/11/21, ck, init
//#========================================================================

string ls_result, ls_data, ls_method, ls_url, ls_text, ls_content
long ll_rtn, ll_status, ll_file, ll_pos, ll_len
Blob lblb_data, lblb_buffer


is_action = lower( of_gettoken( as_cmd, '?' ) )

//### http-source?url => return string, normal for load html
if is_action = 'http-source' then
	
	inv_HttpClient.ClearRequestHeaders()
	ll_rtn = inv_HttpClient.SendRequest('GET', as_cmd)
	ll_status = inv_HttpClient.GetResponseStatusCode()
	
	if ll_rtn = 1 then
		inv_HttpClient.GetResponseBody(ls_result)
		return ls_result
	else
		ls_text = inv_HttpClient.GetResponseStatusText()
		ls_text = 'Errcode=' + string(ll_rtn) + ', Status=' + string(ll_status) + ', Message=' + ls_text
		return '[error] failed to load url ' + as_cmd + ', ' + ls_text
	end if
	
end if

//### http-request?method={get|post|put}&url={url}&data={json}&content={content-type}
if is_action = 'http-request' then
	
	ls_method = upper( of_get_parm( as_cmd, 'method', 'GET' ) )
	ls_url    = of_get_parm( as_cmd, 'url', '' )
	ls_data   = of_get_parm( as_cmd, 'data', '' )
	ls_content= of_get_parm( as_cmd, 'content', '' )

	// set header
	ll_rtn = inv_HttpClient.SetRequestHeader("Content-Type", ls_content)
	ll_rtn = inv_HttpClient.SendRequest(ls_method, ls_url, ls_data)
	ll_status = inv_HttpClient.GetResponseStatusCode()

	// check result (ignore check ll_status = 200)
	if ll_rtn = 1 then
		ll_rtn = inv_HttpClient.GetResponseBody(ls_result)
		//ls_result = of_replaceall( ls_result, '"', '\"' )
		ls_text = '{ "status":' + string(ll_status) + ', "code":' + string(ll_rtn) +', "result":"' + ls_result + '"}'
	else
		ls_text = '{ "status":' + string(ll_status) + ', "code":' + string(ll_rtn) + ' }'
	end if

	return ls_text
end if


//### http-upload?file={file}&url={link} => upload file or image
if is_action = 'http-upload' then
	
	// read file content
	ls_url = of_get_parm( as_cmd, 'file', '' )
	ll_file = fileopen( of_get_parm( as_cmd, 'file', '' ), StreamMode! )
	ll_rtn = FileReadEx ( ll_file, lblb_data )
	fileclose(ll_file)
	
	// set header, and post content
	ll_pos = 1
	inv_HttpClient.SetRequestHeader("Content-Length", String(Len(lblb_data)))
	ll_rtn = inv_HttpClient.PostDataStart(ls_url)
	if ll_rtn < 0 then return string(ll_rtn)

	for ll_pos = 1 to Len(lblb_data) step 20480
		lblb_buffer = blobmid( lblb_buffer, ll_pos, 20480 )
		ll_rtn = inv_HttpClient.PostData( lblb_buffer, len(lblb_buffer) ) 
		if ll_rtn<0 then return string(ll_rtn)
	next
		
	inv_HttpClient.PostDataEnd()
	return String(Len(lblb_data))

end if


messagebox( 'warning', 'unknown http command: ' + as_cmd )

return of_replaceall( '{ "status":-1, "message":"unknown http command ' + as_cmd + '" }', '\', '\\' )

end event

event type string ue_shell(string as_cmd);//#=====================================================
//# run dos command => run?command
//# run by wshShell => run?cmd=command&path=directory&style=[min|max|normal|hide]+wait
//# send keystroke  => sendkeys?{keystrokes}
//# execute shell   => shell?path=&file=&parm=&action=[open|runas|print|find]&style=[min|max|normal|hide]
//#
//# log
//# 	2022/11/10, ck, handle window shell interface.
//#=====================================================

string ls_run, ls_path, ls_style, ls_type, ls_opts, ls_name, ls_mode, ls_parm
long ll_rtn, ll_show

is_action = lower( of_gettoken( as_cmd, '?' ) )

//## run by wshShell => run?cmd=command&path=directory&style=[min|max|normal|hide]+wait
if is_action = 'run' then
	
	ls_run = of_get_parm( as_cmd, 'cmd', is_null )
	ls_path = of_get_parm( as_cmd, 'path', of_get_parm( as_cmd, 'folder', is_null ) )
	ls_style = of_get_parm( as_cmd, 'style', 'normal' ) 

	//# run dos command => run?command
	if isnull(ls_run) then
		ll_rtn = run( as_cmd )
		return string(ll_rtn)
	end if
	
	if pos(lower(ls_style),'normal')>0 then
		ll_show = 1
	elseif pos(lower(ls_style),'min')>0 then
		ll_show = 2
	elseif pos(lower(ls_style),'max')>0 then
		ll_show = 3
	elseif pos(lower(ls_style),'hide')>0 then
		ll_show = 0
	else
		ll_show = 1
	end if
 
	changedirectory( ls_path )
	ll_rtn = of_wsh_run( ls_run, ll_show, pos(ls_style,'wait')>0 )
	changedirectory( gnv_app.is_currentPath )
   
	return  string(ll_rtn)	
end if

//## [send keystroke] sendkeys?{keystrokes}
if is_action = 'sendkeys' then
	return  string(this.of_sendkeys( as_cmd ))
end if

//## execute shell   => shell?path=&file=&parm=&action=[open|runas|print|find]&style=[min|max|normal|hide]
if is_action = 'shell' then
	
	ls_path = of_get_parm( as_cmd, 'path', of_get_parm( as_cmd, 'folder', is_null ) )
	ls_name = of_get_parm( as_cmd, 'file', of_get_parm( as_cmd, 'cmd', is_null ) )
	ls_style = of_get_parm( as_cmd, 'style', 'normal' )
	ls_mode = of_get_parm( as_cmd, 'action', 'open' )
	ls_parm = of_get_parm( as_cmd, 'parm', is_null )
	
	if pos(lower(ls_style),'normal')>0 then
		ll_show = 1
	elseif pos(lower(ls_style),'min')>0 then
		ll_show = 2
	elseif pos(lower(ls_style),'max')>0 then
		ll_show = 3
	elseif pos(lower(ls_style),'hide')>0 then
		ll_show = 0
	else
		ll_show = long(ls_style)
	end if
	
	if ls_name>' ' then
		ll_rtn = ShellExecute( handle(this), ls_mode, ls_name, ls_parm, ls_path, ll_show)
	else
		ll_rtn = ShellExecute( handle(this), 'open', as_cmd, is_null, is_null, 1)
	end if
	
	return  string(ll_rtn)
	
end if

messagebox( 'warning', 'unknown shell command: ' + as_cmd )
return '-1'

end event

event type string ue_unknown(string as_cmd);
messagebox( 'warning', 'unknown command: ' + is_command )

return '-1'

end event

public function string of_eval_javascript (string as_script);//#===============================================================
//# evaluate javascript Sync., reutrn result in string 
//#===============================================================
string ls_result, ls_error, ls_type, ls_value
long	ll_root

gnv_app.of_watch('[js]', 'Eval-Javascript => ' + as_script )

if this.EvaluateJavascriptSync ( as_script, ls_result, ls_error ) < 0 then
	gnv_app.of_watch('[debug]', 'EvaluateJavascriptSync(), error=' + ls_error )
	return '[Error] ' + mid( ls_error, 25, len(ls_error) - 26 )
else
	gnv_app.of_watch('[debug]', 'EvaluateJavascriptSync(), return=' + ls_result )
end if

inv_JsonParser.LoadString(ls_Result)
ll_root = inv_JsonParser.GetRootItem()
ls_type = inv_JsonParser.GetItemString(ll_root, "type")

if ls_type='string' then
	ls_value = inv_JsonParser.GetItemString(ll_root, "value")
else
	ls_value = ls_result
end if

return ls_value

end function

public function string of_gettoken (ref string as_parm, string as_token);//# Description
//#	Cut the string into two section in delimeter, return the first section and also 
//#	cut the parameter as second section.
//#
//#
//#
//# Parameter
//#	as_parm				Passed in String
//#	as_token				Delimiter
//#
//# Example
//#	ls_parm1 = gnv_func.of_gettoken( message.stringparm, '~t' )
//#	ls_parm2 = gnv_func.of_gettoken( message.stringparm, '~t' )
//#	ls_parm3 = gnv_func.of_gettoken( message.stringparm, '~t' )
//#
//# Log
//#	1998/01/20	C.K. Hung
//#=====================================================================================

long 		ll_pos
string	ls_ret

ll_pos = Pos(as_parm, as_token)

if ll_pos > 0 then
	ls_ret 	= left( as_parm, ll_pos - 1)
	as_parm 	= mid( as_parm, ll_pos + Len(as_token) )
else
	ls_ret = as_parm
	as_parm = ""
end if

return ls_ret

end function

public function string of_get_keyword (string as_text, string as_key, string as_delim, string as_default);long ll_pos, ll_delim
string ls_value

ll_pos = pos( as_text, as_key+'=' )

if ll_pos > 0 then
	
	ll_delim = pos( as_text, as_delim, ll_pos )
	
	if ll_delim > 0 then
		ls_value = mid( as_text, ll_pos+len(as_key)+1, ll_delim - ll_pos - len(as_key) - 1 )
	else
		ls_value = mid( as_text, ll_pos+len(as_key)+1 )
	end if
	
	return ls_value
	
end if

return  as_default

end function

public function string of_replaceall (string as_text, string as_old, string as_new);//# Description:
//#
//#	Replace string <as_old> with <as_new> in <as_text>
//# 
//# Example: 
//#
//# 	ls_str = of_ReplaceAll( ls_source, '~t', ';' )
//#
//# Log:
//#	1997/08/05		C.K. Hung	Initial Version
//#============================================================================

Long	ll_len_old, ll_len_new, ll_scan, ll_pos

ll_scan 	= 1
ll_len_old 	= len(as_old)
ll_len_new	= len(as_new)

ll_pos = pos(  as_text, as_old, ll_scan )
DO while ll_pos > 0
	as_text 	= replace ( as_text, ll_pos, ll_len_old, as_new )
	ll_pos	 	= pos( as_text, as_old, ll_pos + ll_len_new )
LOOP

RETURN as_text

end function

public function integer of_wsh_run (string as_run, integer ai_opt, boolean ab_wait);//CONSTANT integer MAXIMIZED = 3
//CONSTANT integer MINIMIZED = 2
//CONSTANT integer NORMAL = 1
//CONSTANT integer HIDE = 0
//CONSTANT boolean WAIT = TRUE
//CONSTANT boolean NOWAIT = FALSE

if not iole_wsh.IsAlive() then
	iole_wsh.ConnectToNewObject("WScript.Shell")	
end if

return iole_wsh.run( as_run, ai_opt, ab_wait )


end function

public function string of_default (string as_string, string as_default);if isnull(as_string) then return as_default

if trim(as_string)='' then return as_default

return as_string

end function

public function string of_get_parm (string as_url, string as_name, string as_default);//#=================================================================
//# get parm and decode from URL. 
//#=================================================================

string ls_parm, ls_text
long ll_pos1, ll_pos2

ll_pos1 = pos( '&'+as_url, '&'+as_name+'=' )
ll_pos2 = pos( as_url, '&', ll_pos1  )

if ll_pos1<=0 then return as_default

if ll_pos2>0 then
	ls_parm = mid( as_url, ll_pos1+len(as_name)+1, ll_pos2 - ll_pos1 - len(as_name) - 1 )
else
	ls_parm = mid( as_url, ll_pos1+len(as_name)+1 )
end if

ls_parm = string(inv_coder.UrlDecode(ls_parm), EncodingANSI!)

return ls_parm

end function

public function integer of_sendkeys (string as_keys);//# [20210604] ck, call Wscript to process sendkeys and commands
//# keys := run=command/go=title/js=jsFunciton/s=1000/&#47;&sol;
//#=============================================

string ls_cmd
long  ll_ms, ll_cpu

if not iole_wsh.IsAlive() then
	if iole_wsh.ConnectToNewObject("WScript.Shell") < 0 then return -1
end if  

do 
	
	ls_cmd = trim( of_gettoken( as_keys, '/' ) )
	ls_cmd = of_replaceall( of_replaceall( ls_cmd, '&#47;', '/' ), '&sol;', '/' )
	
	// run shell command
	if left(ls_cmd,4) = 'run=' then 
		iole_wsh.run( mid( ls_cmd, 5 ) )
		
	// goto window by title	
	elseif left(ls_cmd,6) = 'title=' then 
		iole_wsh.AppActivate( mid( ls_cmd, 7 ) )
		
	// run javascript
	elseif left(ls_cmd,3) = 'js=' then
		this.EvaluateJavascriptAsync (mid( ls_cmd, 4 ) )

	// wait for seconds	
	elseif left(ls_cmd,2) = 's=' then 
		sleep( long( mid( ls_cmd, 3 ) ) )
		
	// wait for milliseconds	
	elseif left(ls_cmd,3) = 'ms=' then
		ll_cpu = cpu()
		ll_ms = long( mid( ls_cmd, 4 ) )
		do
			yield()
		loop while (cpu() - ll_cpu) < ll_ms
		
	// send keystrokes.	
	else
		iole_wsh.SendKeys(ls_cmd)
		
	end if

loop while trim(as_keys)>''

return 1
end function

public function boolean of_db_connect (integer ai_retry);//#===============================================================
//# connect to database try {ai_retry} time if not connected
//#===============================================================

do while ( sqlca.DBhandle() <= 0 and ai_retry > 0 )

	connect using sqlca;
	
	if sqlca.DBhandle() <= 0 then
		yield()
		ai_retry --
		gnv_app.of_microhelp( '[Error@' + string(now(),'hh:mm:ss') + '] Failed to connect database:'+sqlca.ServerName )
	end if

loop

return ( sqlca.DBhandle() > 0 )

end function

public function string of_db_query (string as_sql);//#===============================================================
//# Run DB Query. return result in json format
//#===============================================================

datastore lds
long i, j, ll_colCount, ll_rowCount
string ls_syntax, ls_error, ls_json, ls_row
string ls_colName[], ls_colType[], ls_colLabel, ls_text = ''

// conenct db
if not of_db_connect(3) then return '{ "status":-1, "error": "database not connected" }'

// dw syntax
sqlca.autocommit=TRUE
ls_syntax = sqlca.syntaxfromsql( as_sql, 'Style(Type=grid)', ls_error )
sqlca.autocommit=FALSE

if ls_error > '' then
	messagebox( 'Invlaid SQL Syntax', ls_error )
	return '{ "status": -2, "error": "' + ls_error + '" }'
end if

lds = create datastore
lds.create(ls_syntax)

lds.settransobject(sqlca)
lds.retrieve()

ll_colCount = integer( lds.Object.DataWindow.Column.Count )
ll_rowCount = lds.rowcount()

ls_json   = '{  "colCount":' + string(ll_colCount) + ' ~r~n '
ls_json += ' , "rowCount":' + string(ll_rowCount) + ' ~r~n '
ls_json += ' , "colLabels": [ ~r~n ' 

for i = 1 to ll_colCount
	
	ls_colType[i] = lds.Describe( '#'+String(i) + '.coltype')
	ls_colName[i] = lds.Describe( '#'+String(i) + '.name')
	ls_colLabel = lds.Describe( ls_colname[i] + '_t.text' )
	
	if i>1 then 
		ls_json += ', '
		ls_text += ', '
	end if
	
	ls_text += '"' + ls_colname[i] + '"'
	ls_json += '"' + of_replaceall( of_replaceall(ls_colLabel,'"','' ), '~r~n', ' ' ) + '"' 
	
next

ls_json += '] ~r~n, "columns": [' + ls_text + '] ~r~n, "data": [ ~r~n ' 

for i = 1 to ll_rowcount
	
	ls_row = ' { '
	
	for j=1 to ll_colCount
		
		if j>1 then ls_row += ' , '
		
		ls_row += ' "' + ls_colname[j] + '": '
		
		if left( ls_colType[j], 5 ) = 'char('  then
			
			if isnull( lds.getitemstring( i, j ) ) then
				ls_row += 'null'
			else
				ls_text = of_replaceall( lds.getitemstring( i, j ), '\', '\\' )
				ls_text = of_replaceall( ls_text, '"','\"')
				ls_text = of_replaceall( ls_text, '~r~n', '\n')
				ls_text = of_replaceall( ls_text, '~n', '\n')
				ls_row += '"' + of_replaceall( ls_text, '~r', '\n') + '"'
			end if	
			
		elseif  ls_colType[j] = 'date' then
			
			ls_row += of_default( '"' + string( lds.getitemdate( i, j ), 'yyyy/mm/dd' ) + '"', 'null' )
			
		elseif  ls_colType[j] = 'datetime' or  ls_colType[j] = 'timestamp' then
			
			ls_row += of_default( '"' + string( lds.getitemdatetime( i, j ), 'yyyy/mm/dd hh:mm:ss' ) + '"', 'null' )
			
		elseif ls_colType[j] = 'time' then
			
			ls_row += of_default( '"' + string( lds.getitemtime( i, j ), 'hh:mm:ss' ) + '"', 'null' )
			
		else
			
			ls_row += of_default( string( lds.GetItemDecimal( i, j ) ), 'null' )
			
		end if
		
	next
	
	//ls_row = of_replaceall( ls_row, '\"','&quot;' )
	//ls_row = of_replaceall( ls_row, '~r~n','\n' )
	ls_json += of_replaceall( ls_row, '~r~n','\n' ) + ' }  ,~r~n'
	
next

return left( ls_json, len(ls_json) - 4 ) + ' ~r~n ] } '


end function

public function string of_property (string as_cmd);//# get/set application property, by cmd := name [= value]
//#
//#    app.* for application property
//#    env.* for environment variable
//#    browser.* for browser property
//#
//# 2022/11/20,  ck, 
//#=================================================================

string ls_name, ls_value, ls_ppty, ls_action
long ll_pos, ll_rtn

//=== get property name
ll_pos = pos( as_cmd, '=' )

if ll_pos > 0 then
	ls_name = trim( left( as_cmd, ll_pos - 1) )
	ls_value = trim( mid( as_cmd, ll_pos + 1) )
	ls_action = 'set'
else
	ls_name = trim(as_cmd)
	ls_value = is_null
	ls_action = 'get'
end if

//== get environment variables
if left(ls_name,4) = 'env.' then
	return gnv_app.of_env_variable(mid(ls_name,5))
end if

//=== get/set browser property (not really work, need further study)
if left(ls_name,8) = 'browser.' then
	
	ls_ppty = mid(ls_name, 9)
	
	if ll_pos>0 then
		ll_rtn = WebBrowserSet ( ls_ppty, ls_value )
	else
		ll_rtn = WebBrowserGet ( ls_ppty, ls_value )		
	end if
	
	if ll_rtn<0 then
		return '[error] ' + string(ll_rtn) + ' unknown browser propery: ' + ls_ppty
	else
		return ls_value
	end if
	
end if

//=== get/get browser control ppty
if ls_name = 'popupwindow' then
	if ll_pos>0 then		
		this.popupwindow = (lower(ls_value)='true' or lower(ls_value)='yes')
	else
		if this.popupwindow then return 'true' else return 'false'
	end if
	return ls_value
end if

if ls_name = 'contextmenu' then			
	if ll_pos>0 then		
		this.contextmenu = (lower(ls_value)='true' or lower(ls_value)='yes')
	else		
		if this.contextmenu then return 'true' else return 'false'
	end if
	return ls_value
end if

//=== get/set application property
CHOOSE CASE ls_name
	CASE 'app.title'		
		return of_get_set_ppty( ls_action, gnv_app.is_title, ls_value)
	CASE 'app.version'
		return of_get_set_ppty( ls_action, gnv_app.is_version, ls_value)
	CASE 'app.about'
		return of_get_set_ppty( ls_action, gnv_app.is_about, ls_value)		
	CASE 'app.credit'		
		return of_get_set_ppty( ls_action, gnv_app.is_credit, ls_value)
	CASE 'app.github'
		return of_get_set_ppty( ls_action, gnv_app.is_github, ls_value)
	CASE 'app.home'
		return of_get_set_ppty( ls_action, gnv_app.is_home, ls_value)
	CASE 'app.watch'
		return of_get_set_ppty( ls_action, gnv_app.is_watch, ls_value)
	CASE 'app.cmdline'
		return gnv_app.is_app_cmdline
	CASE 'app.icon', 'win.icon'
		return of_get_set_ppty( ls_action, w_power_chrome.icon, ls_value)
	CASE 'app.runtime'
		return gnv_app.inv_env.RuntimePath
	CASE 'app.screenheight'
		return string(gnv_app.inv_env.ScreenHeight)
	CASE 'app.screenwidth'
		return string(gnv_app.inv_env.ScreenWidth)
	CASE 'app.hostname'
		return gnv_app.is_hostname		
	CASE 'app.path'
		return gnv_app.is_currentpath
	CASE 'app.mode'
		return gnv_app.is_app_mode
	CASE 'app.domain'
		return gnv_app.is_app_domain
		
	CASE 'app.library' 
		if ls_action = 'set' then 
			setlibrarylist(ls_value)
		end if
		return getlibrarylist()

END CHOOSE
	
return '[error] unknown property: ' + ls_name

end function

public function string of_session (string as_cmd);//# get/set application session, by cmd := name [= value]
//# 2022/11/14 ck
//#=================================================================

string ls_name, ls_value
int i

if pos( as_cmd, '=' ) > 0 then
	
	ls_name = trim( of_gettoken( as_cmd, '=' ) )
	ls_value = trim(as_cmd)
	
	for i=1 to upperbound(gnv_app.is_var_name)
		if gnv_app.is_var_name[i]= ls_name then
			gnv_app.is_var_value[i] = ls_value
			return ls_value
		end if	
	next

	gnv_app.is_var_name[upperbound(gnv_app.is_var_name)+1]= ls_name
	gnv_app.is_var_value[upperbound(gnv_app.is_var_name)] = ls_value
	return ls_value
	
end if

// return session variable value
for i=1 to upperbound(gnv_app.is_var_name)
	if gnv_app.is_var_name[i]= trim(as_cmd) then
		return gnv_app.is_var_value[i]
	end if	
next

return 'undefined' 


end function

public function string of_get_set_ppty (string as_action, ref string as_ppty, string as_value);// get or set property

if as_action = 'get' then  
	return as_ppty
else
	as_ppty = as_value
end if

return as_value

end function

public function string of_db_table (string as_sql);//# 2022/11/15, ck, migrate from powerpage.of_sql_to_table()
//#====================================================================

datastore lds
long i, j, ll_colCount, ll_rowCount
string ls_syntax, ls_error, ls_table, ls_colName, ls_colType[], ls_row

// conenct db
if not of_db_connect(3) then return '[error] database not connected!'

// dw syntax
sqlca.autocommit=TRUE
ls_syntax = sqlca.syntaxfromsql( as_sql, 'Style(Type=grid)', ls_error )
sqlca.autocommit=FALSE

if ls_error > '' then
	messagebox( 'Invlaid SQL Syntax', ls_error )
	return '{ "error": "' + ls_error + '" }'
end if

lds = create datastore
lds.create(ls_syntax)

lds.settransobject(sqlca)
lds.retrieve()

ll_colCount = integer( lds.Object.DataWindow.Column.Count )
ll_rowCount = lds.rowcount()


ls_table   = '<table class="pb-table">~r~n<tr>'

for i = 1 to ll_colCount
	ls_colName = lds.Describe( '#'+String(i)+'.name')
	ls_colName = lds.Describe( ls_colname+'_t.text' )
	ls_colType[i] = lds.Describe( '#'+String(i)+'.coltype')
	ls_table += '   <th>' + ls_colName + '</th>'
next

ls_table += '</tr>~r~n' 

for i = 1 to ll_rowcount
	
	ls_row = '<tr>'
	
	for j=1 to ll_colCount
		
		if left( ls_colType[j], 5 ) = 'char('  then
			
			ls_row += '<td>' + of_default( lds.getitemstring( i, j ), '&nbsp;' ) + '</td>'
			
		elseif  ls_colType[j] = 'date' then
			
			ls_row += '<td>' + of_default( string( lds.getitemdate( i, j ), 'yyyy/mm/dd' ), '' ) + '</td>'
			
		elseif  ls_colType[j] = 'datetime' or  ls_colType[j] = 'timestamp' then
			
			ls_row += '<td>' + of_default( string( lds.getitemdatetime( i, j ), 'yyyy/mm/dd hh:mm:ss' ), '&nbsp;' ) + '</td>'
			
		elseif ls_colType[j] = 'time' then
			
			ls_row += '<td>' + of_default( string( lds.getitemtime( i, j ), 'hh:mm:ss' ), '&nbsp;' ) + '</td>'
			
		else
			
			ls_row += '<td>' + of_default( string( lds.GetItemDecimal( i, j ) ), '&nbsp;' ) + '</td>'
			
		end if
		
	next
	
	ls_row = of_replaceall( ls_row, '\"','&quot;' )
	ls_row = of_replaceall( ls_row, '~r~n','<br>' )
	ls_table += of_replaceall( ls_row, '\','\\' ) + '</tr>~r~n'
	
next

return ls_table + '<table>'

end function

public function string of_db_execute (string as_sql);string ls_msg

// conenct db
if not of_db_connect(3) then return '{ "status":-1, "error": "database not connected" }'

// execute sql
EXECUTE IMMEDIATE :as_sql using sqlca; 

ls_msg = '"sqlcode":' + string(sqlca.sqlcode)+ ', "sqlerrtext":"' + of_default(sqlca.sqlerrtext,'null')

// return
if sqlca.sqlcode=0 then 
	COMMIT USING sqlca;
	RETURN  '{ "status": 1, ' + ls_msg +  '" }' 
else
	ROLLBACK using sqlca;
	RETURN '{ "status": -1, ' + ls_msg +  '" }' 
end if



end function

public function integer of_sleepms (integer ai_ms);// sleep in milliseconds
long ll_cpu

ll_cpu = cpu()

do
	yield()
loop while (cpu() - ll_cpu) < ai_ms

return ai_ms
		
end function

public function string of_json_value (string as_result);// get json value from { type:"string", value:"value" }
long 	 ll_root
string ls_type, ls_value

inv_JsonParser.LoadString(as_result)

ll_root = inv_JsonParser.GetRootItem()
ls_type = inv_JsonParser.GetItemString(ll_root, "type")

if ls_type='string' then
	ls_value = inv_JsonParser.GetItemString(ll_root, "value")
else
	ls_value = as_result
end if

return ls_value

end function

public function string of_str_format (string as_str);as_str = of_replaceall( as_str, '~r~n', '\n' )
as_str = of_replaceall( as_str, '~r', '\n' )
as_str = of_replaceall( as_str, '~n', '\n' )

return of_replaceall( as_str, '"', '\"' )
end function

event constructor;//#=======================================================================
//# CEF Web Browser with Web Interface support (migrate from Powerpage)
//# copyright 2022, casualwriter
//#
//# To-Do
//#  * code encryption support. pb.encode(), pb.decode()
//#  * code pb.datawindow()
//#  * work with db procedure/function
//#=======================================================================

inv_coder = Create CoderObject
inv_JsonParser = Create JsonParser
inv_HttpClient = Create HttpClient

iole_wsh = Create OleObject
iole_wsh.ConnectToNewObject("WScript.Shell")

setnull(is_null)

	

end event

on u_web_browser.create
end on

on u_web_browser.destroy
end on

event destructor;
iole_wsh.DisconnectObject()

if IsValid(inv_coder) then destroy inv_coder

if IsValid(inv_JsonParser) then destroy inv_JsonParser;

if IsValid(inv_HttpClient) then destroy inv_HttpClient;


end event

event titletextchanged;is_title = titletext
end event

event navigationprogressindex;// initial interface (execute powerchrome.js) when page loaded
string ls_result, ls_error
long ll_rtn


If progressindex = 100 and is_current_url <> is_ready_url Then

	// for cloud mode, interfce is available for same-domain/white-list only
	if gnv_app.of_whitelist(is_current_url) then
		
		this.RegisterEvent ( 'ue_interface' ) 
		this.RegisterEvent ( 'ue_message' ) 
	
		is_ready_url = is_current_url
		gnv_app.of_watch( '[debug]', 'registered interface for ' + is_current_url )
	  
		ll_rtn = this.EvaluateJavascriptSync ( gnv_app.is_api_script, ls_result, ls_error ) 
		
		if ll_rtn > 0 then
			gnv_app.of_microhelp( 'interface ready. ' + of_json_value(ls_result) )
		else
			gnv_app.of_microhelp( 'load interface failed. rtn='+ string(ll_rtn) + ', err=' + ls_error )
		end if
		
		post event ue_pageready()
		
	else
		
		gnv_app.of_microhelp( 'page ready for ' + is_current_url )
		
	end if	
	
End If



end event

event navigationerror;
gnv_app.of_microhelp( 'navigateerror(), status='+string(errorcode)+', url='+failedurl )





end event

event addresschange;
gnv_app.of_watch( '[debug]', 'event addresschange() - ' + newurl )

is_current_url = of_default( newurl, '' )
is_ready_url = 'about:blank'

end event

event certificateerror;
gnv_app.of_watch( '[debug]', 'event certificateerror() - ' + errortext + ', url=' + requesturl )

return 0
end event

event pdfprintfinished;
gnv_app.of_watch( '[debug]', 'event pdfprintfinished(), file=' + pdffile )

end event

event evaluatejavascriptfinished;
gnv_app.of_watch( '[debug]', 'event evaljsfinished(), result=' + result )

end event

event navigationstart;
gnv_app.of_watch( '[debug]', 'event navigationstart()' )

end event

event resourceredirect;
gnv_app.of_watch( '[debug]', 'event resourceredirect(), goto=' + redirecturl )

end event


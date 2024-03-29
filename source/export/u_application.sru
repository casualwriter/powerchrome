$PBExportHeader$u_application.sru
$PBExportComments$application manager
forward
global type u_application from nonvisualobject
end type
end forward

global type u_application from nonvisualobject autoinstantiate
event ue_open ( string commandline )
event ue_close ( )
event ue_idle ( )
event ue_error ( )
event ue_home ( )
end type

type prototypes
FUNCTION boolean ShowWindow( ulong winhandle, int wincommand ) Library "user32"
FUNCTION boolean BringWindowToTop(  ulong  HWND  )  Library "user32"
FUNCTION long FindWindowA( ulong  Winhandle, string wintitle ) Library "user32"
FUNCTION boolean SetForegroundWindow( long hWnd ) LIBRARY "USER32"

FUNCTION long ShellExecute (long hwnd, string lpOperation, string lpFile, &
											string lpParameters,  string lpDirectory, integer nShowCmd ) &
					LIBRARY "shell32" ALIAS FOR ShellExecuteW
					
/*
SE_ERR_FNF              2       // file not found
SE_ERR_PNF              3       // path not found
SE_ERR_ACCESSDENIED     5       // access denied
SE_ERR_OOM              8       // out of memory
SE_ERR_DLLNOTFOUND      32
SE_ERR_SHARE            26
SE_ERR_ASSOCINCOMPLETE  27
SE_ERR_DDETIMEOUT       28
SE_ERR_DDEFAIL          29
SE_ERR_DDEBUSY          30
SE_ERR_NOASSOC          31
*/


end prototypes

type variables

environment inv_env
CoderObject inv_coder

string is_name = 'powerchrome'
string is_ini 	= 'powerchrome.ini'

string is_version = 'v0.62 build on 2023/01/10'
string is_credit = 'Copyright 2023, Casualwriter'
string is_github = 'https://github.com/casualwriter/powerchrome'
string is_home = 'https://casualwriter.github.io/powerchrome'
string is_about = 'Description of your application...'
string is_title = 'PowerChrome'

string is_currentPath, is_hostname, is_null, is_watch

string is_commandline, is_app_cmdline=''
string is_app_start, is_app_domain, is_app_mode='local'
string is_app_script, is_api_script

string is_var_name[], is_var_value[]
long 	 ii_var_count = 0

string is_microhelp[]
long   ii_microcount=0


end variables
forward prototypes
public function string of_replaceall (string csource, string cold, string cnew)
public function long of_findwindowbytitle (string as_title)
public function boolean of_showwindow (long al_handle)
public function boolean of_bringtotop (long al_handle)
public function string of_gettoken (ref string as_parm, string as_token)
public function any of_default (any aa_var, any aa_default)
public function integer of_microhelp (string as_text)
public function string of_get_keyword (string as_text, string as_key, string as_delim, string as_default)
public function string of_url_format (string as_url)
public function string of_encryption (string as_psw)
public function string of_decryption (string as_psw)
public function long of_shellprint (string as_file)
public function integer of_sendkeys (string as_keys)
public function long of_shellopen (string as_folder, string as_file, string as_parm)
public function long of_shellexecute (string as_type, string as_cmd, string as_parm, string as_folder, integer ai_show)
public function long of_shellrun (string as_cmd, string as_folder)
public function long of_shellexecute (string as_cmd, string as_parm, string as_folder)
public function long of_shellrun (string as_cmd)
public function string of_get_cmdline (ref string as_cmdline, boolean ab_quote)
public function integer of_watch (string as_key, string as_msg)
public function integer of_console (string as_text)
public function string of_env_variable (string as_name)
public function string of_urlencode (string as_url)
public function string of_urldecode (string as_url)
public function string of_get_string (string as_key)
public function boolean of_whitelist (string as_url)
end prototypes

event ue_open(string commandline);//# Copyright 2022, casualwriter, All Rights Reserved.
//#
//# PowerChrome - portable chromium-base (cef) web browser for html/javascript desktop application
//# 
//# v0.10, 2021/10/19, Migrate from powerpage v0.63, feasibility study
//# v0.20, 2022/11/07, rewrite from powerpage v0.63
//# v0.56, 2022/11/30, interface, commandline, basically ready.
//# v0.60, 2022/12/09, security for cloud mode, interface available for same domain only.
//# v0.62, 2023/01/10, bug fixed. update document
//# todo: make use of datawindow for reporting support
//# todo: endoe/decode functions
//#==========================================================================================

string ls_key, ls_cmdline, ls_buffer, ls_parms = ''
ulong ul_val, ul_size, ul_rtn

// Initialize
setnull(is_null)
inv_coder = create CoderObject

// get Environment object
GetEnvironment(inv_env)

// get computer name, current path, commandline
ls_key = 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName'

if RegistryGet (ls_key,'ComputerName', RegString!, is_hostname) > 0 then 
	is_hostname = upper(is_hostname)
else
	messagebox( 'Error', 'Cannot get computer name.' )
end if

is_currentPath = GetCurrentDirectory ( )
is_commandline = commandline

// read application seting from profile ini (production not recommended using ini setting)
is_version= profilestring( this.is_ini, 'system', 'version', is_version )
is_credit = profilestring( this.is_ini, 'system', 'credit', is_credit )
is_github = profilestring( this.is_ini, 'system', 'github', is_github )
is_home   = profilestring( this.is_ini, 'system', 'home', is_home  )
is_about  = profilestring( this.is_ini, 'system', 'about', is_about )
is_title  = profilestring( this.is_ini, 'system', 'title', is_title )
is_watch  = profilestring( this.is_ini, 'system', 'watch', is_watch )

// Set PB extent library list
if profilestring( this.is_ini, 'system', 'extLibrary', '' ) > '' then
	AddToLibraryList( profilestring( this.is_ini, 'system', 'extLibrary', '' ) )
end if

// Connect to db
sqlca.DBMS		  = profilestring( this.is_ini, 'database', 'DBMS', 'N/A' )
sqlca.ServerName = of_get_string( profilestring( this.is_ini, 'database', 'ServerName', '' ) )
sqlca.DBParm 	  = of_get_string( profilestring( this.is_ini, 'database', 'DBParm', '' ) )
sqlca.LogId 	  = of_get_string( profilestring( this.is_ini, 'database', 'LogId', '' ) )
sqlca.LogPass    = of_get_string( profilestring( this.is_ini, 'database', 'LogPass', '' ) )

if sqlca.DBMS <> 'N/A' then
	connect using sqlca;
	if sqlca.sqlcode < 0 then
		of_microhelp( 'failed to connect db. ' + sqlca.SQLErrText )
	elseif sqlca.DBhandle() > 0 then
		of_microhelp( 'database connected.' )
	end if	
end if

// app startup url := cmdline -> ini -> index.html -> powerchrome.html
if profilestring( this.is_ini, 'system', 'start', '' )>' ' then
	is_app_start = of_get_string( profilestring( this.is_ini, 'system', 'start', '' ) )
elseif FileExists( 'index.html') then
	is_app_start = 'index.html'
elseif FileExists( this.is_name + '.html') then
	is_app_start = this.is_name +'.html' 
end if

//=== handle commandline parameters. 
// syntax1: /app=start.html /script=myscript.js /kiosk /fullscreen /watch=[parm]
// syntax2: /url=link /save=output.html /save=output.pdf /select=css /delay=800
do 
	
	commandline = trim(commandline)
	
	if left( commandline,5) = '/app=' or left( commandline,5) = '/url=' then		
		
		commandline = mid( commandline, 6 )
		is_app_start = of_get_string( of_get_cmdline( commandline, false ) )
		
	elseif left( commandline,6) = '/save=' then
		
		commandline = mid( commandline, 7 )	
		is_app_mode = 'output'
		ls_parms += '&save=' + of_urlencode( of_get_cmdline( commandline, false ) )
		
	elseif left( commandline,8) = '/script=' then		
		
		commandline = mid( commandline, 9 )
		is_app_script = of_get_cmdline( commandline, false )
		
	elseif left( commandline,8) = '/select=' then		
		
		commandline = mid( commandline, 9 )
		ls_parms += '&select=' + of_urlencode( of_get_cmdline( commandline, false ) )
		
	elseif left( commandline,7) = '/watch=' then		
		
		commandline = mid( commandline, 8 )
		is_watch = of_get_cmdline( commandline, false )
		
	elseif left( commandline,7) = '/delay=' then		
		
		commandline = mid( commandline, 8 )
		ls_parms += '&delay=' + of_get_cmdline( commandline, false )
		
	else
		
		ls_key = of_get_cmdline( commandline, true )
		
		if ls_key='/fullscreen' or ls_key='/kiosk' then
			is_app_mode = 'fullscreen'
		else
			is_app_cmdline += ' ' + ls_key 
		end if
		
	end if
	
loop while trim(commandline)>''
	
// read for interface js script
long ll_file
string ls_name, ls_text

if isnull(is_app_script) or trim(is_app_script)='' then
	is_app_script = profilestring( this.is_ini, 'system', 'script', this.is_name + '.js' )
end if

if fileexists(is_app_script) then
	ll_file = fileopen( is_app_script, TextMode!  )
	filereadex( ll_file, is_api_script)
   fileclose(ll_file)
end if

// show parameters for debug
if pos( is_watch, '[parm]') > 0 then
	ls_text = ' commandline=' + of_default( is_commandline, '{none}' )
	ls_text += '~r~n page(cmdline)=' + of_default( is_app_cmdline, '{none}' )
   ls_text += '~r~n watch=' + is_watch + '~r~n parms=' + ls_parms
	ls_text += '~r~n url=' + of_default( is_app_start, '{none}' )
	messagebox( 'Program Parameters', ls_text )
end if

// start application (mode := fullscreen | output | web | local )
if is_app_start > ' ' then
	
	if is_app_mode = 'fullscreen' then
		
		// call w_power_kiosk for fullscreen/kiosk mode
		openwithparm( w_power_kiosk, is_app_start )
		
	elseif is_app_mode = 'output' then
		
		// call w_power_dialog for output to html/pdf
		openwithparm( w_power_dialog, ls_parms + '&url=' + of_urlencode(is_app_start) )	
		
	else
		
		// set application mode
		if left(is_app_start,8)='https://' or left(is_app_start,7)='http://' then
			is_app_mode = 'cloud'
			is_app_domain = left( is_app_start, LastPos(is_app_start,'/') )
		else
			is_app_mode = 'local'
		end if	
		
		// open html application
		openwithparm( w_power_chrome, is_app_start )	
		
	end if
	
else
	
	messagebox( 'Error', 'Please specify startup page!' )
	
end if



end event

event ue_close();
if IsValid(inv_coder) then 
	destroy inv_coder
end if

if sqlca.DBhandle() > 0 then 
	DISCONNECT using SQLCA;
end if



end event

event ue_error();// error handling, show messagebox
messagebox( 'Error ' + string(error.number), error.object + '.' + error.objectevent + '(' + string(error.line) + ')~r~n' +  error.text )

end event

public function string of_replaceall (string csource, string cold, string cnew);//# Description:
//#
//#	Replace string <cOld> with <cNew> in <cSource>
//# 
//# Example: 
//#
//# 	ls_str = gnv_func.of_ReplaceAll( ls_source, '~t', ';' )
//#
//# Log:
//#	1997/08/05	C.K. Hung	Initial Version
//#============================================================================

Long	nLenOld, nLenNew, nScan, nPos

nScan 	= 1
nLenOld 	= len(cOld)
nLenNew	= len(cNew)

nPos = pos(  cSource, cOld, nScan )
DO while nPos > 0
	cSource 	= replace ( cSource, nPos, nLenOld, cNew )
	nPos	 	= pos( cSource, cOld, nPos + nLenNew )
LOOP

RETURN cSource

end function

public function long of_findwindowbytitle (string as_title);return FindWindowA( 0, as_title )
end function

public function boolean of_showwindow (long al_handle);return ShowWindow( al_handle, 5 )
end function

public function boolean of_bringtotop (long al_handle);return BringWindowToTop( al_handle )
end function

public function string of_gettoken (ref string as_parm, string as_token);//# Description
//#	Cut the string into two section in delimeter, return the first section 
//#	and also cut the parameter as second section.
//#
//# Parameter
//#	as_parm				Passed by reference
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

public function any of_default (any aa_var, any aa_default);//# Description:
//#
//#	Return a default value for NULL argument
//#
//# Example: 
//#
//# 	ls_username = gnv_func.of_default( ls_username, 'Unknow' )
//# 	li_deptcode = gnv_func.of_default( li_deptcode, 0 )
//#
//# Log
//#	1 Nov 1997	C.K. Hung	Initial version
//#===================================================================

if isnull(aa_var) then
   return aa_default
else
   return aa_var
end if

end function

public function integer of_microhelp (string as_text);//# Show microhelp in statusbar, and console if visible
//# 2021/10/01, ck
//#=================================================================

if isnull(as_text) or trim(as_text) = '' then return 0

// keep history (skip >> for web status text)
if left(trim(as_text),2) <> '>>' then 
	
	if ii_microcount>=1024 then ii_microcount=1 else ii_microcount++
	
	is_microhelp[ii_microcount] = ' [' + string(ii_microcount)+string(now(),'@hh:mm:ss] ') + as_text
	
end if	

// show text at status bar
if isvalid(w_power_chrome) then
	
	w_power_chrome.st_status.text = ' ' + as_text

	if w_power_chrome.st_console.visible and left(trim(as_text),2) <> '>>' then 
		w_power_chrome.st_console.text += '~r~n[' + string(now(),'hh:mm:ss] ') + of_replaceall(as_text,'|','~r~n')
		w_power_chrome.st_console.Scroll(9999)
	end if	

	return 1
	
end if

return 0
end function

public function string of_get_keyword (string as_text, string as_key, string as_delim, string as_default);long ll_pos, ll_delim
string ls_value

ll_pos = pos( as_text, as_key+'=' )

if ll_pos > 0 then
	
	ll_delim = pos( as_text, as_delim, ll_pos+1 )
	
	if ll_delim > 0 then
		ls_value = mid( as_text, ll_pos+len(as_key)+1, ll_delim - ll_pos - len(as_key) - 1 )
	else
		ls_value = mid( as_text, ll_pos+len(as_key)+1 )
	end if
	
	return trim(ls_value)
	
end if

return  trim(as_default)

end function

public function string of_url_format (string as_url);//# format url
//# 1. no change if is web link, e.g. http://mydomain.com
//# 2. no change for network file, e.g. d:\path\folder\index.html
//# 3. local file, add {currentDirectory} + '\' + filename
//#=========================================================================

// for network file, or web link
if pos(as_url,':')>0 or pos(as_url,'\\')>0 then return trim(as_url)

// for local file, add current path
return GetCurrentDirectory() + '\' + trim(as_url)

end function

public function string of_encryption (string as_psw);//# Description:
//#
//#	This function is coded for simple password encryption
//#	use XOR function decode to Hex(a=0..15), XOR key is project name
//#
//# Log:
//#	1997/08/05, CK. Hung	Initial Version
//#	2021/05/17, CK. revise for secret-string
//#============================================================================

int		i, ll_len1, ll_len2, ll_key[], ll_source, ll_keychr
string 	ls_text, ls_key

// for empty password
if isnull(as_psw) or as_psw='' then return ''

// get the ascII array of key
ls_key = '???' + reverse( getapplication().appname ) + '???'

ll_len1 = len( ls_key )

for i = ll_len1 to 1 step -1
	ll_key[i] = asc( mid(ls_key,i,1) )
next

// xor operation, f(source,key) = 256 + key - source
ls_text 	= ''
ll_len2	= len(as_psw)

for i = 1 to ll_len2
	ll_source = asc(mid(as_psw,i,1))
	ll_keychr = 256 + ll_key[ 1 + mod( i - 1, ll_len1 ) ] - ll_source
	ls_text 	 = ls_text + char(asc('a')+int(ll_keychr/16)) + char(asc('a')+mod(ll_keychr,16))
next

return reverse(ls_text)

end function

public function string of_decryption (string as_psw);//# Description:
//#
//#	This function is used to decode password for of_encryption()
//#
//# Log:
//#	2005/12/26		CK. Hung	Initial Version
//#	2021/05/17		CK. Hung	revise for secret-string
//#============================================================================

int		i, ll_len1, ll_len2, ll_key[], ll_source, ll_keychr
string 	ls_text, ls_key

// for empty password
if isnull(as_psw) or as_psw='' then return ''

// get the ascII array of key
as_psw = reverse(as_psw)
ls_key = '???' + reverse( getapplication().appname ) + '???'

ll_len1 = len( ls_key )

for i = ll_len1 to 1 step -1
	ll_key[i] = asc( mid(ls_key,i,1) )
next

// xor operation, f(source,key) = 256 + key - source
ls_text 	= ''
ll_len2	= len(as_psw)
for i = 1 to ll_len2 step 2
	ll_source = (asc(mid(as_psw,i,1)) - asc('a'))*16 + (asc(mid(as_psw,i+1,1)) - asc('a'))
	ll_keychr = 256 + ll_key[ 1 + mod( (i -1)/2, ll_len1 ) ] - ll_source
	ls_text 	 = ls_text + char(ll_keychr)
next

return ls_text

end function

public function long of_shellprint (string as_file);return ShellExecute( handle(this), 'print', as_file, is_null, is_null, 0)

end function

public function integer of_sendkeys (string as_keys);//# [20210604] ck, call Wscript to process sendkeys and commands
//# keys := run=command/go=title/s=1000/&#47;&sol;
//#=============================================
OleObject ole_wsh

string ls_cmd
long  ll_conn, ll_ms, ll_cpu

ole_wsh = Create OleObject

ll_conn = ole_wsh.ConnectToNewObject("WScript.Shell")

if ll_conn<0 then return ll_conn

do 
	
	ls_cmd = trim( of_gettoken( as_keys, '/' ) )
	ls_cmd = of_replaceall( of_replaceall( ls_cmd, '&#47;', '/' ), '&sol;', '/' )
	
	if left(ls_cmd,4) = 'run=' then 
		ole_wsh.run( mid( ls_cmd, 5 ) )
	elseif left(ls_cmd,6) = 'title=' then 
		ole_wsh.AppActivate( mid( ls_cmd, 7 ) )
	elseif left(ls_cmd,2) = 's=' then 
		sleep( long( mid( ls_cmd, 3 ) ) )
	elseif left(ls_cmd,3) = 'ms=' then
		ll_cpu = cpu()
		ll_ms = long( mid( ls_cmd, 4 ) )
		do
			yield()
		loop while (cpu() - ll_cpu) < ll_ms
	else
		ole_wsh.SendKeys(ls_cmd)
	end if

loop while trim(as_keys)>''

ole_wsh.DisconnectObject()

return ll_conn
end function

public function long of_shellopen (string as_folder, string as_file, string as_parm);return ShellExecute( handle(this), 'open', as_file, as_parm, as_folder, 1)
end function

public function long of_shellexecute (string as_type, string as_cmd, string as_parm, string as_folder, integer ai_show);//# FUNCTION long ShellExecute (long hwnd, string lpOperation, string lpFile, string lpParameters,  string lpDirectory, integer nShowCmd ) 
//#  LIBRARY "shell32" ALIAS FOR ShellExecuteW
//#
//# ai_show -> nShowCmd := 0-hide, 1-normal, 2-min, 3-max
//# as_type -> lpOperation := open | runas |print | edit | explore | find
//#====================================================================

return ShellExecute( handle(this), as_type, as_cmd, as_parm, as_folder, ai_show)
end function

public function long of_shellrun (string as_cmd, string as_folder);return ShellExecute( handle(this), 'open', as_cmd, as_folder, is_null, 1)
end function

public function long of_shellexecute (string as_cmd, string as_parm, string as_folder);return ShellExecute( handle(this), 'open', as_cmd, as_parm, as_folder, 1)
end function

public function long of_shellrun (string as_cmd);return ShellExecute( handle(this), 'open', as_cmd, is_null, is_null, 1)
end function

public function string of_get_cmdline (ref string as_cmdline, boolean ab_quote);
string ls_value
long ll_pos

as_cmdline = trim(as_cmdline)

if left(as_cmdline,1) = '"' then
	
	ll_pos = pos( as_cmdline, '"', 2 )
	if ll_pos > 0 then
		ls_value = left( as_cmdline, ll_pos )
		as_cmdline = trim( mid( as_cmdline, ll_pos + 1 ) )
	else
		ls_value = as_cmdline + '"'
		as_cmdline = ''
	end if
	
	if ab_quote then
		return ls_value
	else
		return mid( ls_value, 2, len(ls_value) -2 )
	end if
end if

return of_gettoken( as_cmdline, ' ' )


end function

public function integer of_watch (string as_key, string as_msg);//# Show watch message based on watch keyword, for debug purpose
//# 2022/11/10, ck
//#=================================================================

if pos(this.is_watch, as_key) > 0  then
	return of_microhelp( as_key +': ' + as_msg)
end if

return 0
end function

public function integer of_console (string as_text);//# send message to console. 
//#
//# 2022/11/11, ck
//#=================================================================

// show text at status bar
if isvalid(w_power_chrome) then
	if w_power_chrome.st_console.visible then 
		w_power_chrome.st_console.text += '~r~n' + of_replaceall(as_text,'||','~r~n')
		w_power_chrome.st_console.Scroll(9999)
	end if	
	return 1
end if

return 0
end function

public function string of_env_variable (string as_name);ContextKeyword lcxk_base
String ls_Path
String ls_values[]
 
this.GetContextService("Keyword", lcxk_base)

lcxk_base.GetContextKeywords( as_name, ls_values)

if UpperBound(ls_values) > 0 Then 
	return ls_values[1]
else
	return 'undefined!'
end if



end function

public function string of_urlencode (string as_url);// encode URL or URIComponent

return inv_coder.UrlEncode ( Blob(as_url, EncodingANSI!) )

end function

public function string of_urldecode (string as_url);// decode URL or URIComponent

return string(inv_coder.UrlDecode(as_url), EncodingANSI! )
end function

public function string of_get_string (string as_key);//# cater secret string start with '@'
//#==================================================

if left(as_key,1) = '@' then	
	return of_decryption( mid(as_key,2) )
end if

return trim(as_key)
end function

public function boolean of_whitelist (string as_url);// no restriction for local mode
if this.is_app_mode = 'local' then return true

// ok for same domain with startup page
if left(as_url, len(this.is_app_domain)) = this.is_app_domain then return true

// ok for offical site: https://casualwriter.github.io/powerchrome/
if left(as_url, 43) = 'https://casualwriter.github.io/powerchrome/' then return true

// check white domain list. design and code later.
//....

// else not allow to access interface
return false
end function

on u_application.create
call super::create
TriggerEvent( this, "constructor" )
end on

on u_application.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on


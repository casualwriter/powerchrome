$PBExportHeader$w_login.srw
$PBExportComments$check login for window account
forward
global type w_login from window
end type
type st_3 from statictext within w_login
end type
type st_2 from statictext within w_login
end type
type st_1 from statictext within w_login
end type
type sle_password from singlelineedit within w_login
end type
type sle_userid from singlelineedit within w_login
end type
type cb_validate from commandbutton within w_login
end type
type cb_cancel from commandbutton within w_login
end type
end forward

global type w_login from window
integer width = 1426
integer height = 864
boolean titlebar = true
string title = "Windows Logon"
boolean controlmenu = true
windowtype windowtype = response!
long backcolor = 67108864
string icon = "AppIcon!"
boolean center = true
st_3 st_3
st_2 st_2
st_1 st_1
sle_password sle_password
sle_userid sle_userid
cb_validate cb_validate
cb_cancel cb_cancel
end type
global w_login w_login

type prototypes
Function ulong WNetGetUser( string lpname, ref string lpusername, ref ulong buflen ) Library "mpr.dll" Alias For "WNetGetUserW"

Function boolean LogonUser ( & 
    string lpszUsername, 	string lpszDomain, string lpszPassword, & 
	ulong dwLogonType, ulong dwLogonProvider, ref ulong phToken &
) Library "advapi32.dll" Alias For "LogonUserW"

Function boolean CloseHandle ( ulong hObject ) Library "kernel32.dll"
	




end prototypes

on w_login.create
this.st_3=create st_3
this.st_2=create st_2
this.st_1=create st_1
this.sle_password=create sle_password
this.sle_userid=create sle_userid
this.cb_validate=create cb_validate
this.cb_cancel=create cb_cancel
this.Control[]={this.st_3,&
this.st_2,&
this.st_1,&
this.sle_password,&
this.sle_userid,&
this.cb_validate,&
this.cb_cancel}
end on

on w_login.destroy
destroy(this.st_3)
destroy(this.st_2)
destroy(this.st_1)
destroy(this.sle_password)
destroy(this.sle_userid)
destroy(this.cb_validate)
destroy(this.cb_cancel)
end on

event open;String ls_userid
Ulong lul_result, lul_buflen

lul_buflen = 32
ls_userid = Space(lul_buflen)

lul_result = WNetGetUser("", ls_userid, lul_buflen)

If lul_result = 0 Then
	sle_userid.text = ls_userid
	sle_password.SetFocus()
End If


end event

type st_3 from statictext within w_login
integer x = 73
integer y = 48
integer width = 1289
integer height = 84
integer textsize = -12
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Calibri"
long backcolor = 67108864
string text = "Please login by window user / password"
boolean focusrectangle = false
end type

type st_2 from statictext within w_login
integer x = 82
integer y = 376
integer width = 338
integer height = 64
integer textsize = -11
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Calibri"
long backcolor = 67108864
string text = "Password:"
boolean focusrectangle = false
end type

type st_1 from statictext within w_login
integer x = 87
integer y = 232
integer width = 347
integer height = 64
integer textsize = -11
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Calibri"
long backcolor = 67108864
string text = "User ID:"
boolean focusrectangle = false
end type

type sle_password from singlelineedit within w_login
integer x = 448
integer y = 372
integer width = 795
integer height = 96
integer taborder = 20
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 33554432
boolean password = true
borderstyle borderstyle = stylelowered!
end type

type sle_userid from singlelineedit within w_login
integer x = 448
integer y = 216
integer width = 795
integer height = 96
integer taborder = 10
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 33554432
borderstyle borderstyle = stylelowered!
end type

type cb_validate from commandbutton within w_login
integer x = 430
integer y = 576
integer width = 306
integer height = 104
integer taborder = 30
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Calibri"
string text = "OK"
boolean default = true
end type

event clicked;String ls_domain, ls_username, ls_password
ULong lul_token
Boolean lb_result

ls_domain   = ""
ls_username = sle_userid.text
ls_password = sle_password.text

if LogonUser( ls_username, ls_domain, ls_password, 3, 0, lul_token ) then
	
	CloseHandle(lul_token)
	closewithreturn( parent, ls_username )

else
	
	messagebox( Parent.title, "Invalid User ID or Password!")
	sle_password.selecttext( 1, 20 )
	sle_password.setfocus()
	
End If

end event

type cb_cancel from commandbutton within w_login
integer x = 919
integer y = 568
integer width = 315
integer height = 108
integer taborder = 40
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Calibri"
string text = "Cancel"
boolean cancel = true
end type

event clicked;close(parent)


end event


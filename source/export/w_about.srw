$PBExportHeader$w_about.srw
forward
global type w_about from window
end type
type st_about from statictext within w_about
end type
type cb_home from commandbutton within w_about
end type
type st_credit from statictext within w_about
end type
type cb_github from commandbutton within w_about
end type
type cb_1 from commandbutton within w_about
end type
type st_version from statictext within w_about
end type
type st_1 from statictext within w_about
end type
end forward

global type w_about from window
integer width = 2267
integer height = 1228
boolean titlebar = true
string title = "PowerChrome"
boolean controlmenu = true
windowtype windowtype = response!
long backcolor = 67108864
string icon = "AppIcon!"
boolean center = true
st_about st_about
cb_home cb_home
st_credit st_credit
cb_github cb_github
cb_1 cb_1
st_version st_version
st_1 st_1
end type
global w_about w_about

on w_about.create
this.st_about=create st_about
this.cb_home=create cb_home
this.st_credit=create st_credit
this.cb_github=create cb_github
this.cb_1=create cb_1
this.st_version=create st_version
this.st_1=create st_1
this.Control[]={this.st_about,&
this.cb_home,&
this.st_credit,&
this.cb_github,&
this.cb_1,&
this.st_version,&
this.st_1}
end on

on w_about.destroy
destroy(this.st_about)
destroy(this.cb_home)
destroy(this.st_credit)
destroy(this.cb_github)
destroy(this.cb_1)
destroy(this.st_version)
destroy(this.st_1)
end on

event open;this.title = gnv_app.is_title

st_version.text = gnv_app.is_version
st_credit.text = gnv_app.is_credit
st_about.text = gnv_app.is_about

cb_github.visible = (gnv_app.is_github > '')
end event

type st_about from statictext within w_about
integer x = 64
integer y = 188
integer width = 2153
integer height = 440
integer textsize = -14
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Calibri"
long textcolor = 134217741
long backcolor = 67108864
string text = "Description of your application..."
boolean focusrectangle = false
end type

type cb_home from commandbutton within w_about
integer x = 123
integer y = 940
integer width = 393
integer height = 128
integer taborder = 30
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "HomePage"
end type

event clicked;gnv_app.of_shellrun(gnv_app.is_home)
end event

type st_credit from statictext within w_about
integer x = 151
integer y = 760
integer width = 1915
integer height = 84
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 8388736
long backcolor = 67108864
boolean enabled = false
string text = "Copyright 2022"
alignment alignment = center!
boolean focusrectangle = false
end type

type cb_github from commandbutton within w_about
integer x = 608
integer y = 940
integer width = 393
integer height = 128
integer taborder = 20
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Github"
end type

event clicked;gnv_app.of_shellrun( gnv_app.is_github )

end event

type cb_1 from commandbutton within w_about
integer x = 1691
integer y = 940
integer width = 393
integer height = 128
integer taborder = 10
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "&Close"
end type

event clicked;close(parent)
end event

type st_version from statictext within w_about
integer x = 151
integer y = 652
integer width = 1915
integer height = 84
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 8388736
long backcolor = 67108864
boolean enabled = false
string text = "Version: 0.60, build: 20221201"
alignment alignment = center!
boolean focusrectangle = false
end type

type st_1 from statictext within w_about
integer x = 59
integer y = 8
integer width = 2171
integer height = 160
integer textsize = -12
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Calibri"
long textcolor = 134217749
long backcolor = 67108864
boolean enabled = false
string text = "PowerChrome is a portable chromimum-base (cef) web browser for html/javascript desktop application development."
boolean focusrectangle = false
end type


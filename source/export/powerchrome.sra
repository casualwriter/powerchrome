$PBExportHeader$powerchrome.sra
$PBExportComments$PowerChrome - Web Browser For html/js application
forward
global type powerchrome from application
end type
global transaction sqlca
global dynamicdescriptionarea sqlda
global dynamicstagingarea sqlsa
global error error
global message message
end forward

global variables
u_application	gnv_app

end variables

global type powerchrome from application
string appname = "powerchrome"
boolean freedblibraries = true
string themepath = "C:\PortableApps\PowerBuilder 2019R3 Portable\IDE\theme"
string themename = "Do Not Use Themes"
boolean nativepdfvalid = false
boolean nativepdfincludecustomfont = false
string nativepdfappname = ""
long richtextedittype = 2
long richtexteditx64type = 3
long richtexteditversion = 1
string richtexteditkey = ""
string appicon = "powerchrome.ico"
string appruntimeversion = "19.2.0.2703"
end type
global powerchrome powerchrome

type variables

end variables

on powerchrome.create
appname="powerchrome"
message=create message
sqlca=create transaction
sqlda=create dynamicdescriptionarea
sqlsa=create dynamicstagingarea
error=create error
end on

on powerchrome.destroy
destroy(sqlca)
destroy(sqlda)
destroy(sqlsa)
destroy(error)
destroy(message)
end on

event open;gnv_app.event ue_open( commandline )
end event

event close;gnv_app.event ue_close()
end event

event idle;gnv_app.event ue_idle()
end event

event systemerror;gnv_app.event ue_error()
end event


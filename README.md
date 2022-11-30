## PowerChrome

PowerChrome is a portable chromimum-base (cef) web browser for html/javascript desktop application development.

PowerChrome provides a natual approach for html/javascript application development. It enabled HTML page for the 
accessibility of window shell / file system / database, and also provide additional application support 
by **PowerChome-Javascript-Interface** (run in **sync mode**)

Example of PowerChome-Javascript-Interface:

* Call notepad.exe ``pb.run('notepad.exe')``
* Eexecute file ``pb.shell('calc.exe')``
* Copy File  ``pb.fileCopy( sourceFile, targetFile )``
* Connect to oracle database ``pb.dbConnect( 'O90', dbParm, dbServer, logID, logPass )``
* Run SQL query (sync mode) ``rsStr = pb.dbQuery( 'select * from tablename' )``
* Run SQL query, and convert to json. ``rs = JSON.parse( pb.dbQuery( sql ) )``
* Get HTML source (sync mode) ``src = pb.httpSource(url)`` 
* Popup about dialog ``pb.window('w_about')``

#### Features

* Portable, no installation, no compile, no packing.
* Chromimum-base, may use Chrome/Chromimum for testing/debug
* HTML as application. Javascript for programming
* API run in **sync mode**. no callback, no promise object.
* Work with Powerbuilder for advanced functionality
* Cloud-App Enabled

### Get Started

Please download [powerchrome-0.56-with-runtime.zip](download/powerchrome-0.56-with-runtime.zip) 
and unzip the all-in-one package. Run powerchrome.exe.

The program will load powerchrome.html as startup page. The page demonstates how Powerchrome work with html as an desktop application.

![](powerchrome.jpg)

To start coding, just simple create index.html and write your code in any text editor

### Command Line Options

``powerchrome.exe /app={startup.html} /fullscreen /script={interface.js} /save={name.html} /save={name.pdf} /select={selector}``    

* specify application startup page by ``/app={startup.html}`` or ``/url={startup.html}``
* open application in fullscreen ``/fullscreen`` or ``/kiosk``
* use customized interface script by ``/script={interface.js}``
* crawl page by css-selector, and save to html file ``/ulr={link} /save={name.html} /css=selector``
* print page to pdf file ``/ulr={link} /save={name.pdf}``


### Compare with Powerpage

PowerChrome is rewritten based on same design idea of [Powerpage](https://github.com/casualwriter/powerpage) 
with significant improvement.

| Comparison       | PowerChrom        | PowerPage
|------------------|-----------------|----------
| Web Engine       | Chromimum         | IE 11
| Installation     | portable          | portable
| Package Size     | 170M              | 14M
| API (javascript) | sync mode         | async mode
| Developed By     | powerbuilder 2019R3 | powerbuilder 10.5
| Capability       | all purposes        |  simple application


### Security Consideration

All browser revoke the accessibility of system resource (shell/file system/database, etc..), because it is ricky to 
let html page have the accessibility without proper control.

PowerChrome provides all of them. please be aware the risk of a full-functional html page, and provide sufficient 
security according your application nature. 

* protect source program (should not be modified. better not visisble for end-user)
* protect sensitive information (e.g. encrypt password for database login)


### History and To-do List

2022/11/30, release version v0.56

#### To Do List

* documentation - Get Started
* pb.encode(text, manner), pb.decode(text,manner)
* pb.datawindow(elementID, parm, action) action:=preview|print|form|report
* documentation - API 
* documentation - development guide
* local application - markdown editor, web crawler
* cloud application - oracle schema, oracle helper


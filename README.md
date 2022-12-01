## PowerChrome for HTML/javascript application

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
* Get HTML source (sync mode) ``rs = pb.httpSource('https://hacker-news.firebaseio.com/v0/item/160705.json')`` 
* Popup html dialog ``pb.popup( 'sample-dialog.html', {width:1024,height:700} )``

#### Features

* Portable, no installation.
* Chromimum-base, may use Chrome/Chromimum for testing/debug.
* HTML as application. Javascript for programming.
* API run in **sync mode**. no callback, no promise object.
* Work with Powerbuilder for advanced functionality.
* Simple console support.
* Cloud-App Enabled.

### Get Started

Please download [powerchrome-0.56-with-runtime.zip](download/powerchrome-0.56-with-runtime.zip) 
and unzip the all-in-one package. Run powerchrome.exe.

`powerchrome.html` will be loaded to demonstates how PowerChrome work with html desktop application.

![](powerchrome.jpg)

### Application Startup

Powerchrome load the startup page by the following sequence:

1. commandline options: `/app={startup.html}`
2. ini config at [system] section: `start={startup.html}`
3. index.html 
4. powerchrome.html

after page loaded, `powerchrome.js` will be imported to initialize interface, then call js function `onPageRead()`

To start coding, just simply create ``index.html`` and write your code in any text editor

### Files & Deployment

Powerchrome is a single execution file (powerchrome.exe), only `powerchrome.exe, powerchrome.js` 
and `Powerbuilder-Runtime` is requried. The other files are options or depends on usage.

File Name       | Description
----------------|------------------------
powerchrome.exe | Powerchrome progam 
powerchrome.ini | ini config file (optional, recommeded for development only)
powerchrome.js  | javascript interface
powerchrome.html| html program of introduction an quick reference
powerchrome.pbl | source code of Powerbuilder (2019R3)
sample.mdb      | sample database (MS access)
sample-dialog.html | sample html dialog 
sample-dialog.js  | sample javascript for html dialog 


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

* should not include unknown (or untrust) javascript library
* should not visit unknown (or untrust) html page
* for local mode, protect source program (should not be modified. better not visisble for end-user)
* protect sensitive information (e.g. encrypt password for database login)

will discuss more in ``Development Guide -> Security Consideration``.


### To Do List

* documentation - Get Started
* documentation - API 
* documentation - Development Guide
* firewall of webApp (whitelist,blacklist)
* pb.datawindow(elementID, parm, action) action:=preview|print|form|report
* pb.encode(text, manner), pb.decode(text,manner)
* local application - markdown editor, web crawler
* cloud application - oracle schema, oracle helper, db-reporting

### History

2022/12/01, release version v0.56


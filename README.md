## PowerChrome

PowerChrome is a portable chromimum-base (cef) web browser for html/javascript desktop application development.

PowerChrome is a natual approach for html/javascript application development. it enabled HTML page for the 
accessibility of window shell / file system / database, and also provide additional application support 
by **PowerChome-Javascript-Interface**.

Example of PowerChome-Javascript-Interface:

* Call notepad.exe ``pb.run('notepad.exe')``
* Eexecute file ``pb.shell('calc.exe')``
* Copy File  ``pb.filecopy( sourceFile, targetFile )``
* Connect to oracle database ``pb.dbConnect( 'O90', dbParm, dbServer, logID, logPass )``
* Run SQL query (in sync mode) ``rsStr = pb.dbQuery( 'select * from tablename' )``
* Run SQL query, and convert to json. ``rs = JSONparse( pb.dbQuery( sql ) )``
* Get HTML source (sync mode) ``src = pb.httpSource(url)`` 
* Popup about dialog ``pb.window('w_about')``
* Run Powerbuilder Datawindow for reporting ``pb.datawindow( dwElementId, params )``

#### Features

* Portable, no installation
* Chromimum-base, may use Chrome/Chromimum for testing/debug
* HTML as application. Javascript for programming
* API run in **sync mode**. no callback, no promise object.
* Work with Powerbuilder for advanced functionality
* Cloud-App Enabled

### Get Started

Just download and unzip the package. run powerchrome.exe.

The program will load powerchrome.html as startup page. The page demonstates how Powerchrome work with html as an desktop application.

![](powerchrome.jpg)


### To Do List

* pb.httpSource(url, selector) // no Ajax needed, handy for crawl page
* pb.encode(text, manner), pb.decode(text,manner)
* Commandline: export to html/pdf. ``/url=link /output=name.html /output=name.pdf /selector=``
* release v0.60 
* documentation - API 
* documentation - development guide
* local application - markdown editor, web crawler
* cloud application - oracle schema, oracle helper


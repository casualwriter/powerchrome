## PowerChrome for HTML/javascript application

PowerChrome is a powerful and portable web browser that uses the Chromium engine to enable 
fast and easy development of desktop applications using HTML and JavaScript. 

With PowerChrome, you can quickly and easily write and run your own desktop applications, 
providing a seamless user experience for your users.

PowerChrome provides a natural approach to HTML and JavaScript application development. 
It allows HTML pages to access the window shell, file system, and database, and provides 
additional application support through the PowerChrome JavaScript Interface (which runs in sync mode).

Examples of the PowerChrome JavaScript Interface include:

* Calling notepad.exe: `pb.run('notepad.exe')`
* Executing a file: `pb.shell('calc.exe')`
* Copying a file: `pb.fileCopy(sourceFile, targetFile)`
* Connecting to an Oracle database: `pb.dbConnect('O90', dbParm, dbServer, logID, logPass)`
* Running a SQL query (in sync mode): `rsStr = pb.dbQuery('select * from tablename')`
* Running a SQL query and converting the results to JSON: `rs = JSON.parse(pb.dbQuery(sql))`
* Getting the HTML source of a page (in sync mode): `rs = pb.httpSource('https://hacker-* news.firebaseio.com/v0/item/160705.json')`
* Popup an HTML dialog: `pb.popup('sample-dialog.html', {width: 1024, height: 700})`

#### Features

* Portable - no installation required
* Chromium-based - can use Chrome/Chromium for testing and debugging
* HTML as the application format and JavaScript ES6 for programming
* API that runs in sync mode - no callback or promise objects
* Works with Powerbuilder for advanced functionality
* Simple console support
* Cloud-app enabled
* Run on Windows 7/8/10/11

### Get Started

1. Download [powerchrome-0.60-with-runtime.zip](https://casualwriter.github.io/download/powerchrome-0.60-with-runtime.zip) and unzip the all-in-one package.
2. Run `powerchrome.exe`.
3. `powerchrome.html` will be loaded to demonstrate how PowerChrome works as an HTML desktop application.

![](https://casualwriter.github.io/powerchrome/powerchrome.jpg)


### Application Startup

Powerchrome loads the startup page using the following sequence:

1. Commandline options: /app={startup.html}
1. INI config in the [system] section: start={startup.html}
1. index.html
1. powerchrome.html

After the page is loaded, `powerchrome.js` will be imported to initialize the interface, 
then call the JavaScript function `onPageLoaded()`.

To start coding, simply create an `index.html` file and write your code in any text editor.


### Files & Deployment

Powerchrome is a single execution file (powerchrome.exe), only `powerchrome.exe, powerchrome.js` 
and `Powerbuilder-Runtime` are requried. The other files are optionl or depends on usage.

File Name       | Description
----------------|------------------------
powerchrome.exe | Powerchrome progam 
powerchrome.js  | javascript interface
powerchrome.ini | ini config file (optional, recommeded for development only)
powerchrome.html| default html program. it is API quick reference 
powerchrome.pbl | source code of Powerbuilder (2019R3)
sample.mdb      | sample database (MS Access)
sample-dialog.html | sample html dialog 
sample-dialog.js  | sample javascript for html dialog 


### Command Line Options

``powerchrome.exe /app={startup.html} /fullscreen /script={interface.js} /save={name.html} /save={name.pdf} /select={selector}``    

* specify application startup page by ``/app={startup.html}`` or ``/url={startup.html}``
* open application in fullscreen ``/fullscreen`` or ``/kiosk``
* use customized interface script by ``/script={interface.js}``
* crawl page by css-selector, and save to html file ``/ulr={link} /save={name.html} /css={selector}``
* print page to pdf file ``/url={link} /save={name.pdf}``


### Cloud Mode and Security

Powerchrome will run in **cloud mode** when the startup link start with `https://` or `https://`. 

In cloud mode, **PowerChrome-Javascript-Interface** is available for the url in **SAME DOMAIN**. 

for example, run chromechrome.exe for web-application:

```
powerchrome.exe /app=https://casualwriter.github.io/powerchrome/powerchrome.html

```

API will only available for url start with ``https://casualwriter.github.io/powerchrome/``.
If navigate to another domain, Powerchrome work like normal chromium browser.


### Compare with Powerpage

PowerChrome is rewritten based on same design idea of [Powerpage](https://github.com/casualwriter/powerpage) 
with significant improvement.

| Comparison       | PowerChrom        | PowerPage
|------------------|-----------------|----------
| Web Engine       | chromium         | IE 11
| Installation     | portable          | portable
| Package Size     | 170M              | 14M
| API (javascript) | sync mode         | async mode
| Developed By     | powerbuilder 2019R3 | powerbuilder 10.5
| Capability       | all purposes        |  simple application


### To Do List

* documentation - API 
* documentation - Get Started
* documentation - Development Guide
* pb.datawindow(elementID, parm, action) action:=preview|print|form|report
* pb.encode(text, manner), pb.decode(text,manner)
* local application - markdown editor, web crawler
* cloud application - oracle schema, oracle helper, db-reporting


### History

* 2022/12/01, release version v0.56
* 2022/12/09, release v0.60, implement security for cloud mode.
* 2022/12/12, thanks `chatGPT` for refinement of some description


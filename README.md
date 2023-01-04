## PowerChrome for HTML/JavaScript application

PowerChrome is a portable chromium-base web browser to enable fast and easy development 
of desktop applications using HTML and JavaScript. 

With PowerChrome, you can quickly and easily write and run your own desktop applications, 
providing a seamless user experience for your users.

### Motivation

HTML is great for UI, and JavaScript is awesome for coding. However, developing web-base program 
for desktop is somehow frustrated experience as web browser revoke all accessibility of local 
resources. End-user will not understand why your program cannot access printer, open a file,
run another program or access database. You are hacking problems with hands and legs tied up. 

I had longed for a web browser which has DB connectivity and OS accessibility, so that can 
coding JavaScript/HTML/CSS application like Electron. so thankful that have chance to make one.

### JavaScript Interface

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
* Getting HTML source (in sync mode): `rs = pb.httpSource('https://hacker-news.firebaseio.com/v0/item/160705.json')`
* Popup an HTML dialog: `pb.popup('sample-dialog.html', {width: 1024, height: 700})`

### Features

* Portable - no installation required
* Chromium-based - can use Chrome/Chromium for testing and debugging
* HTML as the application format and JavaScript ES6 for programming
* API runs in sync mode - no callback or promise objects
* Simple console support
* Cloud-app enabled
* Run on Windows 7/8/10/11
  
  
## Get Started

### Download and Run

1. Download [powerchrome-0.60-with-runtime.zip](https://casualwriter.github.io/download/powerchrome-0.60-with-runtime.zip) and unzip the all-in-one package.
2. Run `powerchrome.exe`.
3. `powerchrome.html` will be loaded to demonstrate how PowerChrome works with an HTML desktop application.

![](https://casualwriter.github.io/powerchrome/powerchrome.jpg)


### Application Startup

PowerChrome loads the startup page using the following sequence:

1. Commandline options: `/app={startup.html}`
1. INI config in the [system] section: `start={startup.html}`
1. `index.html`
1. `powerchrome.html`

After the page is loaded, `powerchrome.js` will be imported to initialize the interface, 
then call the JavaScript function `onPageLoaded()`.

To start coding, simply create an `index.html` file and write your code in any text editor.
  

### Files & Deployment

The following files are included in the downloaded package 
[powerchrome-0.60-with-runtime.zip](https://casualwriter.github.io/download/powerchrome-0.60-with-runtime.zip)

Deploy | File Name       	| Description
-------|--------------------|------------------------
Yes | powerchrome.exe 	| PowerChrome program 
Yes | powerchrome.js		| JavaScript interface
    | powerchrome.ini 	| INI config file (optional, recommended for development only)
    | powerchrome.html	| Default HTML program. it is API quick reference 
    | powerchrome.pbl 	| Source code of Powerbuilder (2019R3)
    | sample*.*      	  | Sample files (HTML and MS Access Database)
Yes | *.dll           	| Powerbuilder-Runtime Libraries
Yes | .\pbcef           | chromium (cef)

PowerChrome is a single execution file (powerchrome.exe), only `powerchrome.exe, powerchrome.js` 
and `Powerbuilder-Runtime` are required. The other files are optional or depends on usage.
  

### Command-line Options

``powerchrome.exe /app={startup.html} /fullscreen /script={interface.js} /save={name.html} /save={name.pdf} /select={selector}``  

* specify application startup page by ``/app={startup.html}`` or ``/url={startup.html}``
* open application in fullscreen by ``/fullscreen`` or ``/kiosk``
* use customized interface script by ``/script={interface.js}``
* crawl page by css-selector, and save to HTML file ``/url={link} /save={name.html} /css=selector``
* print page to PDF file ``/url={link} /save={name.pdf}``
  
  
### Cloud Mode and Security

PowerChrome will run in **cloud-mode** when the startup link start with `https://` or `http://`. 

In cloud mode, **PowerChrome-JavaScript-Interface** is available for the URL in **SAME DOMAIN**. 

for example, run `chromechrome.exe` for web-application:

```
powerchrome.exe /app=https://casualwriter.github.io/powerchrome/powerchrome.html
```

API will only available for URL start with ``https://casualwriter.github.io/powerchrome/``.
If navigate to another domain, PowerChrome works like normal chromium browser.
  
  
## Documenation

still working on Documentation at https://casualwriter.github.io/powerchrome

* [Document Home](https://casualwriter.github.io/powerchrome/?file=index.md)
* [Getting Started](https://casualwriter.github.io/powerchrome/?file=get-started.md)
* [Interface (API)](https://casualwriter.github.io/powerchrome/?file=interface.md)
* [Development Guide](https://casualwriter.github.io/powerchrome/?file=development.md)

  
### History

* 2022/12/01, release version v0.56
* 2022/12/09, release v0.60, implement security for cloud mode.
* 2022/12/16-2023/01/04, update document, (Home, Getting Started, API, in progress..)


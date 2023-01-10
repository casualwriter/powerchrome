//==================================================================================
// Copyright 2022-2023, casualwriter, All Rights Reserved.
// PB interface for [PowerChrome](https://github.com/casualwriter/powerchrome) 
//==================================================================================
'use strict';

//=== pb main function, pb('id')=document.getElementById, pb.api() for interface
const pb = (id) => { return document.getElementById(id) }

// compose parameter string for {name1:val1, name2:val2} => name1=val1&name2=val2
pb.parms = function(args) {
  if (typeof args === "string" || typeof args === "number") {
    return '' + args
  } else if (typeof args === "object") {
    let i, opts = ''
    for (i in args) opts += (args[i]? '&' + i + '=' + encodeURIComponent(args[i]) : '' )
    return opts.substr(1);
  } else {  
    return ''
  } 
}

pb.api = ( cmd, args ) => { 
  let url = cmd + ( args? '?' + pb.parms(args) : '' )
  return window.webBrowser.ue_interface(url) 
}

if (typeof window.webBrowser === "undefined") {
  //=== polyfill window.webBrowser if loaded by chrome
  window.webBrowser = { name: 'simulate webBrowser object' }
  window.webBrowser.ue_interface = (x) => { console.log('[api]',x); return x }
  window.webBrowser.ue_message = (x) => { console.log('[api]',x); return x }
} else {
  //=== console support if loaded by PowerChrome
  console.log = pb.console = function () {
    let i, msg = ''
    for (i=0; i < arguments.length; i++) {
      if (typeof arguments[i] === "object") {
        msg += (i==0?'':', ') + JSON.stringify(arguments[i])
      } else {  
        msg += (i==0?'':', ') + arguments[i]
      }
    }
    return window.webBrowser.ue_message('console?' + msg)  
  }
} 

//=== property, session
pb.property = (name,value) => { return pb.api('property?' + name + (value? '=' + value : '') ) }
pb.session = (name,value) => { return pb.api('session?' + name + (value? '=' + value : '') ) }

//=== show message to statusbar/console, message dialog
pb.status  = (msg)      => { return window.webBrowser.ue_message('status?' + msg) } 
pb.alert   = (msg)      => { return window.webBrowser.ue_message('alert?' + msg) }
pb.error   = (code,msg) => { return window.webBrowser.ue_message('console?[error='+code+'] '+msg) }

pb.msgbox = ( title, msg, opt) => { 
  let parm = 'title=' + (title||document.title) + '&options=' + (opt||'ok')
  return window.webBrowser.ue_message('msgbox?' + parm + '&text=' + msg)  
}

// run, sendkeys, shell commands
pb.sendkeys = (keys) => { pb.api( 'sendkeys', keys ) }
pb.run = (cmd, path, style) => { return pb.api( 'run', { cmd:cmd, path:path, style:style } ) }

// opts:=[normal|min|max|hide] [open|runas|print|edit|explore|find]
pb.shell = (file, parm, path, options) => { 
  let args = Object.assign( {}, options, {file:file, parm:parm, path:path } )
  return pb.api( 'shell', args )
}

//=== http request
pb.httpSource = (url) => { return pb.api( 'http-source', url ) };
pb.httpUpload = (file,url) => { return pb.api('http-upload', {file:file, url:url} ) };

pb.httpRequest = (method, url, data, contentType) => { 
  data = ( typeof data==='string'? data : JSON.stringify(data) )
  return pb.api( 'http-request', { method: (method||'GET'), url: url, content:contentType, data:data } )
}

//=== database connection
pb.dbConnect = function (DBMS, dbParm, dbServer, logID, logPass) {
  let parm = 'dbms=' + DBMS + (dbParm? '&dbparm=' + encodeURIComponent(dbParm) : '' )
  parm += (dbServer? '&servername=' + encodeURIComponent(dbServer) : '' )
  parm += (dbServer? '&logid=' + encodeURIComponent(logID) : '' )
  parm += (dbServer? '&logpass=' + encodeURIComponent(logPass) : '' )
  return pb.api( 'db-connect?' + parm )
}

pb.dbDisconnect = () => { return pb.api('db-disconnect') }
pb.dbCommit =     () => { return pb.api('db-commit')     }
pb.dbRollback =   () => { return pb.api('db-rollback')   }
pb.dbQuery = (sql)   => { return pb.api('db-query', sql) }
pb.dbTable = (sql)   => { return pb.api('db-table', sql) }
pb.dbExecute = (sql) => { return pb.api('db-execute', sql) }

// call powerbuilder window/dialog
pb.about  = () => { pb.api('window?name=w_about') }
pb.window = (name,parm)  => { return pb.api( 'window', { name:name, parm:parm } ) }
pb.extfunc = (name,parm) => { return pb.api( 'extfunc', { name:name, parm:parm } ) }

// poup dialog, goto url with further processing
pb.popup = (url, opt)  => { return pb.api( 'popup', Object.assign( {url:url}, opt ) ) }

// print, saveas
pb.print      = () => { pb.api('print') }
pb.printSetup = () => { pb.api('printsetup') }
pb.saveas = (file) => { return pb.api( 'saveas', {file:file} ) }

// file functions
pb.fileExists = (file) => { return pb.api( 'file-exists', {name:file} ) }
pb.fileDelete = (file) => { return pb.api( 'file-delete', {name:file} ) }
pb.fileRead   = (file) => { return pb.api( 'file-read', {name:file} ) }
pb.fileAppend = (file, text) => { return pb.api( 'file-append', { name:file, text:text } ) }
pb.fileWrite  = (file, text) => { return pb.api( 'file-write', { name:file, text:text } ) }
pb.fileCopy = (src, target)  => { return pb.api('file-copy', {source:src, target:target }) }
pb.fileMove = (src, target)  => { return pb.api('file-move', {source:src, target:target }) }

pb.fileOpenDialog = (title, path, filter) => { 
  return pb.api( 'file-open-dialog', { title: title, path: path, filter: filter } ) 
}

pb.fileSaveDialog = ( title, path, filter ) => {
  return pb.api( 'file-save-dialog', { title: title, path: path, filter: filter } ) 
}

pb.dir       = ()     => { return pb.api( 'dir-current' )  }
pb.dirExists = (path) => { return pb.api( 'dir-exists',  path )  }
pb.dirChange = (path) => { return pb.api( 'dir-change', path )  }
pb.dirCreate = (path) => { return pb.api( 'dir-create', path )  }
pb.dirDelete = (path) => { return pb.api( 'dir-delete', path )  }
pb.dirSelect = (title) => { return pb.api( 'dir-select', title )  }

// misc functions
pb.sleep = (ms) => { return pb.api( 'sleep', ms )  }
pb.close = (rtn) => { return pb.api( 'close', rtn )  }

// HTML Selector funciton (selector for outerHTML, @select for innerText, null for header+body)
pb.html = function (selector) {
  let i, divs, html=''  
  if (!selector) {
    html = '<!DOCTYPE html>\n' + document.head.outerHTML + '\n' + document.body.outerHTML + '\n'
  } else if (selector[0] == '@') {
    divs = document.querySelectorAll( selector.substr(1) )
    for (i=0; i<divs.length; i++ ) html += divs[i].innerText + '\n'
  } else {
    divs = document.querySelectorAll( selector )
    for (i=0; i<divs.length; i++ ) html += divs[i].outerHTML + '\n'
  } 
  return html
}

'PowerChrome v0.60c@2023/01/06'

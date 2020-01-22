var itemMap = new Object();
var DrawerWidth = 360;
var DrawerHeight = 40;
var DrawerMargin = 10;
var HomePage = "https://duckduckgo.com";
var RandomString = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
var UserAgent = "Mozilla/5.0 (X11; CrOS armv7l 10895.56.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.102 Safari/537.36";

function openNewTab(pageid, url) {
    //console.log("openNewTab: "+ pageid + ', currentTab: ' + currentTab);
    if (hasTabOpen) {
        tabModel.insert(0, { "title": "Loading..", "url": url, "pageid": pageid, "favicon": "icons/favicon.png" } );
        // hide current tab and display the new
        itemMap[currentTab].visible = false;
    } else {
        tabModel.set(0, { "title": "Loading..", "url": url, "pageid": pageid, "favicon": "icons/favicon.png" } );
    }
    var webView = tabWebView.createObject(content, { id: pageid, objectName: pageid } );
    webView.url = url; // FIXME: should use loadUrl() wrapper 

    itemMap[pageid] = webView;
    currentTab = pageid;
    tabListView.currentIndex = 0 // move highlight to top  
}

function openNewTermTab(pageid) {
    //console.log("openNewTab: "+ pageid + ', currentTab: ' + currentTab);
    if (hasTabOpen) { 
        tabModel.insert(0, { "title": "Terminal", "url": "term://", "pageid": pageid, "favicon": "icons/favicon.png" } );
        itemMap[currentTab].visible = false;
    } else {
        tabModel.set(0, { "title": "Terminal", "url": "term://", "pageid": pageid, "favicon": "icons/favicon.png" } );
    }
    var termView = tabTermView.createObject(content, { id: pageid, objectName: pageid } );
    itemMap[pageid] = termView;

    if (currentTab !== pageid && currentTab !== "") { 
        itemMap[currentTab].visible = false;   
    }

    currentTab = pageid;
    tabListView.currentIndex = 0
    itemMap[currentTab].visible = true;
    urlText.text = itemMap[currentTab].url;
}

function switchToTab(pageid) {
    //console.log("switchToTab: "+ pageid + " , from: " + currentTab + ' , at ' + tabListView.currentIndex);
    if (currentTab !== pageid ) { 
        itemMap[currentTab].visible = false;
        currentTab = pageid;
    }
    itemMap[currentTab].visible = true;
    // assign url to text bar
    urlText.text = itemMap[currentTab].url;
}

function closeTab(deleteIndex, pageid) { 
    //console.log('closeTab: ' + pageid + ' at ' + deleteIndex + ': ' + tabModel.get(deleteIndex))
    //console.log('\ttabListView.model.get(deleteIndex): ' + tabListView.model.get(deleteIndex).pageid)
    itemMap[pageid].visible = false; 
    tabModel.remove(deleteIndex);
    itemMap[pageid].destroy(); 
    delete(itemMap[pageid])

    if (hasTabOpen) { 
        // FIXME: after closed, Qt 5.1 doesn't change tabListView.currentIndex  
        if (tabModel.count == 1 && tabListView.currentIndex == 1) tabListView.currentIndex = 0;  
        currentTab = tabListView.model.get( tabListView.currentIndex ).pageid
        switchToTab(currentTab)
    } else {
        urlText.text = "";
        currentTab = ""; // clean currentTab 
    }
} 

function loadUrl(url) {
    if (url == "term://") {
        tabBounce.start(); // visual cue that we opened a new tab
        openNewTermTab("page"+salt());
    } else if (hasTabOpen) { 
        itemMap[currentTab].url = fixUrl(url)
    } else { 
        openNewTab("page"+salt(), fixUrl(url));
    }
    itemMap[currentTab].focus = true;
}

function fixUrl(url) {
    url = url.replace( /^\s+/, "").replace( /\s+$/, ""); // remove white space
    url = url.replace( /(<([^>]+)>)/ig, ""); // remove <b> tag 
    if (url == "") return url;
    if (url[0] == "/") { return "file://"+url; }
    if (url[0] == '.') { 
        var str = itemMap[currentTab].url.toString();
        var n = str.lastIndexOf('/');
        return str.substring(0, n)+url.substring(1);
    }
    //FIXME: search engine support here
    if (url.startsWith('chrome://')) { return url; } 
    if (url.indexOf('.') < 0) { return "https://duckduckgo.com/?q="+url; }
    if (url.indexOf(":") < 0) { return "https://"+url; } 
    else { return url;}
}

function salt(){
    var salt = ""
    for( var i=0; i < 5; i++ ) {
        salt += RandomString.charAt(Math.floor(Math.random() * RandomString.length));
    }
    return salt
}

function getDatabase() {
    var db = LocalStorage.openDatabaseSync("cutiepi-shell", "1.0", "history db", 100000);
    db.transaction(
        function(tx) { 
            tx.executeSql('CREATE TABLE IF NOT EXISTS history (url TEXT, title TEXT, icon TEXT, date INTEGER)');
        }
    );
    db.transaction(function(tx) {tx.executeSql('CREATE TABLE IF NOT EXISTS previous (url TEXT)'); });
    return db;
}

function updateHistory(url, title, icon) { 
    var date = new Date();
    var db = getDatabase();
    db.transaction(
        function(tx) {
            var result = tx.executeSql('delete from history where url=(?);',[url])
        }
    );
    db.transaction(
        function(tx) {
            var result = tx.executeSql('insert into history values (?,?,?,?);',[url, title, icon, date.getTime()])
            if (result.rowsAffected < 1) {
                console.log("Error inserting url: " + url)
            } else {
            }
        }
    );
}

function highlightTerms(text, terms) {
    if (text === undefined || text === '') {
        return ''
    }
    var highlighted = text.toString()
    highlighted = highlighted.replace(new RegExp(terms, 'ig'), '<b>$&</b>')
    return highlighted
}

function queryHistory(str) {
    var db = getDatabase();
    var result; 
    db.transaction(
        function(tx) {
            result = tx.executeSql("select * from history where url like ?", ['%'+str+'%']) 
        }
    );
    historyModel.clear();
    suggestionContainer.historyListView.currentIndex = 0;
    for (var i=0; i < result.rows.length; i++) {
        historyModel.insert(0, {"url": highlightTerms(result.rows.item(i).url, str), 
        "title": result.rows.item(i).title});
    }
    suggestionContainer.historyListView.currentIndex = 0;
}
import QtQuick 2.14
import QtWebEngine 1.7
import QtQuick.Window 2.2

Window {
    title: webview.title
    width: 800
    height: 1280
    visible: true

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

    FontLoader {
        id: icon
        source: "file:///opt/cutiepi-shell/Font Awesome 5 Free-Solid-900.otf" 
    }

    Rectangle { 
        id: headerBar  
        width: parent.width
        height: 85 
        anchors { top: parent.top; left: parent.left }
        color: '#ECEFF4'

        Item {
            id: backButton
            width: 30; height: 30; anchors { left: headerBar.left; leftMargin: 80; margins: 20; top: parent.top; topMargin: 22 }
            Text { 
                id: backButtonIcon
                text: "\uF053" 
                font { family: icon.name; pointSize: 28 }
                color: webview.canGoBack ? "#434C5E" : "lightgray"
            }

            MouseArea { 
                anchors.fill: parent; anchors.margins: -5; 
                enabled: webview.canGoBack 
                onPressed: backButtonIcon.color = "#bf616a"; 
                onClicked: { webview.goBack() }
                onReleased: backButtonIcon.color = "#434C5E"; 
            }
        }

        Rectangle {
            id: urlBar
            width: parent.width - 510
            height: 55
            color: "#D8DEE9"; border.width: 0; border.color: "#2E3440";
            visible: true 
            anchors {
                top: parent.top
                left: parent.left
                margins: 20; topMargin: 15; leftMargin: 125
            }
            radius: 26

            TextInput { 
                id: urlText
                text: ""
                font.pointSize: 18; color: "#2E3440"; selectionColor: "#434C5E"
                anchors { left: parent.left; top: parent.top; right: stopButton.left; margins: 11; }
                height: parent.height
                inputMethodHints: Qt.ImhNoAutoUppercase // url hint 
                clip: true
                
                onAccepted: { 
                    webview.url = fixUrl(urlText.text)
                }
                onActiveFocusChanged: { 
                    if (urlText.activeFocus) { 
                        webview.stop();
                        urlText.selectAll();
                        Qt.inputMethod.show();
                    } else { 
                        parent.border.color = "#2E3440"; parent.border.width = 0; 
                    }
                }
                onTextChanged: {
                    //if (urlText.activeFocus && urlText.text !== "") {
                    //    Tab.queryHistory(urlText.text)
                    //} else { historyModel.clear() }
                }
            }
            Text {
                id: stopButton
                anchors { right: urlBar.right; rightMargin: 8; verticalCenter: parent.verticalCenter}
                text: "\uF00D"
                font { family: icon.name; pointSize: 18 }
                color: "gray"
                visible: (webview.loadProgress < 100 && !urlText.focus) ? true : false
                MouseArea {
                    anchors { fill: parent; margins: -10; }
                    onClicked: { webview.stop(); }
                }
            }
            Text {
                id: reloadButton
                anchors { right: urlBar.right; rightMargin: 8; verticalCenter: parent.verticalCenter}
                text: "\uF01E"
                font { family: icon.name; pointSize: 14 }
                color: "gray"
                visible: (webview.loadProgress == 100 && !urlText.focus ) ? true : false 
                MouseArea {
                    anchors { fill: parent; margins: -10; }
                    onClicked: { webview.reload(); }
                }
            }
            Text {
                id: clearButton
                anchors { right: urlBar.right; rightMargin: 8; verticalCenter: parent.verticalCenter}
                text: "\uF057"
                font { family: icon.name; pointSize: 18 }
                color: "gray"
                visible: urlText.focus
                MouseArea {
                    anchors { fill: parent; margins: -10; }
                    onClicked: { urlText.text = ""; urlText.focus = true; }
                }
            }
        }
        Rectangle { 
            id: urlProgressBar 
            height: 4
            visible: webview.loadProgress < 100
            width: parent.width * (webview.loadProgress/100)
            anchors { bottom: headerBar.bottom; left: parent.left }
            color: "#bf616a" 
        }
    }

    WebEngineView {
        id: webview 
        anchors { top: headerBar.bottom; left: parent.left; right: parent.right; bottom: parent.bottom } 
        url: "https://duckduckgo.com"
        profile: WebEngineProfile {
            offTheRecord: true
        }
        onLoadingChanged: { 
            urlText.text = webview.url;
        }
    }
}
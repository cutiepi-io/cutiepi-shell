import QtQuick 2.12
import QtWebEngine 1.7

WebEngineView { 
    id: webView
    anchors.fill: parent
    anchors.topMargin: 85
    z: 2 
    profile: WebEngineProfile {
        httpUserAgent: "Mozilla/5.0 (X11; CrOS armv7l 10895.56.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.102 Safari/537.36"
        storageName: "Profile"
        offTheRecord: false
    }
}
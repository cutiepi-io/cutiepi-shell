import QtQuick 2.14
import QtWebEngine 1.7
import QtQuick.Window 2.2

Window {
    title: webview.title
    width: view.width
    height: view.height 
    visible: true

    WebEngineView {
		id: webview 
        anchors.fill: parent
        url: "https://duckduckgo.com"
        profile: WebEngineProfile {
            offTheRecord: true
        }
    }
}
import QtQuick 2.12

Item {
    id: suggestionContainer

    property alias historyListView: historyListView

    width: root.portraitMode ? 400 : urlBar.width
    height: suggestionDialog.height + 55
    anchors { top: urlBar.bottom; topMargin: -8; left: urlBar.left; }
    visible: (urlText.focus && historyModel.count > 0) && root.state !== "setting"
    z: 3

    Rectangle {
        id: suggestionDialog
        color: "#ececec"
        radius: 5 
        anchors.centerIn: parent 
        width: root.portraitMode ? 400 : urlBar.width 
        height: (historyModel.count > 3) ? ((historyModel.count <= 6) ? historyModel.count * 50 : 410) : 180
        anchors { top: parent.top; topMargin: 50; left: parent.left; }
        visible: (urlText.focus && historyModel.count > 0) && root.state !== "setting"

        Text { // caret-up 
            anchors.top: parent.top
            anchors.topMargin: -32
            anchors.left: parent.horizontalCenter
            anchors.leftMargin: root.portraitMode ? - (urlBar.width/2) : -20
            font { family: fontAwesome.name; pointSize: 20 }
            text: "\uF0D8"; 
            color: "#ECEFF4" 
        }

        ListView { 
            id: historyListView
            anchors.fill: parent
            anchors.topMargin: 20
            anchors.bottomMargin: 15
            clip: true
            model: historyModel 
            delegate: historyDelegate

            Component {
                id: historyDelegate
                Rectangle { 
                    color: "transparent"
                    height: 50 
                    width: historyListView.visible ? historyListView.width : 0
                    Text {                          
                        anchors {                       
                            top: parent.top; left: parent.left; right: parent.right
                            margins: 6; leftMargin: 10;
                        }                               
                        text: '<b>'+ model.title +'<b>' 
                        font.pointSize: 8
                        elide: Text.ElideRight
                    }  
                    Text {                          
                        anchors {                       
                            top: parent.top; left: parent.left; right: parent.right
                            margins: 8;          
                            topMargin: 30; leftMargin: 10;
                        }                               
                        color: "#3e3e3e"
                        text: model.url                 
                        font.pointSize: 6 
                        elide: Text.ElideMiddle         
                    }
                    MouseArea { 
                        anchors.fill: parent; 
                        onClicked: view.loadUrlWrapper(model.url)
                    }
                }
            }
            highlight: Rectangle { 
                color: '#d4d4d4'
            }
            highlightMoveDuration: 2
        } // end of historyListView
    }

}

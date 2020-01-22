import QtQuick 2.12

Item {
    id: suggestionContainer

    property alias historyListView: historyListView

    width: urlBar.width
    height: suggestionDialog.height + 55
    anchors { top: urlBar.bottom; topMargin: -15; left: urlBar.left; }
    visible: (urlText.focus && historyModel.count > 0)
    z: 3

    Rectangle {
        id: suggestionDialog
        color: "#ECEFF4"
        radius: 5 
        anchors.centerIn: parent 
        width: urlBar.width 
        height: (historyModel.count > 3) ? ((historyModel.count <= 6) ? historyModel.count * 50 : 410) : 180
        anchors { top: parent.top; topMargin: 50; left: parent.left; }

        Text { // caret-up 
            anchors.top: parent.top
            anchors.topMargin: -25
            anchors.left: parent.horizontalCenter
            anchors.leftMargin: -15
            font { family: icon.name; pointSize: 17 }
            text: "\uF0D8"; 
            color: "#ECEFF4" 
        }

        ListView { 
            id: historyListView
            anchors.fill: parent
            anchors.topMargin: 15 
            anchors.bottomMargin: 15
            clip: true
            model: historyModel 
            delegate: historyDelegate

            Component {
                id: historyDelegate
                Rectangle { 
                    color: "transparent"
                    height: 50 
                    width: parent.width 
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
                        color: "#434C5E"
                        text: model.url                 
                        font.pointSize: 6 
                        elide: Text.ElideMiddle         
                    }
                    MouseArea { 
                        anchors.fill: parent; 
                        onClicked: root.loadUrlWrapper(model.url)
                    }
                }
            }
            highlight: Rectangle { 
                color: "#81a1c1"
            }
            highlightMoveDuration: 2
        } // end of historyListView
    }

}
import QtQuick 2.15
import QtQuick.Controls 2.15

Dialog {
    width: 360 
    height: 360 
    visible: false 
    signal timeZoneSelected(string text)
    modal: true
    anchors.centerIn: parent
    property alias rotation: container.rotation
    Item {
        id: container
        anchors.fill: parent
        ListView {
            id: listView
            anchors.fill: parent
            clip: true
            model: listModel 
            delegate: Rectangle {
                width: 360 
                height: 30
                clip: true
                Text { text: model.name; font.pointSize: xcbFontSizeAdjustment + 8 }
                MouseArea {
                    anchors.fill: parent
                    onClicked: timeZoneSelected(model.name)
                }
            }
        }
    }
    ListModel { id: listModel }
    Component.onCompleted: {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", "./timezone.txt", true); 
        xhr.onreadystatechange = function()
        {
            if (xhr.readyState == xhr.DONE) {
                var response = xhr.responseText.split("\n");
                for (var i=0; i < response.length; i++) {
                    listModel.append( { "name": response[i]} );
                }
                listView.forceLayout()
            }
        }
        xhr.send();
    }
}
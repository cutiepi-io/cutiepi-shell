import QtQuick 2.14

Image {
    id: lockscreen 

    property alias lockscreenMosueArea: lockscreenMosueArea
    property alias lockscreenTime: lockscreenTime
    property alias lockscreenDate: lockscreenDate 

    visible: ( root.state == "locked" )
    source: wallpaperUrl 
    fillMode: Image.PreserveAspectCrop
    z: 6
    x: 0; y: 0; width: parent.width; height: parent.height 
    MouseArea {
        id: lockscreenMosueArea
        anchors.fill: parent 
        drag.target: lockscreen; drag.axis: Drag.YAxis; drag.maximumY: 0
        onReleased: { 
            if (lockscreen.y > -480) { bounce.restart(); } else { root.state = "normal"; lockscreen.y = 0; } 
        } 
    }
    NumberAnimation { id: bounce; target: lockscreen; properties: "y"; to: 0; easing.type: Easing.InOutQuad; duration: 200 }
    Text { 
        id: lockscreenTime
        text: Qt.formatDateTime(new Date(), "HH:mm"); color: 'white'; font.pointSize: 26; 
        anchors { left: parent.left; bottom: lockscreenDate.top; leftMargin: 30; bottomMargin: 5 }
    }
    Text { 
        id: lockscreenDate
        text: Qt.formatDateTime(new Date(), "dddd, MMMM d"); color: 'white'; font.pointSize: 16; 
        anchors { left: parent.left; bottom: parent.bottom; margins: 30 }
    }
}
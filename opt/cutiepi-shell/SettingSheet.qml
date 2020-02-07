import QtQuick 2.14

// setting sheet 
Rectangle {
    id: settingSheet
    width: setting.width - 20 
    height: 600 
    color: "#2E3440"
    anchors { right: parent.right;  }
    y: -600
    radius: 22
    z: 3 

    // volume bar
    Rectangle{
        id: volumeBar
        anchors{
            topMargin: 75
            top: parent.top
            left: parent.left
            right: parent.right
        }
        width: parent.width - 20
        height: 30
        color: "transparent"

        Image {
            id: volumeMuted
            source: "icons/audio-volume-muted-symbolic.svg"
            width: 30; height: width; sourceSize.width: width*2; sourceSize.height: height*2;
            anchors{
                left: parent.left
                leftMargin: 15
                verticalCenter: parent.verticalCenter
            }
        }

        Image {
            id: volumeHigh
            source: "icons/audio-volume-high-symbolic.svg"
            width: 30; height: width; sourceSize.width: width*2; sourceSize.height: height*2;
            anchors{
                right: parent.right
                rightMargin: 20
                verticalCenter: parent.verticalCenter
            }
        }

        Rectangle{
            id: volumeBarTrack
            anchors{
                verticalCenter: parent.verticalCenter
                right: volumeHigh.left
                left: volumeMuted.right
                rightMargin: 20
                leftMargin: 20
            }
            height: 2
            radius: 1
            color: "#ECEFF4"
        }

        Rectangle{
            id: volumeBarThumb
            height: 30
            width: 30
            radius: 15
            y: volumeBarTrack.y - height/2
            x: volumeBarTrack.x + volumeBarTrack.width/2

            MouseArea{
                anchors.fill: parent
                drag.target: volumeBarThumb; drag.axis: Drag.XAxis; drag.minimumX: volumeBarTrack.x; drag.maximumX: volumeBarTrack.x - width + volumeBarTrack.width
            }

            onXChanged: {
                var fullrange = volumeBarTrack.width - volumeBarThumb.width
                var vol = 100*(volumeBarThumb.x - volumeBarTrack.x)/fullrange
                if(vol <= 2)
                    setting.audio.source = "icons/audio-volume-muted-symbolic.svg"
                else if(vol < 25)
                    setting.audio.source = "icons/audio-volume-low-symbolic.svg"
                else if(vol < 75)
                    setting.audio.source = "icons/audio-volume-medium-symbolic.svg"
                else
                    setting.audio.source = "icons/audio-volume-high-symbolic.svg"
            }
        }
    }

    // orientation lock
    Rectangle{
        id: orientationLock
        anchors{
            topMargin: 10
            top: volumeBar.bottom
            left: parent.left
            right: parent.right
        }

        width: parent.width - 25
        height: 40
        color: "transparent"

        Text {
            text: "Orientation Lock"
            color: "#ECEFF4"
            anchors{
                verticalCenter: parent.verticalCenter
                left: parent.left
                leftMargin: 10
            }
            font.pointSize: 9
        }

        Rectangle{
            id: toggleTrack
            anchors{
                verticalCenter: parent.verticalCenter
                right: parent.right
                rightMargin: 20
            }
            width: 60
            height: 30
            radius: 15
            color: sensorEnabled ? "grey" : "limegreen"

            Rectangle{
                id: toggleThumb
                anchors{
                    top: parent.top
                    bottom: parent.bottom
                    right: parent.right
                }
                width: 30
                height: 30
                radius: 15
                color: "white"

                states: [
                    State {
                        name: "enabled"
                        AnchorChanges { target: toggleThumb; anchors.left: undefined; anchors.right: parent.right }
                    },
                    State {
                        name: "disabled"
                        AnchorChanges { target: toggleThumb; anchors.left: parent.left; anchors.right: undefined }
                    }
                ]
            }

            MouseArea{
                anchors.fill: parent
                onClicked: {
                    sensorEnabled = !sensorEnabled
                    if (sensorEnabled)
                        toggleThumb.state = "enabled"
                    else
                        toggleThumb.state = "disabled"
                }
            }
        }
    }

    // separator
    Rectangle{
        id: separator
        anchors{
            right: parent.right
            left:parent.left
            top: orientationLock.bottom
            topMargin: 10
            leftMargin: 20; rightMargin: 20
        }
        height: 1
        color: "#ECEFF4"
    }

    // wifi scan result 
    ListView {
        id: wifiListView
        visible: root.state == "setting" 
        clip: true
        anchors {
            bottomMargin: 15
            topMargin: 15
            top: separator.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        /*
        model: networkingModel
        delegate: Rectangle {
            height: 45
            width: parent.width 
            color: 'transparent' 
            Row {
                width: parent.width - 40 
                height: parent.height
                spacing: 10

                Rectangle { 
                    width: 30
                    height: 20
                    color: 'transparent'
                    anchors.verticalCenter: parent.verticalCenter
                    Text {
                        font.family: icon.name 
                        font.pixelSize: 12
                        text: (modelData.state == "online" || modelData.state == "ready") ? "\uf00c" : ""
                        color: "#ECEFF4"
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                Text {
                    text: (modelData.name == "") ? "[Hidden Wifi]" : modelData.name
                    color: "#ECEFF4"
                    elide: Text.ElideRight
                    width: 230
                    anchors.verticalCenter: parent.verticalCenter
                    font.pointSize: 9
                }
            }
            Row {
                anchors {
                    right: parent.right
                    top: parent.top
                    bottom: parent.bottom
                    rightMargin: 30
                }
                width: 50
                spacing: 10
                Rectangle {
                    width: 20
                    height: 20 
                    color: 'transparent'
                    anchors.verticalCenter: parent.verticalCenter
                    Image { 
                        width: 20; height: width; sourceSize.width: width*2; sourceSize.height: height*2;
                        source: (modelData.security[0] == "none") ? "" : "icons/network-wireless-encrypted-symbolic.svg"
                    }
                }
                Image {
                    width: 20; height: width; sourceSize.width: width*2; sourceSize.height: height*2;
                    source: if (modelData.strength >= 55 ) { return "icons/network-wireless-signal-excellent-symbolic.svg" }
                    else if (modelData.strength >= 50 ) { return "icons/network-wireless-signal-good-symbolic.svg" }
                    else if (modelData.strength >= 45 ) { return "icons/network-wireless-signal-ok-symbolic.svg" }
                    else if (modelData.strength >= 30 ) { return "icons/network-wireless-signal-weak-symbolic.svg" }
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (modelData.state == "idle" || modelData.state == "failure") {
                        networkingModel.networkName = modelData.name 
                        modelData.requestConnect()
                    }
                }
            }
        }
        */
    }
}
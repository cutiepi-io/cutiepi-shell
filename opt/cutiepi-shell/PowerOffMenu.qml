import QtQuick 2.15 

Item {
    id: switchOff
    visible: ( root.state == "switchoff" )
    anchors.fill: parent
    z: 7
    Rectangle {
        id: switchoffContainer
        anchors.fill: parent
        color: "#3B4252"

        Rectangle{
            id: switchoffSlider
            width: 480
            height: 110
            radius: 55
            anchors.top: parent.top
            anchors.topMargin: 100
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#81A1C1"
            Text {
                anchors.centerIn: parent
                color: "white"
                leftPadding: 55
                text: "Slide to power off"
            }

            Rectangle {
                id: switchoffThumb
                height: 100
                width: 100
                radius: 50
                anchors.verticalCenter: parent.verticalCenter
                x: 5
                color: "#ECEFF4"

                MouseArea {
                    id: switchoffMouseArea
                    anchors.fill: parent
                    drag.target: switchoffThumb
                    drag.axis: Drag.XAxis
                    drag.minimumX: 5
                    drag.maximumX: switchoffSlider.width - switchoffThumb.width - 5

                    onReleased: {
                        if(switchoffThumb.x < 290)
                            resetSwitchoffThumb.start();
                    }
                }
                
                Text { anchors.centerIn: parent; 
                    text: "\uf011"; font.family: icon.name }

                NumberAnimation {
                    id: resetSwitchoffThumb
                    target: switchoffThumb
                    properties: "x"
                    to: 5
                    easing.type: Easing.InOutQuad
                    duration: 200
                }

                onXChanged: {
                    if(switchoffThumb.x >= (switchoffSlider.width - switchoffThumb.width - 10)){
                        switchoffThumb.x = 5;
                        switchoffScreen = false;
                        mcuInfo.confirmShutdown();
                    }
                }
            }
        }

        Rectangle {
            id: cancelSwitchOff
            width: 100
            height: 100
            radius: 50
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 150
            color: "#ECEFF4"
            Text {
                anchors.centerIn: parent
                color: "black"
                text: "\uf00d"
                font.family: icon.name
		        Text { text: "Cancel"; anchors.top: parent.bottom; anchors.topMargin: 40; 
                    anchors.horizontalCenter: parent.horizontalCenter; color: 'white' } 
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    switchoffScreen = false
                    mcuInfo.cancelShutdown();
                }
            }
        }
    }

}
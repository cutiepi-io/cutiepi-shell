import QtQuick 2.15
import QtMultimedia 5.15
import QtQuick.Controls 2.15

Rectangle {
    anchors.fill: parent
    color: 'lightgray'

    Row {
        anchors.fill: parent
        anchors.margins: 100
        spacing: 50 

        Column {
            width: parent.width/2
            spacing: 10
            Text { text: "Charging status: " + ( view.batteryCharging ? "true" : "false" ); font.pointSize: 14 }
            Text { text: "Measured voltage: " + (mcuInfo.battery/1000).toFixed(3); font.pointSize: 14 }
            Text { text: "Orientation: " + view.orientation; font.pointSize: 14 }

            MediaPlayer {
                id: mediaplayer
                source: 'gst-pipeline: libcamerasrc ! video/x-raw,width=1920,height=1080,framerate=30/1 ! videoconvert ! qtvideosink'
                autoPlay: true
            }

            VideoOutput {
                width: 400; height: 300
                source: mediaplayer
            }

            Row { 
                spacing: 20; 
                Text { text: "Microphone/Speaker: "; font.pointSize: 14 } 
                Button { 
                    text: "Test"; onClicked: process.start("/opt/cutiepi-shell/assets/mic-test.sh", []);
                } 
            }
        }
    }

    Rectangle { 
        id: rebootButton
        width: 280
        height: 50
        color: 'darkgray'
        anchors {
            right: finishTest.left
            rightMargin: 20
            bottom: parent.bottom
            bottomMargin: 100
        }
        radius: 6
        Text {
            anchors.centerIn: parent;
            text: "Reboot";
            font.pointSize: xcbFontSizeAdjustment + 8; color: 'white'
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                process.start("sudo", [ "reboot" ]);
            }
        } 
    }

    Rectangle {
        id: finishTest
        width: 280
        height: 50
        color: finishTestMouseArea.enabled ? '#4875E2' : 'darkgray'
        anchors {
            right: parent.right
            bottom: parent.bottom
            margins: 100
        }
        radius: 6
        Text {
            anchors.centerIn: parent;
            text: finishTestMouseArea.enabled ? "Done" : "Test Finished" ;
            font.pointSize: xcbFontSizeAdjustment + 8; color: 'white'
        }
        MouseArea {
            id: finishTestMouseArea
            anchors.fill: parent
            onClicked: {
                settings.setValue("untested", "false")
                enabled = false
            }
        }
    }
}

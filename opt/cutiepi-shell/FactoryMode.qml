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
        Component.onCompleted: mcuInfo.getVersion();

        Column {
            width: parent.width/2
            spacing: 10
            Text { text: "Firmware version: " + mcuInfo.version }
            Text { text: "Charging status: " + ( (mcuInfo.charge == 4) ? "true" : "false" ) }
            Text { text: "Measured voltage: " + (mcuInfo.battery/1000).toFixed(3);  }
            Text { text: "Accelerometer: " + accel.reading.x.toFixed(3) + ", " + accel.reading.y.toFixed(3) + ", " + accel.reading.z.toFixed(3) }

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
                Text { text: "Microphone/Speaker: " } 
                Button { 
                    text: "Record"; onClicked: process.start("arecord", ["-f", 'S16_LE', "-D", "hw:2,0", "-d", "5", "/tmp/record.wav"] )
                } 
                Button { 
                    text: "Play"; onClicked: process.start("aplay", ["/tmp/record.wav"] )
                } 
            }
        }
    }
}

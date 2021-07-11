import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    anchors.fill: parent
    color: 'white'

    Component.onCompleted: {
        mcuInfo.getVersion();
    }

    Column {
        anchors.fill: parent
        anchors.margins: 50
        anchors.topMargin: 20
        spacing: 30

        Rectangle {
            width: parent.width
            height: 200
            color: 'white'
            border.width: 1
            border.color: 'lightgray'
            radius: 15 

            Row {
                anchors.fill: parent
                anchors.margins: 20
                Column {
                    width: parent.width * 2/3
                    spacing: 10
                    Text { text: "About"; font.pointSize: 12; font.bold: true; bottomPadding: 20 }

                    Text { text: "Build id: f4e5f88"; font.pointSize: 8 }
                    Text { text: "Firmware version: " + ( mcuInfo.version !== "" ? mcuInfo.version.split(/;/)[0] : "" ) ; font.pointSize: 8 }
                    Text { text: "Serial number: " + ( mcuInfo.version !== "" ? mcuInfo.version.split(/;/)[1] : "" ) ; font.pointSize: 8 }
                }
                Column {
                    width: parent.width * 1/3
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.topMargin: 100
                    spacing: 10
                    Rectangle {
                        width: parent.width - 30
                        height: 50
                        radius: 5
                        color: 'gray'
                        Text { anchors.centerIn: parent; text: "Check for update"; font.pointSize: 8; color: 'white' }
                    }
                }
            }


        }

        Rectangle {
            width: parent.width
            height: 210 
            color: 'white'
            border.width: 1
            border.color: 'lightgray'
            radius: 15 

            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 10
                Text { text: "System"; font.pointSize: 12; font.bold: true; bottomPadding: 20 }

                Text { text: "Airplane mode"; font.pointSize: 8; }
                Text { text: "Keyboard language"; font.pointSize: 8; }
                Text { text: "Timezone"; font.pointSize: 8; }
            }
        }

        Rectangle {
            width: parent.width
            height: 170 
            color: 'white'
            border.width: 1
            border.color: 'lightgray'
            radius: 15 

            Row {
                anchors.fill: parent
                anchors.margins: 20
                Column {
                    width: parent.width * 2/3
                    spacing: 10
                    Text { text: "More Options"; font.pointSize: 12; font.bold: true; bottomPadding: 20 }
                    Text { text: "Default UI"; font.pointSize: 8 }
                }
                Column {
                    width: parent.width * 1/3
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.topMargin: 80
                    spacing: 10
                    Rectangle {
                        width: parent.width - 30
                        height: 50
                        radius: 5
                        color: 'gray'
                        Text { anchors.centerIn: parent; text: "Go to Desktop"; font.pointSize: 8; color: 'white' }
                    }
                }
            }
        }
    }
}

import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt.labs.folderlistmodel 2.15
import QtQuick.Layouts 1.15
import Process 1.0

Rectangle {
    anchors.fill: parent
    color: '#F7F6F4'

    Component.onCompleted: mcuInfo.getVersion();
    Process { id: command }

    Flickable {
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: content.implicitHeight + 100
        clip: true

        Rectangle {
            anchors.fill: parent
            color: '#F7F6F4'

            Column {
                id: content
                anchors.fill: parent
                anchors.margins: 50
                anchors.topMargin: 100
                spacing: 10

                Rectangle {
                    width: parent.width
                    height: systemContent.implicitHeight + 100 
                    color: 'transparent'

                    Text { 
                        anchors {
                            top: parent.top
                            left: parent.left 
                            margins: 25
                        }
                        text: "System" 
                        color: '#5C5C5C'
                        font.pointSize: 10
                    }

                    Rectangle {
                        id: systemSettingSheet
                        width: parent.width - 220 
                        height: parent.height - 50 
                        color: '#ffffff'
                        anchors { 
                            right: parent.right 
                            top: parent.top 
                            margins: 20
                            rightMargin: 0
                        }
                        border.width: 1
                        border.color: '#eeeff0'
                        radius: 6 

                        Column {
                            id: systemContent
                            width: parent.width 
                            topPadding: 15
                            leftPadding: 15 
                            spacing: 30 

                            Rectangle {
                                width: parent.width - 50; height: 50 
                                Text { 
                                    text: "Airplane Mode"; font.pointSize: 9; 
                                    anchors {
                                        verticalCenter: parent.verticalCenter
                                        left: parent.left; 
                                    }
                                } 
                                Switch { 
                                    anchors {
                                        right: parent.right
                                        verticalCenter: parent.verticalCenter
                                    }
                                }
                            }

                            Rectangle {
                                width: parent.width - 50; height: 50 
                                Text { 
                                    text: "Timezone"; font.pointSize: 9; 
                                    anchors {
                                        verticalCenter: parent.verticalCenter
                                        left: parent.left; 
                                    }
                                } 
                                Text { 
                                    id: timeZoneText
                                    width: 120
                                    color: '#5C5C5C'
                                    anchors {
                                        right: parent.right
                                        verticalCenter: parent.verticalCenter
                                    }
                                    horizontalAlignment: Text.AlignRight
                                    text: "Asia/Tokyo"
                                    font.pointSize: 8
                                    rightPadding: 20 
                                    MouseArea {
                                        anchors.fill: parent
                                        anchors.margins: -5 
                                        onClicked: { timeZoneMenu.visible = true }
                                    }
                                }
                                TimeZoneDialog {
                                    id: timeZoneMenu
                                    rotation: view.orientation 
                                    onTimeZoneSelected: {
                                        timeZoneText.text = text 
                                        timeZoneMenu.visible = false
                                    }
                                }
                            }

                            Rectangle {
                                width: parent.width - 50; height: 50 
                                Text {
                                    id: powerModeTitle
                                    text: "Power Mode"; font.pointSize: 9; 
                                    anchors {
                                        verticalCenter: parent.verticalCenter
                                        left: parent.left; 
                                    }
                                    Text { 
                                        font.pointSize: 7; 
                                        color: '#5C5C5C'
                                        text: switch(powerModeSlider.value) {
                                            case 0: "Power Saving"; break;
                                            case 1: "Balance"; break;
                                            case 2: "Performance"; break;
                                        }
                                        anchors { top: powerModeTitle.bottom; topMargin: 5 } 
                                    }
                                }
                                
                                Slider { 
                                    id: powerModeSlider
                                    z: 1 
                                    anchors {
                                        right: parent.right
                                        verticalCenter: parent.verticalCenter
                                    }
                                    from: 0
                                    to: 2
                                    snapMode: Slider.SnapAlways	
                                    stepSize: 1
                                    value: 1
                                }
                            }
                        }
                    }

                    Rectangle { 
                        width: parent.width - 10
                        height: 1 
                        anchors { top: systemSettingSheet.bottom; margins: 30; left: parent.left; leftMargin: 10; }
                        color: '#e5e7eb'
                    }
                }

                Rectangle {
                    width: parent.width
                    height: interfaceContent.implicitHeight + 100  
                    color: 'transparent'

                    Text { 
                        anchors {
                            top: parent.top
                            left: parent.left 
                            margins: 25
                        }
                        text: "Interface" 
                        color: '#5C5C5C'
                        font.pointSize: 10
                    }

                    Rectangle {
                        id: interfaceSettingSheet
                        width: parent.width - 220 
                        height: parent.height - 50 
                        color: '#ffffff'
                        anchors { 
                            right: parent.right 
                            top: parent.top 
                            margins: 20
                            rightMargin: 0
                        }
                        border.width: 1
                        border.color: '#eeeff0'
                        radius: 6 
                        Column {
                            id: interfaceContent
                            width: parent.width 
                            topPadding: 15
                            leftPadding: 15 
                            spacing: 30 

                            Rectangle {
                                width: parent.width - 50; height: 50 
                                Text { 
                                    text: "Enable Adblocker"; font.pointSize: 9; 
                                    anchors {
                                        verticalCenter: parent.verticalCenter
                                        left: parent.left; 
                                    }
                                } 
                                Switch { 
                                    anchors {
                                        right: parent.right
                                        verticalCenter: parent.verticalCenter
                                    }
                                }
                            }
                            Rectangle {
                                width: parent.width - 50; height: 50 
                                Text { 
                                    text: "Wallpaper"; font.pointSize: 9; 
                                    anchors {
                                        verticalCenter: parent.verticalCenter
                                        left: parent.left; 
                                    }
                                } 
                                Text { 
                                    width: 120
                                    color: '#5C5C5C'
                                    anchors {
                                        right: parent.right
                                        verticalCenter: parent.verticalCenter
                                    }
                                    horizontalAlignment: Text.AlignRight
                                    font.pointSize: 8
                                    rightPadding: 20 
                                    text: view.wallpaperUrl.toString().slice(view.wallpaperUrl.toString().lastIndexOf("/")+1)
                                    anchors {
                                        right: parent.right
                                        verticalCenter: parent.verticalCenter
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        anchors.margins: -5 
                                        onClicked: { wallpaperDialog.visible = true }
                                    }
                                    WallpaperDialog {
                                        id: wallpaperDialog
                                        rotation: view.orientation
                                        anchors.centerIn: parent
                                        onWallpaperSelected: { 
                                            view.wallpaperUrl = fileName 
                                            wallpaperDialog.visible = false
                                        }
                                    }
                                }
                            }
                            Rectangle {
                                width: parent.width - 50; height: 80 
                                Text { 
                                    text: "Default UI"; font.pointSize: 9; 
                                    anchors {
                                        verticalCenter: parent.verticalCenter
                                        left: parent.left; 
                                    }
                                }
                                ColumnLayout {
                                    anchors {
                                        right: parent.right
                                        bottom: parent.bottom
                                    }
                                    RadioButton {
                                        id: defaultUiCutiePi
                                        checked: true
                                        text: "CutiePi Shell"
                                            contentItem: Text {
                                            text: parent.text
                                            font.pointSize: 8
                                            color: '#5C5C5C'
                                            verticalAlignment: Text.AlignVCenter
                                            leftPadding: parent.indicator.width + parent.spacing
                                        }
                                    }
                                    RadioButton {
                                        text: "PIXEL Desktop"
                                            contentItem: Text {
                                            text: parent.text
                                            font.pointSize: 8
                                            color: '#5C5C5C'
                                            verticalAlignment: Text.AlignVCenter
                                            leftPadding: parent.indicator.width + parent.spacing
                                        }
                                    }
                                }
                            }
                            Rectangle {
                                width: parent.width - 50; height: 60 
                                Rectangle {
                                    width: 280
                                    height: 50
                                    color: '#4875E2'
                                    anchors {
                                        right: parent.right
                                        bottom: parent.bottom
                                    }
                                    radius: 6
                                    Text { anchors.centerIn: parent; text: "Switch to Desktop now"; font.pointSize: 8; color: 'white' }
                                    MouseArea { 
                                        anchors.fill: parent
                                        onClicked: command.start("/usr/local/bin/start-lightdm.sh", []);
                                    }
                                }
                            }
                        }
                    }

                    Rectangle { 
                        width: parent.width - 10
                        height: 1 
                        anchors { top: interfaceSettingSheet.bottom; margins: 30; left: parent.left; leftMargin: 10; }
                        color: '#e5e7eb'
                    }
                }
                Rectangle {
                    width: parent.width
                    height: aboutContent.implicitHeight + 100 
                    color: 'transparent'

                    Text { 
                        anchors {
                            top: parent.top
                            left: parent.left 
                            margins: 25
                        }
                        text: "About" 
                        color: '#5C5C5C'
                        font.pointSize: 10
                    }

                    Rectangle {
                        width: parent.width - 220 
                        height: parent.height - 50 
                        color: '#ffffff'
                        anchors { 
                            right: parent.right 
                            top: parent.top 
                            margins: 20
                            rightMargin: 0
                        }
                        border.width: 1
                        border.color: '#eeeff0'
                        radius: 6 
                        Column {
                            id: aboutContent
                            width: parent.width 
                            topPadding: 15
                            leftPadding: 15 
                            spacing: 30 

                            Rectangle {
                                width: parent.width - 50; height: 50 
                                Text { 
                                    text: "Build ID"; font.pointSize: 9; 
                                    anchors {
                                        verticalCenter: parent.verticalCenter
                                        left: parent.left; 
                                    }
                                } 
                                Text { 
                                    width: 120
                                    color: '#5C5C5C'
                                    anchors {
                                        right: parent.right
                                        verticalCenter: parent.verticalCenter
                                    }
                                    horizontalAlignment: Text.AlignRight
                                    text: "79222b7"
                                    font.pointSize: 8
                                    rightPadding: 20 
                                }
                            }
                            Rectangle {
                                width: parent.width - 50; height: 50 
                                Text { 
                                    text: "Firmware version"; font.pointSize: 9; 
                                    anchors {
                                        verticalCenter: parent.verticalCenter
                                        left: parent.left; 
                                    }
                                } 
                                Text { 
                                    width: 120
                                    color: '#5C5C5C'
                                    anchors {
                                        right: parent.right
                                        verticalCenter: parent.verticalCenter
                                    }
                                    horizontalAlignment: Text.AlignRight
                                    text: view.mcuVersion.split(/ /)[0]
                                    font.pointSize: 8
                                    rightPadding: 20 
                                }
                            }
                            Rectangle {
                                width: parent.width - 50; height: 50 
                                Text { 
                                    text: "Serial number"; font.pointSize: 9; 
                                    anchors {
                                        verticalCenter: parent.verticalCenter
                                        left: parent.left; 
                                    }
                                } 
                                Text { 
                                    width: 120
                                    color: '#5C5C5C'
                                    anchors {
                                        right: parent.right
                                        verticalCenter: parent.verticalCenter
                                    }
                                    horizontalAlignment: Text.AlignRight
                                    text: view.mcuVersion.split(/:/)[1]
                                    font.pointSize: 8
                                    rightPadding: 20 
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
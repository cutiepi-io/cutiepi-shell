import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt.labs.folderlistmodel 2.15
import QtQuick.Layouts 1.15
import Process 1.0

Rectangle {
    anchors.fill: parent
    color: '#F7F6F4'

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
                anchors.topMargin: 60
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
                        font.pointSize: xcbFontSizeAdjustment + 10
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
                                    text: "Airplane Mode"; font.pointSize: xcbFontSizeAdjustment + 9; 
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
                                    onCheckedChanged: { 
                                        if (checked) 
                                            command.start("sudo", ["rfkill", "block", "all"]);
                                        else
                                            command.start("sudo", ["rfkill", "unblock", "all"]);
                                    }
                                }
                            }

                            Rectangle {
                                width: parent.width - 50; height: 50 
                                Text { 
                                    text: "Timezone"; font.pointSize: xcbFontSizeAdjustment + 9; 
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
                                    text: settings.value("timezone", "UTC");
                                    font.pointSize: xcbFontSizeAdjustment + 8
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
                                        timeZoneMenu.visible = false;
                                        settings.setValue("timezone", text);
                                        timeZoneText.text = settings.value("timezone");
                                        command.start("sudo", ["timedatectl", "set-timezone", settings.value("timezone")]);
                                        view.setSystemClock();
                                    }
                                }
                            }

                            Rectangle {
                                width: parent.width - 50; height: 50 
                                Text {
                                    id: powerModeTitle
                                    text: "Power Mode"; font.pointSize: xcbFontSizeAdjustment + 9; 
                                    anchors {
                                        verticalCenter: parent.verticalCenter
                                        left: parent.left; 
                                    }
                                    Text { 
                                        font.pointSize: xcbFontSizeAdjustment + 7; 
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
                                    onValueChanged: {
                                        switch(powerModeSlider.value) {
                                            case 0: command.start("sudo", ["cpufreq-set", "-g", "powersave"]); break;
                                            case 1: command.start("sudo", ["cpufreq-set", "-g", "conservative"]); break;
                                            case 2: command.start("sudo", ["cpufreq-set", "-g", "performance"]); break;
                                        }
                                    }
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
                        text: "Appearance" 
                        color: '#5C5C5C'
                        font.pointSize: xcbFontSizeAdjustment + 10
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
                                    text: "Enable Adblocker"; font.pointSize: xcbFontSizeAdjustment + 9; 
                                    anchors {
                                        verticalCenter: parent.verticalCenter
                                        left: parent.left; 
                                    }
                                } 
                                Switch { 
                                    checked: settings.value("enableAdblocker", true);
                                    anchors {
                                        right: parent.right
                                        verticalCenter: parent.verticalCenter
                                    }
                                    onCheckedChanged: { settings.setValue("enableAdblocker", checked) }
                                }
                            }
                            Rectangle {
                                width: parent.width - 50; height: 50 
                                Text { 
                                    text: "Wallpaper"; font.pointSize: xcbFontSizeAdjustment + 9; 
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
                                    font.pointSize: xcbFontSizeAdjustment + 8
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
                                            settings.setValue("wallpaperUrl", fileName);
                                            view.wallpaperUrl = settings.value("wallpaperUrl");
                                            wallpaperDialog.visible = false
                                        }
                                    }
                                }
                            }
                            Rectangle {
                                width: parent.width - 50; height: 80 
                                Text { 
                                    text: "Default UI"; font.pointSize: xcbFontSizeAdjustment + 9; 
                                    anchors {
                                        verticalCenter: parent.verticalCenter
                                        left: parent.left; 
                                    }
                                    Text { 
                                        font.pointSize: xcbFontSizeAdjustment + 7; 
                                        color: '#5C5C5C'
                                        text: "Effective after reboot"
                                        anchors { top: parent.bottom; topMargin: 5 } 
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
                                            font.pointSize: xcbFontSizeAdjustment + 8
                                            color: '#5C5C5C'
                                            verticalAlignment: Text.AlignVCenter
                                            leftPadding: parent.indicator.width + parent.spacing
                                        }
                                        onCheckedChanged: {
                                            if (checked)
                                                settings.setValue("defaultVisibility", "FullScreen");
                                            else
                                                settings.setValue("defaultVisibility", "Hidden");
                                        }
                                    }
                                    RadioButton {
                                        text: "PIXEL Desktop"
                                            contentItem: Text {
                                            text: parent.text
                                            font.pointSize: xcbFontSizeAdjustment + 8
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
                                    id: switchDesktopButton
                                    width: 280
                                    height: 50
                                    color: switchDesktopMouseArea.enabled ? '#4875E2' : 'darkgray' 
                                    anchors {
                                        right: parent.right
                                        bottom: parent.bottom
                                    }
                                    radius: 6
                                    Text { 
                                        anchors.centerIn: parent; 
                                        text: switchDesktopMouseArea.enabled ? "Switch to Desktop now" : "Loading..." ; 
                                        font.pointSize: xcbFontSizeAdjustment + 8; color: 'white' 
                                    }
                                    MouseArea {
                                        id: switchDesktopMouseArea
                                        anchors.fill: parent
                                        onClicked: { 
                                            view.visibility = "Hidden"
                                            //command.start("gsettings", ["set", "org.gnome.settings-daemon.peripherals.touchscreen", "orientation-lock", "false"]);
                                        }
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
                        font.pointSize: xcbFontSizeAdjustment + 10
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
                                    text: "Build ID"; font.pointSize: xcbFontSizeAdjustment + 9; 
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
                                    text: "b8f4e5c"
                                    font.pointSize: xcbFontSizeAdjustment + 8
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
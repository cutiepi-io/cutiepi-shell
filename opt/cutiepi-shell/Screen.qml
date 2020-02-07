import QtQuick 2.14
import QtQuick.Window 2.2
import QtWayland.Compositor 1.14
import Liri.XWayland 1.0 as LXW

import QtQuick.Controls 2.1
import QtSensors 5.11
//import MeeGo.Connman 0.2 

import McuInfo 1.0
import Process 1.0

WaylandOutput {
    id: compositor
    property variant formatDateTimeString: "HH:mm"
    property variant batteryPercentage: ""
    property variant queue: []
    property bool screenLocked: false
    property bool batteryCharging: false
    property variant wallpaperUrl: "file:///usr/share/rpd-wallpaper/temple.jpg" 

    property real pitch: 0.0
    property real roll: 0.0
    readonly property double radians_to_degrees: 180 / Math.PI
    property variant orientation: 180 
    property variant sensorEnabled: true 

    property int drawerWidth: 360 
    property int drawerMargin: 10
    property int drawerHeight: 40 

    function handleShellSurface(shellSurface) {
        shellSurfaces.insert(0, {shellSurface: shellSurface});
    }

    onScreenLockedChanged: {
        if (screenLocked) {
            process.start("raspi-gpio", ["set", "12", "dl"]);
            root.state = "locked";
            lockscreen.lockscreenMosueArea.enabled = false; 
        } else {
            process.start("raspi-gpio", ["set", "12", "dh"]);
            lockscreen.lockscreenMosueArea.enabled = true; 
        }
    }

    onOrientationChanged: {
        var i = sidebar.tabListView.currentIndex;
        shellSurfaces.get(i).shellSurface.sendConfigure(Qt.size(view.height, view.width), WlShellSurface.NoneEdge);
    }

    Item {
        id: root
        state: "normal" 
        states: [
            State {
                name: "setting"
                PropertyChanges { target: settingSheet; y: 0 } 
            },
            State { name: "locked" }, 
            State { name: "popup" }, 
            State{
                name: "drawer"
                PropertyChanges { target: content; anchors.leftMargin: drawerWidth }
            },
            State {
                name: "normal"
                PropertyChanges { target: content; anchors.leftMargin: 0 }
                PropertyChanges { target: settingSheet; y: -600 + 65 }
            }
        ]

        transitions: [
            Transition {
                to: "*"
                NumberAnimation { target: settingSheet; properties: "y"; duration: 400; easing.type: Easing.InOutQuad; }
                NumberAnimation { target: content; properties: "anchors.leftMargin"; duration: 300; easing.type: Easing.InOutQuad; }
            }
        ]
    }

    sizeFollowsWindow: true
    window: Window {
        visible: true
        Rectangle {
            id: view 
            color: "#2E3440"
            width: (orientation == 180 || orientation == 0) ? 800 : 1280
            height: (orientation == 180 || orientation == 0) ? 1280 : 800 
            x: (orientation == 180 || orientation == 0) ? 0 : -240 
            y: (orientation == 180 || orientation == 0) ? 0 : 240
            rotation: orientation 

            Rectangle { anchors.fill: parent; color: '#2E3440' }

            Component.onCompleted: {
                mcuInfo.start();
            }

            Process { id: process }
            Component { 
                id: procComponent 
                Process {} 
            }

            McuInfo {
                id: mcuInfo
                portName: "/dev/ttyS0"
                portBaudRate: 115200

                property variant batteryAttributes: 
                    { '4.20': 100, '4.15': 95, '4.11': 90, '4.08': 85, '4.02': 80, '3.98': 75, '3.95': 70, 
                    '3.91': 65, '3.87': 60, '3.85': 55, '3.84': 50, '3.82': 45, '3.80': 40, '3.79': 35, 
                    '3.77': 30, '3.75': 25, '3.73': 20, '3.71': 15, '3.69': 10, '3.61': 5, '3.27': 0 }

                onButtonChanged: {
                    screenLocked = !screenLocked
                }
                onBatteryChanged: {
                    if (battery > 5) { 
                        var currentVol = (battery/1000).toFixed(2); 
                        var sum = 0; 
                        queue.push(currentVol); 
                        if (queue.length > 10)
                            queue.shift()
                        for (var i = 0; i < queue.length; i++) {
                            sum += parseFloat(queue[i])
                        }
                        var meanVol = (sum/queue.length).toFixed(2);
                        for (var vol in batteryAttributes) {
                            if (meanVol >= parseFloat(vol)) { 
                                var volPercent = batteryAttributes[vol];
                                batteryPercentage = volPercent
                                break;
                            }
                        }
                    } else { // temporary hack for charging signal 
                        if (battery == 4) batteryCharging = true 
                        if (battery == 5) batteryCharging = false 
                    }
                }
            }

            Accelerometer {
                id: accel
                active: sensorEnabled
                dataRate: 100
                onReadingChanged: {
                    var accX = accel.reading.x
                    var accY = accel.reading.y - 2 //experimental calibration
                    var accZ = -accel.reading.z

                    var pitchAcc = Math.atan2(accY, accZ)*radians_to_degrees;
                    var rollAcc = Math.atan2(accX, accZ)*radians_to_degrees;

                    pitch = pitch * 0.98 + pitchAcc * 0.02;
                    roll = roll * 0.98 + rollAcc * 0.02;
                    
                    //update orientation
                    if(pitch >= 30.0)
                        orientation = 0
                    else if(pitch <= -30.0)
                        orientation = 180
                    if(roll >= 30.0)
                        orientation = 270
                    else if(roll <= -30.0)
                        orientation = 90 
                }
            }

            Gyroscope {
                id: gyro
                active: sensorEnabled
                dataRate: 100
                onReadingChanged: {
                    //integrate gyro rates to update angles (pitch and roll)
                    var dt=0.01 //10ms
                    pitch += gyro.reading.x*dt;
                    roll -= gyro.reading.y*dt;
                }
            }

            FontLoader {
                id: icon
                source: "file:///opt/cutiepi-shell/Font Awesome 5 Free-Solid-900.otf" 
            }

            SideBar { id: sidebar }

            Rectangle {
                id: content 
                anchors.fill: parent 

                // navi bar 
                Rectangle {
                    id: naviBar
                    color: "#ECEFF4"
                    width: parent.width 
                    height: 85
                    anchors {
                        top: parent.top
                        right: parent.right
                    }
                }

                MouseArea { 
                    id: overlayMouseArea 
                    anchors.fill: parent 
                    z: 3
                    enabled: (root.state == "setting" || root.state == "popup" || root.state == "drawer" )
                    onClicked: { 
                        if ( root.state == "setting" || root.state == "drawer") 
                            root.state = "normal"
                    }
                }

                Rectangle { 
                    width: 10; height: 10; color: "#2E3440"; z: 2; anchors { top: parent.top; right: setting.left } 
                }
                Rectangle { 
                    width: 24; height: 24; color: "#ECEFF4"; radius: 12; z: 3; anchors { top: parent.top; right: setting.left }
                }
                Rectangle { 
                    width: setting.width - 20; height: 65 + 25; color: "#2E3440"; z: 3 
                    anchors { top: parent.top; right: parent.right; topMargin: -25 } radius: 22 
                }

                Rectangle {
                    color: "transparent"
                    width: 85 
                    height: 85
                    anchors { top: parent.top; left: parent.left }
                    z: 3 
                    // hamburger button 
                    Text {
                        id: hamburgerButton
                        font.pointSize: 14
                        font.family: icon.name 
                        text: "\uf0c9"
                        color: "#434C5E"
                        anchors {
                            left: parent.left; margins: 22; verticalCenter: parent.verticalCenter;
                        }
                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -20 
                            // open or close the drawer 
                            onClicked: {
                                root.state == "drawer" ? root.state = "normal" : root.state = "drawer"
                                Qt.inputMethod.hide();
                            }
                        }
                    }
                }

                SettingSheet { id: settingSheet } 
                StatusArea { id: setting }

                Repeater {
                    anchors { top: naviBar.bottom; left: parent.left; bottom: parent.bottom; right: parent.right }
                    model: shellSurfaces
                    delegate: Component {
                        Loader {
                            source: ( modelData.toString().match(/XWaylandShellSurface/) ) ? 
                                "XWaylandChrome.qml" : "WaylandChrome.qml" 
                        }
                    }
                }
            }

            LockScreen { id: lockscreen }

            Loader {
                anchors.fill: parent
                source: "Keyboard.qml"
            }
        }
    }
}
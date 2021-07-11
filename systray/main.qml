import QtQuick 2.15
import McuInfo 1.0
import Process 1.0
import QtSensors 5.11
import Qt.labs.platform 1.1

Item {
    property bool batteryCharging: false
    property bool screenLocked: false
    property bool powerOffButton: false

    property real pitch: 0.0
    property real roll: 0.0
    readonly property double radians_to_degrees: 180 / Math.PI

    property variant orientation: 270

    property variant batteryPercentage: ""
    property variant meanVol: ""
    property variant queue: []

    Component.onCompleted: {
        mcuInfo.start();
    }

    function turnScreenOn() { setScreenBrightness(100) }
    function turnScreenOff() { setScreenBrightness(0) }
    function setScreenBrightness(val) { process.start("/opt/cutiepi-shell/assets/setBrightness", [val]); }

    onOrientationChanged: {
        process.start("rotate-screen", [orientation]);
    }

    onScreenLockedChanged: {
        if (screenLocked) 
            turnScreenOff()
        else 
            turnScreenOn()
        powerOffButton = false;
    }

    onPowerOffButtonChanged: {
        if (powerOffButton) {
            turnScreenOn();
            process.start("lxde-pi-shutdown-helper", []);
        }
    }

    SystemTrayIcon {
        visible: true
        icon.source: if (batteryCharging) { "images/battery-full-charged-symbolic.svg" }
            else if (batteryPercentage >= 80) { "images/battery-full-symbolic.svg" }
            else if (batteryPercentage >= 50) { "images/battery-good-symbolic.svg" }
            else if (batteryPercentage >= 30) { "images/battery-low-symbolic.svg" }
            else if (batteryPercentage >= 20) { "images/battery-caution-symbolic.svg" }
            else { "images/battery-empty-symbolic.svg" }
        onActivated: showMessage("Battery: " + batteryPercentage + "%", "Measured voltage: " + meanVol + " v")
    }

    Process { id: process }

    McuInfo {
        id: mcuInfo
        portName: "/dev/ttyS0"
        portBaudRate: 115200

        property variant batteryAttributes: 
            { '4.20': 100, '3.99': 95, '3.97': 90, '3.92': 85, '3.87': 80, '3.83': 75, '3.79': 70, 
              '3.75': 65, '3.73': 60, '3.70': 55, '3.68': 50, '3.66': 45, '3.65': 40, '3.63': 35, 
              '3.62': 30, '3.60': 25, '3.58': 20, '3.545': 15, '3.51': 10, '3.42': 5, '3.00': 0 }

        onButtonChanged: {
            if (button == 1)
                screenLocked = !screenLocked;
            if (button == 3) {
                powerOffButton = true;
            }
        }

        onBatteryChanged: {
            var currentVol = (battery/1000).toFixed(2); 
            var sum = 0; 
            queue.push(currentVol); 
            if (queue.length > 10)
                queue.shift()
            for (var i = 0; i < queue.length; i++) {
                sum += parseFloat(queue[i])
            }
            meanVol = (sum/queue.length).toFixed(2);
            for (var vol in batteryAttributes) {
                if (meanVol >= parseFloat(vol)) { 
                    var volPercent = batteryAttributes[vol];
                    batteryPercentage = volPercent
                    break;
                }
            }
        }

        onChargeChanged: {
            if (charge == 4) batteryCharging = true 
            if (charge == 5) batteryCharging = false 
        }
    }

    Accelerometer {
        id: accel
        active: true
        dataRate: 30
        onReadingChanged: {
            var accX = accel.reading.x
            var accY = accel.reading.y - 2 //experimental calibration
            var accZ = -accel.reading.z

            var pitchAcc = Math.atan2(accY, accZ)*radians_to_degrees;
            var rollAcc = Math.atan2(accX, accZ)*radians_to_degrees;

            pitch = pitch * 0.98 + pitchAcc * 0.02;
            roll = roll * 0.98 + rollAcc * 0.02;
            
            var tmp = orientation;

            //update orientation
            if(pitch >= 30.0)
                tmp = 0
            else if(pitch <= -30.0)
                tmp = 180
            if(roll >= 30.0)
                tmp = 270
            else if(roll <= -30.0)
                tmp = 90 

            orientation = tmp;
        }
    }

    Gyroscope {
        id: gyro
        active: true
        dataRate: 30
        onReadingChanged: {
            //integrate gyro rates to update angles (pitch and roll)
            var dt=0.01 //10ms
            pitch += gyro.reading.x*dt;
            roll -= gyro.reading.y*dt;
        }
    }
}

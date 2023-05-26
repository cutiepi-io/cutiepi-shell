import QtQuick 2.15
import Nemo.DBus 2.0

Item {
    id: wifiManager

    property bool wifiEnable: true
    property bool airplaneMode: false
    property string networkState: "unkonwn"
    property string currentSSID: ""
    property int currentStrength: 0
    property alias networkModel: networkModel 

    signal accessPointsLoaded()

    ListModel { 
        id: networkModel
    }

    Timer {
        id: getAPTimer
        running: false
        interval: 2000
        repeat: false
        onTriggered: {
            getAccessPoints();
            getAPTimer.running = false;
        }
    }

    DBusInterface {
        id: nmInterface
        bus: DBus.SystemBus
        service: "org.freedesktop.NetworkManager"
        path: "/org/freedesktop/NetworkManager"
        iface: "org.freedesktop.DBus.Properties"
    }

    DBusInterface {
        id: activeConnectionInterface
        bus: DBus.SystemBus
        service: "org.freedesktop.NetworkManager"
        iface: "org.freedesktop.NetworkManager.Connection.Active"
    }

    DBusInterface {
        id: propertiesInterface
        bus: DBus.SystemBus
        service: "org.freedesktop.NetworkManager"
        iface: "org.freedesktop.DBus.Properties"
    }

    DBusInterface {
        id: deviceInterface
        bus: DBus.SystemBus
        service: "org.freedesktop.NetworkManager"
        iface: "org.freedesktop.NetworkManager.Device.Wireless"
        signalsEnabled: true

        function accessPointAdded() {
            getAPTimer.running = true;
        }
    }

    DBusInterface {
        id: activeDeviceInterface
        bus: DBus.SystemBus
        service: "org.freedesktop.NetworkManager"
        iface: "org.freedesktop.NetworkManager.Device"
        signalsEnabled: true
        function stateChanged(new_state, old_state, reason) {
            switch(new_state) {
                case 30:
                    networkState = "disconnected";
                    currentSSID = "";
                    break;
                case 40:
                case 50:
                case 60:
                case 70:
                case 80:
                case 90:
                    networkState = "connecting";
                    break;
                case 100:
                    networkState = "connected";
                    updateCurrentSSID();
                    break;
                case 110:
                    networkState = "disconnecting";
                    break;
                case 120:
                    networkState = "failed";
                    currentSSID = "";
                    break;
                default:
                    networkState = "unknown";
                    currentSSID = "";
                    break;
            }
        }
    }

    DBusInterface {
        id: settingsConnectionInterface
        bus: DBus.SystemBus
        service: "org.freedesktop.NetworkManager"
        iface: "org.freedesktop.NetworkManager.Settings.Connection"
    }

    DBusInterface {
        id: nmStatusInterface
        bus: DBus.SystemBus
        service: "org.freedesktop.NetworkManager"
        path: "/org/freedesktop/NetworkManager"
        iface: "org.freedesktop.NetworkManager"
    }

    DBusInterface { 
        id: accessPointInterface
        bus: DBus.SystemBus
        service: "org.freedesktop.NetworkManager"
        iface: "org.freedesktop.DBus.Properties" 
    }

    function getStrengthBySSID(ssid) {
        if (ssid === "") {
            return null;
        }
        for (var i = 0; i < networkModel.count; i++) {
            var item = networkModel.get(i);
            console.log("    SSID: " + item.ssid + " strength: " + item.strength)
            if (item.ssid === ssid) {
                return item.strength;
            }
        }
        console.error("SSID not found in networkModel: " + ssid);
        return null;
    }

    function updateCurrentSSID() {
        nmInterface.call("Get", ["org.freedesktop.NetworkManager", "ActiveConnections"], function(result, error) {
            if (error) {
                console.error("Failed to get active access point: " + error);
                return;
            }
            propertiesInterface.path = result[0];
            propertiesInterface.call("Get", ["org.freedesktop.NetworkManager.Connection.Active", "Connection"], function(result, error) {
                if (error) {
                    console.error("Failed to get active connection Connection: " + error);
                    return;
                }
                settingsConnectionInterface.path = result;
                settingsConnectionInterface.call("GetSettings", [], function(result, error) {
                    if (error) {
                        console.error("Failed to get settings: " + error);
                        return;
                    }
                    currentSSID = String.fromCharCode.apply(null, result["802-11-wireless"]["ssid"]);
                });
            });
        });
    }

    function initialize() {
        function getWirelessDeviceTypeAndSetPath(devicePath) {
            propertiesInterface.path = devicePath;
            propertiesInterface.call("Get", ["org.freedesktop.NetworkManager.Device", "DeviceType"], function(deviceTypeResult, error) {
                if (error) {
                    console.error("Failed to get device type: " + error);
                    return;
                }
                if (deviceTypeResult == 2) { // WiFi device
                    deviceInterface.path = devicePath;
                    activeDeviceInterface.path = devicePath;
                }
                updateCurrentSSID();
            });
        }
        nmStatusInterface.call("GetDevices", [], function(result, error) {
            if (error) {
                console.error("Failed to get devices: " + error);
                return;
            }
            var devicesPaths = result;
            for (var i = 0; i < devicesPaths.length; i++) {
                getWirelessDeviceTypeAndSetPath(devicesPaths[i]);
            }
        });
    }

    function getAccessPoints() {
        deviceInterface.call("GetAccessPoints", [], function(accessPointsResult, error) {
            if (error) {
                console.log("Failed to get access points: " + error);
                return;
            }

            function retrieveProperties(index) {
                if (index >= accessPointsResult.length) {
                    wifiManager.accessPointsLoaded();
                    return;
                }

                var accessPointPath = accessPointsResult[index];
                accessPointInterface.path = accessPointPath;
                accessPointInterface.call("Get", ["org.freedesktop.NetworkManager.AccessPoint", "Ssid"], function(ssidResult, error) {
                    if (error) {
                        console.log("Failed to get SSID: " + error);
                        return;
                    }
                    function ssidExists(ssid) {
                        for (var i = 0; i < networkModel.count; i++) {
                            if (networkModel.get(i).ssid === ssid) {
                                return true;
                            }
                        }
                        return false;
                    }
                    var ssid = String.fromCharCode.apply(null, ssidResult);
                    if (ssidExists(ssid)) {
                        retrieveProperties(index + 1);
                        return;
                    }
                    accessPointInterface.call("Get", ["org.freedesktop.NetworkManager.AccessPoint", "Strength"], function(strengthResult, error) {
                        if (error) {
                            console.log("Failed to get strength: " + error);
                            return;
                        }
                        var strength = strengthResult;
                        accessPointInterface.call("Get", ["org.freedesktop.NetworkManager.AccessPoint", "RsnFlags"], function(rsnFlagsResult, error) {
                            if (error) {
                                wifiManager.retrievalError("Failed to get RsnFlags: " + error);
                                return;
                            }
                            var encryptionFlag = (rsnFlagsResult > 0) ? true : false;
                            if (ssid === currentSSID)
                                currentStrength = strength;
                            
			                networkModel.append({ 'ssid': ssid, 'strength': strength, 'encrypted': encryptionFlag })
                            console.log(ssid + " (" + strength + ") (" + encryptionFlag + ")");
                            retrieveProperties(index + 1);
                        });
                    });
                });
            }

            networkModel.clear();
            retrieveProperties(0);
        });
    }

    function requestScan() {
        deviceInterface.call("RequestScan", [{}], function(result, error) {
            if (error) {
                console.log("Failed to request scan: " + error);
                return;
            }
            console.log("Scan requested successfully");
        });
    }

    function requestConnect(ssid, password) {
        var connectionParameters = {
            'type': 'a{sa{sv}}',
            'value': {
                'connection': {
                    'id': { 'type' : 's', 'value': ssid },
                    'type': { 'type' : 's', 'value': '802-11-wireless' },
                },
                '802-11-wireless': {
                    'ssid': { 'type' : 'ay', 'value': Array.from(ssid).map(c => c.charCodeAt(0)) },
                    'mode': { 'type' : 's', 'value': 'infrastructure' },
                },
                '802-11-wireless-security': {
                    'key-mgmt': { 'type' : 's', 'value': 'wpa-psk' },
                    'psk': { 'type' : 's', 'value': password },
                }
            }
        };
        if (password === "") {
            delete connectionParameters.value["802-11-wireless-security"];
        }
        nmStatusInterface.typedCall("AddAndActivateConnection", [
            connectionParameters,
            { "type": "o", "value": deviceInterface.path },
            { "type": "o", "value": '/' }
        ], function(result, error) {
            if (error) {
                    console.log("Failed to activate connection: " + error);
                    return;
                }
                console.log("Successfully activated connection to SSID: " + ssid);

        });
    }

    function toggleWifi() {
        wifiEnable = !wifiEnable;
        nmStatusInterface.setProperty("WirelessEnabled", wifiEnable);
    }

    function toggleAirplaneMode() {
        airplaneMode = !airplaneMode;
        nmStatusInterface.setProperty("NetworkingEnabled", airplaneMode);
    }

    Component.onCompleted: initialize()
}
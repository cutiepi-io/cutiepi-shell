import QtQuick 2.0
import QtQuick.VirtualKeyboard 2.1
import QtQuick.VirtualKeyboard.Styles 2.1

BaseKey {
    key: Qt.ControlModifier // not working this way 
    showPreview: false
    functionKey: true
    repeat: true
    noModifier: true
    weight: 154
    keyPanelDelegate: KeyPanel {
        id: ctrlKeyPanel
        property real keyBackgroundMargin: Math.round(13 * keyboard.style.scaleHint)
        Rectangle {
            radius: 5
            color: "#1e1b18"
            anchors.fill: ctrlKeyPanel
            anchors.margins: keyBackgroundMargin
            Text {
                id: ctrlKeyText
                text: "Ctrl"
                clip: true
                fontSizeMode: Text.HorizontalFit
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: "white" 
                font {
                    family: keyboard.style.fontFamily
                    weight: Font.Normal
                    pixelSize: 44 * keyboard.style.scaleHint
                }
                anchors.fill: parent
                anchors.margins: Math.round(42 * keyboard.style.scaleHint)
            }
        }
    }
}

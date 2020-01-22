import QtQuick 2.0
import QtQuick.VirtualKeyboard 2.1
import QtQuick.VirtualKeyboard.Styles 2.1

BaseKey {
    key: Qt.Key_Tab
    displayText: "Tab"
    showPreview: false
    weight: 250
    functionKey: true
    noModifier: true
    keyPanelDelegate: KeyPanel {
        id: tabKeyPanel
        property real keyBackgroundMargin: Math.round(13 * keyboard.style.scaleHint)
        Rectangle {
            radius: 5
            color: "#1e1b18"
            anchors.fill: tabKeyPanel
            anchors.margins: keyBackgroundMargin
            Text {
                id: tabKeyText
                text: "Tab"
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

import QtQuick 2.15
import QtGraphicalEffects 1.15

Rectangle {
    property Item target 
    radius: 22 
    color: '#989897'
    clip: true

    ShaderEffectSource {
        id: effectSource
        sourceItem: target
        anchors.fill: parent
        sourceRect: Qt.rect(view.width - width, targetY, width, height)
        clip: true
    }

    FastBlur {
        id: blur
        anchors.fill: effectSource
        source: effectSource
        radius: 22
    }

    ColorOverlay {
        anchors.fill: blur
        source: blur
        color: '#8A323232' // alpha + rgb 
    }
}
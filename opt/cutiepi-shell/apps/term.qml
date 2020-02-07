import QtQuick 2.14
import QtQuick.Window 2.2
import Yat 1.0 as Yat

Window {
    title: "Terminal"
    width: 800
    height: 1280
    visible: true

	Yat.Screen { 
		id: terminal
		anchors.fill: parent 
		anchors.topMargin: 85 
		font.pointSize: 12
	}
}

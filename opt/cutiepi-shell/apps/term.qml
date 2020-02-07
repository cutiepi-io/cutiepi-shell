import QtQuick 2.14
import QtQuick.Window 2.2
import Yat 1.0 as Yat

Window {
    title: "Terminal"
    width: view.width
    height: view.height 
    visible: true

	Yat.Screen { 
		id: terminal
		anchors.fill: parent 
		font.pointSize: 12
	}
}

import QtQuick 2.14
import QtWayland.Compositor 1.14

ShellSurfaceItem {
    anchors { top: parent.top; topMargin: 85; left: parent.left  }
    sizeFollowsSurface: false
    shellSurface: modelData
    onSurfaceDestroyed: shellSurfaces.remove(index)
    visible: sidebar.tabListView.currentIndex == index                     
}
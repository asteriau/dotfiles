import QtQuick
import QtQuick.Layouts
import Quickshell.Wayland
import qs.utils

Item {
    id: root

    readonly property Toplevel activeWindow: ToplevelManager.activeToplevel
    readonly property bool focused: activeWindow?.activated ?? false

    readonly property string appId:  focused ? (activeWindow?.appId  ?? "") : ""
    readonly property string title:  focused ? (activeWindow?.title  ?? "Desktop") : "Desktop"

    implicitWidth:  col.implicitWidth
    implicitHeight: col.implicitHeight

    ColumnLayout {
        id: col
        anchors.verticalCenter: parent.verticalCenter
        spacing: -4

        Text {
            visible: root.appId !== ""
            Layout.fillWidth: true
            elide: Text.ElideRight
            Layout.maximumWidth: 200
            text: root.appId
            font.family: Config.fontFamily
            font.pixelSize: Config.typography.smaller
            color: Colors.comment
        }

        Text {
            Layout.fillWidth: true
            elide: Text.ElideRight
            Layout.maximumWidth: 200
            text: root.title
            font.family: Config.fontFamily
            font.pixelSize: Config.typography.small
            color: Colors.foreground
        }
    }
}

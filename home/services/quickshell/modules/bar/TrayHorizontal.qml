import QtQuick
import Quickshell.Services.SystemTray
import qs.modules.common.widgets
import qs.modules.common

Row {
    id: root

    property bool iconsVisible: false
    property int iconSize: 20
    property int toggleSize: 26

    signal toggled

    anchors.centerIn: parent
    spacing: iconsVisible ? Appearance.layout.gapSm : 0

    Behavior on spacing { Motion.Spatial {} }

    Item {
        anchors.verticalCenter: parent.verticalCenter
        implicitWidth: root.iconsVisible ? iconsRow.implicitWidth : 0
        implicitHeight: root.iconSize
        clip: true

        Behavior on implicitWidth { Motion.SpatialEmph {} }

        Row {
            id: iconsRow
            anchors.verticalCenter: parent.verticalCenter
            spacing: Appearance.layout.gapMd

            Repeater {
                model: SystemTray.items
                TrayEntry { iconSize: root.iconSize }
            }
        }
    }

    PressablePill {
        anchors.verticalCenter: parent.verticalCenter
        implicitWidth: root.toggleSize
        implicitHeight: root.toggleSize
        radius: root.toggleSize / 2
        colorIdle: Appearance.colors.transparent
        useStateLayer: true
        pressScale: 0.94
        onClicked: root.toggled()

        MaterialIcon {
            anchors.centerIn: parent
            text: "chevron_right"
            pixelSize: 18
            color: root.iconsVisible ? Appearance.colors.accent : Appearance.colors.m3onSurfaceVariant
            rotation: root.iconsVisible ? 0 : 180

            layer.enabled: true
            layer.smooth: true

            Behavior on rotation { Motion.SpatialEmph {} }
            Behavior on color { Motion.ColorFadeQuick {} }
        }
    }
}

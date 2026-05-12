import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import qs.modules.common.widgets
import qs.modules.common

ColumnLayout {
    id: root

    property bool iconsVisible: false
    property int iconSize: 20
    property int toggleSize: 26

    signal toggled

    anchors.centerIn: parent
    spacing: iconsVisible ? Appearance.layout.gapMd : 0

    Behavior on spacing { Motion.Spatial {} }

    Item {
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: root.iconSize + Appearance.layout.gapSm
        implicitHeight: root.iconsVisible ? iconsCol.implicitHeight : 0
        clip: true
        opacity: root.iconsVisible ? 1 : 0

        Behavior on implicitHeight { Motion.SpatialEmph {} }
        Behavior on opacity { Motion.Fade {} }

        ColumnLayout {
            id: iconsCol
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Appearance.layout.gapMd

            Repeater {
                model: SystemTray.items
                TrayEntry { iconSize: root.iconSize }
            }
        }
    }

    PressablePill {
        Layout.alignment: Qt.AlignHCenter
        implicitWidth: root.toggleSize
        implicitHeight: root.toggleSize
        radius: root.toggleSize / 2
        colorIdle: Appearance.colors.transparent
        useStateLayer: true
        pressScale: 0.94
        onClicked: root.toggled()

        MaterialIcon {
            anchors.centerIn: parent
            text: "expand_more"
            pixelSize: 18
            color: root.iconsVisible ? Appearance.colors.accent : Appearance.colors.m3onSurfaceVariant
            rotation: root.iconsVisible ? 180 : 0
            renderType: Text.QtRendering

            Behavior on rotation { Motion.SpatialEmph {} }
            Behavior on color { Motion.ColorFadeQuick {} }
        }
    }
}

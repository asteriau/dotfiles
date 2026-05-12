import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs.components.surfaces
import qs.components.text
import qs.utils

Item {
    id: root

    property bool vertical: true
    property bool iconsVisible: false

    readonly property int entryIconSize: 20
    readonly property int toggleSize:    26

    Layout.alignment: Qt.AlignHCenter

    implicitWidth:  vertical ? Config.bar.width
                             : (hRow.implicitWidth + Config.layout.gapMd * 2)
    implicitHeight: vertical ? (vCol.implicitHeight + Config.layout.gapMd)
                             : Config.bar.height

    Rectangle {
        id: card
        anchors.fill: parent
        anchors.topMargin:    root.vertical ? 0 : Config.layout.gapSm
        anchors.bottomMargin: root.vertical ? 0 : Config.layout.gapSm
        anchors.leftMargin:   root.vertical ? Config.layout.gapSm : 0
        anchors.rightMargin:  root.vertical ? Config.layout.gapSm : 0
        radius: Config.layout.radiusContainer
        color: Colors.surfaceContainerLow

        Behavior on color {
            ColorAnimation { duration: M3Easing.effectsDuration; easing.type: Easing.OutCubic }
        }
    }

    // Shared delegate: clickable icon with right-click menu.
    component TrayEntry: Item {
        id: entry
        required property SystemTrayItem modelData

        implicitWidth: root.entryIconSize
        implicitHeight: root.entryIconSize

        IconImage {
            id: trayIcon
            anchors.fill: parent
            mipmap: true
            source: entry.modelData.icon
        }

        MultiEffect {
            source: trayIcon
            anchors.fill: trayIcon
            shadowEnabled: Config.shadow.enabled
            shadowVerticalOffset: Config.shadow.verticalOffset
            blurMax: Config.shadow.blur
            opacity: Config.shadow.opacity
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            cursorShape: Qt.PointingHandCursor

            onPressed: event => {
                switch (event.button) {
                case Qt.LeftButton:
                    entry.modelData.activate();
                    break;
                case Qt.RightButton:
                    if (entry.modelData.hasMenu) {
                        if (menuLoader.active && menuLoader.item)
                            menuLoader.item.close();
                        else
                            menuLoader.active = true;
                    }
                    break;
                }
                event.accepted = true;
            }
        }

        Loader {
            id: menuLoader
            active: false
            sourceComponent: SysTrayMenu {
                trayItemMenuHandle: entry.modelData.menu
                anchor {
                    window: entry.QsWindow.window
                    item: entry
                    gravity: Config.bar.vertical
                        ? (Config.bar.onEnd ? Edges.Left : Edges.Right)
                        : (Config.bar.onEnd ? Edges.Top : Edges.Bottom)
                    edges: Config.bar.vertical
                        ? (Config.bar.onEnd ? Edges.Left : Edges.Right)
                        : (Config.bar.onEnd ? Edges.Top : Edges.Bottom)
                }
                Component.onCompleted: open()
                onMenuClosed: menuLoader.active = false
            }
        }
    }

    // Vertical: collapsible column with rotating expand_more chevron.
    // Spacing collapses to 0 when icons are hidden so the toggle sits centred
    // in the card; otherwise the empty icons slot leaves a phantom gap above.
    ColumnLayout {
        id: vCol
        visible: root.vertical
        anchors.centerIn: parent
        spacing: root.iconsVisible ? Config.layout.gapMd : 0

        Behavior on spacing { Motion.Spatial {} }

        Item {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: root.entryIconSize + Config.layout.gapSm
            implicitHeight: root.iconsVisible ? iconsCol.implicitHeight : 0
            clip: true
            opacity: root.iconsVisible ? 1 : 0

            Behavior on implicitHeight { Motion.SpatialEmph {} }
            Behavior on opacity { Motion.Fade {} }

            ColumnLayout {
                id: iconsCol
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Config.layout.gapMd

                Repeater {
                    model: SystemTray.items
                    TrayEntry {}
                }
            }
        }

        PressablePill {
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: root.toggleSize
            implicitHeight: root.toggleSize
            radius: root.toggleSize / 2
            colorIdle: Colors.transparent
            useStateLayer: true
            pressScale: 0.94
            onClicked: root.iconsVisible = !root.iconsVisible

            MaterialIcon {
                anchors.centerIn: parent
                text: "expand_more"
                pixelSize: 18
                color: root.iconsVisible ? Colors.accent : Colors.m3onSurfaceVariant
                rotation: root.iconsVisible ? 180 : 0
                renderType: Text.QtRendering

                Behavior on rotation { Motion.SpatialEmph {} }
                Behavior on color { Motion.ColorFadeQuick {} }
            }
        }
    }

    // Horizontal: collapsible row with a rotating chevron 
    Row {
        id: hRow
        visible: !root.vertical
        anchors.centerIn: parent
        spacing: root.iconsVisible ? Config.layout.gapSm : 0

        Behavior on spacing { Motion.Spatial {} }

        Item {
            anchors.verticalCenter: parent.verticalCenter
            implicitWidth: root.iconsVisible ? iconsRow.implicitWidth : 0
            implicitHeight: root.entryIconSize
            clip: true

            Behavior on implicitWidth { Motion.SpatialEmph {} }

            Row {
                id: iconsRow
                anchors.verticalCenter: parent.verticalCenter
                spacing: Config.layout.gapMd

                Repeater {
                    model: SystemTray.items
                    TrayEntry {}
                }
            }
        }

        PressablePill {
            anchors.verticalCenter: parent.verticalCenter
            implicitWidth: root.toggleSize
            implicitHeight: root.toggleSize
            radius: root.toggleSize / 2
            colorIdle: Colors.transparent
            useStateLayer: true
            pressScale: 0.94
            onClicked: root.iconsVisible = !root.iconsVisible

            MaterialIcon {
                anchors.centerIn: parent
                text: "chevron_right"
                pixelSize: 18
                color: root.iconsVisible ? Colors.accent : Colors.m3onSurfaceVariant
                // Rotated 180° → looks like chevron_left when collapsed.
                rotation: root.iconsVisible ? 0 : 180

                layer.enabled: true
                layer.smooth: true

                Behavior on rotation { Motion.SpatialEmph {} }
                Behavior on color { Motion.ColorFadeQuick {} }
            }
        }
    }
}

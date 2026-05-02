import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs.components.effects
import qs.components.text
import qs.utils

Rectangle {
    id: root

    property bool vertical: true
    property bool iconsVisible: false

    // Honoured when parent is a ColumnLayout (vertical bar); ignored by plain Row
    // in the horizontal bar, which is fine — no behavior change either way.
    Layout.alignment: Qt.AlignHCenter

    implicitWidth:  vertical ? 32 : (hRow.implicitWidth + 12)
    implicitHeight: vertical ? (vCol.implicitHeight + 12) : (Config.bar.height - 8)
    radius: Config.layout.radiusSm
    color: "transparent"

    // Shared delegate: icon with right-click menu + tooltip.
    component TrayEntry: HoverTooltip {
        id: entry
        required property SystemTrayItem modelData

        text: modelData.tooltipTitle
        visible: true

        Item {
            implicitWidth: trayIcon.implicitWidth
            implicitHeight: trayIcon.implicitHeight

            IconImage {
                id: trayIcon
                mipmap: true
                source: entry.modelData.icon
                implicitSize: Config.iconSize
            }

            MultiEffect {
                source: trayIcon
                anchors.fill: trayIcon
                shadowEnabled: Config.shadow.enabled
                shadowVerticalOffset: Config.shadow.verticalOffset
                blurMax: Config.shadow.blur
                opacity: Config.shadow.opacity
            }
        }

        acceptedButtons: Qt.RightButton | Qt.LeftButton

        onClicked: event => {
            switch (event.button) {
            case Qt.LeftButton:
                modelData.activate();
                break;
            case Qt.RightButton:
                if (modelData.hasMenu)
                    menu.open();
                break;
            }
            event.accepted = true;
        }

        QsMenuAnchor {
            id: menu
            menu: entry.modelData.menu
            onVisibleChanged: QsWindow.window.inhibitGrab = visible

            anchor {
                item: trayIcon
                edges: Edges.Right | Edges.Top
                gravity: Edges.Right | Edges.Bottom
                adjustment: PopupAdjustment.All
            }
        }
    }

    // Vertical: collapsible column with rotating expand_more chevron.
    ColumnLayout {
        id: vCol
        visible: root.vertical
        anchors.centerIn: parent
        spacing: 8

        Item {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 20
            implicitHeight: root.iconsVisible ? iconsCol.implicitHeight : 0
            clip: true
            opacity: root.iconsVisible ? 1 : 0

            Behavior on implicitHeight {
                NumberAnimation { duration: M3Easing.spatialDuration; easing.bezierCurve: M3Easing.emphasized }
            }
            Behavior on opacity {
                NumberAnimation { duration: M3Easing.effectsDuration; easing.type: Easing.OutCubic }
            }

            ColumnLayout {
                id: iconsCol
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10

                Repeater {
                    model: SystemTray.items
                    TrayEntry {}
                }
            }
        }

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            visible: root.iconsVisible && SystemTray.items.values.length > 0
            implicitWidth: 16
            implicitHeight: 1
            color: Colors.divider
        }

        WrapperMouseArea {
            Layout.alignment: Qt.AlignHCenter
            onClicked: root.iconsVisible = !root.iconsVisible

            MaterialIcon {
                text: "expand_more"
                pixelSize: 14
                color: root.iconsVisible ? Colors.accent : Colors.foreground
                rotation: root.iconsVisible ? 180 : 0

                Behavior on rotation {
                    NumberAnimation { duration: M3Easing.spatialDuration; easing.bezierCurve: M3Easing.emphasized }
                }
                Behavior on color {
                    ColorAnimation { duration: M3Easing.effectsDuration }
                }
            }
        }
    }

    // Horizontal: collapsible row with chevron_left/right (flips icon, no rotation).
    Row {
        id: hRow
        visible: !root.vertical
        anchors.centerIn: parent
        spacing: 6

        Item {
            anchors.verticalCenter: parent.verticalCenter
            implicitWidth: root.iconsVisible ? iconsRow.implicitWidth : 0
            implicitHeight: Config.iconSize
            clip: true

            Behavior on implicitWidth {
                NumberAnimation { duration: M3Easing.spatialDuration; easing.bezierCurve: M3Easing.emphasized }
            }

            Row {
                id: iconsRow
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                Repeater {
                    model: SystemTray.items
                    TrayEntry {}
                }
            }
        }

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.iconsVisible && SystemTray.items.values.length > 0
            implicitWidth: 1
            implicitHeight: 12
            color: Colors.divider
        }

        WrapperMouseArea {
            anchors.verticalCenter: parent.verticalCenter
            onClicked: root.iconsVisible = !root.iconsVisible

            MaterialIcon {
                text: root.iconsVisible ? "chevron_right" : "chevron_left"
                pixelSize: 14
                color: root.iconsVisible ? Colors.accent : Colors.foreground

                Behavior on color {
                    ColorAnimation { duration: M3Easing.effectsDuration }
                }
            }
        }
    }
}

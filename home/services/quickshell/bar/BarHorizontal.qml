import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Services.UPower
import Quickshell.Widgets
import qs.components
import qs.utils

Rectangle {
    id: root
    color: Colors.background

    // ── Left: heart icon ───────────────────────────────────────────────────
    Row {
        anchors {
            left: parent.left
            leftMargin: 10
            verticalCenter: parent.verticalCenter
        }

        HeartIcon {}
    }

    // ── Center: workspaces ─────────────────────────────────────────────────
    Row {
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }

        Workspaces {}
    }

    // ── Right: tray + network + bluetooth + battery + clock ────────────────
    Row {
        id: rightGroup
        anchors {
            right: parent.right
            rightMargin: 10
            verticalCenter: parent.verticalCenter
        }
        spacing: 8

        // Tray: collapsible icons + chevron
        Rectangle {
            id: trayContainer
            anchors.verticalCenter: parent.verticalCenter
            implicitHeight: Config.barHeight - 8
            implicitWidth: trayInner.implicitWidth + 12
            radius: 8
            color: Colors.elevated

            property bool iconsVisible: false

            Row {
                id: trayInner
                anchors.centerIn: parent
                spacing: 6

                Item {
                    anchors.verticalCenter: parent.verticalCenter
                    implicitWidth: trayContainer.iconsVisible ? iconsRow.implicitWidth : 0
                    implicitHeight: Config.iconSize
                    clip: true

                    Behavior on implicitWidth {
                        NumberAnimation { duration: M3Easing.durationMedium1; easing.type: Easing.OutCubic }
                    }

                    Row {
                        id: iconsRow
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 6

                        Repeater {
                            model: SystemTray.items

                            HoverTooltip {
                                id: trayDelegate
                                required property SystemTrayItem modelData
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData.tooltipTitle

                                Item {
                                    implicitWidth: Config.iconSize
                                    implicitHeight: Config.iconSize

                                    IconImage {
                                        anchors.centerIn: parent
                                        source: trayDelegate.modelData.icon
                                        implicitSize: Config.iconSize
                                        mipmap: true
                                    }
                                }

                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                onClicked: event => {
                                    if (event.button === Qt.LeftButton)
                                        trayDelegate.modelData.activate();
                                    else if (event.button === Qt.RightButton && trayDelegate.modelData.hasMenu)
                                        trayCtx.open();
                                }

                                QsMenuAnchor {
                                    id: trayCtx
                                    menu: trayDelegate.modelData.menu
                                    anchor {
                                        item: trayDelegate
                                        edges: Edges.Bottom
                                        gravity: Edges.Bottom
                                        adjustment: PopupAdjustment.All
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: trayContainer.iconsVisible && SystemTray.items.values.length > 0
                    implicitWidth: 1
                    implicitHeight: 12
                    color: Colors.divider
                }

                WrapperMouseArea {
                    anchors.verticalCenter: parent.verticalCenter
                    onClicked: trayContainer.iconsVisible = !trayContainer.iconsVisible

                    MaterialIcon {
                        text: trayContainer.iconsVisible ? "chevron_right" : "chevron_left"
                        font.pixelSize: 14
                        color: trayContainer.iconsVisible ? Colors.accent : Colors.foreground

                        Behavior on color {
                            ColorAnimation { duration: M3Easing.effectsDuration }
                        }
                    }
                }
            }
        }

        // Network + Bluetooth
        Network  { anchors.verticalCenter: parent.verticalCenter }
        Bluetooth { anchors.verticalCenter: parent.verticalCenter }

        // Compact horizontal battery
        HoverTooltip {
            id: battRow
            anchors.verticalCenter: parent.verticalCenter
            visible: UPower.displayDevice.isLaptopBattery

            readonly property int pct: Math.round(UPower.displayDevice.percentage * 100)
            readonly property bool charging:
                UPower.displayDevice.state === UPowerDeviceState.Charging ||
                UPower.displayDevice.state === UPowerDeviceState.FullyCharged

            text: `Battery ${pct}%${charging ? " (charging)" : ""}`

            Row {
                spacing: 5
                anchors.verticalCenter: parent.verticalCenter

                Item {
                    implicitWidth: 28
                    implicitHeight: 12
                    anchors.verticalCenter: parent.verticalCenter

                    Rectangle {
                        anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                        width: 3; height: 6; radius: 1
                        color: Colors.comment
                    }

                    Rectangle {
                        width: 24; height: 12; radius: 3
                        color: "transparent"
                        border.color: Colors.comment
                        border.width: 1
                        clip: true

                        Rectangle {
                            anchors { left: parent.left; top: parent.top; bottom: parent.bottom; margins: 2 }
                            width: Math.max(0, (parent.width - 4) * Math.min(1, UPower.displayDevice.percentage))
                            radius: 2
                            color: Qt.rgba(Colors.mpris.r, Colors.mpris.g, Colors.mpris.b, 0.85)
                            Behavior on width {
                                NumberAnimation { duration: M3Easing.durationMedium2; easing.type: Easing.OutQuad }
                            }
                        }
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: `${battRow.pct}%`
                    font.pixelSize: 11
                    font.family: Config.fontFamily
                    color: Colors.comment
                }
            }
        }

        // Clock — rightmost
        Clock { anchors.verticalCenter: parent.verticalCenter }
    }
}

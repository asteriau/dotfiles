import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs.components
import qs.utils

WrapperRectangle {
    id: root
    resizeChild: false
    color: "transparent"

    property bool iconsVisible: false

    RowLayout {
        spacing: Config.spacing

        // System tray icons
        Repeater {
            model: SystemTray.items

            HoverTooltip {
                id: mouseArea
                required property SystemTrayItem modelData

                text: modelData.tooltipTitle
                // Always visible for animation; opacity handles actual visibility
                visible: true  

                Item {
                    implicitWidth: trayIcon.implicitWidth
                    implicitHeight: trayIcon.implicitHeight
                    opacity: root.iconsVisible ? 1 : 0
                    // Block mouse events when invisible
                    enabled: root.iconsVisible

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 250
                            easing.type: Easing.InOutQuad
                        }
                    }

                    IconImage {
                        id: trayIcon
                        mipmap: true
                        source: mouseArea.modelData.icon
                        implicitSize: Config.iconSize
                    }

                    MultiEffect {
                        source: trayIcon
                        anchors.fill: trayIcon
                        shadowEnabled: Config.shadowEnabled
                        shadowVerticalOffset: Config.shadowVerticalOffset
                        blurMax: Config.blurMax
                        opacity: Config.shadowOpacity
                    }
                }

                acceptedButtons: Qt.RightButton | Qt.LeftButton

                onClicked: event => {
                    switch (event.button) {
                    case Qt.LeftButton:
                        modelData.activate()
                        break
                    case Qt.RightButton:
                        if (modelData.hasMenu)
                            menu.open()
                        break
                    }
                    event.accepted = true
                }

                QsMenuAnchor {
                    id: menu
                    menu: mouseArea.modelData.menu
                    onVisibleChanged: QsWindow.window.inhibitGrab = visible

                    anchor {
                        item: trayIcon
                        edges: Edges.Right | Edges.Top
                        gravity: Edges.Left | Edges.Bottom
                        adjustment: PopupAdjustment.All
                    }
                }
            }
        }

        // Overflow icon
        WrapperMouseArea {
            onClicked: {
                root.iconsVisible = !root.iconsVisible
            }

            MaterialIcon {
                id: chevronIcon
                text: "chevron_left"
                font.pixelSize: 16

                rotation: root.iconsVisible ? 180 : 0

                Behavior on rotation {
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }
    }
}

import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs.components
import qs.utils

Rectangle {
    id: root
    Layout.alignment: Qt.AlignHCenter

    property bool iconsVisible: false

    implicitWidth: 32
    implicitHeight: col.implicitHeight + 12
    radius: 8
    color: Colors.elevated

    Behavior on implicitHeight {
        NumberAnimation {
            duration: 260
            easing.type: Easing.OutCubic
        }
    }

    ColumnLayout {
        id: col
        anchors.centerIn: parent
        spacing: 8

        Item {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 20
            implicitHeight: root.iconsVisible ? iconsCol.implicitHeight : 0
            clip: true
            opacity: root.iconsVisible ? 1 : 0

            Behavior on implicitHeight {
                NumberAnimation {
                    duration: 260
                    easing.type: Easing.OutCubic
                }
            }
            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }

            ColumnLayout {
                id: iconsCol
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10

                Repeater {
                    model: SystemTray.items

                    HoverTooltip {
                        id: mouseArea
                        required property SystemTrayItem modelData

                        text: modelData.tooltipTitle
                        visible: true

                        Item {
                            implicitWidth: trayIcon.implicitWidth
                            implicitHeight: trayIcon.implicitHeight

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
                            menu: mouseArea.modelData.menu
                            onVisibleChanged: QsWindow.window.inhibitGrab = visible

                            anchor {
                                item: trayIcon
                                edges: Edges.Right | Edges.Top
                                gravity: Edges.Right | Edges.Bottom
                                adjustment: PopupAdjustment.All
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            visible: root.iconsVisible && SystemTray.items.values.length > 0
            implicitWidth: 16
            implicitHeight: 1
            color: Qt.rgba(Colors.foreground.r, Colors.foreground.g, Colors.foreground.b, 0.15)
        }

        WrapperMouseArea {
            Layout.alignment: Qt.AlignHCenter
            onClicked: root.iconsVisible = !root.iconsVisible

            MaterialIcon {
                id: chevronIcon
                text: "expand_more"
                font.pixelSize: 14
                color: root.iconsVisible ? Colors.accent : Colors.foreground

                rotation: root.iconsVisible ? 180 : 0

                Behavior on rotation {
                    NumberAnimation {
                        duration: 260
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on color {
                    ColorAnimation {
                        duration: 180
                    }
                }
            }
        }
    }
}

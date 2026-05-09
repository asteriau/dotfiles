pragma ComponentBehavior: Bound

import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Widgets
import qs.utils
import qs.services

Item {
    id: root

    property string image: ""
    property string appIcon: ""
    property string summary: ""
    property int urgency: NotificationUrgency.Normal
    property int implicitSize: 38

    readonly property bool isUrgent: urgency === NotificationUrgency.Critical
    readonly property real materialIconScale: 0.57
    readonly property real appIconScale: 0.8
    readonly property real smallAppIconScale: 0.49
    readonly property real materialIconSize: implicitSize * materialIconScale
    readonly property real appIconSize: implicitSize * appIconScale
    readonly property real smallAppIconSize: implicitSize * smallAppIconScale

    readonly property color tileBg: isUrgent ? Qt.rgba(Colors.red.r, Colors.red.g, Colors.red.b, 0.28) : Qt.rgba(Colors.accent.r, Colors.accent.g, Colors.accent.b, 0.22)
    readonly property color tileFg: isUrgent ? Colors.red : Colors.accent

    implicitWidth: implicitSize
    implicitHeight: implicitSize

    Rectangle {
        id: tile
        anchors.fill: parent
        radius: width / 2
        color: root.tileBg
        antialiasing: true
        visible: root.image === ""
    }

    Loader {
        active: root.image === "" && root.appIcon === ""
        anchors.fill: parent
        sourceComponent: Text {
            anchors.centerIn: parent
            text: {
                const def = NotificationUtils.defaultIcon;
                const guess = NotificationUtils.findSuitableMaterialSymbol(root.summary);
                return (root.isUrgent && guess === def) ? "priority_high" : guess;
            }
            color: root.tileFg
            font.family: "Material Symbols Rounded"
            font.pixelSize: root.materialIconSize
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.variableAxes: ({
                    FILL: 0,
                    GRAD: -25,
                    opsz: root.materialIconSize,
                    wght: 500
                })
        }
    }

    Loader {
        active: root.image === "" && root.appIcon !== ""
        anchors.centerIn: parent
        sourceComponent: IconImage {
            implicitSize: root.appIconSize
            asynchronous: true
            source: Utils.getImage(root.appIcon)
        }
    }

    Loader {
        active: root.image !== ""
        anchors.fill: parent
        sourceComponent: Item {
            anchors.fill: parent

            Image {
                id: notifImage
                anchors.fill: parent
                readonly property int size: Math.max(1, parent.width)
                source: root.image ? Utils.getImage(root.image) : ""
                sourceSize.width: size
                sourceSize.height: size
                fillMode: Image.PreserveAspectCrop
                cache: true
                asynchronous: true
                antialiasing: true

                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: notifImage.size
                        height: notifImage.size
                        radius: width / 2
                    }
                }
            }

            Loader {
                active: root.appIcon !== ""
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                sourceComponent: IconImage {
                    implicitSize: root.smallAppIconSize
                    asynchronous: true
                    source: Utils.getImage(root.appIcon)
                }
            }
        }
    }
}

import QtQuick
import QtQuick.Layouts
import qs.services
import qs.utils

Item {
    id: row
    required property var modelData
    property bool expanded: false

    Layout.fillWidth: true
    implicitHeight: column.implicitHeight

    readonly property string deviceName: modelData?.name || "(unknown)"
    readonly property bool   connected:  modelData?.connected ?? false
    readonly property bool   paired:     modelData?.paired ?? false
    readonly property bool   batAvail:   modelData?.batteryAvailable ?? false
    readonly property real   battery:    modelData?.battery ?? 0
    readonly property string iconHint:   modelData?.icon ?? ""

    function _materialIcon(hint) {
        const h = (hint || "").toLowerCase();
        if (h.includes("audio") || h.includes("headset") || h.includes("headphone")) return "headphones";
        if (h.includes("phone")) return "smartphone";
        if (h.includes("input-keyboard") || h.includes("keyboard")) return "keyboard";
        if (h.includes("input-mouse") || h.includes("mouse")) return "mouse";
        if (h.includes("computer")) return "computer";
        return "bluetooth";
    }

    ColumnLayout {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 0

        Rectangle {
            id: header
            Layout.fillWidth: true
            implicitHeight: 48
            radius: Config.layout.radiusSm
            color: headerMa.containsMouse ? Colors.colLayer3 : "transparent"
            Behavior on color { Motion.ColorFade {} }

            RowLayout {
                anchors {
                    left: parent.left
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    leftMargin: 10
                    rightMargin: 10
                }
                spacing: 10

                Text {
                    text: row._materialIcon(row.iconHint)
                    color: row.connected ? Colors.colPrimary : Colors.m3onSurface
                    font.family: "Material Symbols Rounded"
                    font.pixelSize: 20
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    Text {
                        Layout.fillWidth: true
                        text: row.deviceName
                        color: Colors.m3onSurface
                        font.family: "Inter"
                        font.pixelSize: 13
                        font.weight: row.connected ? Font.Medium : Font.Normal
                        elide: Text.ElideRight
                    }

                    Text {
                        Layout.fillWidth: true
                        visible: row.connected || row.paired
                        text: {
                            const parts = [];
                            parts.push(row.connected ? "Connected" : "Paired");
                            if (row.batAvail) parts.push(Math.round(row.battery * 100) + "%");
                            return parts.join(" • ");
                        }
                        color: Colors.m3onSurfaceVariant
                        font.family: "Inter"
                        font.pixelSize: 11
                        elide: Text.ElideRight
                    }
                }

                Text {
                    text: "keyboard_arrow_down"
                    color: Colors.m3onSurfaceVariant
                    font.family: "Material Symbols Rounded"
                    font.pixelSize: 18
                    rotation: row.expanded ? 180 : 0
                    Behavior on rotation { Motion.Spatial {} }
                }
            }

            MouseArea {
                id: headerMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: row.expanded = !row.expanded
            }
        }

        RowLayout {
            visible: row.expanded
            Layout.fillWidth: true
            Layout.leftMargin: 10
            Layout.rightMargin: 10
            Layout.topMargin: 4
            Layout.bottomMargin: 8
            spacing: 8

            Rectangle {
                implicitHeight: 30
                Layout.fillWidth: true
                radius: Config.layout.radiusSm
                color: pairMa.containsMouse ? Colors.colLayer3 : Colors.colLayer2
                border.width: 1
                border.color: Colors.outlineVariant

                Text {
                    anchors.centerIn: parent
                    text: row.paired ? "Forget" : "Pair"
                    color: Colors.m3onSurface
                    font.family: "Inter"
                    font.pixelSize: 12
                    font.weight: Font.Medium
                }

                MouseArea {
                    id: pairMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (row.paired) BluetoothState.forget(row.modelData);
                        else BluetoothState.pair(row.modelData);
                    }
                }
            }

            Rectangle {
                implicitHeight: 30
                Layout.fillWidth: true
                radius: Config.layout.radiusSm
                color: connectMa.containsMouse ? Colors.accentHover : Colors.accent

                Text {
                    anchors.centerIn: parent
                    text: row.connected ? "Disconnect" : "Connect"
                    color: Colors.background
                    font.family: "Inter"
                    font.pixelSize: 12
                    font.weight: Font.Medium
                }

                MouseArea {
                    id: connectMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (row.connected) BluetoothState.disconnect(row.modelData);
                        else BluetoothState.connect(row.modelData);
                    }
                }
            }
        }
    }
}

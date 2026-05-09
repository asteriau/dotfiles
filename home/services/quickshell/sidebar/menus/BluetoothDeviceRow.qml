import QtQuick
import QtQuick.Layouts
import qs.components.controls
import qs.services
import qs.utils

DialogListItem {
    id: row
    required property var modelData
    property bool expanded: false

    readonly property string deviceName: modelData?.name || "Unknown device"
    readonly property bool   connected:  modelData?.connected ?? false
    readonly property bool   paired:     modelData?.paired ?? false
    readonly property bool   batAvail:   modelData?.batteryAvailable ?? false
    readonly property real   battery:    modelData?.battery ?? 0
    readonly property string iconHint:   modelData?.icon ?? ""

    active: connected
    contentHeight: column.implicitHeight + row.verticalPadding * 2
    onClicked: row.expanded = !row.expanded

    function _materialIcon(hint) {
        const h = (hint || "").toLowerCase();
        if (h.includes("audio") || h.includes("headset") || h.includes("headphone")) return "headphones";
        if (h.includes("phone")) return "smartphone";
        if (h.includes("input-keyboard") || h.includes("keyboard")) return "keyboard";
        if (h.includes("input-mouse") || h.includes("mouse")) return "mouse";
        if (h.includes("computer")) return "computer";
        return "bluetooth";
    }

    readonly property string _meta: {
        if (!connected && !paired) return "";
        const parts = [];
        parts.push(connected ? "Connected" : "Paired");
        if (batAvail) parts.push(Math.round(battery * 100) + "%");
        return parts.join(" • ");
    }

    ColumnLayout {
        id: column
        anchors {
            fill: parent
            topMargin: row.verticalPadding
            bottomMargin: row.verticalPadding
            leftMargin: row.horizontalPadding
            rightMargin: row.horizontalPadding
        }
        spacing: 0

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Text {
                text: row._materialIcon(row.iconHint)
                color: Colors.m3onSurfaceVariant
                font.family: Config.typography.iconFamily
                font.pixelSize: Config.typography.larger
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    Layout.fillWidth: true
                    text: row.deviceName
                    color: Colors.m3onSurfaceVariant
                    font.family: Config.typography.family
                    font.pixelSize: Config.typography.small
                    elide: Text.ElideRight
                }

                Text {
                    Layout.fillWidth: true
                    visible: row._meta.length > 0
                    text: row._meta
                    color: Colors.comment
                    font.family: Config.typography.family
                    font.pixelSize: Config.typography.smaller
                    elide: Text.ElideRight
                }
            }

            Text {
                text: "keyboard_arrow_down"
                color: Colors.m3onSurface
                font.family: Config.typography.iconFamily
                font.pixelSize: Config.typography.larger
                rotation: row.expanded ? 180 : 0
                Behavior on rotation { Motion.ElementFast {} }
            }
        }

        RowLayout {
            visible: row.expanded
            Layout.topMargin: 8
            Layout.fillWidth: true
            spacing: 4

            Item { Layout.fillWidth: true }

            DialogButton {
                visible: row.paired
                text: "Forget"
                variant: DialogButton.Variant.Danger
                onClicked: BluetoothState.forget(row.modelData)
            }

            DialogButton {
                visible: !row.paired
                text: "Pair"
                variant: DialogButton.Variant.Default
                onClicked: BluetoothState.pair(row.modelData)
            }

            DialogButton {
                visible: row.paired
                text: row.connected ? "Disconnect" : "Connect"
                variant: DialogButton.Variant.Primary
                onClicked: {
                    if (row.connected) BluetoothState.disconnect(row.modelData);
                    else BluetoothState.connect(row.modelData);
                }
            }
        }
    }
}

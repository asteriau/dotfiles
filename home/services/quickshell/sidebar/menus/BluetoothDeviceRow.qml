import QtQuick
import QtQuick.Layouts
import qs.components.controls
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

    readonly property string _meta: {
        if (!connected && !paired) return "";
        const parts = [];
        parts.push(connected ? "Connected" : "Paired");
        if (batAvail) parts.push(Math.round(battery * 100) + "%");
        return parts.join(" • ");
    }

    Component {
        id: chevronC
        Text {
            text: "keyboard_arrow_down"
            color: Colors.m3onSurfaceVariant
            font.family: Config.typography.iconFamily
            font.pixelSize: 18
            rotation: row.expanded ? 180 : 0
            Behavior on rotation { Motion.Spatial {} }
        }
    }

    ColumnLayout {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 0

        MenuRow {
            primaryText: row.deviceName
            secondaryText: row._meta
            iconName: row._materialIcon(row.iconHint)
            iconColor: row.connected ? Colors.colPrimary : Colors.m3onSurface
            active: row.connected
            trailing: chevronC
            expanded: row.expanded

            onClicked: row.expanded = !row.expanded
        }

        // Action row, semantic by intent.
        RowLayout {
            visible: row.expanded
            Layout.fillWidth: true
            Layout.leftMargin: Config.layout.gapMd
            Layout.rightMargin: Config.layout.gapMd
            Layout.topMargin: Config.layout.gapXs
            Layout.bottomMargin: Config.layout.gapMd
            spacing: Config.layout.gapSm

            // Pair (when not paired).
            MenuActionButton {
                visible: !row.paired
                text: "Pair"
                variant: MenuActionButton.Variant.Primary
                onClicked: BluetoothState.pair(row.modelData)
            }

            // Connect / Disconnect (paired only).
            MenuActionButton {
                visible: row.paired
                text: row.connected ? "Disconnect" : "Connect"
                variant: row.connected ? MenuActionButton.Variant.Tonal
                                       : MenuActionButton.Variant.Primary
                onClicked: {
                    if (row.connected) BluetoothState.disconnect(row.modelData);
                    else BluetoothState.connect(row.modelData);
                }
            }

            // Forget (paired only, destructive).
            MenuActionButton {
                visible: row.paired
                text: "Forget"
                variant: MenuActionButton.Variant.Danger
                onClicked: BluetoothState.forget(row.modelData)
            }
        }
    }
}

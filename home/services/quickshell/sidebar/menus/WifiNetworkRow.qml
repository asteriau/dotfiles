import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.components.controls
import qs.services
import qs.utils

Item {
    id: row
    required property var modelData
    property bool expanded: false
    property bool errored: false
    property string errorMsg: ""

    Layout.fillWidth: true
    implicitHeight: column.implicitHeight

    readonly property string ssid:    modelData?.ssid ?? ""
    readonly property int    rssi:    modelData?.signal ?? 0
    readonly property bool   secure:  (modelData?.security ?? "") !== ""
    readonly property bool   active:  modelData?.active ?? false
    readonly property bool   known:   modelData?.knownProfile ?? false

    function _signalIcon(s) {
        if (s > 80) return "signal_wifi_4_bar";
        if (s > 60) return "network_wifi_3_bar";
        if (s > 40) return "network_wifi_2_bar";
        if (s > 20) return "network_wifi_1_bar";
        return "signal_wifi_0_bar";
    }

    Component {
        id: trailingC
        RowLayout {
            spacing: Config.layout.gapSm

            Text {
                visible: row.active
                text: "check"
                color: Colors.colPrimary
                font.family: Config.typography.iconFamily
                font.pixelSize: 16
            }

            Text {
                visible: row.secure
                text: "lock"
                color: row.active ? Colors.colPrimary : Colors.m3onSurfaceVariant
                font.family: Config.typography.iconFamily
                font.pixelSize: 14
            }
        }
    }

    ColumnLayout {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 0

        MenuRow {
            primaryText: row.ssid || "(hidden)"
            secondaryText: row.errored ? row.errorMsg : ""
            iconName: row._signalIcon(row.rssi)
            iconColor: row.active ? Colors.colPrimary : Colors.m3onSurface
            active: row.active
            trailing: trailingC

            onClicked: {
                if (row.active) {
                    NetworkState.disconnect(row.ssid);
                } else if (row.secure && !row.known) {
                    row.expanded = !row.expanded;
                } else {
                    NetworkState.connect(row.ssid, "");
                }
            }
        }

        // Password row.
        RowLayout {
            visible: row.expanded
            Layout.fillWidth: true
            Layout.leftMargin: Config.layout.gapMd
            Layout.rightMargin: Config.layout.gapMd
            Layout.topMargin: Config.layout.gapXs
            Layout.bottomMargin: Config.layout.gapMd
            spacing: Config.layout.gapSm

            MaterialTextField {
                id: pwField
                Layout.fillWidth: true
                echoMode: TextInput.Password
                placeholderText: "Password"
                hasError: row.errored
                onAccepted: connectBtn.trigger()
            }

            MenuActionButton {
                id: connectBtn
                Layout.fillWidth: false
                implicitWidth: Math.max(86, implicitWidth)
                text: "Connect"
                variant: MenuActionButton.Variant.Primary
                enabled: pwField.text.length > 0
                onClicked: trigger()

                function trigger() {
                    if (pwField.text.length === 0) return;
                    NetworkState.connect(row.ssid, pwField.text);
                }
            }
        }
    }

    Connections {
        target: NetworkState
        function onPasswordRequired(ssid) {
            if (ssid === row.ssid) {
                row.expanded = true;
                row.errored = true;
                row.errorMsg = "Password required";
            }
        }
        function onConnectFailed(ssid, msg) {
            if (ssid === row.ssid) {
                row.errored = true;
                row.errorMsg = msg;
            }
        }
        function onConnected(ssid) {
            if (ssid === row.ssid) {
                row.expanded = false;
                row.errored = false;
                row.errorMsg = "";
            }
        }
    }
}

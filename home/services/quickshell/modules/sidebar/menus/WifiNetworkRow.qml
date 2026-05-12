import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules.common.widgets
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models

DialogListItem {
    id: row
    required property var modelData
    property bool errored: false
    property string errorMsg: ""
    property bool asking: false

    readonly property string ssid:      modelData?.ssid ?? ""
    readonly property int    rssi:      modelData?.signal ?? 0
    readonly property bool   secure:    (modelData?.security ?? "") !== ""
    readonly property bool   isActive:  modelData?.active ?? false
    readonly property bool   known:     modelData?.knownProfile ?? false

    active: row.isActive || row.asking
    contentHeight: column.implicitHeight + row.verticalPadding * 2

    function _signalIcon(s) {
        if (s > 80) return "signal_wifi_4_bar";
        if (s > 60) return "network_wifi_3_bar";
        if (s > 40) return "network_wifi_2_bar";
        if (s > 20) return "network_wifi_1_bar";
        return "signal_wifi_0_bar";
    }

    onClicked: {
        if (row.isActive) {
            NetworkState.disconnect(row.ssid);
        } else if (row.secure && !row.known) {
            row.asking = !row.asking;
        } else {
            NetworkState.connect(row.ssid, "");
        }
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
            spacing: 10

            Text {
                text: row._signalIcon(row.rssi)
                color: Appearance.colors.m3onSurfaceVariant
                font.family: Appearance.typography.iconFamily
                font.pixelSize: Appearance.typography.larger
            }

            Text {
                Layout.fillWidth: true
                text: row.ssid || "(hidden)"
                color: Appearance.colors.m3onSurfaceVariant
                font.family: Config.typography.family
                font.pixelSize: Appearance.typography.small
                font.weight: row.isActive ? Appearance.typography.weightMedium : Appearance.typography.weightNormal
                elide: Text.ElideRight
            }

            Text {
                visible: row.secure || row.isActive
                text: row.isActive ? "check" : "lock"
                color: Appearance.colors.m3onSurfaceVariant
                font.family: Appearance.typography.iconFamily
                font.pixelSize: Appearance.typography.larger
            }
        }

        // Error caption.
        Text {
            Layout.fillWidth: true
            visible: row.errored
            text: row.errorMsg
            color: Appearance.colors.red
            font.family: Config.typography.family
            font.pixelSize: Appearance.typography.smaller
            elide: Text.ElideRight
        }

        // Password row.
        ColumnLayout {
            visible: row.asking
            Layout.topMargin: 8
            Layout.fillWidth: true
            spacing: Appearance.layout.gapMd

            MaterialTextField {
                id: pwField
                Layout.fillWidth: true
                echoMode: TextInput.Password
                placeholderText: "Password"
                hasError: row.errored
                onAccepted: connectBtn.trigger()
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 4

                Item { Layout.fillWidth: true }

                DialogButton {
                    text: "Cancel"
                    onClicked: row.asking = false
                }

                DialogButton {
                    id: connectBtn
                    text: "Connect"
                    variant: DialogButton.Variant.Primary
                    enabled: pwField.text.length > 0
                    onClicked: trigger()
                    function trigger() {
                        if (pwField.text.length === 0) return;
                        NetworkState.connect(row.ssid, pwField.text);
                    }
                }
            }
        }
    }

    Connections {
        target: NetworkState
        function onPasswordRequired(ssid) {
            if (ssid === row.ssid) {
                row.asking = true;
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
                row.asking = false;
                row.errored = false;
                row.errorMsg = "";
            }
        }
    }
}

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

    ColumnLayout {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 0

        // Tappable header row.
        Rectangle {
            id: header
            Layout.fillWidth: true
            implicitHeight: 44
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
                    text: row._signalIcon(row.rssi)
                    color: row.active ? Colors.colPrimary : Colors.m3onSurface
                    font.family: "Material Symbols Rounded"
                    font.pixelSize: 20
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    Text {
                        Layout.fillWidth: true
                        text: row.ssid || "(hidden)"
                        color: Colors.m3onSurface
                        font.family: "Inter"
                        font.pixelSize: 13
                        font.weight: row.active ? Font.Medium : Font.Normal
                        elide: Text.ElideRight
                    }

                    Text {
                        Layout.fillWidth: true
                        visible: row.errored
                        text: row.errorMsg
                        color: Qt.rgba(0.92, 0.45, 0.45, 1)
                        font.family: "Inter"
                        font.pixelSize: 11
                        elide: Text.ElideRight
                    }
                }

                Text {
                    visible: row.secure
                    text: row.active ? "check" : "lock"
                    color: row.active ? Colors.colPrimary : Colors.m3onSurfaceVariant
                    font.family: "Material Symbols Rounded"
                    font.pixelSize: 16
                }

                Text {
                    visible: row.active && !row.secure
                    text: "check"
                    color: Colors.colPrimary
                    font.family: "Material Symbols Rounded"
                    font.pixelSize: 16
                }
            }

            MouseArea {
                id: headerMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
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
        }

        // Password row.
        RowLayout {
            visible: row.expanded
            Layout.fillWidth: true
            Layout.leftMargin: 10
            Layout.rightMargin: 10
            Layout.topMargin: 4
            Layout.bottomMargin: 8
            spacing: 6

            MaterialTextField {
                id: pwField
                Layout.fillWidth: true
                echoMode: TextInput.Password
                placeholderText: "Password"
                hasError: row.errored
                onAccepted: connectBtn.activate()
            }

            Rectangle {
                id: connectBtn
                implicitHeight: 32
                implicitWidth: connectText.implicitWidth + 22
                radius: Config.layout.radiusSm
                color: connectMa.containsMouse ? Colors.accentHover : Colors.accent

                function activate() {
                    if (pwField.text.length === 0) return;
                    NetworkState.connect(row.ssid, pwField.text);
                }

                Text {
                    id: connectText
                    anchors.centerIn: parent
                    text: "Connect"
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
                    onClicked: connectBtn.activate()
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

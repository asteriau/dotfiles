pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import qs.components.text
import qs.utils
import qs.services

Item {
    id: root

    property bool expanded: false

    readonly property real level: BatteryState.level
    readonly property bool charging: BatteryState.charging
    readonly property bool low: BatteryState.low
    readonly property bool critical: BatteryState.critical

    readonly property color tint: critical
        ? "#ff5454"
        : (low ? "#e0c060"
              : (charging ? Colors.accent : Colors.foreground))

    readonly property string icon: {
        if (charging) return "battery_charging_full";
        const lv = Math.round(level * 100);
        if (lv >= 95) return "battery_full";
        if (lv >= 80) return "battery_6_bar";
        if (lv >= 65) return "battery_5_bar";
        if (lv >= 50) return "battery_4_bar";
        if (lv >= 35) return "battery_3_bar";
        if (lv >= 20) return "battery_2_bar";
        if (lv >= 10) return "battery_1_bar";
        return "battery_alert";
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        spacing: 8
        opacity: root.expanded ? 0 : 1
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: Appearance.motion.duration.short4; easing.type: Easing.OutCubic } }

        MaterialIcon {
            text: root.icon
            fill: 1
            pixelSize: 20
            color: root.tint
            Layout.alignment: Qt.AlignVCenter
        }
        StyledText {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            variant: StyledText.Variant.Body
            color: Colors.foreground
            font.weight: Font.Medium
            text: Math.round(root.level * 100) + "%" + (root.charging ? " · Charging" : "")
            elide: Text.ElideRight
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 14
        opacity: root.expanded ? 1 : 0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: Appearance.motion.duration.short4; easing.type: Easing.OutCubic } }

        Rectangle {
            Layout.preferredWidth: 56
            Layout.preferredHeight: 56
            Layout.alignment: Qt.AlignVCenter
            radius: width / 2
            color: Qt.rgba(root.tint.r, root.tint.g, root.tint.b, 0.18)
            MaterialIcon {
                anchors.centerIn: parent
                text: root.icon
                fill: 1
                pixelSize: 28
                color: root.tint
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 2

            StyledText {
                variant: StyledText.Variant.Label
                text: root.charging ? "Charging" : (root.low ? "Low battery" : "On battery")
                color: Colors.foreground
                font.weight: Font.DemiBold
            }
            StyledText {
                variant: StyledText.Variant.Subtitle
                text: Math.round(root.level * 100) + "%"
                color: Colors.foreground
            }
            StyledText {
                variant: StyledText.Variant.BodySm
                text: BatteryState.status
                color: Colors.foreground
                opacity: 0.7
            }
            Item { Layout.fillHeight: true }
        }
    }
}

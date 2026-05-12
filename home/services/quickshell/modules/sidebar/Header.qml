import QtQuick
import QtQuick.Layouts
import qs.modules.common.widgets
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models
import qs.services

Item {
    id: root
    Layout.fillWidth: true
    implicitHeight: row.implicitHeight

    Component.onCompleted: Weather.subscribe()
    Component.onDestruction: Weather.unsubscribe()

    property date now: new Date()
    readonly property string longDateLabel: {
        const day = root.now.getDate();
        let suffix = "th";

        if (day % 100 < 11 || day % 100 > 13) {
            if (day % 10 === 1) suffix = "st";
            else if (day % 10 === 2) suffix = "nd";
            else if (day % 10 === 3) suffix = "rd";
        }

        return Qt.formatDateTime(root.now, "ddd, MMM ") + day + suffix;
    }

    Timer {
        interval: 30000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.now = new Date()
    }

    // Single M3 row: date/weather meta · minimal settings icon
    RowLayout {
        id: row
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: 14

        ColumnLayout {
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: false
            spacing: 2

            StyledText {
                text: root.longDateLabel
                color: Appearance.colors.foreground
                font.pixelSize: Appearance.typography.small
                font.weight: Font.Medium
            }

            RowLayout {
                spacing: 6
                visible: Weather.ready

                MaterialIcon {
                    text: Weather.glyph
                    pixelSize: 14
                    fill: 1
                    weight: 450
                    grade: 0
                    color: Appearance.colors.m3onSurfaceVariant
                }

                StyledText {
                    text: Math.round(Weather.temp) + "°"
                    color: Appearance.colors.m3onSurfaceVariant
                    font.pixelSize: Appearance.typography.smaller
                    font.weight: Font.Medium
                }

                StyledText {
                    text: "·"
                    color: Appearance.colors.m3onSurfaceVariant
                    font.pixelSize: Appearance.typography.smaller
                }

                StyledText {
                    text: {
                        const d = Weather.description || Weather.condition;
                        return d ? d.charAt(0).toUpperCase() + d.slice(1) : "";
                    }
                    color: Appearance.colors.m3onSurfaceVariant
                    font.pixelSize: Appearance.typography.smaller
                }
            }
        }

        Item { Layout.fillWidth: true }

        IconButton {
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            implicitWidth: 32
            implicitHeight: 32
            radius: 16
            icon: "settings"
            iconPixelSize: 20
            iconGrade: 0
            colorIdle: "transparent"
            colorActive: "transparent"
            colorActiveHover: "transparent"
            tintOnHover: true
            onClicked: Utils.launchSettings()
        }
    }
}

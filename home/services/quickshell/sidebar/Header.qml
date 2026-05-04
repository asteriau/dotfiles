import QtQuick
import QtQuick.Layouts
import qs.components.surfaces
import qs.components.text
import qs.utils
import qs.utils.state

Item {
    id: root
    Layout.fillWidth: true
    implicitHeight: contentCol.implicitHeight

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
    readonly property string hiLowLabel: "H " + Math.round(WeatherState.tempMax) + "°  L " + Math.round(WeatherState.tempMin) + "°"

    Timer {
        interval: 30000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.now = new Date()
    }

    // ── Top-left: hero clock + date/weather inline ──
    ColumnLayout {
        id: contentCol
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: 0

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            StyledText {
                Layout.alignment: Qt.AlignVCenter
                text: Qt.formatDateTime(root.now, "HH:mm")
                color: Colors.foreground
                font.pixelSize: 40
                font.weight: Font.Medium
                font.letterSpacing: -0.6
            }

            Item { Layout.fillWidth: true }

            IconButton {
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredWidth: Config.layout.iconBtnSize
                Layout.preferredHeight: Config.layout.iconBtnSize
                radius: width / 2
                colorIdle:    Colors.transparent
                tintOnHover:  true
                colorHover:   Colors.hover
                colorPressed: Colors.hover
                enableScale:  false
                iconPixelSize: 18
                iconGrade: 0
                iconWeight: 400
                colorIcon: Colors.m3onSurfaceVariant
                icon: "settings"
                onClicked: Utils.launchSettings()
            }
        }

        RowLayout {
            Layout.topMargin: 2
            spacing: 8

            StyledText {
                text: root.longDateLabel
                variant: StyledText.Variant.Caption
            }

            StyledText {
                visible: WeatherState.ready
                text: "·"
                color: Colors.m3onSurfaceVariant
                font.pixelSize: Config.typography.small
            }

            MaterialIcon {
                visible: WeatherState.ready
                text: WeatherState.glyph
                pixelSize: 14
                fill: 1
                weight: 450
                grade: 0
                color: Colors.m3onSurfaceVariant
            }

            StyledText {
                visible: WeatherState.ready
                text: Math.round(WeatherState.temp) + "°"
                color: Colors.foreground
                font.pixelSize: Config.typography.small
                font.weight: Font.Medium
            }

            StyledText {
                visible: WeatherState.ready
                text: root.hiLowLabel
                color: Colors.m3onSurfaceVariant
                font.pixelSize: Config.typography.smaller
            }
        }
    }
}

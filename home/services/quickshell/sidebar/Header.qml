import QtQuick
import QtQuick.Layouts
import qs.components.surfaces
import qs.components.text
import qs.utils
import qs.utils.state

RowLayout {
    id: root
    Layout.fillWidth: true
    spacing: 12

    property date now: new Date()
    readonly property string longDateLabel: {
        const day = root.now.getDate();
        let suffix = "th";

        if (day % 100 < 11 || day % 100 > 13) {
            if (day % 10 === 1) suffix = "st";
            else if (day % 10 === 2) suffix = "nd";
            else if (day % 10 === 3) suffix = "rd";
        }

        return Qt.formatDateTime(root.now, "dddd, MMMM ") + day + suffix;
    }
    readonly property string weatherLabel: {
        const d = WeatherState.description;
        const fallback = WeatherState.condition;
        const label = d.length > 0 ? d : fallback;
        return label.length > 0 ? label.charAt(0).toUpperCase() + label.slice(1) : "Weather";
    }
    readonly property string hiLowLabel: "H " + Math.round(WeatherState.tempMax) + "°  L " + Math.round(WeatherState.tempMin) + "°"

    Timer {
        interval: 30000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.now = new Date()
    }

    // Flat ghost button (no idle fill, subtle hover tint). Reuses IconButton
    // so the pill, hover tint, and press scale all come from PressablePill.
    component IconBtn: IconButton {
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
    }

    ColumnLayout {
        Layout.alignment: Qt.AlignVCenter
        spacing: 2

        StyledText {
            text: Qt.formatDateTime(root.now, "HH:mm")
            color: Colors.foreground
            font.pixelSize: Config.typography.title
            font.weight: Font.Medium
            font.letterSpacing: -0.44
        }

        StyledText {
            text: root.longDateLabel
            variant: StyledText.Variant.Caption
        }

        RowLayout {
            visible: WeatherState.ready || WeatherState.errorMessage.length > 0
            spacing: 4

            StyledText {
                visible: WeatherState.ready
                text: root.weatherLabel
                variant: StyledText.Variant.Caption
                elide: Text.ElideRight
                Layout.maximumWidth: 112
            }

            StyledText {
                visible: WeatherState.ready
                text: root.hiLowLabel
                variant: StyledText.Variant.Caption
            }

            RowLayout {
                Layout.alignment: Qt.AlignVCenter
                spacing: 2

                StyledText {
                    Layout.alignment: Qt.AlignVCenter
                    text: WeatherState.ready ? Math.round(WeatherState.temp) + "°" : "Weather unavailable"
                    color: Colors.m3onSurfaceVariant
                    font.pixelSize: Config.typography.smaller
                    font.weight: Font.Medium
                }

                MaterialIcon {
                    visible: WeatherState.ready
                    Layout.alignment: Qt.AlignVCenter
                    Layout.topMargin: 1
                    text: WeatherState.glyph
                    pixelSize: 13
                    fill: 1
                    weight: 450
                    grade: 0
                    color: Colors.m3onSurfaceVariant
                }
            }
        }
    }

    Item { Layout.fillWidth: true }

    IconBtn { icon: "edit" }
    IconBtn { icon: "power_settings_new" }
    IconBtn {
        icon: "settings"
        onClicked: Utils.launchSettings()
    }
}

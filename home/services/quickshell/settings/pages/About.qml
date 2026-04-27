import QtQuick
import QtQuick.Layouts
import qs.utils
import qs.components
import qs.settings

ContentPage {
    ColumnLayout {
        Layout.fillWidth: true
        spacing: 4

        Text {
            text: "Tachyon"
            color: Colors.accent
            font.family: Config.typography.family
            font.pixelSize: Config.typography.huge + 4
            font.weight: Font.Medium
            font.letterSpacing: -0.4
        }

        Text {
            text: "A shell that's slightly fast"
            color: Colors.comment
            font.family: Config.typography.family
            font.pixelSize: Config.typography.small
            Layout.bottomMargin: 6
        }

        InfoRow { label: "Distro";   value: SystemInfoState.distro }
        InfoRow { label: "Kernel";   value: SystemInfoState.kernel }
        InfoRow { label: "Hostname"; value: SystemInfoState.hostname }
        InfoRow { label: "WM";       value: SystemInfoState.desktop }
        InfoRow { label: "Uptime";   value: SystemInfoState.uptime }
    }
}

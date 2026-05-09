import QtQuick
import QtQuick.Layouts
import qs.components.content
import qs.components.text
import qs.settings
import qs.utils
import qs.utils.state

ContentPage {
    ColumnLayout {
        Layout.fillWidth: true
        Layout.leftMargin: 4
        Layout.bottomMargin: 8
        spacing: 4

        StyledText {
            text: "Tachyon"
            color: Colors.accent
            font.pixelSize: Config.typography.huge + 4
            font.weight: Font.Medium
            font.letterSpacing: -0.4
        }

        StyledText {
            text: "A shell that's slightly fast"
            color: Colors.m3onSurfaceVariant
            font.pixelSize: Config.typography.small
        }
    }

    ContentSection {
        title: "System"

        InfoRow { label: "Distro";   value: SystemInfoState.distro }
        InfoRow { label: "Kernel";   value: SystemInfoState.kernel }
        InfoRow { label: "Hostname"; value: SystemInfoState.hostname }
        InfoRow { label: "WM";       value: SystemInfoState.desktop }
        InfoRow { label: "Uptime";   value: SystemInfoState.uptime }
    }
}

import QtQuick
import QtQuick.Layouts
import qs.modules.common.widgets
import qs.modules.settings
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models
import qs.services

ContentPage {
    Component.onCompleted: SystemInfoState.subscribe()
    Component.onDestruction: SystemInfoState.unsubscribe()

    ColumnLayout {
        Layout.fillWidth: true
        Layout.leftMargin: 4
        Layout.bottomMargin: 8
        spacing: 4

        StyledText {
            text: "Tachyon"
            color: Appearance.colors.accent
            font.pixelSize: Appearance.typography.huge + 4
            font.weight: Font.Medium
            font.letterSpacing: -0.4
        }

        StyledText {
            text: "A shell that's slightly fast"
            color: Appearance.colors.m3onSurfaceVariant
            font.pixelSize: Appearance.typography.small
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

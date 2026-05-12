import QtQuick
import QtQuick.Layouts
import qs.modules.common.widgets
import qs.modules.settings
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models
import qs.services

ContentPage {
    Component.onCompleted: SystemInfo.subscribe()
    Component.onDestruction: SystemInfo.unsubscribe()

    ColumnLayout {
        Layout.fillWidth: true
        Layout.leftMargin: Appearance.layout.gapSm
        Layout.bottomMargin: Appearance.layout.gapMd
        spacing: Appearance.layout.gapSm

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

        InfoRow { label: "Distro";   value: SystemInfo.distro }
        InfoRow { label: "Kernel";   value: SystemInfo.kernel }
        InfoRow { label: "Hostname"; value: SystemInfo.hostname }
        InfoRow { label: "WM";       value: SystemInfo.desktop }
        InfoRow { label: "Uptime";   value: SystemInfo.uptime }
    }
}

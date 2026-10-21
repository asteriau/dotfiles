import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.widgets

ContentPage {
    forceWidth: true
    Component.onCompleted: SystemInfo.subscribe()
    Component.onDestruction: SystemInfo.unsubscribe()

    ColumnLayout {
        Layout.fillWidth: true
        Layout.leftMargin: 10
        Layout.bottomMargin: 10
        spacing: 4

        StyledText {
            text: "Tachyon"
            color: Appearance.colors.colPrimary
            font.pixelSize: Appearance.font.pixelSize.hugeass + 4
            font.weight: Font.Medium
        }
        StyledText {
            text: Translation.tr("A shell that's slightly fast")
            color: Appearance.colors.colSubtext
            font.pixelSize: Appearance.font.pixelSize.small
        }
    }

    ContentSection {
        icon: "info"
        title: Translation.tr("System")

        InfoRow { label: Translation.tr("Distro");   value: SystemInfo.distroName }
        InfoRow { label: Translation.tr("Kernel");   value: SystemInfo.kernel }
        InfoRow { label: Translation.tr("Hostname"); value: SystemInfo.hostname }
        InfoRow { label: Translation.tr("WM");       value: SystemInfo.desktopEnvironment }
        InfoRow { label: Translation.tr("Uptime");   value: SystemInfo.uptime }
    }
}

import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.widgets

ContentPage {
    forceWidth: true
    Component.onCompleted: SystemInfo.subscribe()
    Component.onDestruction: SystemInfo.unsubscribe()

    ColumnLayout { // Lockup
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: 36
        spacing: 14

        MaterialShapeWrappedMaterialSymbol {
            Layout.alignment: Qt.AlignHCenter
            shape: MaterialShape.Shape.Cookie7Sided
            text: "motion_blur"
            iconSize: 64
            padding: 28
            fill: 1
            color: Appearance.colors.colPrimaryContainer
            colSymbol: Appearance.colors.colOnPrimaryContainer
        }
        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 4
            StyledText {
                Layout.alignment: Qt.AlignHCenter
                text: "Tachyon"
                color: Appearance.colors.colPrimary
                font.pixelSize: 34
                font.family: Appearance.font.family.title
                font.variableAxes: Appearance.font.variableAxes.title
            }
            StyledText {
                Layout.alignment: Qt.AlignHCenter
                text: Translation.tr("A shell that's slightly fast")
                color: Appearance.colors.colSubtext
                font.pixelSize: Appearance.font.pixelSize.small
            }
        }
    }

    ColumnLayout { // Info list
        Layout.fillWidth: true
        spacing: 2

        InfoRow { first: true; iconSource: SystemInfo.distroIcon; label: Translation.tr("Distro"); value: SystemInfo.distroName }
        InfoRow { icon: "memory"; label: Translation.tr("Kernel"); value: SystemInfo.kernel }
        InfoRow { icon: "computer"; label: Translation.tr("Hostname"); value: SystemInfo.hostname }
        InfoRow { icon: "desktop_windows"; label: Translation.tr("WM"); value: `${SystemInfo.desktopEnvironment}   •   ${SystemInfo.windowingSystem}` }
        InfoRow { last: true; icon: "schedule"; label: Translation.tr("Uptime"); value: SystemInfo.uptime }
    }
}

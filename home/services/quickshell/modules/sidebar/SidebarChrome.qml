import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import qs.modules.common

Rectangle {
    id: root

    anchors {
        margins: Appearance.layout.gapMd
        topMargin:    Config.bar.position === "top"    ? Appearance.bar.height + Appearance.layout.gapMd : Appearance.layout.gapMd
        bottomMargin: Config.bar.position === "bottom" ? Appearance.bar.height + Appearance.layout.gapMd : Appearance.layout.gapMd
    }
    radius: Appearance.layout.cardRadius
    color: Appearance.colors.background
    layer.enabled: true

    Item {
        id: chromeWrap
        anchors.fill: parent

        property real blurAmt: UiState.sidebarMenu !== "none" ? 1.0 : 0.0
        Behavior on blurAmt {
            NumberAnimation {
                duration: Appearance.motion.duration.medium3
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Appearance.motion.easing.emphasized
            }
        }

        layer.enabled: chromeWrap.blurAmt > 0.001
        layer.effect: MultiEffect {
            blurEnabled: true
            blurMax: 32
            blur: chromeWrap.blurAmt
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.topMargin: Appearance.layout.gapXl + Appearance.layout.gapSm
            anchors.bottomMargin: Appearance.layout.gapLg
            anchors.leftMargin: 0
            anchors.rightMargin: 0
            spacing: Appearance.layout.gapLg

            Header {
                Layout.leftMargin: Appearance.layout.gapXl + Appearance.layout.gapSm
                Layout.rightMargin: Appearance.layout.gapXl + Appearance.layout.gapSm
                Layout.bottomMargin: Appearance.layout.gapLg
            }

            QuickToggles {
                Layout.fillWidth: true
                Layout.leftMargin: Appearance.layout.gapLg
                Layout.rightMargin: Appearance.layout.gapLg
                Layout.bottomMargin: Appearance.layout.gapLg
            }

            QuickSliders {
                Layout.fillWidth: true
                Layout.leftMargin: Appearance.layout.gapLg
                Layout.rightMargin: Appearance.layout.gapLg
                Layout.bottomMargin: Appearance.layout.gapLg
            }

            NotificationCenter {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.leftMargin: Appearance.layout.gapMd
                Layout.rightMargin: Appearance.layout.gapMd
            }

            NotificationToolbar {
                Layout.leftMargin: Appearance.layout.gapXl + Appearance.layout.gapSm
                Layout.rightMargin: Appearance.layout.gapXl + Appearance.layout.gapSm
            }
        }
    }
}

import QtQuick
import QtQuick.Layouts
import qs.modules.common.widgets
import qs.modules.common
import qs.modules.common.functions

Item {
    id: root

    Rectangle {
        anchors.fill: parent
        color: Appearance.colors.background
        visible: !Config.bar.rounding
    }

    BarShape {
        anchors.fill: parent
        bodyWidth:    parent.width
        bodyHeight:   parent.height
        onEnd:        Config.bar.onEnd
        screenRadius: 0
        freeRadius:   Appearance.bar.cornerRadius
        fillColor:    Appearance.colors.background
        visible:      Config.bar.rounding
    }

    Item {
        id: navZone
        anchors {
            top: parent.top
            topMargin: Appearance.layout.zonePaddingV
            horizontalCenter: parent.horizontalCenter
        }
        implicitWidth: sidebarToggle.implicitWidth
        implicitHeight: sidebarToggle.implicitHeight

        SidebarToggle { id: sidebarToggle }
    }

    ColumnLayout {
        id: centerZone
        anchors {
            verticalCenter: parent.verticalCenter
            horizontalCenter: parent.horizontalCenter
        }
        spacing: Appearance.layout.barZoneGap

        BarGroup {
            Layout.alignment: Qt.AlignHCenter
            tone: "low"
            padding: 0

            ResourcesBar {}
        }
        Workspaces { Layout.alignment: Qt.AlignHCenter }

        BarGroup {
            Layout.alignment: Qt.AlignHCenter
            tone: "low"
            rowSpacing: Appearance.layout.gapMd
            padding: 0

            Clock {}
        }
    }

    ColumnLayout {
        id: statusZone
        anchors {
            bottom: parent.bottom
            bottomMargin: Appearance.layout.zonePaddingV
            horizontalCenter: parent.horizontalCenter
        }
        spacing: Appearance.layout.barZoneGap

        BarGroup {
            id: batteryGroup
            Layout.alignment: Qt.AlignHCenter
            tone: "low"
            rowSpacing: Appearance.layout.gapMd
            transparent: !battery.low
            bgColor: battery.low
                ? ColorUtils.mix(Appearance.colors.red, toneColor, 0.2)
                : toneColor

            Battery { id: battery }
        }

        Tray { Layout.alignment: Qt.AlignHCenter }
    }
}

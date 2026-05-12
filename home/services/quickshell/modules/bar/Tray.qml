import QtQuick
import QtQuick.Layouts
import qs.modules.common

Item {
    id: root

    property bool vertical: true
    property bool iconsVisible: false

    readonly property int entryIconSize: 20
    readonly property int toggleSize:    26

    Layout.alignment: Qt.AlignHCenter

    implicitWidth:  vertical ? Appearance.bar.width
                             : (layoutLoader.item?.implicitWidth ?? 0) + Appearance.layout.gapMd * 2
    implicitHeight: vertical ? (layoutLoader.item?.implicitHeight ?? 0) + Appearance.layout.gapMd
                             : Appearance.bar.height

    Rectangle {
        id: card
        anchors.fill: parent
        anchors.topMargin:    root.vertical ? 0 : Appearance.layout.gapSm
        anchors.bottomMargin: root.vertical ? 0 : Appearance.layout.gapSm
        anchors.leftMargin:   root.vertical ? Appearance.layout.gapSm : 0
        anchors.rightMargin:  root.vertical ? Appearance.layout.gapSm : 0
        radius: Appearance.layout.radiusContainer
        color: Appearance.colors.surfaceContainerLow

        Behavior on color {
            ColorAnimation { duration: Appearance.motion.duration.effects; easing.type: Easing.OutCubic }
        }
    }

    Loader {
        id: layoutLoader
        anchors.fill: parent
        sourceComponent: root.vertical ? verticalLayout : horizontalLayout
    }

    Component {
        id: verticalLayout
        TrayVertical {
            iconsVisible: root.iconsVisible
            iconSize: root.entryIconSize
            toggleSize: root.toggleSize
            onToggled: root.iconsVisible = !root.iconsVisible
        }
    }
    Component {
        id: horizontalLayout
        TrayHorizontal {
            iconsVisible: root.iconsVisible
            iconSize: root.entryIconSize
            toggleSize: root.toggleSize
            onToggled: root.iconsVisible = !root.iconsVisible
        }
    }
}

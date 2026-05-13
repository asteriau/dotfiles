import QtQuick
import QtQuick.Layouts
import qs.modules.common

Item {
    id: root

    property bool vertical: true
    property bool iconsVisible: false
    property string cluster: "solo"

    readonly property bool _roundStart: cluster === "start" || cluster === "solo"
    readonly property bool _roundEnd:   cluster === "end"   || cluster === "solo"
    readonly property bool _roundTL: vertical ? _roundStart : _roundStart
    readonly property bool _roundTR: vertical ? _roundStart : _roundEnd
    readonly property bool _roundBL: vertical ? _roundEnd   : _roundStart
    readonly property bool _roundBR: vertical ? _roundEnd   : _roundEnd

    readonly property int entryIconSize: 20
    readonly property int toggleSize:    26

    Layout.alignment: Qt.AlignHCenter

    implicitWidth:  vertical ? Appearance.bar.width
                             : (hLayout.implicitWidth + Appearance.layout.gapMd * 2)
    implicitHeight: vertical ? (vLayout.implicitHeight + Appearance.layout.gapMd)
                             : Appearance.bar.height

    Rectangle {
        id: card
        anchors.fill: parent
        anchors.topMargin:    root.vertical ? 0 : Appearance.layout.gapSm
        anchors.bottomMargin: root.vertical ? 0 : Appearance.layout.gapSm
        anchors.leftMargin:   root.vertical ? Appearance.layout.gapSm : 0
        anchors.rightMargin:  root.vertical ? Appearance.layout.gapSm : 0
        topLeftRadius:     root._roundTL ? Appearance.layout.radiusContainer : Appearance.layout.radiusInner
        topRightRadius:    root._roundTR ? Appearance.layout.radiusContainer : Appearance.layout.radiusInner
        bottomLeftRadius:  root._roundBL ? Appearance.layout.radiusContainer : Appearance.layout.radiusInner
        bottomRightRadius: root._roundBR ? Appearance.layout.radiusContainer : Appearance.layout.radiusInner
        color: Appearance.colors.surfaceContainerLow

        Behavior on color {
            ColorAnimation { duration: Appearance.motion.duration.effects; easing.type: Easing.OutCubic }
        }
    }

    TrayVertical {
        id: vLayout
        visible: root.vertical
        iconsVisible: root.iconsVisible
        iconSize: root.entryIconSize
        toggleSize: root.toggleSize
        onToggled: root.iconsVisible = !root.iconsVisible
    }

    TrayHorizontal {
        id: hLayout
        visible: !root.vertical
        iconsVisible: root.iconsVisible
        iconSize: root.entryIconSize
        toggleSize: root.toggleSize
        onToggled: root.iconsVisible = !root.iconsVisible
    }
}

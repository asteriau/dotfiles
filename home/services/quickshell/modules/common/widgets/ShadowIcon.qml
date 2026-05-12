import org.kde.kirigami
import QtQuick
import QtQuick.Effects
import Quickshell
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models

Item {
    id: root

    property alias source: iconItem.source
    property alias color: iconItem.color
    property bool isMask: true

    implicitWidth: Config.typography.iconSize
    implicitHeight: Config.typography.iconSize

    Icon {
        id: iconItem
        anchors.fill: parent
        isMask: root.isMask
        color: Appearance.colors.foreground
    }

    MultiEffect {
        source: iconItem
        anchors.fill: iconItem
        shadowEnabled: Appearance.shadow.enabled
        shadowVerticalOffset: Appearance.shadow.verticalOffset
        blurMax: Appearance.shadow.blur
        opacity: Appearance.shadow.opacity
    }
}

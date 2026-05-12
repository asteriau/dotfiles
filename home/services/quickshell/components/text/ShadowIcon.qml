import org.kde.kirigami
import QtQuick
import QtQuick.Effects
import Quickshell
import qs.utils

Item {
    id: root

    property alias source: iconItem.source
    property alias color: iconItem.color
    property bool isMask: true

    implicitWidth: Config.iconSize
    implicitHeight: Config.iconSize

    Icon {
        id: iconItem
        anchors.fill: parent
        isMask: root.isMask
        color: Appearance.colors.foreground
    }

    MultiEffect {
        source: iconItem
        anchors.fill: iconItem
        shadowEnabled: Config.shadow.enabled
        shadowVerticalOffset: Config.shadow.verticalOffset
        blurMax: Config.shadow.blur
        opacity: Config.shadow.opacity
    }
}

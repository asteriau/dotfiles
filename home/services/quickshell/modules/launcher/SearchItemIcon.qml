import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.modules.common.widgets
import qs.modules.common

Loader {
    id: root

    required property var entry
    required property color color

    sourceComponent: {
        switch (entry?.iconType) {
            case "system":   return sysIconComp;
            case "material": return matIconComp;
            case "text":     return textIconComp;
            default:         return null;
        }
    }

    Component {
        id: sysIconComp
        IconImage {
            source: root.entry?.iconSource
                ?? Quickshell.iconPath(root.entry?.iconName ?? "", "application-x-executable")
            asynchronous: true
            anchors.fill: parent
        }
    }

    Component {
        id: matIconComp
        MaterialIcon {
            anchors.centerIn: parent
            text: root.entry?.iconName ?? ""
            pixelSize: 26
            color: root.color
        }
    }

    Component {
        id: textIconComp
        StyledText {
            anchors.centerIn: parent
            text: root.entry?.iconName ?? ""
            font.pixelSize: Appearance.typography.huge
            color: root.color
        }
    }
}

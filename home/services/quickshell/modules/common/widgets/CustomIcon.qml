import QtQuick
import Quickshell.Widgets
import Qt5Compat.GraphicalEffects
import qs.modules.common

Item {
    id: root

    property bool colorize: false
    property color color
    property string source: ""
    property string iconFolder: "file://" + Directories.shellDir + "/assets/icons"
    width: 30
    height: 30

    IconImage {
        id: iconImage
        anchors.fill: parent
        source: {
            const fullPathWhenSourceIsIconName = root.iconFolder + "/" + root.source;
            if (root.iconFolder && fullPathWhenSourceIsIconName) {
                return fullPathWhenSourceIsIconName;
            }
            return root.source;
        }
        implicitSize: root.height
    }

    Loader {
        active: root.colorize
        anchors.fill: iconImage
        sourceComponent: ColorOverlay {
            source: iconImage
            color: root.color
        }
    }
}

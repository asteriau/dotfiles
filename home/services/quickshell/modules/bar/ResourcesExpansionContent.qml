import QtQuick
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models

Item {
    id: root

    property real padding: Appearance.layout.gapXl

    implicitWidth:  panel.width + padding * 2
    implicitHeight: panel.implicitHeight + padding * 2

    ResourcesPanel {
        id: panel
        x: root.padding
        y: root.padding
    }
}

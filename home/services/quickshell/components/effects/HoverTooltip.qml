import QtQuick
import Quickshell.Widgets
import qs.utils

WrapperMouseArea {
    id: root

    property var rect: Qt.rect(root.width / 2, root.height + Config.padding * 2, 0, 0)
    required property string text
    default property alias contentItem: contentItem.data

    hoverEnabled: true
    acceptedButtons: Qt.NoButton

    onEntered: {
        if (root.text === "") return
        hideTimer.stop()
        tooltip.visible = true
    }
    onExited: {
        if (tooltip.visible) {
            tooltip.shown = false
            hideTimer.restart()
        }
    }

    implicitWidth: contentItem.childrenRect.width
    implicitHeight: contentItem.childrenRect.height

    Timer {
        id: hideTimer
        // Matches the bg shrink animation duration so the popup window stays
        // alive long enough to play the exit transition.
        interval: 220
        onTriggered: tooltip.visible = false
    }

    TextTooltip {
        id: tooltip
        targetItem: root
        targetRect: root.rect
        targetText: root.text
        visible: false
    }

    Item {
        id: contentItem
    }
}

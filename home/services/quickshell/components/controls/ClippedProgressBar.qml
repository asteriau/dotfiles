import QtQuick
import Qt5Compat.GraphicalEffects
import qs.utils

// Pill progress bar with text rendered as a solid overlay via OpacityMask.
// Fill shows level; text/icon is masked on top in textColor for readability.
Item {
    id: root

    property bool  vertical:      false
    property real  value:          0
    property real  valueBarWidth:  30
    property real  valueBarHeight: 18
    property color highlightColor: Colors.m3onSecondaryContainer
    property color trackColor:     Qt.rgba(highlightColor.r, highlightColor.g, highlightColor.b, 0.35)
    property color textColor:      Colors.background
    default property Item textMask: Item {
        width:  root.valueBarWidth
        height: root.valueBarHeight
    }

    implicitWidth:  valueBarWidth
    implicitHeight: valueBarHeight

    Behavior on value {
        NumberAnimation { duration: M3Easing.durationShort4; easing.type: Easing.OutCubic }
    }

    // Step 1: track + fill (small radius on fill so it doesn't look nested)
    Rectangle {
        id: trackRect
        anchors.fill: parent
        radius: 9999
        color: root.trackColor
        visible: false
        layer.enabled: true

        Rectangle {
            color: root.highlightColor
            radius: 3
            x: 0
            y: root.vertical ? parent.height * (1 - root.value) : 0
            width:  root.vertical ? parent.width  : parent.width  * root.value
            height: root.vertical ? parent.height * root.value : parent.height
        }
    }

    // Step 2: clip track+fill to pill outline — rendered visible
    OpacityMask {
        anchors.fill: parent
        source: trackRect
        maskSource: Rectangle {
            width:  root.valueBarWidth
            height: root.valueBarHeight
            radius: 9999
        }
    }

    // Step 3: text overlay — textColor rect masked to text shape, on top of fill
    Rectangle {
        id: textColorRect
        anchors.fill: parent
        color: root.textColor
        visible: false
        layer.enabled: true
    }

    OpacityMask {
        anchors.fill: parent
        source: textColorRect
        invert: false
        maskSource: root.textMask
    }
}

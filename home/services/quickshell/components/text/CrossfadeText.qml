import QtQuick
import qs.utils

// Crossfades between two StyledText instances when `text` changes.
Item {
    id: root

    property string text: ""
    property real pixelSize: Config.typography.medium
    property int fontWeight: Font.Normal
    property color color: Colors.foreground
    property int elide: Text.ElideNone
    property int horizontalAlignment: Text.AlignLeft

    property string _a: text
    property string _b: text
    property bool _aActive: true

    implicitWidth:  Math.max(labelA.implicitWidth, labelB.implicitWidth)
    implicitHeight: Math.max(labelA.implicitHeight, labelB.implicitHeight)

    onTextChanged: {
        const current = _aActive ? _a : _b;
        if (text === current) return;
        if (_aActive) { _b = text; _aActive = false; }
        else          { _a = text; _aActive = true; }
    }

    StyledText {
        id: labelA
        anchors.fill: parent
        text: root._a
        font.pixelSize: root.pixelSize
        font.weight: root.fontWeight
        color: root.color
        elide: root.elide
        horizontalAlignment: root.horizontalAlignment
        opacity: root._aActive ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: M3Easing.effectsDuration; easing.type: Easing.OutCubic } }
    }
    StyledText {
        id: labelB
        anchors.fill: parent
        text: root._b
        font.pixelSize: root.pixelSize
        font.weight: root.fontWeight
        color: root.color
        elide: root.elide
        horizontalAlignment: root.horizontalAlignment
        opacity: root._aActive ? 0 : 1
        Behavior on opacity { NumberAnimation { duration: M3Easing.effectsDuration; easing.type: Easing.OutCubic } }
    }
}

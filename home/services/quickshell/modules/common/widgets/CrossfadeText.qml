import QtQuick
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models

// Crossfades between two StyledText instances when `text` changes.
Item {
    id: root

    property string text: ""
    property real pixelSize: Config.typography.medium
    property int fontWeight: Font.Normal
    property color color: Appearance.colors.foreground
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
        verticalAlignment: Text.AlignVCenter
        opacity: root._aActive ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: Appearance.motion.duration.effects; easing.type: Easing.OutCubic } }
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
        verticalAlignment: Text.AlignVCenter
        opacity: root._aActive ? 0 : 1
        Behavior on opacity { NumberAnimation { duration: Appearance.motion.duration.effects; easing.type: Easing.OutCubic } }
    }
}

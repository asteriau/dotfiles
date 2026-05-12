import QtQuick
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models

Item {
    id: root

    property string text: ""
    property real pointSize: Appearance.typography.huge
    property real pixelSize: 0                 // when > 0, overrides pointSize
    property color color: Appearance.colors.foreground
    property real fill: 0
    property int  weight: 400
    property int  grade: -25

    // Seed both slots with the initial text so first paint doesn't flash empty.
    property string _a: text
    property string _b: text
    property bool _aActive: true

    readonly property real _effectiveSize: pixelSize > 0 ? pixelSize : pointSize
    implicitWidth:  _effectiveSize
    implicitHeight: _effectiveSize

    onTextChanged: {
        const current = _aActive ? _a : _b;
        if (text === current) return;
        if (_aActive) { _b = text; _aActive = false; }
        else          { _a = text; _aActive = true; }
    }

    MaterialIcon {
        anchors.centerIn: parent
        text: root._a
        font.pointSize: root.pointSize
        pixelSize: root.pixelSize
        fill: root.fill
        weight: root.weight
        grade: root.grade
        color: root.color
        opacity: root._aActive ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: Appearance.motion.duration.effects; easing.type: Easing.OutCubic } }
    }
    MaterialIcon {
        anchors.centerIn: parent
        text: root._b
        font.pointSize: root.pointSize
        pixelSize: root.pixelSize
        fill: root.fill
        weight: root.weight
        grade: root.grade
        color: root.color
        opacity: root._aActive ? 0 : 1
        Behavior on opacity { NumberAnimation { duration: Appearance.motion.duration.effects; easing.type: Easing.OutCubic } }
    }
}

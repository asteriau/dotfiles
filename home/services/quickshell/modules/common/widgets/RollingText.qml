import QtQuick
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models

Item {
    id: root

    property string text: ""
    property int    pixelSize: Appearance.typography.large
    property string family: Config.typography.family
    property int    weight: Font.Normal
    property color  color: Appearance.colors.foreground
    property int    horizontalAlignment: Text.AlignHCenter
    property int    duration: Appearance.motion.duration.medium1

    property string _a: text
    property string _b: ""
    property bool   _aActive: true

    clip: true
    implicitWidth:  Math.max(a.implicitWidth, b.implicitWidth)
    implicitHeight: Math.max(a.implicitHeight, b.implicitHeight)

    onTextChanged: {
        const cur = _aActive ? _a : _b;
        if (text === cur) return;
        if (_aActive) { _b = text; _aActive = false; }
        else          { _a = text; _aActive = true; }
    }

    Text {
        id: a
        text: root._a
        font.family: root.family
        font.pixelSize: root.pixelSize
        font.weight: root.weight
        color: root.color
        renderType: Text.NativeRendering
        horizontalAlignment: root.horizontalAlignment
        anchors.horizontalCenter: parent.horizontalCenter
        y: root._aActive ? 0 : -root.implicitHeight
        Behavior on y {
            NumberAnimation {
                duration: root.duration
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Appearance.motion.easing.emphasizedDecel
            }
        }
    }

    Text {
        id: b
        text: root._b
        font.family: root.family
        font.pixelSize: root.pixelSize
        font.weight: root.weight
        color: root.color
        renderType: Text.NativeRendering
        horizontalAlignment: root.horizontalAlignment
        anchors.horizontalCenter: parent.horizontalCenter
        y: root._aActive ? root.implicitHeight : 0
        Behavior on y {
            NumberAnimation {
                duration: root.duration
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Appearance.motion.easing.emphasizedDecel
            }
        }
    }
}

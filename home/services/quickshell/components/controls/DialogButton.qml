import QtQuick
import QtQuick.Layouts
import qs.utils

// Pill action button used in dialog footers and inline expanded rows.
// Default variant: transparent fill, primary-colored text (M3 text button).
// Override `variant` for affirming, destructive, or layered actions.
Item {
    id: root

    enum Variant { Default, Primary, Danger, Layer4 }

    property int    variant: DialogButton.Variant.Default
    property string text: ""
    property bool   enabled: true

    signal clicked

    Layout.fillWidth: false
    implicitHeight: 36
    implicitWidth: label.implicitWidth + 28
    opacity: enabled ? 1 : 0.4

    readonly property color _bg: {
        switch (variant) {
        case DialogButton.Variant.Primary: return Colors.accent;
        case DialogButton.Variant.Danger:  return Colors.red;
        case DialogButton.Variant.Layer4:  return Colors.colLayer4;
        case DialogButton.Variant.Default: return Qt.rgba(Colors.colLayer3.r, Colors.colLayer3.g, Colors.colLayer3.b, 0);
        }
    }
    readonly property color _bgHover: {
        switch (variant) {
        case DialogButton.Variant.Primary: return Colors.accentHover;
        case DialogButton.Variant.Danger:  return Qt.lighter(Colors.red, 1.10);
        case DialogButton.Variant.Layer4:  return Qt.lighter(Colors.colLayer4, 1.10);
        case DialogButton.Variant.Default: return Colors.colLayer3Hover;
        }
    }
    readonly property color _fg: {
        switch (variant) {
        case DialogButton.Variant.Primary: return Colors.background;
        case DialogButton.Variant.Danger:  return Colors.background;
        case DialogButton.Variant.Layer4:  return Colors.colOnLayer4;
        case DialogButton.Variant.Default: return Colors.accent;
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: Config.layout.pillRadius
        color: ma.containsMouse ? root._bgHover : root._bg
        Behavior on color { Motion.ColorFade {} }
    }

    Text {
        id: label
        anchors.centerIn: parent
        text: root.text
        color: root._fg
        font.family: Config.typography.family
        font.pixelSize: Config.typography.smaller
        font.weight: Config.typography.weightMedium
        Behavior on color { Motion.ColorFade {} }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: root.enabled
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        enabled: root.enabled
        onClicked: root.clicked()
    }
}

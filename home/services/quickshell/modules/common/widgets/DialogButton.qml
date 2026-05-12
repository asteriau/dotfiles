import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models

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
        case DialogButton.Variant.Primary: return Appearance.colors.accent;
        case DialogButton.Variant.Danger:  return Appearance.colors.red;
        case DialogButton.Variant.Layer4:  return Appearance.colors.colLayer4;
        case DialogButton.Variant.Default: return Qt.rgba(Appearance.colors.colLayer3.r, Appearance.colors.colLayer3.g, Appearance.colors.colLayer3.b, 0);
        }
    }
    readonly property color _bgHover: {
        switch (variant) {
        case DialogButton.Variant.Primary: return Appearance.colors.accentHover;
        case DialogButton.Variant.Danger:  return Qt.lighter(Appearance.colors.red, 1.10);
        case DialogButton.Variant.Layer4:  return Qt.lighter(Appearance.colors.colLayer4, 1.10);
        case DialogButton.Variant.Default: return Appearance.colors.colLayer3Hover;
        }
    }
    readonly property color _fg: {
        switch (variant) {
        case DialogButton.Variant.Primary: return Appearance.colors.background;
        case DialogButton.Variant.Danger:  return Appearance.colors.background;
        case DialogButton.Variant.Layer4:  return Appearance.colors.colOnLayer4;
        case DialogButton.Variant.Default: return Appearance.colors.accent;
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: Appearance.layout.pillRadius
        color: ma.containsMouse ? root._bgHover : root._bg
        Behavior on color { Motion.ColorFade {} }
    }

    Text {
        id: label
        anchors.centerIn: parent
        text: root.text
        color: root._fg
        font.family: Config.typography.family
        font.pixelSize: Appearance.typography.smaller
        font.weight: Appearance.typography.weightMedium
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

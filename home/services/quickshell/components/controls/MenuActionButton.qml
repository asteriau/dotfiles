import QtQuick
import QtQuick.Layouts
import qs.utils

// Compact action button with semantic variants used by sidebar context menu
// expansions (Connect / Disconnect / Forget / Pair / etc).
Item {
    id: root

    enum Variant { Primary, Tonal, Danger, Text }

    property int    variant: MenuActionButton.Variant.Primary
    property string text: ""
    property string iconName: ""
    property bool   enabled: true

    signal clicked()

    Layout.fillWidth: true
    implicitHeight: 32
    implicitWidth: contentRow.implicitWidth + 24
    opacity: enabled ? 1 : 0.4

    readonly property color _bg: {
        switch (variant) {
        case MenuActionButton.Variant.Primary: return Colors.accent;
        case MenuActionButton.Variant.Tonal:   return Colors.secondaryContainer;
        case MenuActionButton.Variant.Danger:  return Colors.red;
        case MenuActionButton.Variant.Text:    return "transparent";
        }
    }
    readonly property color _bgHover: {
        switch (variant) {
        case MenuActionButton.Variant.Primary: return Colors.accentHover;
        case MenuActionButton.Variant.Tonal:   return Colors.colLayer3;
        case MenuActionButton.Variant.Danger:  return Qt.lighter(Colors.red, 1.10);
        case MenuActionButton.Variant.Text:    return Colors.colLayer2Hover;
        }
    }
    readonly property color _fg: {
        switch (variant) {
        case MenuActionButton.Variant.Primary: return Colors.background;
        case MenuActionButton.Variant.Tonal:   return Colors.m3onSecondaryContainer;
        case MenuActionButton.Variant.Danger:  return Colors.background;
        case MenuActionButton.Variant.Text:    return Colors.accent;
        }
    }

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: Config.layout.radiusSm
        color: ma.containsMouse ? root._bgHover : root._bg
        Behavior on color { Motion.ColorFade {} }
    }

    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        spacing: Config.layout.gapSm

        Text {
            visible: root.iconName.length > 0
            text: root.iconName
            font.family: Config.typography.iconFamily
            font.pixelSize: 14
            color: root._fg
        }

        Text {
            visible: root.text.length > 0
            text: root.text
            color: root._fg
            font.family: Config.typography.family
            font.pixelSize: Config.typography.smaller
            font.weight: Config.typography.weightMedium
        }
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

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.modules.common.widgets
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models

Item {
    id: root

    required property var entry
    property string query: ""
    property bool selected: false

    signal activated

    implicitHeight: row.implicitHeight + 12
    implicitWidth: row.implicitWidth + 24

    Rectangle {
        id: bg
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        radius: 14
        color: ma.pressed ? Appearance.colors.colPrimaryActive
            : root.selected ? Appearance.colors.primaryContainer
            : ma.containsMouse ? Qt.rgba(Appearance.colors.primaryContainer.r, Appearance.colors.primaryContainer.g, Appearance.colors.primaryContainer.b, 0.6)
            : "transparent"
        Behavior on color {
            ColorAnimation { duration: 120; easing.type: Easing.OutCubic }
        }
    }

    readonly property color fgColor: root.selected || ma.containsMouse ? Appearance.colors.m3onPrimaryContainer : Appearance.colors.foreground

    function highlight(text, q) {
        if (!q || q.length === 0) return _escape(text);
        const tl = text.toLowerCase();
        const ql = q.toLowerCase();
        let out = "";
        let qi = 0;
        const tag = `<u><font color="${Appearance.colors.accent}">`;
        for (let i = 0; i < text.length; i++) {
            const ch = _escape(text[i]);
            if (qi < ql.length && tl[i] === ql[qi]) {
                out += tag + ch + "</font></u>";
                qi++;
            } else {
                out += ch;
            }
        }
        return out;
    }

    function _escape(s) {
        return s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
    }

    RowLayout {
        id: row
        anchors.fill: parent
        anchors.leftMargin: 24
        anchors.rightMargin: 24
        spacing: 10

        Loader {
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            sourceComponent: {
                switch (root.entry?.iconType) {
                    case "system":   return sysIconComp;
                    case "material": return matIconComp;
                    case "text":     return textIconComp;
                    default:         return null;
                }
            }
        }

        Component {
            id: sysIconComp
            IconImage {
                source: root.entry?.iconSource
                    ?? Quickshell.iconPath(root.entry?.iconName ?? "", "application-x-executable")
                asynchronous: true
                anchors.fill: parent
            }
        }
        Component {
            id: matIconComp
            MaterialIcon {
                anchors.centerIn: parent
                text: root.entry?.iconName ?? ""
                pixelSize: 26
                color: root.fgColor
            }
        }
        Component {
            id: textIconComp
            StyledText {
                anchors.centerIn: parent
                text: root.entry?.iconName ?? ""
                font.pixelSize: 22
                color: root.fgColor
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 0

            StyledText {
                visible: root.entry?.type && root.entry.type !== "App"
                variant: StyledText.Variant.Caption
                color: root.selected ? Appearance.colors.m3onPrimaryContainer : Appearance.colors.comment
                text: root.entry?.type ?? ""
            }

            StyledText {
                Layout.fillWidth: true
                textFormat: Text.StyledText
                font.pixelSize: Appearance.typography.small
                color: root.fgColor
                elide: Text.ElideRight
                text: root.selected
                    ? root._escape(root.entry?.name ?? "")
                    : root.highlight(root.entry?.name ?? "", root.query)
            }
        }

        StyledText {
            visible: root.selected || ma.containsMouse
            font.pixelSize: Appearance.typography.normal
            color: Appearance.colors.m3onPrimaryContainer
            text: root.entry?.verb ?? ""
            Layout.alignment: Qt.AlignVCenter
        }
    }

    MouseArea {
        id: ma
        anchors.fill: bg
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated()
    }

    Keys.onPressed: event => {
        if ((event.key === Qt.Key_Return || event.key === Qt.Key_Enter)) {
            root.activated();
            event.accepted = true;
        } else if (event.key === Qt.Key_Delete && (event.modifiers & Qt.ShiftModifier)) {
            if (root.entry?.deleteEntry) {
                root.entry.deleteEntry();
                event.accepted = true;
            }
        }
    }
}

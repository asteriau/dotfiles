import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Pipewire
import qs.components.controls
import qs.utils

Item {
    id: row
    required property PwNode modelData
    Layout.fillWidth: true
    implicitHeight: rowLayout.implicitHeight + 12

    PwObjectTracker { objects: row.modelData ? [row.modelData] : [] }

    readonly property PwNode node: modelData
    readonly property string appName: {
        if (!node) return "Unknown";
        return node.properties["application.name"]
            || node.description
            || node.name
            || "Unknown";
    }
    readonly property string mediaName: node?.properties["media.name"] ?? ""
    readonly property string iconSource: {
        if (!node) return "";
        const hint = node.properties["application.icon-name"];
        if (hint && hint.length > 0) {
            const guess = WorkspaceIconSearch.guessIcon(hint);
            if (WorkspaceIconSearch.iconExists(guess)) return Quickshell.iconPath(guess, "image-missing");
        }
        const fromName = WorkspaceIconSearch.guessIcon(node.properties["node.name"] ?? "");
        return Quickshell.iconPath(fromName, "image-missing");
    }
    readonly property bool muted: node?.audio?.muted ?? false

    RowLayout {
        id: rowLayout
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        spacing: 8

        Item {
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: 36
            Layout.preferredHeight: 36

            IconImage {
                id: iconImg
                anchors.fill: parent
                source: row.iconSource
                opacity: row.muted ? 0.4 : 1.0
                Behavior on opacity { Motion.Fade {} }
            }

            Text {
                anchors.centerIn: parent
                visible: row.muted
                text: "volume_off"
                color: Appearance.colors.m3onSurface
                font.family: Appearance.typography.iconFamily
                font.pixelSize: 22
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (row.node?.audio) row.node.audio.muted = !row.node.audio.muted;
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6

            Text {
                Layout.fillWidth: true
                text: row.mediaName.length > 0
                    ? (row.appName + " • " + row.mediaName)
                    : row.appName
                color: Appearance.colors.comment
                font.family: Config.typography.family
                font.pixelSize: Appearance.typography.small
                elide: Text.ElideRight
            }

            StyledSlider {
                Layout.fillWidth: true
                configuration: StyledSlider.Configuration.S
                value: row.node?.audio?.volume ?? 0
                onMoved: {
                    if (row.node?.audio) row.node.audio.volume = value;
                }
            }
        }
    }
}

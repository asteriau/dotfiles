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
    implicitHeight: column.implicitHeight + 10

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
    readonly property string iconHint: {
        if (!node) return "";
        return node.properties["application.icon-name"]
            || node.properties["application.name"]
            || node.properties["node.name"]
            || "";
    }
    readonly property string iconSource: iconHint.length > 0
        ? Quickshell.iconPath(WorkspaceIconSearch.guessIcon(iconHint), "image-missing")
        : ""
    readonly property bool muted: node?.audio?.muted ?? false

    ColumnLayout {
        id: column
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            leftMargin: 6
            rightMargin: 6
        }
        spacing: 4

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            IconImage {
                implicitSize: 22
                source: row.iconSource
                opacity: row.muted ? 0.4 : 1.0
                Behavior on opacity { Motion.Fade {} }
            }

            Text {
                Layout.fillWidth: true
                text: row.mediaName.length > 0
                    ? (row.appName + " • " + row.mediaName)
                    : row.appName
                color: row.muted ? Colors.m3onSurfaceInactive : Colors.m3onSurface
                font.family: "Inter"
                font.pixelSize: 12
                font.weight: Font.Medium
                elide: Text.ElideRight
            }

            Item {
                implicitWidth: 26
                implicitHeight: 26

                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: muteMa.containsMouse ? Colors.colLayer3 : "transparent"
                    Behavior on color { Motion.ColorFade {} }
                }

                Text {
                    anchors.centerIn: parent
                    text: row.muted ? "volume_off" : "volume_up"
                    color: row.muted ? Qt.rgba(0.92, 0.45, 0.45, 1) : Colors.m3onSurface
                    font.family: "Material Symbols Rounded"
                    font.pixelSize: 16
                }

                MouseArea {
                    id: muteMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (row.node?.audio) row.node.audio.muted = !row.node.audio.muted;
                    }
                }
            }
        }

        StyledSlider {
            Layout.fillWidth: true
            configuration: StyledSlider.Configuration.S
            value: row.node?.audio?.volume ?? 0
            opacity: row.muted ? 0.4 : 1.0
            Behavior on opacity { Motion.Fade {} }
            onMoved: {
                if (row.node?.audio) row.node.audio.volume = value;
            }
        }
    }
}

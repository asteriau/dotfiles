import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Pipewire
import qs.components.controls
import qs.components.text
import qs.utils

Item {
    id: row
    required property PwNode modelData
    Layout.fillWidth: true
    implicitHeight: column.implicitHeight + Config.layout.gapSm * 2

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

    Rectangle {
        anchors.fill: parent
        radius: Config.layout.radiusSm
        color: "transparent"
        border.width: 0
    }

    ColumnLayout {
        id: column
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            leftMargin: Config.layout.gapMd
            rightMargin: Config.layout.gapMd
        }
        spacing: Config.layout.gapSm

        RowLayout {
            Layout.fillWidth: true
            spacing: Config.layout.gapMd

            IconImage {
                implicitSize: 22
                source: row.iconSource
                opacity: row.muted ? 0.4 : 1.0
                Behavior on opacity { Motion.Fade {} }
            }

            StyledText {
                Layout.fillWidth: true
                variant: StyledText.Variant.Caption
                text: row.mediaName.length > 0
                    ? (row.appName + " • " + row.mediaName)
                    : row.appName
                color: row.muted ? Colors.m3onSurfaceInactive : Colors.m3onSurface
                font.weight: Config.typography.weightMedium
                elide: Text.ElideRight
            }

            Item {
                implicitWidth: 26
                implicitHeight: 26

                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: muteMa.containsMouse ? Colors.colLayer2Hover : "transparent"
                    Behavior on color { Motion.ColorFade {} }
                }

                Text {
                    anchors.centerIn: parent
                    text: row.muted ? "volume_off" : "volume_up"
                    color: row.muted ? Colors.red : Colors.m3onSurface
                    font.family: Config.typography.iconFamily
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

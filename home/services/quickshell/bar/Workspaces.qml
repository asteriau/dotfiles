import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Hyprland
import qs.components
import qs.utils

ColumnLayout {
    id: root
    spacing: 6

    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(QsWindow.window?.screen)
    readonly property int activeWorkspace: monitor?.activeWorkspace?.id ?? 1
    property int shownWorkspaces: 5
    property int baseWorkspace: Math.floor((activeWorkspace - 1) / shownWorkspaces) * shownWorkspaces + 1

    property int scrollAccumulator: 0

    Rectangle {
        id: card
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: 38
        implicitWidth: 38
        implicitHeight: col.implicitHeight + 32

        radius: 8
        color: Colors.elevated

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            onWheel: event => {
                event.accepted = true;
                let acc = Math.abs(root.scrollAccumulator - event.angleDelta.x - event.angleDelta.y);
                const sign = Math.sign(acc);
                acc = Math.abs(acc);

                const offset = sign * Math.floor(acc / 120);
                root.scrollAccumulator = sign * (acc % 120);

                if (offset) {
                    const currentWorkspace = root.activeWorkspace;
                    const targetWorkspace = currentWorkspace + offset;
                    const id = Math.max(root.baseWorkspace, Math.min(root.baseWorkspace + root.shownWorkspaces - 1, targetWorkspace));
                    if (id != currentWorkspace)
                        Hyprland.dispatch(`workspace ${id}`);
                }
            }
        }

        ColumnLayout {
            id: col
            anchors.fill: parent
            anchors.topMargin: 16
            anchors.bottomMargin: 16
            anchors.leftMargin: 13
            anchors.rightMargin: 13
            spacing: 10

            Repeater {
                model: ScriptModel {
                    objectProp: "index"
                    values: {
                        const workspaces = Hyprland.workspaces.values;
                        const base = root.baseWorkspace;
                        return Array.from({
                            length: root.shownWorkspaces
                        }, (_, i) => ({
                                    index: base + i,
                                    workspace: workspaces.find(w => w.id == base + i)
                                }));
                    }
                }

                Rectangle {
                    id: pill
                    required property var modelData

                    readonly property bool focused: modelData.workspace?.focused ?? false
                    readonly property bool occupied: !!modelData.workspace && !focused

                    Layout.preferredWidth: 12
                    Layout.preferredHeight: focused ? 100 : (occupied ? 70 : 30)
                    Layout.alignment: Qt.AlignHCenter

                    radius: 6
                    color: focused ? Colors.accent : Qt.rgba(Colors.foreground.r, Colors.foreground.g, Colors.foreground.b, 0.1)

                    Behavior on Layout.preferredHeight {
                        NumberAnimation {
                            duration: 100
                            easing.type: Easing.OutQuad
                        }
                    }
                    Behavior on color {
                        ColorAnimation {
                            duration: 100
                            easing.type: Easing.OutQuad
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onPressed: Hyprland.dispatch(`workspace ${pill.modelData.index}`)
                    }
                }
            }
        }
    }

}

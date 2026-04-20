import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.utils

Rectangle {
    id: root

    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(QsWindow.window?.screen)
    readonly property int activeWorkspace: monitor?.activeWorkspace?.id ?? 1
    property int shownWorkspaces: 4
    property int baseWorkspace: Math.floor((activeWorkspace - 1) / shownWorkspaces) * shownWorkspaces + 1

    property int scrollAccumulator: 0

    Layout.preferredWidth: 28
    implicitWidth: 28
    implicitHeight: col.implicitHeight + 24

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
        anchors.topMargin: 12
        anchors.bottomMargin: 12
        anchors.leftMargin: 9
        anchors.rightMargin: 9
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

                Layout.preferredWidth: 10
                Layout.preferredHeight: focused ? 100 : (occupied ? 70 : 30)
                Layout.alignment: Qt.AlignHCenter

                radius: 5
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

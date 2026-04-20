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
    readonly property int minShown: 5
    readonly property int shownWorkspaces: {
        const values = Hyprland.workspaces.values;
        let maxId = minShown;
        for (let i = 0; i < values.length; i++) {
            if (values[i].id > maxId)
                maxId = values[i].id;
        }
        if (activeWorkspace > maxId)
            maxId = activeWorkspace;
        return maxId;
    }
    readonly property int baseWorkspace: 1

    property int scrollAccumulator: 0

    Rectangle {
        id: card
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: 32
        implicitWidth: 32
        implicitHeight: col.implicitHeight + 24

        radius: 8
        color: Colors.elevated

        Behavior on implicitHeight {
            NumberAnimation {
                duration: 260
                easing.type: Easing.OutCubic
            }
        }

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
                    const id = Math.max(root.baseWorkspace, targetWorkspace);
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
            anchors.leftMargin: 13
            anchors.rightMargin: 13
            spacing: 8

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

                    Layout.preferredWidth: 6
                    Layout.preferredHeight: focused ? 72 : (occupied ? 46 : 18)
                    Layout.alignment: Qt.AlignHCenter

                    radius: 3
                    color: focused ? Colors.accent : Qt.rgba(Colors.foreground.r, Colors.foreground.g, Colors.foreground.b, 0.1)

                    Behavior on Layout.preferredHeight {
                        NumberAnimation {
                            duration: 260
                            easing.type: Easing.OutCubic
                        }
                    }
                    Behavior on color {
                        ColorAnimation {
                            duration: 180
                            easing.type: Easing.OutCubic
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

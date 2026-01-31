import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import qs.utils

WrapperMouseArea {
    id: root
    Layout.fillHeight: true

    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(QsWindow.window?.screen)
    readonly property int activeWorkspace: monitor?.activeWorkspace?.id ?? 1
    property int shownWorkspaces: 10
    property int baseWorkspace: Math.floor((activeWorkspace - 1) / shownWorkspaces) * shownWorkspaces + 1
    property int scrollAccumulator: 0

    acceptedButtons: Qt.NoButton

    onWheel: event => {
        event.accepted = true
        let acc = Math.abs(scrollAccumulator - event.angleDelta.x - event.angleDelta.y)
        const sign = Math.sign(acc)
        acc = Math.abs(acc)
        const offset = sign * Math.floor(acc / 120)
        scrollAccumulator = sign * (acc % 120)

        if (offset) {
            const currentWorkspace = root.activeWorkspace
            const targetWorkspace = currentWorkspace + offset
            const id = Math.max(baseWorkspace, Math.min(baseWorkspace + shownWorkspaces - 1, targetWorkspace))
            if (id !== currentWorkspace)
                Hyprland.dispatch(`workspace ${id}`)
        }
    }

    RowLayout {
        id: row
        spacing: height / 7
        anchors.centerIn: parent

        Repeater {
            id: repeater
            model: ScriptModel {
                objectProp: "index"
                values: {
                    const workspaces = Hyprland.workspaces.values
                    const base = root.baseWorkspace
                    return Array.from({ length: root.shownWorkspaces }, (_, i) => ({
                        index: base + i,
                        workspace: workspaces.find(w => w.id === base + i)
                    }))
                }
            }

            WrapperMouseArea {
                id: ws
                required property var modelData
                implicitHeight: parent.height * 0.4
                hoverEnabled: true

                onPressed: Hyprland.dispatch(`workspace ${modelData.index}`)

                Item {
                    id: wsItem
                    implicitHeight: parent.height
                    implicitWidth: (ws.modelData.workspace?.focused ?? false)
                                   ? parent.height * 2
                                   : parent.height

                    Behavior on implicitWidth {
                        NumberAnimation {
                            duration: 325
                            easing.type: Easing.OutBack
                        }
                    }

                    Rectangle {
                        id: wsRect
                        radius: height / 2
                        color: ws.modelData.workspace
                               ? Colors.monitorColors[ws.modelData.workspace?.monitor?.id ?? 0]
                               : Colors.bgBar
                        implicitHeight: parent.height
                        implicitWidth: parent.width
                        opacity: ws.modelData.workspace ? 1.0 : 0.55
                    }

                    MultiEffect {
                        source: wsRect
                        anchors.fill: wsRect
                        shadowEnabled: Config.shadowEnabled
                        shadowVerticalOffset: Config.shadowVerticalOffset
                        shadowBlur: Config.shadowBlur
                        shadowColor: Qt.rgba(0, 0, 0, Config.shadowOpacity)
                    }
                }
            }
        }
    }
}

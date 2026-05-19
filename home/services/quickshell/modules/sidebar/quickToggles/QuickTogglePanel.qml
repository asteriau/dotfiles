import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.sidebar.quickToggles
import QtQuick
import QtQuick.Layouts
import Quickshell

QuickTogglePanelBase {
    id: root
    readonly property bool editMode: UiState.quickTogglesEditMode
    Layout.fillWidth: true

    implicitHeight: (editMode ? contentColumn.implicitHeight : usedRows.implicitHeight) + root.padding * 2
    Behavior on implicitHeight {
        NumberAnimation {
            duration: Appearance.motion.duration.elementMove
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Appearance.motion.easing.expressiveDefaultSpatial
        }
    }
    property real spacing: 6
    property real padding: 6
    readonly property real baseCellWidth: {
        const availableWidth = root.width - (root.padding * 2) - (root.spacing * (root.columns));
        return availableWidth / root.columns;
    }
    readonly property real baseCellHeight: 56

    readonly property list<string> availableToggleTypes: ["network", "bluetooth", "notifications", "mic",
        "audio", "nightLight", "cloudflareWarp", "darkMode"]
    readonly property int columns: Config.sidebar.quickToggles.columns
    readonly property list<var> toggles: Config.sidebar.quickToggles.toggles ?? []
    readonly property list<var> toggleRows: toggleRowsForList(toggles)
    readonly property list<var> unusedToggles: {
        const types = availableToggleTypes.filter(type => !toggles.some(toggle => (toggle && toggle.type
                                                                                   === type)));
        return types.map(type => {
                             return {
                                 type: type,
                                 size: 1
                             };
                         });
    }
    readonly property list<var> unusedToggleRows: toggleRowsForList(unusedToggles)

    function toggleRowsForList(togglesList) {
        var rows = [];
        var row = [];
        var totalSize = 0;
        for (var i = 0; i < togglesList.length; i++) {
            if (!togglesList[i])
                continue;
            if (totalSize + togglesList[i].size > columns) {
                rows.push(row);
                row = [];
                totalSize = 0;
            }
            row.push(togglesList[i]);
            totalSize += togglesList[i].size;
        }
        if (row.length > 0)
            rows.push(row);
        return rows;
    }

    Component.onCompleted: Network.subscribe()
    Component.onDestruction: Network.unsubscribe()

    Column {
        id: contentColumn
        anchors {
            fill: parent
            margins: root.padding
        }
        spacing: 12

        Column {
            id: usedRows
            spacing: root.spacing
            Repeater {
                model: ScriptModel {
                    values: Array(root.toggleRows.length)
                }
                delegate: ButtonGroup {
                    id: toggleRow
                    required property int index
                    property var modelData: root.toggleRows[index]
                    property int startingIndex: {
                        const rows = root.toggleRows;
                        let sum = 0;
                        for (let i = 0; i < index; i++)
                            sum += rows[i].length;
                        return sum;
                    }
                    spacing: root.spacing
                    Repeater {
                        model: ScriptModel {
                            values: toggleRow?.modelData ?? []
                            objectProp: "type"
                        }
                        delegate: QuickToggleDelegateChooser {
                            startingIndex: toggleRow.startingIndex
                            editMode: root.editMode
                            baseCellWidth: root.baseCellWidth
                            baseCellHeight: root.baseCellHeight
                            spacing: root.spacing
                        }
                    }
                }
            }
        }

        FadeLoader {
            shown: root.editMode
            x: root.baseCellHeight / 2
            width: parent.width - root.baseCellHeight
            sourceComponent: Rectangle {
                implicitHeight: 1
                color: Appearance.colors.colOutlineVariant
            }
        }

        FadeLoader {
            shown: root.editMode
            sourceComponent: Column {
                spacing: root.spacing
                Repeater {
                    model: ScriptModel {
                        values: Array(root.unusedToggleRows.length)
                    }
                    delegate: ButtonGroup {
                        id: unusedToggleRow
                        required property int index
                        property var modelData: root.unusedToggleRows[index]
                        spacing: root.spacing
                        Repeater {
                            model: ScriptModel {
                                values: unusedToggleRow?.modelData ?? []
                                objectProp: "type"
                            }
                            delegate: QuickToggleDelegateChooser {
                                startingIndex: -1
                                editMode: root.editMode
                                baseCellWidth: root.baseCellWidth
                                baseCellHeight: root.baseCellHeight
                                spacing: root.spacing
                            }
                        }
                    }
                }
            }
        }
    }
}

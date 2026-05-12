pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import qs.components.text
import qs.utils

// M3 segmented control.
//
// Two use modes:
//   1. Index-based: set `options: ["A", "B"]` or `[{label,icon}, ...]`
//      and bind `currentIndex` / react to `selected(index)`.
//   2. Value-based: set options to `[{label,icon,value}, ...]`, bind
//      `currentValue` and react to `selectedValue(value)`.
Item {
    id: root

    property var options: []            // [string] | [{label,icon,value?}]
    property int  currentIndex: -1
    property var  currentValue: undefined

    signal selected(int index)
    signal selectedValue(var value)

    Layout.fillWidth: true
    // Track Flow's wrapped content size so neighbors in a ColumnLayout don't
    // overlap when options wrap to multiple rows (e.g. a 9-way scheme picker).
    implicitHeight: flow.implicitHeight
    implicitWidth:  flow.implicitWidth

    readonly property int _resolvedIndex: {
        if (root.currentValue !== undefined) {
            for (let i = 0; i < options.length; i++) {
                const o = options[i];
                if (o && typeof o === "object" && o.value === root.currentValue) return i;
            }
        }
        return root.currentIndex;
    }

    component SegButton: Item {
        id: btn
        required property int index
        required property var modelData

        readonly property string label: typeof modelData === "string" ? modelData : (modelData.label || "")
        readonly property string icon:  typeof modelData === "string" ? "" : (modelData.icon  || "")
        readonly property bool isFirst: index === 0
        readonly property bool isLast:  index === root.options.length - 1
        readonly property bool isSelected: root._resolvedIndex === index

        readonly property real _bigRadius: height / 2
        readonly property real _smallRadius: 6

        implicitHeight: 40
        implicitWidth:  contentRow.implicitWidth + 28

        Rectangle {
            anchors.fill: parent
            color: btn.isSelected
                ? (ma.containsMouse ? Appearance.colors.accentHover : Appearance.colors.accent)
                : (ma.containsMouse ? Qt.lighter(Appearance.colors.background, 1.2) : Appearance.colors.background)
            topLeftRadius:     btn.isFirst ? btn._bigRadius : btn._smallRadius
            bottomLeftRadius:  btn.isFirst ? btn._bigRadius : btn._smallRadius
            topRightRadius:    btn.isLast  ? btn._bigRadius : btn._smallRadius
            bottomRightRadius: btn.isLast  ? btn._bigRadius : btn._smallRadius
            Behavior on color { ColorAnimation { duration: Appearance.motion.duration.effects } }

            RowLayout {
                id: contentRow
                anchors.centerIn: parent
                spacing: 6

                MaterialIcon {
                    visible: btn.icon.length > 0
                    text: btn.icon
                    font.pointSize: Appearance.typography.normal
                    fill: btn.isSelected ? 1 : 0
                    color: btn.isSelected ? Appearance.colors.accentText : Appearance.colors.m3onSurfaceVariant
                    Behavior on color { ColorAnimation { duration: Appearance.motion.duration.effects } }
                }

                Text {
                    visible: btn.label.length > 0
                    text: btn.label
                    color: btn.isSelected ? Appearance.colors.accentText : Appearance.colors.m3onSurfaceVariant
                    font.family: Config.typography.family
                    font.pixelSize: Appearance.typography.smallie
                    font.weight: btn.isSelected ? Font.Medium : Font.Normal
                    Behavior on color { ColorAnimation { duration: Appearance.motion.duration.effects } }
                }
            }
        }

        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                root.currentIndex = btn.index;
                root.selected(btn.index);
                const opt = root.options[btn.index];
                if (opt && typeof opt === "object" && opt.value !== undefined)
                    root.selectedValue(opt.value);
            }
        }
    }

    Flow {
        id: flow
        // Bind width (not anchors.fill) so `implicitHeight` reflects the
        // wrapped content rather than inheriting parent's fixed height.
        width: root.width
        spacing: 2

        Repeater {
            model: root.options
            SegButton {}
        }
    }
}

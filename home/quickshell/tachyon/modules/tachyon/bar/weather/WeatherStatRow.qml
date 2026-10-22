import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts

// Stat row with a 2px progress bar underneath, matching ResourcesPopup
ColumnLayout {
    id: row
    property string icon
    property string value
    property string sub
    property string label
    property string lo
    property string hi
    property real progress

    Layout.fillWidth: true
    spacing: 6

    RowLayout {
        Layout.fillWidth: true
        spacing: 8

        MaterialSymbol {
            Layout.alignment: Qt.AlignVCenter
            text: row.icon
            iconSize: 22
            color: Appearance.colors.colOnLayer1
        }
        StyledText {
            Layout.alignment: Qt.AlignBaseline
            text: row.value
            font.pixelSize: Appearance.font.pixelSize.larger
            font.weight: Font.Medium
            color: Appearance.colors.colOnLayer1
        }
        StyledText {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignBaseline
            text: row.sub
            font.pixelSize: Appearance.font.pixelSize.smallie
            color: Appearance.colors.colSubtext
            elide: Text.ElideRight
        }
        StyledText {
            Layout.alignment: Qt.AlignBaseline
            text: row.label
            font.pixelSize: Appearance.font.pixelSize.smallie
            color: Appearance.colors.colSubtext
        }
    }
    RowLayout {
        Layout.fillWidth: true
        spacing: 8

        StyledText {
            Layout.minimumWidth: 22
            text: row.lo
            font.pixelSize: Appearance.font.pixelSize.smaller
            color: Appearance.colors.colSubtext
        }
        StyledCombinedProgressBar {
            Layout.fillWidth: true
            valueWeights: [1]
            values: [row.progress]
            valueHighlights: [Appearance.colors.colPrimary]
            valueTroughs: [Appearance.colors.colSecondaryContainer]
        }
        StyledText {
            Layout.minimumWidth: 22
            horizontalAlignment: Text.AlignRight
            text: row.hi
            font.pixelSize: Appearance.font.pixelSize.smaller
            color: Appearance.colors.colSubtext
        }
    }
}

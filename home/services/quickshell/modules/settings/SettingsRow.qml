import QtQuick
import QtQuick.Layouts
import qs.modules.common.widgets
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models

RowLayout {
    id: root
    Layout.fillWidth: true
    spacing: Appearance.layout.gapLg

    property string icon: ""
    property string label: ""
    property string caption: ""
    // If > 0, reserves a fixed width for the label column.
    property int labelColumnWidth: 0

    // Slot: children of SettingsRow render here (right-aligned).
    default property alias rightData: rightSlot.data

    MaterialIcon {
        visible: root.icon.length > 0
        text: root.icon
        font.pointSize: Appearance.typography.huge
        color: Appearance.colors.m3onSurfaceVariant
        Layout.preferredWidth: 24
        Layout.alignment: Qt.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }

    ColumnLayout {
        Layout.fillWidth: root.labelColumnWidth === 0
        Layout.preferredWidth: root.labelColumnWidth > 0 ? root.labelColumnWidth : -1
        Layout.alignment: Qt.AlignVCenter
        spacing: 2

        StyledText {
            visible: root.label.length > 0
            text: root.label
            Layout.fillWidth: true
            elide: Text.ElideRight
            variant: StyledText.Variant.Body
        }
        StyledText {
            visible: root.caption.length > 0
            text: root.caption
            Layout.fillWidth: true
            elide: Text.ElideRight
            variant: StyledText.Variant.Caption
        }
    }

    Item {
        id: rightSlot
        Layout.alignment: Qt.AlignVCenter
        implicitWidth: childrenRect.width
        implicitHeight: childrenRect.height
    }
}

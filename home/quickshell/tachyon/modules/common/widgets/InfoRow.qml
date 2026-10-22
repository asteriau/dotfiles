import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

Rectangle {
    id: root
    property string icon: ""
    property string iconSource: "" // CustomIcon name, used instead of icon when set
    property string label: ""
    property string value: ""
    property bool first: false
    property bool last: false

    Layout.fillWidth: true
    implicitHeight: 52
    color: Appearance.colors.colLayer2
    topLeftRadius: first ? Appearance.rounding.normal : Appearance.rounding.unsharpenmore
    topRightRadius: topLeftRadius
    bottomLeftRadius: last ? Appearance.rounding.normal : Appearance.rounding.unsharpenmore
    bottomRightRadius: bottomLeftRadius

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 18
        spacing: 16

        CustomIcon {
            visible: root.iconSource !== ""
            Layout.preferredWidth: 22
            Layout.preferredHeight: 22
            source: root.iconSource
            colorize: true
            color: Appearance.colors.colOnLayer1
        }
        MaterialSymbol {
            visible: root.iconSource === ""
            text: root.icon
            iconSize: 22
            color: Appearance.colors.colOnLayer1
        }
        StyledText {
            text: root.label
            color: Appearance.colors.colOnLayer2
            Layout.fillWidth: true
        }
        StyledText {
            text: root.value
            color: Appearance.colors.colSubtext
            elide: Text.ElideRight
            Layout.maximumWidth: parent.width / 2
            horizontalAlignment: Text.AlignRight
        }
    }
}

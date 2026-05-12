import QtQuick
import QtQuick.Controls
import qs.utils

// MD3-flavored ComboBox. `model` may be a list of plain values or objects;
// `displayRole` picks the field to render (defaults to whole entry as string).
ComboBox {
    id: root

    property string displayRole: ""

    font.family: "Inter"
    font.pixelSize: 13
    leftPadding: 12
    rightPadding: 32
    topPadding: 8
    bottomPadding: 8
    implicitHeight: 36

    textRole: ""
    valueRole: ""

    background: Rectangle {
        radius: Config.layout.radiusSm
        color: root.hovered ? Appearance.colors.colLayer3 : Appearance.colors.colLayer2
        border.width: 1
        border.color: root.activeFocus ? Appearance.colors.colPrimary : Appearance.colors.outlineVariant

        Behavior on color { ColorAnimation { duration: 120 } }
    }

    contentItem: Text {
        text: root._displayOf(root.currentValue !== undefined ? root.currentValue
            : (root.currentIndex >= 0 && root.model ? root.model[root.currentIndex] : ""))
        color: Appearance.colors.colOnLayer2
        font: root.font
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    indicator: Text {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: 10
        text: "expand_more"
        font.family: "Material Symbols Rounded"
        font.pixelSize: 16
        color: Appearance.colors.colOnLayer2
    }

    delegate: ItemDelegate {
        id: delegateRoot
        required property var modelData
        required property int index
        width: root.width
        leftPadding: 12
        rightPadding: 12
        topPadding: 8
        bottomPadding: 8

        contentItem: Text {
            text: root._displayOf(delegateRoot.modelData)
            color: Appearance.colors.colOnLayer2
            font: root.font
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }

        background: Rectangle {
            color: delegateRoot.hovered ? Appearance.colors.colLayer3 : "transparent"
        }
    }

    popup: Popup {
        y: root.height + 2
        width: root.width
        padding: 4
        background: Rectangle {
            color: Appearance.colors.surfaceContainerHigh
            radius: Config.layout.radiusSm
            border.width: 1
            border.color: Appearance.colors.outlineVariant
        }
        contentItem: ListView {
            clip: true
            implicitHeight: Math.min(contentHeight, 240)
            model: root.delegateModel
            currentIndex: root.highlightedIndex
            ScrollIndicator.vertical: ScrollIndicator {}
        }
    }

    function _displayOf(entry) {
        if (entry === null || entry === undefined) return "";
        if (root.displayRole && typeof entry === "object")
            return entry[root.displayRole] ?? "";
        return String(entry);
    }
}

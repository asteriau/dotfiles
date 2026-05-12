import QtQuick
import QtQuick.Controls
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models

ComboBox {
    id: root

    property string displayRole: ""

    font.family: Config.typography.family
    font.pixelSize: Appearance.typography.smallie
    leftPadding: 16
    rightPadding: 40
    topPadding: 10
    bottomPadding: 10
    implicitHeight: 44

    textRole: ""
    valueRole: ""

    background: Rectangle {
        radius: Appearance.layout.radiusSm
        color: root.hovered
            ? Appearance.colors.surfaceContainerHigh
            : Appearance.colors.surfaceContainer
        border.width: 1
        border.color: Appearance.colors.outlineVariant

        Behavior on color { ColorAnimation { duration: Appearance.motion.duration.short2 } }
    }

    contentItem: Text {
        text: root._displayLabel()
        color: Appearance.colors.foreground
        font: root.font
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    indicator: Text {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: 14
        text: root.popup.visible ? "expand_less" : "expand_more"
        font.family: "Material Symbols Rounded"
        font.pixelSize: Appearance.typography.normal
        color: Appearance.colors.m3onSurfaceVariant
    }

    delegate: ItemDelegate {
        id: delegateRoot
        required property var modelData
        required property int index
        width: root.width
        leftPadding: 16
        rightPadding: 16
        topPadding: 10
        bottomPadding: 10

        readonly property bool isSelected: index === root.currentIndex

        contentItem: Text {
            text: root._displayOf(delegateRoot.modelData)
            color: delegateRoot.isSelected
                ? Appearance.colors.accent
                : Appearance.colors.foreground
            font.family: root.font.family
            font.pixelSize: root.font.pixelSize
            font.weight: delegateRoot.isSelected ? Font.Medium : Font.Normal
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }

        background: Rectangle {
            color: delegateRoot.isSelected
                ? Qt.rgba(Appearance.colors.accent.r, Appearance.colors.accent.g, Appearance.colors.accent.b, 0.12)
                : (delegateRoot.hovered ? Appearance.colors.surfaceContainerHighest : "transparent")
            radius: Appearance.layout.radiusSm
            Behavior on color { ColorAnimation { duration: Appearance.motion.duration.short2 } }
        }
    }

    popup: Popup {
        y: root.height + 4
        width: root.width
        padding: Appearance.layout.gapSm
        background: Rectangle {
            color: Appearance.colors.surfaceContainerHigh
            radius: Appearance.layout.radiusMd
            border.width: 1
            border.color: Appearance.colors.outlineVariant
        }
        contentItem: ListView {
            clip: true
            implicitHeight: Math.min(contentHeight, 280)
            model: root.delegateModel
            currentIndex: root.highlightedIndex
            ScrollIndicator.vertical: ScrollIndicator {}
        }
    }

    // Render the *current* selection's label. When valueRole is set,
    // `currentValue` is a primitive (the value), not the model row — so look
    // the row up via currentIndex.
    function _displayLabel() {
        if (root.currentIndex >= 0 && root.model && root.model[root.currentIndex] !== undefined)
            return _displayOf(root.model[root.currentIndex]);
        return _displayOf(root.currentValue);
    }

    function _displayOf(entry) {
        if (entry === null || entry === undefined) return "";
        if (root.displayRole && typeof entry === "object")
            return entry[root.displayRole] ?? "";
        return String(entry);
    }
}

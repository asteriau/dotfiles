import QtQuick
import qs.utils
import qs.components.text
import qs.components.effects

Item {
    id: root
    property var action
    property var selectionMode

    property string description: {
        switch (root.action) {
        case 0: return "Copy region";
        case 1: case 2: return "Record region";
        }
        return "";
    }
    property string materialSymbol: {
        switch (root.action) {
        case 0: return "content_cut";
        case 1: case 2: return "videocam";
        }
        return "";
    }

    property bool showDescription: true
    function hideDescription() { root.showDescription = false; }
    Timer {
        id: descTimeout
        interval: 1000
        running: true
        onTriggered: root.hideDescription()
    }
    onActionChanged: {
        root.showDescription = true;
        descTimeout.restart();
    }

    property int margins: 8
    implicitWidth: content.implicitWidth + margins * 2
    implicitHeight: content.implicitHeight + margins * 2

    Rectangle {
        id: content
        anchors.centerIn: parent

        property real padding: 8
        implicitHeight: 38
        implicitWidth: root.showDescription ? contentRow.implicitWidth + padding * 2 : implicitHeight
        clip: true

        topLeftRadius: 6
        bottomLeftRadius: implicitHeight - topLeftRadius
        bottomRightRadius: bottomLeftRadius
        topRightRadius: bottomLeftRadius

        color: Colors.accent

        Behavior on topLeftRadius {
            animation: Appearance.animation.elementMoveSmall.numberAnimation.createObject(this)
        }
        Behavior on implicitWidth {
            animation: Appearance.animation.elementMoveSmall.numberAnimation.createObject(this)
        }

        Row {
            id: contentRow
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
                leftMargin: content.padding
            }
            spacing: 12

            MaterialIcon {
                anchors.verticalCenter: parent.verticalCenter
                pixelSize: 22
                color: Colors.m3onPrimary
                text: root.materialSymbol
            }

            FadeLoader {
                id: descriptionLoader
                anchors.verticalCenter: parent.verticalCenter
                shown: root.showDescription
                sourceComponent: StyledText {
                    color: Colors.m3onPrimary
                    text: root.description
                    anchors.right: parent.right
                    anchors.rightMargin: 6
                }
            }
        }
    }
}

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.components.shape
import qs.components.text
import qs.launcher
import qs.utils

RowLayout {
    id: root
    spacing: 8

    property alias input: input
    property bool animateWidth: false

    signal accepted

    readonly property string query: LauncherSearch.query
    readonly property bool isClipboard: query.startsWith(LauncherSearch.clipboardPrefix)

    function focusInput() { input.forceActiveFocus(); }

    Item {
        Layout.alignment: Qt.AlignVCenter
        Layout.preferredWidth: 40
        Layout.preferredHeight: 40

        MaterialShape {
            anchors.fill: parent
            color: Colors.secondaryContainer
            implicitSize: Math.max(width, height)
            shape: root.isClipboard
                ? MaterialShape.Shape.Gem
                : (root.query === "" ? MaterialShape.Shape.Cookie7Sided : MaterialShape.Shape.Clover4Leaf)

            Behavior on color {
                ColorAnimation { duration: 180; easing.type: Easing.OutCubic }
            }
        }

        MaterialIcon {
            anchors.centerIn: parent
            text: root.isClipboard ? "content_paste_search" : (root.query === "" ? "search" : "apps")
            pixelSize: Config.typography.huge
            color: Colors.m3onSecondaryContainer
        }
    }

    TextField {
        id: input
        Layout.fillWidth: false
        Layout.topMargin: 4
        Layout.bottomMargin: 4
        leftPadding: 14
        rightPadding: 14
        implicitHeight: 40
        font.family: Config.typography.family
        font.pixelSize: Config.typography.small
        color: Colors.foreground
        placeholderText: "Search apps, # for clipboard"
        placeholderTextColor: Colors.comment
        selectByMouse: true
        verticalAlignment: TextInput.AlignVCenter

        background: Rectangle {
            radius: 20
            color: Colors.surfaceContainerLow
        }

        readonly property int collapsedWidth: 320
        readonly property int expandedWidth: 560
        implicitWidth: root.query === "" ? collapsedWidth : expandedWidth

        Behavior on implicitWidth {
            NumberAnimation { duration: 280; easing.type: Easing.OutCubic }
        }

        onTextChanged: LauncherSearch.query = text
        onAccepted: root.accepted()
        Keys.onEscapePressed: event => event.accepted = false
    }
}

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules.common.widgets
import qs.modules.launcher
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models

RowLayout {
    id: root
    spacing: Appearance.layout.gapMd

    property alias input: input
    property bool animateWidth: false

    signal accepted
    signal upPressed
    signal downPressed

    readonly property string query: LauncherSearch.query
    readonly property bool isClipboard: query.startsWith(LauncherSearch.clipboardPrefix)

    function focusInput() { input.forceActiveFocus(); }

    Item {
        Layout.alignment: Qt.AlignVCenter
        Layout.preferredWidth: 40
        Layout.preferredHeight: 40

        MaterialShape {
            anchors.fill: parent
            color: Appearance.colors.secondaryContainer
            implicitSize: Math.max(width, height)
            shape: root.isClipboard
                ? MaterialShape.Shape.Gem
                : (root.query === "" ? MaterialShape.Shape.Cookie7Sided : MaterialShape.Shape.Clover4Leaf)

            Behavior on color { ColorAnimation { duration: Appearance.motion.duration.medium3; easing.bezierCurve: Appearance.motion.easing.emphasized } }
        }

        MaterialIcon {
            anchors.centerIn: parent
            text: root.isClipboard ? "content_paste_search" : (root.query === "" ? "search" : "apps")
            pixelSize: Appearance.typography.huge
            color: Appearance.colors.m3onSecondaryContainer
        }
    }

    Item {
        Layout.topMargin: Appearance.layout.gapSm
        Layout.bottomMargin: Appearance.layout.gapSm
        Layout.alignment: Qt.AlignVCenter

        readonly property int collapsedWidth: 320
        readonly property int expandedWidth: 560
        implicitWidth: root.query === "" ? collapsedWidth : expandedWidth
        implicitHeight: 40

        Behavior on implicitWidth { Motion.Emph {} }

        TextField {
            id: input
            anchors.fill: parent
            leftPadding: 14
            rightPadding: 14
            font.family: Config.typography.family
            font.pixelSize: Appearance.typography.small
            color: Appearance.colors.foreground
            placeholderText: ""
            selectByMouse: true
            verticalAlignment: TextInput.AlignVCenter

            background: Rectangle {
                radius: 20
                color: Appearance.colors.surfaceContainer
            }

            onTextChanged: LauncherSearch.query = text
            onAccepted: root.accepted()
            Keys.onEscapePressed: event => event.accepted = false
            Keys.onUpPressed: event => { root.upPressed(); event.accepted = true; }
            Keys.onDownPressed: event => { root.downPressed(); event.accepted = true; }
        }

        Text {
            anchors.left: parent.left
            anchors.leftMargin: input.leftPadding
            anchors.right: parent.right
            anchors.rightMargin: input.rightPadding
            anchors.verticalCenter: parent.verticalCenter
            text: qsTr("Search apps, # for clipboard")
            color: Appearance.colors.comment
            font: input.font
            elide: Text.ElideRight
            opacity: input.text === "" ? 1 : 0
            Behavior on opacity { Motion.SpatialEmph {} }
        }
    }
}

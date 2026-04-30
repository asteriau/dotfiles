import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.components.text
import qs.utils

// Compact active-window indicator for the horizontal bar focal slot.
// Crossfades app icon + title on focus changes.
Item {
    id: root

    readonly property Toplevel activeWindow: ToplevelManager.activeToplevel
    readonly property bool focused: activeWindow?.activated ?? false

    readonly property string appId: focused ? (activeWindow?.appId ?? "") : ""
    readonly property string title: focused ? (activeWindow?.title ?? "") : ""

    property int maxTitleWidth: 240
    property bool iconOnly: false

    implicitWidth:  row.implicitWidth
    implicitHeight: row.implicitHeight

    RowLayout {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        spacing: Config.layout.gapSm

        // App icon — crossfade on appId change.
        Item {
            Layout.alignment: Qt.AlignVCenter
            implicitWidth:  Config.iconSize
            implicitHeight: Config.iconSize

            property string _a: root.appId
            property string _b: ""
            property bool _aActive: true

            onChildrenChanged: {}
            Component.onCompleted: _a = root.appId
            Connections {
                target: root
                function onAppIdChanged() {
                    if (root.appId === (parent._aActive ? parent._a : parent._b)) return;
                    if (parent._aActive) { parent._b = root.appId; parent._aActive = false; }
                    else                 { parent._a = root.appId; parent._aActive = true; }
                }
            }

            Image {
                id: imgA
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
                smooth: true
                source: parent._a ? Quickshell.iconPath(WorkspaceIconSearch.guessIcon(parent._a), true) : ""
                opacity: parent._aActive ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: M3Easing.effectsDuration; easing.type: Easing.OutCubic } }
            }
            Image {
                id: imgB
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
                smooth: true
                source: parent._b ? Quickshell.iconPath(WorkspaceIconSearch.guessIcon(parent._b), true) : ""
                opacity: parent._aActive ? 0 : 1
                Behavior on opacity { NumberAnimation { duration: M3Easing.effectsDuration; easing.type: Easing.OutCubic } }
            }
        }

        // Title — crossfade on text change.
        Item {
            visible: !root.iconOnly
            Layout.alignment: Qt.AlignVCenter
            Layout.maximumWidth: root.maxTitleWidth
            implicitWidth:  Math.min(Math.max(titleA.implicitWidth, titleB.implicitWidth), root.maxTitleWidth)
            implicitHeight: Math.max(titleA.implicitHeight, titleB.implicitHeight)
            clip: true

            property string _a: root.title
            property string _b: ""
            property bool _aActive: true

            Connections {
                target: root
                function onTitleChanged() {
                    if (root.title === (parent._aActive ? parent._a : parent._b)) return;
                    if (parent._aActive) { parent._b = root.title; parent._aActive = false; }
                    else                 { parent._a = root.title; parent._aActive = true; }
                }
            }

            StyledText {
                id: titleA
                width: parent.width
                anchors.verticalCenter: parent.verticalCenter
                text: parent._a
                font.pixelSize: Config.typography.small
                font.family: Config.typography.family
                color: Colors.m3onSecondaryContainer
                elide: Text.ElideRight
                opacity: parent._aActive ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: M3Easing.effectsDuration; easing.type: Easing.OutCubic } }
            }
            StyledText {
                id: titleB
                width: parent.width
                anchors.verticalCenter: parent.verticalCenter
                text: parent._b
                font.pixelSize: Config.typography.small
                font.family: Config.typography.family
                color: Colors.m3onSecondaryContainer
                elide: Text.ElideRight
                opacity: parent._aActive ? 0 : 1
                Behavior on opacity { NumberAnimation { duration: M3Easing.effectsDuration; easing.type: Easing.OutCubic } }
            }
        }
    }
}

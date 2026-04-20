pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import qs.utils

Rectangle {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true
    radius: 10
    color: Qt.rgba(0.13, 0.13, 0.13, 0.5)

    ListModel {
        id: localModel
    }

    function syncFromSource() {
        const src = NotificationState.allNotifs;
        const srcSet = new Set(src);
        for (let i = 0; i < localModel.count; i++) {
            const item = localModel.get(i);
            if (!srcSet.has(item.notifRef) && !item.dying) {
                localModel.setProperty(i, "dying", true);
            }
        }
        const localRefs = new Set();
        for (let i = 0; i < localModel.count; i++) {
            localRefs.add(localModel.get(i).notifRef);
        }
        for (let i = src.length - 1; i >= 0; i--) {
            if (!localRefs.has(src[i])) {
                localModel.insert(0, {
                    notifRef: src[i],
                    dying: false
                });
            }
        }
    }

    function removeDying(ref) {
        for (let i = 0; i < localModel.count; i++) {
            if (localModel.get(i).notifRef === ref) {
                localModel.remove(i);
                return;
            }
        }
    }

    Component.onCompleted: syncFromSource()

    Connections {
        target: NotificationState
        function onAllNotifsChanged() {
            root.syncFromSource();
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 10

        RowLayout {
            Layout.fillWidth: true

            Text {
                text: "Notifications"
                color: Colors.foreground
                font.family: "Google Sans Flex"
                font.pixelSize: 14
                font.weight: Font.Medium
                Layout.fillWidth: true
            }

            Item {
                implicitWidth: 22
                implicitHeight: 22

                Text {
                    anchors.centerIn: parent
                    text: "clear_all"
                    color: Colors.accent
                    font.family: "Material Symbols Rounded"
                    font.pixelSize: 18
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: NotificationState.closeAll()
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Column {
                anchors.centerIn: parent
                visible: localModel.count === 0
                spacing: 10
                opacity: visible ? 0.9 : 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 250
                    }
                }

                Image {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 96
                    height: 96
                    source: Qt.resolvedUrl("../assets/wedding-bells.png")
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    mipmap: true
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Nothing here D:"
                    color: Colors.comment
                    font.family: "Google Sans Flex"
                    font.pixelSize: 13
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            ListView {
                id: list
                anchors.fill: parent
                visible: localModel.count > 0
                spacing: 12
                clip: true
                model: localModel

                displaced: Transition {
                    NumberAnimation {
                        properties: "x,y"
                        duration: 260
                        easing.type: Easing.OutCubic
                    }
                }

                delegate: Item {
                    id: delegate
                    required property var notifRef
                    required property bool dying
                    width: ListView.view.width
                    implicitHeight: card.implicitHeight
                    height: dying ? 0 : card.implicitHeight
                    opacity: dying ? 0 : 1
                    clip: true

                    Behavior on height {
                        NumberAnimation {
                            duration: 260
                            easing.type: Easing.InCubic
                        }
                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 220
                            easing.type: Easing.InCubic
                        }
                    }

                    transform: Translate {
                        id: tr
                        x: delegate.dying ? delegate.width : 0

                        Behavior on x {
                            NumberAnimation {
                                duration: 260
                                easing.type: Easing.InCubic
                                onRunningChanged: {
                                    if (!running && delegate.dying) {
                                        root.removeDying(delegate.notifRef);
                                    }
                                }
                            }
                        }
                    }

                    NumberAnimation on opacity {
                        id: fadeIn
                        to: 1
                        duration: 300
                        easing.type: Easing.OutCubic
                        running: false
                    }

                    NumberAnimation on scale {
                        id: scaleIn
                        from: 0.95
                        to: 1
                        duration: 300
                        easing.type: Easing.OutCubic
                        running: false
                    }

                    Component.onCompleted: {
                        if (!dying) {
                            opacity = 0;
                            scale = 0.95;
                            fadeIn.start();
                            scaleIn.start();
                        }
                    }

                    Rectangle {
                        id: card
                        anchors.fill: parent
                        implicitHeight: innerCol.implicitHeight
                        radius: 10
                        color: Colors.elevated
                        clip: true

                        ColumnLayout {
                            id: innerCol
                            width: parent.width
                            spacing: 0

                            Rectangle {
                                Layout.fillWidth: true
                                implicitHeight: titleRow.implicitHeight + 10
                                color: Qt.rgba(Colors.foreground.r, Colors.foreground.g, Colors.foreground.b, 0.04)

                                RowLayout {
                                    id: titleRow
                                    anchors.fill: parent
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 6
                                    anchors.topMargin: 5
                                    anchors.bottomMargin: 5

                                    Text {
                                        text: delegate.notifRef?.summary ?? ""
                                        color: Colors.foreground
                                        font.family: "Google Sans Flex"
                                        font.pixelSize: 13
                                        font.weight: Font.Medium
                                        wrapMode: Text.WordWrap
                                        Layout.fillWidth: true
                                    }

                                    Item {
                                        implicitWidth: 18
                                        implicitHeight: 18

                                        Text {
                                            anchors.centerIn: parent
                                            text: "close"
                                            color: Colors.red
                                            font.family: "Material Symbols Rounded"
                                            font.pixelSize: 16
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (delegate.notifRef)
                                                    NotificationState.notifCloseByNotif(delegate.notifRef);
                                            }
                                        }
                                    }
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Layout.margins: 10
                                spacing: 10

                                Image {
                                    readonly property string src: delegate.notifRef ? (delegate.notifRef.image || delegate.notifRef.appIcon) : ""
                                    source: src ? Utils.getImage(src) : Qt.resolvedUrl("../assets/wedding-bells.png")
                                    sourceSize.width: 32
                                    sourceSize.height: 32
                                    Layout.preferredWidth: 32
                                    Layout.preferredHeight: 32
                                    fillMode: Image.PreserveAspectFit
                                }

                                Text {
                                    text: delegate.notifRef?.body ?? ""
                                    color: Colors.foreground
                                    font.family: "Google Sans Flex"
                                    font.pixelSize: 12
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

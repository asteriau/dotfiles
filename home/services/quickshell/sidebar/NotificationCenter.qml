pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Widgets
import qs.components
import qs.utils
import qs.notifications

Item {
    id: root
    Layout.fillWidth: true
    implicitHeight: 180
    clip: true

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
        id: mainCol
        anchors.fill: parent
        spacing: 6

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                anchors.fill: parent
                visible: localModel.count === 0
                opacity: visible ? 0.9 : 0

                Behavior on opacity {
                    NumberAnimation { duration: 250 }
                }

                Item { Layout.fillHeight: true }

                Item {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 80

                    MaterialShape {
                        anchors.fill: parent
                        shape: MaterialShape.Shape.Ghostish
                        color: Colors.secondaryContainer
                        implicitSize: 80
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "notifications_active"
                        font.family: "Material Symbols Rounded"
                        font.pixelSize: 40
                        font.variableAxes: ({ FILL: 0, wght: 400, opsz: 48, GRAD: 0 })
                        color: Colors.m3onSecondaryContainer
                        renderType: Text.NativeRendering
                    }
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 10
                    text: "Nothing"
                    color: Colors.m3outline
                    font.family: Config.fontFamily
                    font.pixelSize: 15
                    font.weight: Font.Medium
                    horizontalAlignment: Text.AlignHCenter
                }

                Item { Layout.fillHeight: true }
            }

            ListView {
                id: list
                anchors.fill: parent
                visible: localModel.count > 0
                spacing: 12
                clip: true
                interactive: true
                model: localModel
                verticalLayoutDirection: ListView.BottomToTop

                add: Transition {
                    NumberAnimation {
                        properties: "opacity"
                        from: 0
                        to: 1
                        duration: 300
                        easing.type: Easing.OutCubic
                    }
                    NumberAnimation {
                        properties: "scale"
                        from: 0.95
                        to: 1
                        duration: 300
                        easing.type: Easing.OutCubic
                    }
                }

                addDisplaced: Transition {
                    NumberAnimation {
                        properties: "x,y"
                        duration: 260
                        easing.type: Easing.OutCubic
                    }
                }

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

                    NotificationBox {
                        id: card
                        anchors.fill: parent
                        n: delegate.notifRef
                        isPopup: false
                        onlyNotification: false
                    }
                }
            }

            // Top fade mask
            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                height: 24
                visible: localModel.count > 0
                gradient: Gradient {
                    GradientStop { position: 0; color: Colors.background }
                    GradientStop { position: 1; color: "transparent" }
                }
            }

            // Bottom fade mask
            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: 24
                visible: localModel.count > 0
                gradient: Gradient {
                    GradientStop { position: 0; color: "transparent" }
                    GradientStop { position: 1; color: Colors.background }
                }
            }
        }

    }
}

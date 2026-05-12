pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Widgets
import qs.modules.common.widgets
import qs.modules.notifications
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models
import qs.services

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

                Behavior on opacity { NumberAnimation { duration: Appearance.motion.duration.medium1 } }

                Item { Layout.fillHeight: true }

                Item {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 80

                    MaterialShape {
                        anchors.fill: parent
                        shape: MaterialShape.Shape.Cookie12Sided
                        color: Appearance.colors.elevated
                        implicitSize: 80
                    }

                    MaterialIcon {
                        anchors.centerIn: parent
                        text: "notifications_active"
                        pixelSize: 40
                        fill: 0
                        weight: 400
                        grade: 0
                        color: Appearance.colors.accent
                    }
                }

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 14
                    text: "Nothing here D:"
                    color: Appearance.colors.comment
                    font.pixelSize: Appearance.typography.small
                    font.weight: Font.Medium
                    horizontalAlignment: Text.AlignHCenter
                }

                Item { Layout.fillHeight: true }
            }

            Rectangle {
                id: listClipMask
                anchors.fill: parent
                visible: false
                layer.enabled: true
                color: "white"
                radius: Appearance.layout.cardRadius
            }

            ListView {
                id: list
                anchors.fill: parent
                visible: localModel.count > 0
                spacing: 12
                interactive: true
                model: localModel
                boundsBehavior: Flickable.DragAndOvershootBounds
                boundsMovement: Flickable.FollowBoundsBehavior
                flickDeceleration: 2200
                maximumFlickVelocity: 4000
                layer.enabled: localModel.count > 0
                layer.effect: OpacityMask {
                    maskSource: listClipMask
                }

                add: Transition {
                    NumberAnimation {
                        properties: "opacity"
                        from: 0
                        to: 1
                        duration: Appearance.motion.duration.spatial
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Appearance.motion.easing.emphasizedDecel
                    }
                    NumberAnimation {
                        properties: "scale"
                        from: 0.90
                        to: 1
                        duration: Appearance.motion.duration.spatial
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Appearance.motion.easing.emphasizedDecel
                    }
                }

                addDisplaced: Transition {
                    NumberAnimation {
                        properties: "x,y"
                        duration: Appearance.motion.duration.medium2
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Appearance.motion.easing.emphasizedDecel
                    }
                }

                displaced: Transition {
                    NumberAnimation {
                        properties: "x,y"
                        duration: Appearance.motion.duration.medium2
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Appearance.motion.easing.emphasizedDecel
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
                        enabled: delegate.dying
                        Motion.EmphAccel {}
                    }

                    Behavior on opacity {
                        Motion.EmphAccel { duration: Appearance.motion.duration.effects }
                    }

                    transform: Translate {
                        id: tr
                        x: delegate.dying ? delegate.width : 0

                        Behavior on x {
                            Motion.EmphAccel {
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

        }

    }
}

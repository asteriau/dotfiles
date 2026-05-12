pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.modules.common.widgets
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models

PopupWindow {
    id: root
    required property QsMenuHandle trayItemMenuHandle
    property real popupPadding: 8
    property real popupInnerPadding: 4

    signal menuClosed
    signal menuOpened(qsWindow: var)

    color: "transparent"

    implicitHeight: {
        let result = 0;
        for (const child of stackView.children) {
            result = Math.max(child.implicitHeight, result);
        }
        return result + popupInnerPadding * 2 + popupPadding * 2;
    }
    implicitWidth: {
        let result = 0;
        for (const child of stackView.children) {
            result = Math.max(child.implicitWidth, result);
        }
        return result + popupInnerPadding * 2 + popupPadding * 2;
    }

    function open() {
        root.visible = true;
        root.menuOpened(root);
    }

    function close() {
        root.visible = false;
        while (stackView.depth > 1)
            stackView.pop();
        root.menuClosed();
    }

    onVisibleChanged: {
        if (!visible) {
            while (stackView.depth > 1)
                stackView.pop();
            root.menuClosed();
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.BackButton | Qt.RightButton
        onPressed: event => {
            if ((event.button === Qt.BackButton || event.button === Qt.RightButton) && stackView.depth > 1)
                stackView.pop();
        }

        Rectangle {
            id: popupBackground
            anchors.fill: parent
            anchors.margins: root.popupPadding

            color: Appearance.colors.popupBackground
            radius: Appearance.layout.radiusContainer
            border.width: 1
            border.color: Appearance.colors.cardBorder
            clip: true

            opacity: 0
            scale: 0.94
            transformOrigin: Config.bar.vertical
                ? (Config.bar.onEnd ? Item.Right : Item.Left)
                : (Config.bar.onEnd ? Item.Bottom : Item.Top)

            Component.onCompleted: {
                opacity = 1;
                scale = 1;
            }

            Behavior on opacity { Motion.Fade {} }
            Behavior on scale { Motion.SpatialEmph {} }
            Behavior on implicitHeight { Motion.SpatialEmph {} }
            Behavior on implicitWidth { Motion.SpatialEmph {} }

            StackView {
                id: stackView
                anchors {
                    fill: parent
                    margins: root.popupInnerPadding
                }
                pushEnter: NoAnim {}
                pushExit: NoAnim {}
                popEnter: NoAnim {}
                popExit: NoAnim {}

                implicitWidth: currentItem ? currentItem.implicitWidth : 0
                implicitHeight: currentItem ? currentItem.implicitHeight : 0

                initialItem: SubMenu {
                    handle: root.trayItemMenuHandle
                }
            }
        }
    }

    component NoAnim: Transition {
        NumberAnimation { duration: 0 }
    }

    component SubMenu: ColumnLayout {
        id: submenu
        required property QsMenuHandle handle
        property bool isSubMenu: false
        property bool shown: false
        opacity: shown ? 1 : 0

        Behavior on opacity { Motion.ElementFast {} }

        Component.onCompleted: shown = true
        StackView.onActivating: shown = true
        StackView.onDeactivating: shown = false
        StackView.onRemoved: destroy()

        QsMenuOpener {
            id: menuOpener
            menu: submenu.handle
        }

        spacing: 0

        Loader {
            Layout.fillWidth: true
            visible: submenu.isSubMenu
            active: visible
            sourceComponent: RippleButton {
                id: backButton
                buttonRadius: popupBackground.radius - root.popupInnerPadding
                colBackground: ColorUtils.transparentize(Appearance.colors.surfaceContainerHigh, 1)
                colBackgroundHover: Appearance.colors.surfaceContainerHigh
                implicitWidth: backContent.implicitWidth + 24
                implicitHeight: 36

                downAction: () => stackView.pop()

                contentItem: RowLayout {
                    id: backContent
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                        right: parent.right
                        leftMargin: 12
                        rightMargin: 12
                    }
                    spacing: 8

                    MaterialIcon {
                        text: "chevron_left"
                        pixelSize: 20
                        color: Appearance.colors.m3onSurfaceVariant
                    }

                    Text {
                        Layout.fillWidth: true
                        text: "Back"
                        font.family: Config.typography.family
                        font.pixelSize: Appearance.typography.smallie
                        color: Appearance.colors.foreground
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            visible: submenu.isSubMenu
            implicitHeight: 1
            color: Appearance.colors.m3outline
            Layout.topMargin: 4
            Layout.bottomMargin: 4
        }

        Repeater {
            id: menuEntriesRepeater
            property bool iconColumnNeeded: {
                for (let i = 0; i < menuOpener.children.values.length; i++) {
                    if (menuOpener.children.values[i].icon.length > 0)
                        return true;
                }
                return false;
            }
            property bool specialInteractionColumnNeeded: {
                for (let i = 0; i < menuOpener.children.values.length; i++) {
                    if (menuOpener.children.values[i].buttonType !== QsMenuButtonType.None)
                        return true;
                }
                return false;
            }
            model: menuOpener.children
            delegate: SysTrayMenuEntry {
                required property QsMenuEntry modelData
                forceIconColumn: menuEntriesRepeater.iconColumnNeeded
                forceSpecialInteractionColumn: menuEntriesRepeater.specialInteractionColumnNeeded
                menuEntry: modelData

                buttonRadius: popupBackground.radius - root.popupInnerPadding

                onDismiss: root.close()
                onOpenSubmenu: handle => {
                    stackView.push(subMenuComponent.createObject(null, {
                        handle: handle,
                        isSubMenu: true
                    }));
                }
            }
        }
    }

    Component {
        id: subMenuComponent
        SubMenu {}
    }
}

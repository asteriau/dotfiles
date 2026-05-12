import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs.modules.common
import qs.modules.bar.popups

Item {
    id: root
    required property SystemTrayItem modelData
    property int iconSize: 20

    implicitWidth: iconSize
    implicitHeight: iconSize

    IconImage {
        id: trayIcon
        anchors.fill: parent
        mipmap: true
        source: root.modelData.icon
    }

    MultiEffect {
        source: trayIcon
        anchors.fill: trayIcon
        shadowEnabled: Appearance.shadow.enabled
        shadowVerticalOffset: Appearance.shadow.verticalOffset
        blurMax: Appearance.shadow.blur
        opacity: Appearance.shadow.opacity
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor

        onPressed: event => {
            switch (event.button) {
            case Qt.LeftButton:
                root.modelData.activate();
                break;
            case Qt.RightButton:
                if (root.modelData.hasMenu) {
                    if (menuLoader.active && menuLoader.item)
                        menuLoader.item.close();
                    else
                        menuLoader.active = true;
                }
                break;
            }
            event.accepted = true;
        }
    }

    Loader {
        id: menuLoader
        active: false
        sourceComponent: SysTrayMenu {
            trayItemMenuHandle: root.modelData.menu
            anchor {
                window: root.QsWindow.window
                item: root
                gravity: Config.bar.vertical
                    ? (Config.bar.onEnd ? Edges.Left : Edges.Right)
                    : (Config.bar.onEnd ? Edges.Top : Edges.Bottom)
                edges: Config.bar.vertical
                    ? (Config.bar.onEnd ? Edges.Left : Edges.Right)
                    : (Config.bar.onEnd ? Edges.Top : Edges.Bottom)
            }
            Component.onCompleted: open()
            onMenuClosed: menuLoader.active = false
        }
    }
}

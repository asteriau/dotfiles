import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland

LazyLoader {
    id: root

    property Item hoverTarget
    default property Item contentItem
    property real popupBackgroundMargin: 0
    // Set by a click on the target so popups with controls (calendar) stay open
    property bool pinned: false

    readonly property bool wantShown: pinned || (hoverTarget && hoverTarget.containsMouse)
    // Same as main's BarPopup: `_show` keeps the surface alive through the exit
    // animation, `_shown` drives the opacity/scale reveal
    property bool _show: false
    property bool _shown: false
    // A property, not a child: the loader's default property is `component`
    property Timer hideTimer: Timer {
        interval: Appearance.animation.effectsDefault.duration
        onTriggered: root._show = false
    }
    onWantShownChanged: {
        if (wantShown) {
            hideTimer.stop();
            root._show = true;
            Qt.callLater(() => root._shown = true);
        } else {
            root._shown = false;
            hideTimer.restart();
        }
    }
    active: _show

    component: PanelWindow {
        id: popupWindow
        color: "transparent"

        anchors.left: !Config.options.bar.vertical || (Config.options.bar.vertical && !Config.options.bar.bottom)
        anchors.right: Config.options.bar.vertical && Config.options.bar.bottom
        anchors.top: Config.options.bar.vertical || (!Config.options.bar.vertical && !Config.options.bar.bottom)
        anchors.bottom: !Config.options.bar.vertical && Config.options.bar.bottom

        implicitWidth: popupBackground.implicitWidth + Appearance.sizes.elevationMargin * 2 + root.popupBackgroundMargin
        implicitHeight: popupBackground.implicitHeight + Appearance.sizes.elevationMargin * 2 + root.popupBackgroundMargin

        mask: Region {
            item: popupBackground
        }

        exclusionMode: ExclusionMode.Ignore
        exclusiveZone: 0
        margins {
            left: {
                if (!Config.options.bar.vertical) return root.QsWindow?.mapFromItem(
                    root.hoverTarget, 
                    (root.hoverTarget.width - popupBackground.implicitWidth) / 2, 0
                ).x;
                return Appearance.sizes.verticalBarWidth
            }
            top: {
                if (!Config.options.bar.vertical) return Appearance.sizes.barHeight;
                return root.QsWindow?.mapFromItem(
                    root.hoverTarget, 
                    (root.hoverTarget.height - popupBackground.implicitHeight) / 2, 0
                ).y;
            }
            right: Appearance.sizes.verticalBarWidth
            bottom: Appearance.sizes.barHeight
        }
        WlrLayershell.namespace: "quickshell:popup"
        WlrLayershell.layer: WlrLayer.Overlay

        Item {
            id: animWrap
            anchors.fill: parent
            opacity: root._shown ? 1 : 0
            scale: root._shown ? 1 : 0.92
            transformOrigin: Config.options.bar.vertical
                ? (Config.options.bar.bottom ? Item.Right : Item.Left)
                : (Config.options.bar.bottom ? Item.Bottom : Item.Top)
            Behavior on opacity {
                animation: Appearance.animation.effectsDefault.numberAnimation.createObject(this)
            }
            Behavior on scale {
                animation: Appearance.animation.effectsDefault.numberAnimation.createObject(this)
            }

        StyledRectangularShadow {
            target: popupBackground
        }

        Rectangle {
            id: popupBackground
            readonly property real margin: 10
            anchors {
                fill: parent
                leftMargin: Appearance.sizes.elevationMargin + root.popupBackgroundMargin * (!popupWindow.anchors.left)
                rightMargin: Appearance.sizes.elevationMargin + root.popupBackgroundMargin * (!popupWindow.anchors.right)
                topMargin: Appearance.sizes.elevationMargin + root.popupBackgroundMargin * (!popupWindow.anchors.top)
                bottomMargin: Appearance.sizes.elevationMargin + root.popupBackgroundMargin * (!popupWindow.anchors.bottom)
            }
            implicitWidth: root.contentItem.implicitWidth + margin * 2
            implicitHeight: root.contentItem.implicitHeight + margin * 2
            color: Appearance.m3colors.m3surfaceContainer
            radius: Appearance.rounding.small
            children: [root.contentItem]

            border.width: 1
            border.color: Appearance.colors.colLayer0Border
        }
        }
    }
}

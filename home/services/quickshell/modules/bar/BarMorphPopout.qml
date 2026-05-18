import QtQuick
import qs.modules.common
import qs.modules.bar
import qs.modules.bar.popups

// Drives the faithful morph: a pill-sized "widget frame" positioned exactly
// over the trigger pill in bar-surface space. BarWidgetShapeBackground anchors
// into this frame and (via the source's own margin/offset math) extends out
// into one continuous stitched bar-pill ∪ popup outline. Popout content is
// parented to the shape and placed at the shape's popupContentOffset.
//
// Coordinate space: `parent` is the bar host PanelWindow's content item
// (spans the screen — same space `strip` uses). Not the PanelWindow itself
// (that is a WaylandPanelInterface, not a QQuickItem).
Item {
    id: root

    readonly property bool active: BarPopouts.open && !Config.bar.vertical
    readonly property real surfaceW: root.parent ? root.parent.width : 0
    readonly property real surfaceH: root.parent ? root.parent.height : 0

    // Trigger pill rect in surface coords. Until triggers are wired (Phase 4),
    // the forced-open verification has no trigger → fall back to a centred,
    // pill-sized frame so the morph is still visible/testable.
    readonly property Item trigger: BarPopouts.triggerItem
    readonly property real triggerW: root.trigger ? root.trigger.width : 120
    readonly property real triggerH: root.trigger ? root.trigger.height : Appearance.bar.height
                                                    - Appearance.layout.gapSm * 2
    // No trigger yet (forced-open verification): centre on the bar strip,
    // respecting bar position (top vs bottom — Config.bar.onEnd).
    readonly property real _stripTop: Config.bar.onEnd ? (root.surfaceH - Appearance.bar.height) : 0
    readonly property point triggerPos: root.trigger ? root.trigger.mapToItem(root.parent, 0, 0) : Qt.point(
                                                           root.surfaceW / 2 - root.triggerW / 2,
                                                           root._stripTop + (Appearance.bar.height
                                                                             - root.triggerH) / 2)

    // Content natural size via the proven childrenRect chain.
    readonly property real contentW: contentHost.childrenRect.width
    readonly property real contentH: contentHost.childrenRect.height

    // The widget frame: exactly over the trigger pill.
    x: root.triggerPos.x
    y: root.triggerPos.y
    width: root.triggerW
    height: root.triggerH

    // Stay alive through the morph-out (popupHiding) so the shape can collapse
    // back into the pill instead of vanishing.
    visible: root.active || shape.popupHiding
    opacity: root.active || shape.popupHiding ? 1 : 0
    Behavior on opacity {
        NumberAnimation {
            duration: Appearance.motion.duration.effects
            easing.type: Easing.OutCubic
        }
    }

    // The window mask must follow the shape (it spans pill ∪ popup); the frame
    // itself is only pill-sized.
    readonly property Item maskItem: shape

    // Content tracks the shape: hold the reveal until the body has mostly
    // expanded (else text renders outside the still-growing container for a
    // frame); drop it instantly on close so it never lingers outside the
    // collapsing shape.
    property bool contentRevealed: false
    onActiveChanged: {
        if (root.active)
            contentRevealTimer.restart();
        else {
            root.contentRevealed = false;
            contentRevealTimer.stop();
        }
    }
    Timer {
        id: contentRevealTimer
        interval: Appearance.motion.duration.elementMoveFast
        onTriggered: root.contentRevealed = true
    }

    BarWidgetShapeBackground {
        id: shape

        vertical: false
        atBottom: Config.bar.onEnd
        showPopup: root.active

        backgroundWidth: root.width
        backgroundHeight: root.height
        startRadius: Appearance.layout.radiusContainer
        endRadius: Appearance.layout.radiusContainer

        popupContentWidth: root.contentW
        popupContentHeight: root.contentH
        popupPadding: Appearance.layout.gapLg
        baseMargin: Appearance.layout.gapSm

        surfaceWidth: root.surfaceW
        surfaceHeight: root.surfaceH
        surfaceOriginX: root.x
        surfaceOriginY: root.y
    }

    // Popout content is a SIBLING of the shape in the widget-frame (slot)
    // space — exactly the source model: HBarWidgetWithPopout places its
    // PopupContent at popupContentOffsetX/Y in the widget slot, NOT inside the
    // ShapeCanvas. popupContentOffset is computed for this space.
    Item {
        id: contentHost
        x: shape.popupContentOffsetX
        y: shape.popupContentOffsetY
        opacity: root.active && root.contentRevealed ? 1 : 0
        Behavior on opacity {
            NumberAnimation {
                duration: Appearance.motion.duration.elementMoveFast
                easing.type: Easing.OutCubic
            }
        }

        Loader {
            id: contentLoader
            active: BarPopouts.activeName !== ""
            sourceComponent: {
                switch (BarPopouts.activeName) {
                case "calendar":
                    return calendarComp;
                case "resources":
                    return resourcesComp;
                case "weather":
                    return weatherComp;
                default:
                    return null;
                }
            }
        }
    }

    Component {
        id: calendarComp
        CalendarPopup {
            active: root.active
        }
    }
    Component {
        id: resourcesComp
        ResourcesPopup {}
    }
    Component {
        id: weatherComp
        WeatherPopup {
            active: root.active
        }
    }
}

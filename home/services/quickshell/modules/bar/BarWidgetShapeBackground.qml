pragma ComponentBehavior: Bound
import QtQuick
import qs.modules.common
import qs.modules.common.widgets as W
import qs.modules.common.widgets.shapes as Shapes
import "../common/widgets/shapes/material-shapes.js" as MaterialShapes

// Faithful port of illogical-impulse hefty-hype
// modules/hefty/topLayer/bar/HBarWidgetShapeBackground.qml.
//
// VERBATIM from source (this is *why* it reads like the reference — do not
// "improve" it): popupXOffset/popupYOffset + lockPopupX/Y, popupHiding, the
// width/height/xOffset/yOffset geometry, the stitched `roundedPolygon`
// (containerShape ∪ popupShape via MaterialShapes.customPolygon +
// joinRadiusOverride), and the elementMove animation.
//
// ADAPTED host coupling only:
//   • imports → this repo's qs.modules.common(+widgets/.shapes); JS path.
//   • tokens: elementMove → motion.duration.elementMove + BezierSpline +
//     motion.easing.expressiveDefaultSpatial; colLayer1 → surfaceContainerLow;
//     colLayer3Base → colors.elevated; rounding.large → layout.radiusXl.
//   • source read `parent.anchors.topMargin/leftMargin` (the bar's edge gap)
//     for baseMargin → injected `baseMargin` property.
//   • source used QsWindow.window.screen + mapToGlobal (non-reactive) for the
//     on-screen popup clamp → injected, reactive `surfaceWidth/Height` and
//     `surfaceOriginX/Y` (the shape frame's position in the bar surface). The
//     clamp *formula* is unchanged.
Shapes.ShapeCanvas {
    id: bgShape

    required property bool vertical
    required property bool atBottom
    required property bool showPopup
    required property real backgroundWidth
    required property real backgroundHeight
    property real popupContentWidth: 400
    property real popupContentHeight: 500
    property real popupPadding: 10
    property real popupWidth: popupContentWidth + popupPadding * 2
    property real popupHeight: popupContentHeight + popupPadding * 2
    required property real startRadius
    required property real endRadius

    // Was parent.anchors.topMargin/leftMargin (bar edge gap). Injected.
    property real baseMargin: 0

    // Was QsWindow.window.screen.* + mapToGlobal. Injected, reactive.
    property real surfaceWidth: 0
    property real surfaceHeight: 0
    property real surfaceOriginX: 0
    property real surfaceOriginY: 0

    property alias containerShape: containerShape
    property alias popupShape: popupShape

    // Reactive replacement for the source's manual mapToGlobal hooks.
    // Source: xInGlobal = mapToGlobal(0,0).x + xOffset, where mapToGlobal
    // already includes shape.x == anchors.leftMargin == -xOffset, so it
    // resolves to the widget frame's surface x. We inject that frame origin
    // directly, so bind to it as-is (adding xOffset would double-count).
    readonly property real xInGlobal: bgShape.surfaceOriginX
    readonly property real yInGlobal: bgShape.surfaceOriginY
    // Keep the popup this far from the screen edges so a corner trigger's
    // popup doesn't sit flush against the edge.
    property real popupEdgeMargin: Appearance.layout.gapLg
    readonly property real minPopupXOffset: -xInGlobal + bgShape.popupEdgeMargin
    readonly property real minPopupYOffset: -yInGlobal
    readonly property real maxPopupXOffset: {
        const maxPopupX = bgShape.surfaceWidth - popupWidth - bgShape.popupEdgeMargin;
        return maxPopupX - xInGlobal;
    }
    readonly property real maxPopupYOffset: {
        const maxPopupY = bgShape.surfaceHeight - popupHeight;
        return maxPopupY - yInGlobal;
    }
    property bool lockPopupX: false
    property bool lockPopupY: false
    // Source "froze" the offset while shown by returning `undefined` from
    // this binding (QML there kept the prior value). Qt 6.10 turns that into
    // NaN and poisons the polygon. Instead keep popupXOffset/Y *pure* (no
    // self-reference → no binding loop), snapshot into lockedPopup*Offset on
    // the showPopup edge (deferred so content has settled), and consume eff*.
    // Same anti-jitter intent, deterministic, loop-free.
    property real lockedPopupXOffset: 0
    property real lockedPopupYOffset: 0
    readonly property real popupXOffset: {
        if (!vertical)
        return Math.min(Math.max(-(popupWidth - containerShape.width) / 2, minPopupXOffset), maxPopupXOffset);
        else
        return atBottom ? -(popupShape.width + spacing) : (containerShape.width + spacing);
    }
    readonly property real popupYOffset: {
        if (!vertical)
        return atBottom ? -(popupShape.height + spacing) : (containerShape.height + spacing);
        else
        return Math.min(Math.max(-(popupHeight - containerShape.height) / 2, minPopupYOffset),
                        maxPopupYOffset);
    }
    readonly property real effPopupXOffset: bgShape.lockPopupX ? bgShape.lockedPopupXOffset :
                                                                 bgShape.popupXOffset
    readonly property real effPopupYOffset: bgShape.lockPopupY ? bgShape.lockedPopupYOffset :
                                                                 bgShape.popupYOffset
    function captureLocks() {
        if (!bgShape.showPopup)
            return;
        bgShape.lockedPopupXOffset = bgShape.popupXOffset;
        bgShape.lockedPopupYOffset = bgShape.popupYOffset;
        bgShape.lockPopupX = true;
        bgShape.lockPopupY = true;
    }

    // Where the popout *content* sits, in this shape's local space. Source
    // added parent.anchors.* here (its widget's offset in the bar group); for
    // us content is placed relative to this shape, so just popupPadding.
    readonly property real popupContentOffsetBase: popupPadding
    readonly property real paddedContainerHeight: containerShape.height
    readonly property real paddedContainerWidth: containerShape.width
    readonly property real popupContentOffsetX: {
        if (!vertical)
        return effPopupXOffset + popupContentOffsetBase;
        else
        return paddedContainerWidth + spacing + popupContentOffsetBase + (atBottom * -(popupWidth
                                                                                       + backgroundWidth
                                                                                       + spacing * 2));
    }
    readonly property real popupContentOffsetY: {
        if (!vertical)
        return paddedContainerHeight + spacing + popupContentOffsetBase + (atBottom * -(popupHeight
                                                                                        + backgroundHeight
                                                                                        + spacing * 2));
        else
        return effPopupYOffset + popupContentOffsetBase;
    }

    anchors {
        left: parent.left
        leftMargin: {
            if (!vertical)
            return -xOffset;
            if (!bgShape.atBottom || !bgShape.showPopup)
            return 0;
            return -popupShape.width - bgShape.spacing;
        }
        top: parent.top
        topMargin: {
            if (vertical)
            return -yOffset;
            if (!bgShape.atBottom || !bgShape.showPopup)
            return 0;
            return -popupShape.height - bgShape.spacing;
        }
    }
    width: {
        if (!vertical)
        return bgShape.showPopup ? Math.max(backgroundWidth, popupWidth) : backgroundWidth;
        else
        return bgShape.showPopup ? (containerShape.width + popupShape.width + bgShape.spacing) :
                                   containerShape.width;
    }
    height: {
        if (!vertical)
        return bgShape.showPopup ? (containerShape.height + popupShape.height + bgShape.spacing) :
                                   containerShape.height;
        else
        return bgShape.showPopup ? Math.max(backgroundHeight, popupHeight) : backgroundHeight;
    }
    property bool popupHiding: false
    onShowPopupChanged: {
        popupHiding = true;
        if (showPopup) {
            lockPopupX = false;
            lockPopupY = false;
        }
    }
    onProgressChanged: {
        if (progress == 1) {
            popupHiding = false;
            if (showPopup)
            bgShape.captureLocks();
            else {
                lockPopupX = false;
                lockPopupY = false;
            }
        }
    }
    color: showPopup || popupHiding ? Appearance.colors.elevated : Appearance.colors.surfaceContainerLow
    xOffset: {
        if (!vertical)
        return showPopup ? Math.max(-effPopupXOffset, 0) : 0;
        else
        return bgShape.atBottom ? (width - containerShape.width) : 0;
    }
    yOffset: {
        if (!vertical)
        return bgShape.atBottom ? (height - containerShape.height) : 0;
        else
        return showPopup ? Math.max(-effPopupYOffset, 0) : 0;
    }
    animation: Anim {}

    Behavior on width {
        Anim {}
    }
    Behavior on height {
        Anim {}
    }
    Behavior on anchors.topMargin {
        enabled: !bgShape.vertical
        Anim {}
    }
    Behavior on anchors.leftMargin {
        enabled: bgShape.vertical
        Anim {}
    }
    Behavior on xOffset {
        enabled: !bgShape.vertical
        Anim {}
    }
    Behavior on yOffset {
        enabled: bgShape.vertical
        Anim {}
    }

    polygonIsNormalized: false
    property real spacing: baseMargin * 2
    W.AxisRectangularContainerShape {
        id: containerShape
        width: bgShape.backgroundWidth
        height: bgShape.backgroundHeight
        startRadius: bgShape.startRadius
        endRadius: bgShape.endRadius
        vertical: bgShape.vertical
    }
    W.RectangularContainerShape {
        id: popupShape
        width: bgShape.popupWidth
        height: bgShape.popupHeight
        radius: Appearance.layout.radiusXl
        xOffset: bgShape.effPopupXOffset
        yOffset: bgShape.effPopupYOffset
    }

    roundedPolygon: {
        var points = [];
        // Until the popup content is measured (or any dimension is still
        // degenerate during construction), show just the pill — this avoids a
        // one-shot polygon-measure TypeError and is the sensible intermediate.
        if (!bgShape.showPopup || bgShape.popupWidth <= 1 || bgShape.popupHeight <= 1
            || bgShape.backgroundWidth <= 1 || bgShape.backgroundHeight <= 1)
        return containerShape.getFullShape();

        const joinRadiusOverride = containerShape.radiusLimit;
        if (!bgShape.vertical) {
            const popupBigger = bgShape.popupWidth > bgShape.backgroundWidth;
            // Inline comment spam to mitigate qmlls' sabotaging of the (code) layout
            points = [//
                      ...(bgShape.atBottom ? containerShape.getFirstBottomPoints() : [//
                                                                                      ...popupShape.getFirstBottomPoints(
                                                                                          ), popupShape.getBottomLeftPoint(
                                                                                          )//
                                                                                      , ...popupShape.leftPoints,
                                                                                      //
                                                                                      popupShape.getTopLeftPoint(
                                                                                          0, -bgShape.spacing
                                                                                          * (!popupBigger),
                                                                                          joinRadiusOverride)//
                                             ])//
                      , containerShape.getBottomLeftPoint(0, bgShape.spacing * (!bgShape.atBottom
                                                                                && popupBigger),
                                                          joinRadiusOverride)//
                      , containerShape.getTopLeftPoint(0, -bgShape.spacing * (bgShape.atBottom && popupBigger),
                                                       joinRadiusOverride)//
                      , ...(!bgShape.atBottom ? containerShape.topPoints : [//
                                                                            popupShape.getBottomLeftPoint(0,
                                                                                                          bgShape.spacing
                                                                                                          * (!popupBigger),
                                                                                                          joinRadiusOverride),
                                                                            //
                                                                            ...popupShape.leftPoints//
                                                                            , popupShape.getTopLeftPoint()//
                                                                            , ...popupShape.topPoints//
                                                                            , popupShape.getTopRightPoint()//
                                                                            , ...popupShape.rightPoints//
                                                                            , popupShape.getBottomRightPoint(0,
                                                                                                             bgShape.spacing
                                                                                                             * (!popupBigger),
                                                                                                             joinRadiusOverride)
                                                                            //
                                                ])//
                      , containerShape.getTopRightPoint(0, -bgShape.spacing * (bgShape.atBottom
                                                                               && popupBigger),
                                                        joinRadiusOverride)//
                      , containerShape.getBottomRightPoint(0, bgShape.spacing * (!bgShape.atBottom
                                                                                 && popupBigger),
                                                           joinRadiusOverride)//
                      , ...(bgShape.atBottom ? containerShape.getLastBottomPoints() : [//
                                                                                       popupShape.getTopRightPoint(
                                                                                           0, -bgShape.spacing
                                                                                           * (!popupBigger),
                                                                                           joinRadiusOverride),
                                                                                       //
                                                                                       ...popupShape.rightPoints,
                                                                                       //
                                                                                       popupShape.getBottomRightPoint(
                                                                                           )//
                                                                                       , ...popupShape.getLastBottomPoints(
                                                                                           )//
                                               ])//
            ];
        } else {
            const popupBigger = bgShape.popupHeight > bgShape.backgroundHeight;
            points = [//
                      ...containerShape.getFirstBottomPoints()//
                      , containerShape.getBottomLeftPoint(-bgShape.spacing * (popupBigger && bgShape.atBottom),
                                                          0, joinRadiusOverride)//
                      , ...(!bgShape.atBottom ? containerShape.leftPoints : [//
                                                                             popupShape.getBottomRightPoint(
                                                                                 bgShape.spacing * (
                                                                                     !popupBigger))//
                                                                             , ...popupShape.bottomPoints//
                                                                             , popupShape.getBottomLeftPoint(),
                                                                             //
                                                                             ...popupShape.leftPoints//
                                                                             , popupShape.getTopLeftPoint()//
                                                                             , ...popupShape.topPoints//
                                                                             , popupShape.getTopRightPoint(
                                                                                 bgShape.spacing * (
                                                                                     !popupBigger))//
                                                ])//
                      , containerShape.getTopLeftPoint(-bgShape.spacing * (popupBigger && bgShape.atBottom), 0,
                                                       joinRadiusOverride)//
                      , ...containerShape.topPoints//
                      , containerShape.getTopRightPoint(bgShape.spacing * (popupBigger && !bgShape.atBottom),
                                                        0, joinRadiusOverride)//
                      , ...(bgShape.atBottom ? containerShape.rightPoints : [//
                                                                             popupShape.getTopLeftPoint(
                                                                                 -bgShape.spacing * (
                                                                                     !popupBigger), 0,
                                                                                 joinRadiusOverride)//
                                                                             , ...popupShape.topPoints//
                                                                             , popupShape.getTopRightPoint()//
                                                                             , ...popupShape.rightPoints//
                                                                             , popupShape.getBottomRightPoint(
                                                                                 )//
                                                                             , ...popupShape.bottomPoints//
                                                                             , popupShape.getBottomLeftPoint(
                                                                                 -bgShape.spacing * (
                                                                                     !popupBigger), 0,
                                                                                 joinRadiusOverride)//
                                               ])//
                      , containerShape.getBottomRightPoint(bgShape.spacing * (popupBigger &&
                                                                              !bgShape.atBottom), 0,
                                                           joinRadiusOverride)//
                      , ...containerShape.getLastBottomPoints()//
            ];
        }
        return MaterialShapes.customPolygon(points);
    }

    component Anim: NumberAnimation {
        duration: Appearance.motion.duration.elementMove
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Appearance.motion.easing.expressiveDefaultSpatial
    }
}

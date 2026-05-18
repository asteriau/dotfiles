import QtQuick
import qs.modules.common
import qs.modules.bar
import qs.modules.bar.popups

// Hosts a bar popout's content INSIDE the fullscreen bar surface, just outside
// the bar strip, horizontally centred under its trigger (clamped to screen).
//
// Coordinate space: this Item is a child of the bar host PanelWindow, so its
// `parent` is the window's content item (a sized QQuickItem spanning the
// screen — the same space `strip` anchors into). We deliberately do NOT take
// the PanelWindow itself as a property: it is a WaylandPanelInterface, not a
// QQuickItem, and assigning it to an Item property fails.
//
// Sizing/structure mirrors BarPopup exactly (the proven path for these
// contents): a bg Rectangle filling root, an `inner` container anchored
// fill+margins with the content at its origin, and root sized to
// inner.childrenRect + pad*2 so it tightly wraps the content. CalendarPopup/
// WeatherPopup are ChoreographerLoaders whose size only propagates via this
// childrenRect chain — an anchors.centerIn (zero-size) container makes the
// content draw from the centre and overflow, which is wrong.
//
// Phase 2: plain elevated rounded rectangle — no morph shape yet. Proves
// positioning, content hosting and the mask union before the Phase-3 shape.
Item {
    id: root

    readonly property bool active: BarPopouts.open && !Config.bar.vertical
    readonly property real pad: Appearance.layout.gapLg
    readonly property real edgeMargin: Appearance.layout.zonePaddingH
    readonly property real surfaceWidth: root.parent ? root.parent.width : 0
    readonly property real surfaceHeight: root.parent ? root.parent.height : 0

    // Trigger centre in this Item's coordinate space (== parent's). Falls back
    // to screen centre when driven with no trigger (Phase-2 forced-open test).
    readonly property point triggerCenter: BarPopouts.triggerItem ? BarPopouts.triggerItem.mapToItem(
                                                                        root.parent,
                                                                        BarPopouts.triggerItem.width / 2,
                                                                        BarPopouts.triggerItem.height / 2) :
                                                                    Qt.point(root.surfaceWidth / 2, 0)

    implicitWidth: inner.childrenRect.width + root.pad * 2
    implicitHeight: inner.childrenRect.height + root.pad * 2

    visible: root.active || closeAnim.running
    opacity: root.active ? 1 : 0
    Behavior on opacity {
        NumberAnimation {
            id: closeAnim
            duration: Appearance.motion.duration.effects
            easing.type: Easing.OutCubic
        }
    }

    x: Math.max(root.edgeMargin, Math.min(root.triggerCenter.x - root.implicitWidth / 2, root.surfaceWidth
                                          - root.implicitWidth - root.edgeMargin))
    y: Config.bar.onEnd ? root.surfaceHeight - Appearance.bar.height - root.implicitHeight :
                          Appearance.bar.height

    Rectangle {
        anchors.fill: parent
        radius: Appearance.layout.radiusXl
        color: Appearance.colors.elevated
    }

    Item {
        id: inner
        anchors.fill: parent
        anchors.margins: root.pad

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

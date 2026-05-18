import QtQuick
import qs.modules.common.widgets
import qs.modules.common
import qs.services
import qs.modules.bar
import qs.modules.bar.popups

PressablePill {
    id: root

    Component.onCompleted: Resources.subscribe()
    Component.onDestruction: Resources.unsubscribe()

    implicitWidth: Appearance.bar.width - Appearance.layout.gapSm * 2
    implicitHeight: col.implicitHeight + 8

    radius: Appearance.layout.radiusContainer

    // Suppress button hover/press feedback once this trigger's morph is open
    // (the pill has become the morph shape, not a clickable button).
    readonly property bool morphActive: !Config.bar.vertical && BarPopouts.activeName === "resources"

    colorIdle: Appearance.colors.transparent
    useStateLayer: !root.morphActive
    animateColor: !root.morphActive
    pressScale: 0.98

    onClicked: {
        if (Config.bar.vertical)
            popupLoader.item.active = !popupLoader.item.active;
        else
            BarPopouts.toggle("resources", root);
    }

    Column {
        id: col
        anchors.centerIn: parent
        spacing: 6

        ResourceDial {
            icon: "memory"
            value: Resources.memoryUsedPercentage
        }

        ResourceDial {
            visible: Resources.swapTotal > 0
            icon: "swap_horiz"
            value: Resources.swapUsedPercentage
        }

        ResourceDial {
            icon: "planner_review"
            value: Resources.cpuUsage
        }
    }

    // Vertical bar keeps the original separate popup window; horizontal uses
    // the in-bar morph (BarPopouts → BarMorphPopout) instead.
    Loader {
        id: popupLoader
        active: Config.bar.vertical
        sourceComponent: BarPopup {
            id: popup
            targetItem: root
            padding: Appearance.layout.gapXl

            ResourcesPopup {}
        }
    }
}

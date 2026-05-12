import QtQuick
import qs.modules.common

QtObject {
    id: root

    required property string mode
    required property bool hoverActive
    required property bool peeking
    property string launcherQuery: ""
    property real launcherDesiredHeight: 0

    property string _displayMode: mode
    property bool _modeStable: true

    readonly property bool hoverable:
        _displayMode === "launcher" ? false :
        Appearance.island.hoverIdleExpand
            ? (_displayMode !== "osd")
            : (_displayMode === "media" || _displayMode === "battery")

    readonly property bool expanded:
        _displayMode === "launcher" ? true :
        (hoverable && _modeStable && (hoverActive || peeking))

    readonly property int targetW: {
        if (_displayMode === "launcher") {
            return launcherQuery === ""
                ? Appearance.island.launcherCollapsedWidth
                : Appearance.island.launcherWidth;
        }
        if (expanded) {
            switch (_displayMode) {
                case "media":   return Appearance.island.expandedWidthMedia;
                case "battery": return Appearance.island.expandedWidthBattery;
                case "home":    return Appearance.island.expandedWidthHome;
            }
        }
        switch (_displayMode) {
            case "osd":     return Appearance.island.compactWidthOsd;
            case "battery": return Appearance.island.compactWidthBattery;
            case "media":   return Appearance.island.compactWidthMedia;
            case "home":    return Appearance.island.notchClosedWidth;
        }
        return Appearance.island.notchClosedWidth;
    }

    readonly property int targetH: {
        if (_displayMode === "launcher") {
            return Math.max(Appearance.island.launcherMinHeight,
                            Math.min(Appearance.island.launcherMaxHeight,
                                     launcherDesiredHeight));
        }
        if (!expanded) {
            if (_displayMode === "osd") return Appearance.island.osdHeight;
            return Appearance.island.notchClosedHeight;
        }
        switch (_displayMode) {
            case "media":   return Appearance.island.expandedHeightMedia;
            case "battery": return Appearance.island.expandedHeightBattery;
            case "home":    return Appearance.island.expandedHeightHome;
        }
        return Appearance.island.notchClosedHeight;
    }

    readonly property real targetTopR:
        _displayMode === "launcher" ? Appearance.island.launcherTopRadius
        : _displayMode === "osd" ? Appearance.island.osdTopRadius
        : expanded ? Appearance.island.notchOpenTopRadius
        : Appearance.island.notchClosedTopRadius

    readonly property real targetBottomR:
        _displayMode === "launcher" ? Appearance.island.launcherBottomRadius
        : _displayMode === "osd" ? Appearance.island.osdBottomRadius
        : expanded ? Appearance.island.notchOpenBottomRadius
        : Appearance.island.notchClosedBottomRadius

    onModeChanged: {
        _modeStable = false;
        modeStableTimer.restart();
    }

    property Timer _modeStableTimer: Timer {
        id: modeStableTimer
        interval: Appearance.island.swapDurationMs
        onTriggered: {
            root._displayMode = root.mode;
            root._modeStable = true;
        }
    }
}

pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Mpris
import Quickshell.Hyprland
import qs.launcher
import qs.utils
import qs.utils.state


Scope {
    id: scope

    required property var launcher

    // State sources
    readonly property MprisPlayer player: MprisState.player
    readonly property bool mediaActive: player !== null

    readonly property bool launcherOpen: launcher?.open ?? false

    // OSD payload
    property bool _osdActive: false
    property string osdIcon: "volume_up"
    property string osdLabel: ""
    property real osdProgress: 0

    // OSD change-detection (avoid spurious triggers from upstream property refreshes)
    property real _lastSinkVol: -1
    property bool _lastSinkMuted: false
    property bool _seededSink: false
    property real _lastSourceVol: -1
    property bool _lastSourceMuted: false
    property bool _seededSource: false

    // Battery peek state
    property bool _batteryActive: false
    property bool _lastCharging: false
    property bool _seededCharging: false

    // Auto-peek: short force-expand window after fresh battery event
    property bool peeking: false

    // Hide entirely when any window on the active workspace is fullscreen
    readonly property HyprlandMonitor _hMonitor: Hyprland.monitorFor(win.screen)
    readonly property int _activeWsId: _hMonitor?.activeWorkspace?.id ?? -1
    readonly property bool fullscreenActive: WorkspaceAppData.windowList.some(w =>
        (w.fullscreen ?? 0) > 0 && (w.workspace?.id ?? -2) === _activeWsId)

    // Resolved priority: launcher > osd > battery > media > home (idle)
    readonly property string mode: {
        if (launcherOpen)   return "launcher";
        if (_osdActive)     return "osd";
        if (_batteryActive) return "battery";
        if (mediaActive)    return "media";
        return "home";
    }

    Timer {
        id: peekTimer
        interval: Config.island.peekDurationMs
        repeat: false
        onTriggered: scope.peeking = false
    }

    // OSD inputs
    Connections {
        target: PipeWireState.defaultSink ? PipeWireState.defaultSink.audio : null
        function update() {
            const muted = PipeWireState.defaultSink?.audio.muted ?? false;
            const vol = PipeWireState.defaultSink?.audio.volume ?? 0;
            const changed = !scope._seededSink
                || muted !== scope._lastSinkMuted
                || Math.abs(vol - scope._lastSinkVol) > 0.0005;
            scope._lastSinkVol = vol;
            scope._lastSinkMuted = muted;
            if (!scope._seededSink) { scope._seededSink = true; return; }
            if (!changed) return;
            scope.osdIcon = muted ? "volume_off" : (vol < 0.01 ? "volume_mute" : (vol < 0.5 ? "volume_down" : "volume_up"));
            scope.osdLabel = "Volume";
            scope.osdProgress = vol;
            scope._osdActive = true;
            osdHide.restart();
        }
        function onVolumeChanged() { update() }
        function onMutedChanged()  { update() }
    }

    Connections {
        target: PipeWireState.defaultSource ? PipeWireState.defaultSource.audio : null
        function update() {
            const muted = PipeWireState.defaultSource?.audio.muted ?? false;
            const vol = PipeWireState.defaultSource?.audio.volume ?? 0;
            const changed = !scope._seededSource
                || muted !== scope._lastSourceMuted
                || Math.abs(vol - scope._lastSourceVol) > 0.0005;
            scope._lastSourceVol = vol;
            scope._lastSourceMuted = muted;
            if (!scope._seededSource) { scope._seededSource = true; return; }
            if (!changed) return;
            scope.osdIcon = muted ? "mic_off" : "mic";
            scope.osdLabel = "Microphone";
            scope.osdProgress = vol;
            scope._osdActive = true;
            osdHide.restart();
        }
        function onVolumeChanged() { update() }
        function onMutedChanged()  { update() }
    }

    Connections {
        target: BrightnessState
        function onBrightnessChanged() {
            scope.osdIcon = "brightness_medium";
            scope.osdLabel = "Brightness";
            scope.osdProgress = BrightnessState.brightness ?? 0;
            scope._osdActive = true;
            osdHide.restart();
        }
    }

    Connections {
        target: OsdState
        function onShow(icon, label, progress) {
            scope.osdIcon = icon;
            scope.osdLabel = label;
            scope.osdProgress = progress;
            scope._osdActive = true;
            osdHide.restart();
        }
    }

    Timer {
        id: osdHide
        interval: Config.osd.timeoutMs
        onTriggered: scope._osdActive = false
    }

    // Battery transitions
    Connections {
        target: BatteryState
        function onChargingChanged() {
            if (!scope._seededCharging) {
                scope._lastCharging = BatteryState.charging;
                scope._seededCharging = true;
                return;
            }
            if (BatteryState.charging !== scope._lastCharging) {
                scope._lastCharging = BatteryState.charging;
                scope._batteryActive = true;
                scope.peeking = true;
                peekTimer.restart();
                batteryHide.restart();
            }
        }
    }
    Timer {
        id: batteryHide
        interval: Config.island.batteryPeekMs
        onTriggered: scope._batteryActive = false
    }

    // Window
    PanelWindow {
        id: win
        screen: Config.preferredMonitor
        visible: true

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        WlrLayershell.namespace: "quickshell:island"
        WlrLayershell.keyboardFocus: scope.launcherOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
        color: "transparent"
        mask: Region { item: container }

        anchors { top: true }
        margins { top: 0 }

        HyprlandFocusGrab {
            windows: [win]
            active: scope.launcherOpen
            onCleared: scope.launcher?.hide()
        }

        Keys.onPressed: event => {
            if (!scope.launcherOpen) return;
            if (event.key === Qt.Key_Escape) {
                scope.launcher.hide();
                event.accepted = true;
            } else if (event.key === Qt.Key_Down) {
                launcherView.listView.incrementCurrentIndex();
                event.accepted = true;
            } else if (event.key === Qt.Key_Up) {
                launcherView.listView.decrementCurrentIndex();
                event.accepted = true;
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                launcherView.activateCurrent();
                event.accepted = true;
            }
        }

        Shortcut {
            sequences: ["Escape"]
            enabled: scope.launcherOpen
            onActivated: scope.launcher?.hide()
        }

        implicitWidth: Math.max(Config.island.maxWidth, Config.island.launcherWidth) + 80
        implicitHeight: Math.max(Config.island.expandedHeightHome,
                                 Config.island.expandedHeightMedia,
                                 Config.island.expandedHeightNotif,
                                 Config.island.expandedHeightBattery,
                                 Config.island.launcherMaxHeight) + 80

        Item {
            id: container
            anchors.horizontalCenter: parent.horizontalCenter
            y: 0
            implicitWidth:  notch.implicitWidth
            implicitHeight: notch.implicitHeight

            readonly property bool mediaPeekVisible:
                pillState._displayMode === "media" && !pillState.expanded

            // Idle = nothing happening. Hide entirely with M3 emphasized
            // expand/collapse animation instead of rendering a "home" pill.
            readonly property bool idleHidden: pillState._displayMode === "home" || scope.fullscreenActive

            opacity: idleHidden ? 0 : 1
            visible: opacity > 0.001

            Behavior on opacity {
                NumberAnimation {
                    duration: M3Easing.durationMedium3
                    easing.bezierCurve: M3Easing.emphasized
                }
            }

            transform: [
                Scale {
                    id: containerScale
                    origin.x: container.width / 2
                    origin.y: 0
                    xScale: container.idleHidden ? 0.6 : 1
                    yScale: container.idleHidden ? 0.6 : 1
                    Behavior on xScale {
                        NumberAnimation {
                            duration: M3Easing.durationLong1
                            easing.bezierCurve: M3Easing.emphasized
                        }
                    }
                    Behavior on yScale {
                        NumberAnimation {
                            duration: M3Easing.durationLong1
                            easing.bezierCurve: M3Easing.emphasized
                        }
                    }
                },
                Translate {
                    id: containerTranslate
                    y: container.idleHidden ? -container.implicitHeight : 0
                    Behavior on y {
                        NumberAnimation {
                            duration: M3Easing.durationLong1
                            easing.bezierCurve: M3Easing.emphasized
                        }
                    }
                }
            ]

            QtObject {
                id: pillState

                property string _displayMode: scope.mode
                property bool _modeStable: true

                readonly property bool hoverable:
                    _displayMode === "launcher" ? false :
                    Config.island.hoverIdleExpand
                        ? (_displayMode !== "osd")
                        : (_displayMode === "media" || _displayMode === "battery")

                readonly property bool expanded:
                    _displayMode === "launcher" ? true :
                    (hoverable && _modeStable && (hoverHandler.hovered || scope.peeking))

                readonly property int targetW: {
                    if (_displayMode === "launcher") {
                        return LauncherSearch.query === ""
                            ? Config.island.launcherCollapsedWidth
                            : Config.island.launcherWidth;
                    }
                    if (expanded) {
                        switch (_displayMode) {
                            case "media":   return Config.island.expandedWidthMedia;
                            case "battery": return Config.island.expandedWidthBattery;
                            case "home":    return Config.island.expandedWidthHome;
                        }
                    }
                    switch (_displayMode) {
                        case "osd":     return Config.island.compactWidthOsd;
                        case "battery": return Config.island.compactWidthBattery;
                        case "media":   return Config.island.compactWidthMedia;
                        case "home":    return Config.island.notchClosedWidth;
                    }
                    return Config.island.notchClosedWidth;
                }
                readonly property int targetH: {
                    if (_displayMode === "launcher") {
                        return Math.max(Config.island.launcherMinHeight,
                                        Math.min(Config.island.launcherMaxHeight,
                                                 launcherView.desiredHeight));
                    }
                    if (!expanded) {
                        if (_displayMode === "osd") return Config.island.osdHeight;
                        return Config.island.notchClosedHeight;
                    }
                    switch (_displayMode) {
                        case "media":   return Config.island.expandedHeightMedia;
                        case "battery": return Config.island.expandedHeightBattery;
                        case "home":    return Config.island.expandedHeightHome;
                    }
                    return Config.island.notchClosedHeight;
                }
                readonly property real targetTopR:
                    _displayMode === "launcher" ? Config.island.launcherTopRadius
                    : _displayMode === "osd" ? Config.island.osdTopRadius
                    : expanded ? Config.island.notchOpenTopRadius
                    : Config.island.notchClosedTopRadius
                readonly property real targetBottomR:
                    _displayMode === "launcher" ? Config.island.launcherBottomRadius
                    : _displayMode === "osd" ? Config.island.osdBottomRadius
                    : expanded ? Config.island.notchOpenBottomRadius
                    : Config.island.notchClosedBottomRadius
            }

            Connections {
                target: scope
                function onModeChanged() {
                    pillState._modeStable = false;
                    modeStableTimer.restart();
                }
            }
            Timer {
                id: modeStableTimer
                interval: Config.island.swapDurationMs
                onTriggered: {
                    pillState._displayMode = scope.mode;
                    pillState._modeStable = true;
                }
            }

            IslandShadow {
                anchors.horizontalCenter: parent.horizontalCenter
                z: -1
                bodyWidth: notch.bodyWidth
                bodyHeight: notch.bodyHeight
                topRadius: notch.topRadius
                bottomRadius: notch.bottomRadius
                tint: mediaTint
                tintAmount: pillState._displayMode === "media" ? 1 : 0
                shadowOpacity: pillState.expanded ? 0.65 : 0.35
            }

            NotchShape {
                id: notch
                anchors.horizontalCenter: parent.horizontalCenter
                y: 0
                bodyWidth:    pillState.targetW
                bodyHeight:   pillState.targetH
                topRadius:    pillState.targetTopR
                bottomRadius: pillState.targetBottomR
                fillColor:    (pillState._displayMode === "media" && pillState.expanded)
                                  ? mediaExpanded.backdropColor
                                  : Colors.background
                layer.enabled: true
            }

            HoverHandler { id: hoverHandler }

            MouseArea {
                anchors.fill: notch
                hoverEnabled: false
                acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                enabled: !(pillState._displayMode === "media" && pillState.expanded)
                          && pillState._displayMode !== "launcher"
                onClicked: e => {
                    if (pillState._displayMode === "media" && scope.player) {
                        if (e.button === Qt.MiddleButton && scope.player.canGoNext) scope.player.next();
                        else if (scope.player.canTogglePlaying) scope.player.togglePlaying();
                    }
                }
            }

            // OSD compact (volume/brightness/mic)
            IslandOsd {
                anchors.fill: notch
                anchors.leftMargin: notch.topRadius
                anchors.rightMargin: notch.topRadius
                icon: scope.osdIcon
                label: scope.osdLabel
                progress: scope.osdProgress
                opacity: pillState._displayMode === "osd" ? 1 : 0
                visible: opacity > 0
                Behavior on opacity { NumberAnimation { duration: M3Easing.effectsDuration; easing.type: Easing.OutCubic } }
            }

            IslandBattery {
                id: batteryView
                anchors.fill: notch
                anchors.leftMargin: notch.topRadius
                anchors.rightMargin: notch.topRadius
                expanded: pillState.expanded
                opacity: pillState._displayMode === "battery" ? 1 : 0
                visible: opacity > 0
                Behavior on opacity { NumberAnimation { duration: M3Easing.effectsDuration; easing.type: Easing.OutCubic } }
            }

            // Media expanded card (clipped to the notch body via OpacityMask
            // would be ideal; here we just inset slightly and let the curved
            // bottom corners frame the content)
            Item {
                id: mediaExpanded
                anchors.fill: notch
                readonly property bool shouldShow: pillState._displayMode === "media" && pillState.expanded
                readonly property color tintColor: card.blendedColors?.colPrimary ?? Colors.accent
                readonly property color backdropColor: card.blendedColors?.colLayer0 ?? Colors.background
                opacity: 0
                visible: shouldShow || opacity > 0

                states: State {
                    name: "visible"
                    when: mediaExpanded.shouldShow
                    PropertyChanges { target: mediaExpanded; opacity: 1 }
                }
                transitions: [
                    Transition {
                        to: "visible"
                        NumberAnimation { property: "opacity"; duration: M3Easing.durationShort4; easing.type: Easing.OutCubic }
                    },
                    Transition {
                        from: "visible"
                        NumberAnimation { property: "opacity"; duration: M3Easing.effectsDuration; easing.type: Easing.OutCubic }
                    }
                ]

                IslandMediaCard {
                    id: card
                    anchors.fill: parent
                    radius: notch.bottomRadius
                    backdropMask: notch
                    contentSideInset: notch.topRadius
                }
            }

            readonly property color mediaTint: mediaExpanded.tintColor

            IslandMediaArtPeek {
                id: artPeek
                width: Config.island.mediaArtPeekSize
                height: Config.island.mediaArtPeekSize
                anchors.left: notch.left
                anchors.leftMargin: notch.topRadius + Config.island.mediaPeekGap
                anchors.verticalCenter: notch.verticalCenter
                opacity: container.mediaPeekVisible ? 1 : 0
                visible: opacity > 0
                Behavior on opacity { NumberAnimation { duration: M3Easing.durationMedium2; easing.type: Easing.OutCubic } }
            }
            
            IslandLauncher {
                id: launcherView
                anchors.fill: notch
                anchors.leftMargin: notch.topRadius
                anchors.rightMargin: notch.topRadius
                opacity: pillState._displayMode === "launcher" ? 1 : 0
                visible: opacity > 0
                onActivated: scope.launcher?.hide()
                Behavior on opacity {
                    NumberAnimation {
                        duration: M3Easing.durationLong1
                        easing.bezierCurve: M3Easing.emphasized
                    }
                }
                Component.onCompleted: {
                    if (scope.launcher) scope.launcher.islandView = launcherView;
                }
            }

            IslandMediaVizPeek {
                id: vizPeek
                width: Config.island.mediaVizPeekWidth
                height: Config.island.mediaArtPeekSize
                anchors.right: notch.right
                anchors.rightMargin: notch.topRadius + Config.island.mediaPeekGap
                anchors.verticalCenter: notch.verticalCenter
                accentColor: container.mediaTint
                opacity: container.mediaPeekVisible ? 1 : 0
                visible: opacity > 0
                Behavior on opacity { NumberAnimation { duration: M3Easing.durationMedium2; easing.type: Easing.OutCubic } }
            }
        }
    }
}

pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Mpris
import Quickshell.Hyprland
import qs.utils
import qs.utils.state

// Top-center floating dynamic island. Single PanelWindow that morphs between
// hidden (idle) → compact (peek/passive) → expanded (hover) for OSD, notif,
// and media states. Per-mode child Items handle their own visuals; this file
// owns the state machine, sizing, motion and shadow.
Scope {
    id: scope

    // ── State sources ────────────────────────────────────────────────────
    readonly property var topNotif: NotificationState.popupNotifs[0] ?? null
    readonly property MprisPlayer player: MprisState.player
    readonly property bool mediaActive: player !== null

    property bool _notifActive: false
    property var _lastNotif: null

    // OSD payload (volume / mic / brightness / programmatic show)
    property bool _osdActive: false
    property string osdIcon: "volume_up"
    property string osdLabel: ""
    property real osdProgress: 0

    // Peek-on-arrival auto-expand (notif only).
    property bool peeking: false

    // Hide entirely when any window on the active workspace is fullscreen.
    readonly property HyprlandMonitor _hMonitor: Hyprland.monitorFor(win.screen)
    readonly property int _activeWsId: _hMonitor?.activeWorkspace?.id ?? -1
    readonly property bool fullscreenActive: WorkspaceAppData.windowList.some(w =>
        (w.fullscreen ?? 0) > 0 && (w.workspace?.id ?? -2) === _activeWsId)

    // Resolved priority: osd > notif > media > idle
    readonly property string mode: {
        if (_osdActive)               return "osd";
        if (_notifActive && topNotif) return "notif";
        if (mediaActive)              return "media";
        return "idle";
    }

    // ── Notif timing ─────────────────────────────────────────────────────
    onTopNotifChanged: {
        if (topNotif && topNotif !== _lastNotif) {
            _lastNotif = topNotif;
            _notifActive = true;
            notifTimer.restart();
            scope.peeking = true;
            peekTimer.restart();
        } else if (!topNotif) {
            _notifActive = false;
            notifTimer.stop();
        }
    }
    Timer {
        id: notifTimer
        interval: Config.notifications.expireTimeout
        repeat: false
        onTriggered: scope._notifActive = false
    }

    Timer {
        id: peekTimer
        interval: Config.island.peekDurationMs
        repeat: false
        onTriggered: scope.peeking = false
    }

    // ── OSD inputs ───────────────────────────────────────────────────────
    Connections {
        target: PipeWireState.defaultSink ? PipeWireState.defaultSink.audio : null
        function update() {
            const muted = PipeWireState.defaultSink?.audio.muted ?? false;
            const vol = PipeWireState.defaultSink?.audio.volume ?? 0;
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
            scope.osdIcon = muted ? "mic_off" : "mic";
            scope.osdLabel = "Microphone";
            scope.osdProgress = PipeWireState.defaultSource?.audio.volume ?? 0;
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

    // ── Window ───────────────────────────────────────────────────────────
    PanelWindow {
        id: win
        screen: Config.preferredMonitor
        visible: !scope.fullscreenActive

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        WlrLayershell.namespace: "quickshell:island"
        color: "transparent"
        mask: Region { item: pill }

        anchors { top: true }
        margins { top: 0 }

        // Sized to fit the largest expanded card plus shadow blur headroom.
        implicitWidth: Config.island.maxWidth + 60
        implicitHeight: Config.island.expandedHeight + 60

        // ── Pill ─────────────────────────────────────────────────────────
        Item {
            id: pill
            anchors.horizontalCenter: parent.horizontalCenter
            y: 0

            // Latched display mode: when scope.mode changes mid-hover, expansion
            // collapses for a swap window before the new mode is shown.
            property string _displayMode: scope.mode
            property bool _modeStable: true

            Connections {
                target: scope
                function onModeChanged() {
                    pill._modeStable = false;
                    modeStableTimer.restart();
                }
            }
            Timer {
                id: modeStableTimer
                interval: Config.island.swapDurationMs
                onTriggered: {
                    pill._displayMode = scope.mode;
                    pill._modeStable = true;
                }
            }

            readonly property bool hoverable: _displayMode === "media" || _displayMode === "notif"
            readonly property bool expanded:
                hoverable && _modeStable && (hover.hovered || scope.peeking)

            // Target sizes per state.
            readonly property int targetW: {
                if (_displayMode === "idle") return 0;
                if (expanded && _displayMode === "media") return Config.island.expandedWidthMedia;
                if (expanded && _displayMode === "notif") return Config.island.expandedWidthNotif;
                switch (_displayMode) {
                    case "osd":   return Config.island.compactWidthOsd;
                    case "notif": return Config.island.compactWidthNotif;
                    case "media": return Config.island.compactWidthMedia;
                }
                return 0;
            }
            readonly property int targetH: {
                if (_displayMode === "idle") return 0;
                if (expanded) {
                    return _displayMode === "notif"
                        ? Config.island.expandedHeightNotif
                        : Config.island.expandedHeight;
                }
                return Config.island.compactHeight;
            }
            readonly property real targetR: {
                if (_displayMode === "idle") return Config.island.compactRadius;
                if (expanded) return Config.island.expandRadius;
                return Config.island.compactRadius;
            }

            implicitWidth:  targetW
            implicitHeight: targetH
            opacity: _displayMode === "idle" ? 0 : 1
            visible: opacity > 0.001

            Behavior on implicitWidth {
                SpringAnimation { spring: 3.8; damping: 0.34; mass: 0.6; epsilon: 0.05 }
            }
            Behavior on implicitHeight {
                SpringAnimation { spring: 4.0; damping: 0.36; mass: 0.55; epsilon: 0.05 }
            }
            Behavior on opacity {
                NumberAnimation { duration: M3Easing.durationMedium2; easing.type: Easing.OutCubic }
            }

            // ── Shadow (drawn behind everything) ─────────────────────────
            IslandShadow {
                anchors.fill: parent
                z: -1
                radius: pill.targetR
            }

            // ── Background ───────────────────────────────────────────────
            // Hidden when media-expanded (MediaArtBackdrop owns the surface).
            Rectangle {
                id: bg
                anchors.fill: parent
                topLeftRadius: pill.targetR
                topRightRadius: pill.targetR
                bottomLeftRadius: pill.targetR
                bottomRightRadius: pill.targetR
                color: Colors.background
                antialiasing: true
                clip: true

                Behavior on topLeftRadius     { SpringAnimation { spring: 5.0; damping: 0.42 } }
                Behavior on topRightRadius    { SpringAnimation { spring: 5.0; damping: 0.42 } }
                Behavior on bottomLeftRadius  { SpringAnimation { spring: 5.0; damping: 0.42 } }
                Behavior on bottomRightRadius { SpringAnimation { spring: 5.0; damping: 0.42 } }
                Behavior on color   { ColorAnimation  { duration: M3Easing.effectsDuration } }

                // Subtle accent edge ring for non-media states (M3E feel).
                Rectangle {
                    anchors.fill: parent
                    radius: parent.bottomLeftRadius
                    color: "transparent"
                    border.color: ColorMix.transparentize(Colors.accent, 0.85)
                    border.width: 1
                    visible: pill._displayMode !== "media"
                    opacity: pill.expanded ? 0.0 : 0.6
                    Behavior on opacity { NumberAnimation { duration: M3Easing.effectsDuration } }
                }
            }

            HoverHandler { id: hover }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: false
                acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                // Expanded media gives clicks to IslandMediaCard (button hit areas).
                enabled: !(pill._displayMode === "media" && pill.expanded)
                onClicked: e => {
                    if (pill._displayMode === "notif") {
                        Config.showSidebar = true;
                    } else if (pill._displayMode === "media" && scope.player) {
                        if (e.button === Qt.MiddleButton && scope.player.canGoNext) scope.player.next();
                        else if (scope.player.canTogglePlaying) scope.player.togglePlaying();
                    }
                }
            }

            // ── OSD compact ──────────────────────────────────────────────
            IslandOsd {
                anchors.fill: parent
                icon: scope.osdIcon
                progress: scope.osdProgress
                opacity: pill._displayMode === "osd" ? 1 : 0
                visible: opacity > 0
                Behavior on opacity { NumberAnimation { duration: M3Easing.effectsDuration; easing.type: Easing.OutCubic } }
            }

            // ── Notif compact ────────────────────────────────────────────
            IslandNotifCompact {
                anchors.fill: parent
                notif: scope.topNotif
                opacity: pill._displayMode === "notif" && !pill.expanded ? 1 : 0
                visible: opacity > 0
                Behavior on opacity { NumberAnimation { duration: M3Easing.effectsDuration; easing.type: Easing.OutCubic } }
            }

            // ── Notif expanded ───────────────────────────────────────────
            IslandNotifExpanded {
                anchors.fill: parent
                notif: scope.topNotif
                opacity: pill._displayMode === "notif" && pill.expanded ? 1 : 0
                visible: opacity > 0
                Behavior on opacity {
                    SequentialAnimation {
                        PauseAnimation { duration: 90 }
                        NumberAnimation { duration: M3Easing.durationShort4; easing.type: Easing.OutCubic }
                    }
                }
            }

            // ── Media compact ────────────────────────────────────────────
            IslandMediaCompact {
                anchors.fill: parent
                accentColor: mediaExpanded.tintColor
                opacity: pill._displayMode === "media" && !pill.expanded ? 1 : 0
                visible: opacity > 0
                Behavior on opacity { NumberAnimation { duration: M3Easing.effectsDuration; easing.type: Easing.OutCubic } }
            }

            // ── Media expanded ───────────────────────────────────────────
            Item {
                id: mediaExpanded
                anchors.fill: parent
                readonly property bool shouldShow: pill._displayMode === "media" && pill.expanded
                readonly property color tintColor: card.blendedColors?.colPrimary ?? Colors.accent
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
                    radius: pill.targetR
                }
            }
        }
    }
}

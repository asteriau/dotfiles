pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Services.Mpris
import Quickshell.Hyprland
import qs.components.controls
import qs.components.text
import qs.notifications
import qs.utils
import qs.utils.state

// Top-center floating dynamic island. Single PanelWindow that morphs between
// idle pebble / mpris / notif / osd compact rows and hover-expanded cards.
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

    // Hide entirely when any window on the active workspace is fullscreen.
    readonly property HyprlandMonitor _hMonitor: Hyprland.monitorFor(win.screen)
    readonly property int _activeWsId: _hMonitor?.activeWorkspace?.id ?? -1
    readonly property bool fullscreenActive: WorkspaceAppData.windowList.some(w =>
        (w.fullscreen ?? 0) > 0 && (w.workspace?.id ?? -2) === _activeWsId)

    // Resolved priority: osd > notif > media > idle
    readonly property string mode: {
        if (_osdActive)              return "osd";
        if (_notifActive && topNotif) return "notif";
        if (mediaActive)             return "media";
        return "idle";
    }

    // ── Notif timing ─────────────────────────────────────────────────────
    onTopNotifChanged: {
        if (topNotif && topNotif !== _lastNotif) {
            _lastNotif = topNotif;
            _notifActive = true;
            notifTimer.restart();
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

        // Sized for the largest possible state (hover-expanded card) plus headroom.
        implicitWidth: 480
        implicitHeight: 200

        // ── Pill ─────────────────────────────────────────────────────────
        Item {
            id: pill
            anchors.horizontalCenter: parent.horizontalCenter
            y: 0

            // Latched display mode: when scope.mode changes mid-hover, expansion
            // collapses for one spring period before the new mode is shown.
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
                interval: 140
                onTriggered: {
                    pill._displayMode = scope.mode;
                    pill._modeStable = true;
                }
            }

            readonly property bool hoverable: _displayMode === "media" || _displayMode === "notif"
            readonly property bool expanded: hoverable && hover.hovered && _modeStable

            // Target sizes per state.
            readonly property int targetW: {
                if (expanded && _displayMode === "media") return 420;
                if (expanded && _displayMode === "notif") return 360;
                switch (_displayMode) {
                    case "idle":  return 140;
                    case "osd":   return 240;
                    case "notif": return Math.min(320, notifCompact.implicitWidth + 24);
                    case "media": return 140;
                }
                return 140;
            }
            readonly property int targetH: {
                if (expanded && _displayMode === "media") return 96;
                if (expanded && _displayMode === "notif") return 120;
                switch (_displayMode) {
                    case "idle":  return 8;
                    case "media": return 32;
                    default:      return 36;
                }
            }
            readonly property real targetR: {
                if (expanded) return 22;
                if (_displayMode === "idle") return 4;
                return 16;
            }

            implicitWidth:  targetW
            implicitHeight: targetH

            Behavior on implicitWidth {
                SpringAnimation { spring: 4.5; damping: 0.26; mass: 0.55; epsilon: 0.1 }
            }
            Behavior on implicitHeight {
                SpringAnimation { spring: 4.5; damping: 0.26; mass: 0.55; epsilon: 0.1 }
            }

            Rectangle {
                id: bg
                anchors.fill: parent
                topLeftRadius: pill.expanded ? pill.targetR : 0
                topRightRadius: pill.expanded ? pill.targetR : 0
                bottomLeftRadius: pill.targetR
                bottomRightRadius: pill.targetR
                color: pill._displayMode === "idle" ? Colors.surfaceContainerHighest : Colors.background
                antialiasing: true
                clip: true

                Behavior on topLeftRadius { SpringAnimation { spring: 5.5; damping: 0.32 } }
                Behavior on topRightRadius { SpringAnimation { spring: 5.5; damping: 0.32 } }
                Behavior on bottomLeftRadius { SpringAnimation { spring: 5.5; damping: 0.32 } }
                Behavior on bottomRightRadius { SpringAnimation { spring: 5.5; damping: 0.32 } }
                Behavior on color {
                    ColorAnimation { duration: M3Easing.effectsDuration }
                }
            }

            HoverHandler { id: hover }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: false
                acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                // In expanded media, IslandMediaCard owns clicks (button hit areas only).
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

            // ── Idle pebble (no content) ─────────────────────────────────
            // (just bg)

            // ── OSD compact ──────────────────────────────────────────────
            RowLayout {
                id: osdCompact
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 14
                spacing: Config.layout.gapMd
                opacity: pill._displayMode === "osd"  ? 1 : 0
                visible: opacity > 0
                Behavior on opacity { NumberAnimation { duration: M3Easing.effectsDuration; easing.type: Easing.OutCubic } }

                CrossfadeIcon {
                    text: scope.osdIcon
                    fill: 1
                    pixelSize: 20
                    color: Colors.foreground
                    Layout.alignment: Qt.AlignVCenter
                }
                StyledProgressBar {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    Layout.preferredHeight: 4
                    valueBarHeight: 4
                    value: Math.max(0, Math.min(1, scope.osdProgress))
                    highlightColor: Colors.accent
                    trackColor: Qt.rgba(Colors.accent.r, Colors.accent.g, Colors.accent.b, 0.35)
                }
                StyledText {
                    Layout.alignment: Qt.AlignVCenter
                    text: Math.round(Math.max(0, Math.min(1, scope.osdProgress)) * 100)
                    font.pixelSize: Config.typography.small
                    font.weight: Font.Medium
                    color: Colors.foreground
                    horizontalAlignment: Text.AlignRight
                }
            }

            // ── Notif compact ────────────────────────────────────────────
            Row {
                id: notifCompact
                anchors.centerIn: parent
                spacing: Config.layout.gapSm
                opacity: pill._displayMode === "notif" && !pill.expanded  ? 1 : 0
                visible: opacity > 0
                Behavior on opacity { NumberAnimation { duration: M3Easing.effectsDuration; easing.type: Easing.OutCubic } }

                MaterialIcon {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "notifications_active"
                    fill: 1
                    pixelSize: Config.typography.normal
                    color: Colors.foreground
                }
                StyledText {
                    anchors.verticalCenter: parent.verticalCenter
                    width: Math.min(implicitWidth, 260)
                    elide: Text.ElideRight
                    font.pixelSize: Config.typography.small
                    color: Colors.foreground
                    text: {
                        const n = scope.topNotif;
                        if (!n) return "";
                        const s = n.summary ?? "";
                        const b = n.body ?? "";
                        return s && b ? `${s} — ${b}` : (s || b);
                    }
                }
            }

            // ── Notif expanded ───────────────────────────────────────────
            RowLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 12
                opacity: pill._displayMode === "notif" && pill.expanded  ? 1 : 0
                visible: opacity > 0
                Behavior on opacity { NumberAnimation { duration: M3Easing.effectsDuration; easing.type: Easing.OutCubic } }

                NotificationAppIcon {
                    Layout.alignment: Qt.AlignTop
                    image: scope.topNotif?.image ?? ""
                    appIcon: scope.topNotif?.appIcon ?? ""
                    summary: scope.topNotif?.summary ?? ""
                    urgency: scope.topNotif?.urgency ?? 0
                    implicitSize: 40
                    Layout.preferredWidth: 40
                    Layout.preferredHeight: 40
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 2

                    StyledText {
                        Layout.fillWidth: true
                        text: scope.topNotif?.appName ?? ""
                        visible: text.length > 0
                        color: Colors.m3onSurfaceVariant
                        font.pixelSize: Config.typography.smaller
                        elide: Text.ElideRight
                    }
                    StyledText {
                        Layout.fillWidth: true
                        text: scope.topNotif?.summary ?? ""
                        color: Colors.foreground
                        font.pixelSize: Config.typography.normal
                        font.weight: Font.Medium
                        wrapMode: Text.WordWrap
                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }
                    StyledText {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        visible: text.length > 0
                        text: scope.topNotif?.body ?? ""
                        color: Colors.m3onSurfaceVariant
                        font.pixelSize: Config.typography.small
                        wrapMode: Text.WordWrap
                        elide: Text.ElideRight
                        maximumLineCount: 2
                    }
                }
            }

            // ── Media compact ────────────────────────────────────────────
            // Mini cover left, audio-bars equalizer right. No text.
            Item {
                id: mediaCompact
                width: 140
                height: 32
                anchors.centerIn: parent
                opacity: pill._displayMode === "media" && !pill.expanded  ? 1 : 0
                visible: opacity > 0
                Behavior on opacity { NumberAnimation { duration: M3Easing.effectsDuration; easing.type: Easing.OutCubic } }

                readonly property string artUrl: (scope.player?.trackArtUrl ?? "").toString()
                readonly property bool playing: scope.player?.isPlaying ?? false

                ClippingRectangle {
                    id: artClip
                    width: 26
                    height: 26
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    radius: width / 2
                    color: Colors.surfaceContainerHighest
                    antialiasing: true

                    Image {
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectCrop
                        smooth: true
                        mipmap: true
                        asynchronous: true
                        cache: true
                        sourceSize.width: 256
                        sourceSize.height: 256
                        source: mediaCompact.artUrl ? MprisState.resolveArtSource(mediaCompact.artUrl) : ""
                        visible: status === Image.Ready
                    }
                    MaterialIcon {
                        anchors.centerIn: parent
                        visible: !mediaCompact.artUrl
                        text: "music_note"
                        fill: 1
                        pixelSize: 14
                        color: Colors.foreground
                    }
                }

                Row {
                    id: bars
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2

                    Repeater {
                        model: 4
                        Rectangle {
                            required property int index
                            width: 2
                            height: 14
                            radius: 1
                            color: Colors.accent
                            transformOrigin: Item.Center

                            SequentialAnimation on scale {
                                running: mediaCompact.playing
                                loops: Animation.Infinite
                                NumberAnimation { from: 0.25; to: 1.0; duration: 380 + index * 80; easing.type: Easing.InOutSine }
                                NumberAnimation { from: 1.0; to: 0.35; duration: 320 + index * 60; easing.type: Easing.InOutSine }
                                NumberAnimation { from: 0.35; to: 0.7; duration: 240 + index * 40; easing.type: Easing.InOutSine }
                            }

                            scale: mediaCompact.playing ? scale : 0.3
                            Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
                        }
                    }
                }
            }

            // ── Media expanded ───────────────────────────────────────────
            Item {
                id: mediaExpanded
                anchors.fill: parent
                readonly property bool shouldShow: pill._displayMode === "media" && pill.expanded
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
                        SequentialAnimation {
                            PauseAnimation { duration: 110 }
                            NumberAnimation { property: "opacity"; duration: 160; easing.type: Easing.OutCubic }
                        }
                    },
                    Transition {
                        from: "visible"
                        NumberAnimation { property: "opacity"; duration: M3Easing.effectsDuration; easing.type: Easing.OutCubic }
                    }
                ]

                IslandMediaCard {
                    anchors.fill: parent
                    radius: pill.targetR
                }
            }
        }
    }
}

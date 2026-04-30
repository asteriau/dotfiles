import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Mpris
import qs.components.controls
import qs.components.text
import qs.sidebar.media
import qs.utils
import qs.utils.state

// Single contextual slot in the bar's center zone. Priority chain:
//   Notif (timed 5s) > Media > ActiveWindow (horizontal only) > collapse.
// Idle = zero-sized so the bar reflows; otherwise inflates (spring) into a
// surfaceContainerHigh pill with one of three states.
Item {
    id: root

    readonly property bool horizontal: !Config.bar.vertical

    // ── Inputs ────────────────────────────────────────────────────────────
    readonly property var topNotif: (NotificationState.popupNotifs[0] ?? null)
    readonly property MprisPlayer player: MprisState.player
    readonly property bool mediaActive: player !== null
    readonly property Toplevel activeWin: ToplevelManager.activeToplevel
    readonly property bool windowActive: horizontal && (activeWin?.activated ?? false)

    // ── State ─────────────────────────────────────────────────────────────
    property var _lastNotif: null
    property bool _notifActive: false
    property string mode: "idle"   // idle | notif | media | window

    function _recompute() {
        if (_notifActive && topNotif) { mode = "notif";  return; }
        if (mediaActive)              { mode = "media";  return; }
        if (windowActive)             { mode = "window"; return; }
        mode = "idle";
    }

    onTopNotifChanged: {
        if (topNotif && topNotif !== _lastNotif) {
            _lastNotif = topNotif;
            _notifActive = true;
            notifTimer.restart();
        } else if (!topNotif) {
            _notifActive = false;
            notifTimer.stop();
        }
        _recompute();
    }
    onMediaActiveChanged:  _recompute()
    onWindowActiveChanged: _recompute()
    Component.onCompleted: _recompute()

    Timer {
        id: notifTimer
        interval: 5000
        repeat: false
        onTriggered: { root._notifActive = false; root._recompute(); }
    }

    // ── Sizing ────────────────────────────────────────────────────────────
    readonly property bool active: mode !== "idle"

    // Horizontal: width inflates around content. Vertical: just the icon at
    // bar width — height inflates only enough to host the icon. Notif/media
    // in vertical bar use icon-only (text doesn't fit on a 46px column).
    readonly property int hContentWidth: {
        if (mode === "notif")  return notifIconHRow.implicitWidth + Config.layout.gapMd * 2
        if (mode === "media")  return mediaIconHRow.implicitWidth + Config.layout.gapMd * 2
        if (mode === "window") return windowLoader.implicitWidth  + Config.layout.gapMd * 2
        return 0
    }

    implicitWidth:  horizontal ? Math.min(hContentWidth, Config.layout.focalMaxWidth) : Config.bar.width
    implicitHeight: horizontal ? Config.bar.height : (active ? Config.layout.focalMinHeight + 4 : 0)

    Behavior on implicitWidth {
        enabled: root.horizontal
        NumberAnimation {
            duration: M3Easing.spatialDuration
            easing.type: Easing.BezierSpline
            easing.bezierCurve: M3Easing.expressiveSpring
        }
    }
    Behavior on implicitHeight {
        enabled: !root.horizontal
        NumberAnimation {
            duration: M3Easing.spatialDuration
            easing.type: Easing.BezierSpline
            easing.bezierCurve: M3Easing.expressiveSpring
        }
    }

    // ── Visual ────────────────────────────────────────────────────────────
    Rectangle {
        id: pill
        anchors.fill: parent
        anchors.topMargin:    root.horizontal ? 4 : 0
        anchors.bottomMargin: root.horizontal ? 4 : 0
        anchors.leftMargin:   root.horizontal ? 0 : 4
        anchors.rightMargin:  root.horizontal ? 0 : 4
        radius: Config.layout.radiusMd
        color: Colors.surfaceContainerLowest
        visible: root.active
        opacity: root.active ? 1 : 0
        clip: true

        Behavior on opacity {
            NumberAnimation { duration: M3Easing.effectsDuration; easing.type: Easing.OutCubic }
        }

        HoverHandler { id: pillHover }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: false
            acceptedButtons: Qt.LeftButton | Qt.MiddleButton
            onClicked: (e) => {
                if (root.mode === "notif") {
                    Config.showSidebar = true;
                } else if (root.mode === "media" && root.player) {
                    if (e.button === Qt.MiddleButton && root.player.canGoNext) root.player.next();
                    else if (root.player.canTogglePlaying) root.player.togglePlaying();
                }
            }
        }

        // ── Notif ─────────────────────────────────────────────────────────
        // Horizontal: icon + summary. Vertical: icon only (body fits poorly).
        Row {
            id: notifIconHRow
            visible: root.horizontal && root.mode === "notif"
            anchors.centerIn: parent
            spacing: Config.layout.gapSm

            MaterialIcon {
                anchors.verticalCenter: parent.verticalCenter
                text: "notifications_active"
                fill: 1
                pixelSize: Config.typography.normal
                color: Colors.foreground
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                width: Math.min(implicitWidth, Config.layout.focalMaxWidth - 60)
                elide: Text.ElideRight
                font.pixelSize: Config.typography.small
                font.family: Config.typography.family
                color: Colors.foreground
                text: {
                    const n = root.topNotif;
                    if (!n) return "";
                    const s = n.summary ?? "";
                    const b = n.body ?? "";
                    return s && b ? `${s} — ${b}` : (s || b);
                }
            }
        }

        MaterialIcon {
            visible: !root.horizontal && root.mode === "notif"
            anchors.centerIn: parent
            text: "notifications_active"
            fill: 1
            pixelSize: Config.typography.large
            color: Colors.foreground
        }

        // ── Media ─────────────────────────────────────────────────────────
        // Horizontal: icon + title elided. Vertical: icon only.
        Row {
            id: mediaIconHRow
            visible: root.horizontal && root.mode === "media"
            anchors.centerIn: parent
            spacing: Config.layout.gapSm

            CrossfadeIcon {
                anchors.verticalCenter: parent.verticalCenter
                text: (root.player?.isPlaying ?? false) ? "pause" : "music_note"
                fill: 1
                pixelSize: Config.typography.normal
                weight: Font.DemiBold
                color: Colors.foreground
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                width: Math.min(implicitWidth, Config.layout.focalMaxWidth - 60)
                elide: Text.ElideRight
                font.pixelSize: Config.typography.small
                font.family: Config.typography.family
                color: Colors.foreground
                text: {
                    const t = root.player?.trackTitle  ?? "";
                    const a = root.player?.trackArtist ?? "";
                    if (t && a) return `${t} • ${a}`;
                    return t || a || "";
                }
            }
        }

        CrossfadeIcon {
            visible: !root.horizontal && root.mode === "media"
            anchors.centerIn: parent
            text: (root.player?.isPlaying ?? false) ? "pause" : "music_note"
            fill: 1
            pixelSize: Config.typography.large
            weight: Font.DemiBold
            color: Colors.foreground
        }

        // ── Window (horizontal only) ──────────────────────────────────────
        Loader {
            id: windowLoader
            visible: root.horizontal && root.mode === "window"
            anchors.centerIn: parent
            active: root.horizontal && root.windowActive
            sourceComponent: ActiveWindow {
                maxTitleWidth: Config.layout.focalMaxWidth - 60
            }
        }

        // ── Hover popups ──────────────────────────────────────────────────
        BarPopup {
            targetItem: root
            active: root.mode === "media" && pillHover.hovered
            transparent: true

            Item {
                implicitWidth: 360
                implicitHeight: 160
                MediaCard {
                    anchors.fill: parent
                    showShadow: false
                }
            }
        }

        BarPopup {
            targetItem: root
            active: root.mode === "notif" && pillHover.hovered && root.topNotif !== null

            Column {
                spacing: 4
                width: 280

                Text {
                    width: parent.width
                    text: root.topNotif?.summary ?? ""
                    color: Colors.foreground
                    font.pixelSize: Config.typography.normal
                    font.family: Config.typography.family
                    font.weight: Font.Medium
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                    maximumLineCount: 2
                }
                Text {
                    width: parent.width
                    visible: text.length > 0
                    text: root.topNotif?.body ?? ""
                    color: Colors.comment
                    font.pixelSize: Config.typography.small
                    font.family: Config.typography.family
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                    maximumLineCount: 4
                }
            }
        }
    }
}

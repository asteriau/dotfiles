import QtQuick
import Quickshell.Io
import qs.services

Item {
    id: root

    // Inputs.
    property string playerName: ""
    property bool   active: false
    property real   maxLength: 0
    property int    intervalMs: 500

    // Outputs.
    readonly property string status:    _status
    readonly property real   position:  _position
    readonly property bool   animating: _animating

    // Internal backing storage.
    property string _status: "Stopped"
    property real   _position: 0
    property real   _lastPosition: 0
    property int    _stalledPolls: 0
    property bool   _hasSample: false
    property bool   _animating: false

    function reset(): void {
        _status = "Stopped";
        _position = 0;
        _lastPosition = 0;
        _stalledPolls = 0;
        _hasSample = false;
        _animating = false;
    }

    // Seed the cached position (e.g., after a user seek) so the next poll
    // doesn't flag it as a stall.
    function syncPosition(pos: real): void {
        const clamped = _clamp(pos);
        _position = clamped;
        _lastPosition = clamped;
        _stalledPolls = 0;
    }

    function pollNow(): void {
        if (!active || playerName.length === 0 || proc.running)
            return;
        proc.command = [
            "bash", "-lc",
            `playerctl -p ${MprisController.shellQuote(playerName)} status 2>/dev/null; `
            + `playerctl -p ${MprisController.shellQuote(playerName)} position 2>/dev/null`
        ];
        proc.running = true;
    }

    function _clamp(pos: real): real {
        const safe = Math.max(0, pos ?? 0);
        return maxLength > 0 ? Math.min(safe, maxLength) : safe;
    }

    function _apply(text: string): void {
        const lines = String(text ?? "").trim().split(/\r?\n/).filter(Boolean);
        if (lines.length === 0)
            return;

        const nextStatus = lines[0];
        const parsed = lines.length > 1 ? parseFloat(lines[1]) : _position;
        const nextPos = Number.isFinite(parsed) ? _clamp(parsed) : _position;
        const moved = !_hasSample || Math.abs(nextPos - _lastPosition) > 0.05;

        _status = nextStatus;
        _position = nextPos;

        if (nextStatus === "Playing") {
            _stalledPolls = moved ? 0 : _stalledPolls + 1;
            _animating = _stalledPolls < 2;
        } else {
            _stalledPolls = 0;
            _animating = false;
        }

        _lastPosition = nextPos;
        _hasSample = true;
    }

    Timer {
        running: root.active && root.playerName.length > 0
        interval: root.intervalMs
        repeat: true
        triggeredOnStart: true
        onTriggered: root.pollNow()
    }

    Process {
        id: proc
        stdout: StdioCollector {
            onStreamFinished: root._apply(text)
        }
        onExited: exitCode => {
            if (exitCode !== 0 && root.active)
                root._animating = false;
        }
    }
}

pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import qs.components.controls
import qs.components.shape
import qs.components.text
import qs.utils
import qs.utils.state

Scope {
    id: scope
    property bool osdVisible: false
    property real progress: 0
    property string icon: "volume_up"
    property string label: ""

    Connections {
        target: PipeWireState.defaultSink ? PipeWireState.defaultSink.audio : null

        function update() {
            const muted = PipeWireState.defaultSink?.audio.muted ?? false;
            const vol = PipeWireState.defaultSink?.audio.volume ?? 0;
            scope.osdVisible = true;
            scope.icon = muted ? "volume_off" : (vol < 0.01 ? "volume_mute" : (vol < 0.5 ? "volume_down" : "volume_up"));
            scope.label = "Volume";
            scope.progress = vol;
            hideTimer.restart();
        }

        function onVolumeChanged() {
            update();
        }

        function onMutedChanged() {
            update();
        }
    }

    Connections {
        target: PipeWireState.defaultSource ? PipeWireState.defaultSource.audio : null

        function update() {
            const muted = PipeWireState.defaultSource?.audio.muted ?? false;
            scope.osdVisible = true;
            scope.icon = muted ? "mic_off" : "mic";
            scope.label = "Microphone";
            scope.progress = PipeWireState.defaultSource?.audio.volume ?? 0;
            hideTimer.restart();
        }

        function onVolumeChanged() {
            update();
        }

        function onMutedChanged() {
            update();
        }
    }

    Connections {
        target: OsdState

        function onShow(icon, label, progress) {
            scope.osdVisible = true;
            scope.icon = icon;
            scope.label = label;
            scope.progress = progress;
            hideTimer.restart();
        }
    }

    Connections {
        target: BrightnessState

        function onBrightnessChanged() {
            scope.osdVisible = true;
            scope.icon = "brightness_medium";
            scope.label = "Brightness";
            scope.progress = BrightnessState.brightness ?? 0;
            hideTimer.restart();
        }
    }

    Timer {
        id: hideTimer
        interval: Config.osdTimeoutMs
        onTriggered: scope.osdVisible = false
    }

    // Hold the window mapped long enough for the exit animation to finish.
    Timer {
        id: exitHold
        interval: M3Easing.durationLong1
        repeat: false
    }

    onOsdVisibleChanged: {
        if (!osdVisible) {
            exitHold.restart();
        } else {
            exitHold.stop();
        }
    }

    LazyLoader {
        active: scope.osdVisible || exitHold.running

        PanelWindow {
            id: root

            screen: Config.preferredMonitor

            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "quickshell:osd"
            color: "transparent"
            mask: Region {
                item: osdPill
            }

            anchors {
                top: true
            }

            margins {
                top: Config.barHeight + Config.padding * 4
            }

            implicitWidth: osdPill.implicitWidth + Config.padding * 10
            implicitHeight: osdPill.implicitHeight + Config.padding * 10

            Item {
                id: osdPill

                anchors.horizontalCenter: parent.horizontalCenter
                y: (parent.height - height) / 2 + yOffset
                implicitWidth: Config.osdWidth
                implicitHeight: 48

                property real yOffset: scope.osdVisible ? 0 : -18
                opacity: scope.osdVisible ? 1 : 0

                // M3 emphasized easing: decelerate in (long2), accelerate out (short4).
                Behavior on opacity {
                    NumberAnimation {
                        duration: scope.osdVisible ? M3Easing.durationLong2 : M3Easing.durationShort4
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: scope.osdVisible ? M3Easing.emphasizedDecel : M3Easing.emphasizedAccel
                    }
                }
                Behavior on yOffset {
                    NumberAnimation {
                        duration: scope.osdVisible ? M3Easing.durationLong2 : M3Easing.durationShort4
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: scope.osdVisible ? M3Easing.emphasizedDecel : M3Easing.emphasizedAccel
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: scope.osdVisible = false
                }

                RectangularShadow {
                    anchors.fill: pillBg
                    radius: pillBg.radius
                    offset.y: Config.padding
                    blur: Config.blurMax
                    spread: Config.padding
                    color: Colors.windowShadow
                }

                Rectangle {
                    id: pillBg
                    anchors.fill: parent
                    radius: height / 2
                    color: Colors.background
                    antialiasing: true
                }

                RowLayout {
                    id: row
                    anchors.fill: parent
                    anchors.leftMargin: 0
                    anchors.rightMargin: 0
                    anchors.topMargin: 0
                    anchors.bottomMargin: 0
                    spacing: 10

                    Item {
                        id: iconStack
                        Layout.alignment: Qt.AlignVCenter
                        Layout.preferredWidth: 30
                        Layout.preferredHeight: 30
                        Layout.leftMargin: 10
                        Layout.topMargin: 9
                        Layout.bottomMargin: 9

                        MaterialShape {
                            anchors.fill: parent
                            color: Colors.accent
                            shape: MaterialShape.Shape.Clover8Leaf
                            implicitSize: 30
                        }

                        CrossfadeIcon {
                            anchors.fill: parent
                            text: scope.icon
                            pixelSize: 30
                            color: Colors.background
                        }
                    }

                    ColumnLayout {
                        Layout.alignment: Qt.AlignVCenter
                        Layout.fillWidth: true
                        Layout.rightMargin: 20
                        spacing: 5

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.leftMargin: 3
                            Layout.rightMargin: 3

                            StyledText {
                                text: scope.label
                                font.pixelSize: Config.typography.small
                                font.weight: Font.Medium
                                color: Colors.foreground
                                Layout.fillWidth: true
                            }

                            StyledText {
                                text: Math.round(Math.max(0, Math.min(1, scope.progress)) * 100)
                                font.pixelSize: Config.typography.small
                                font.weight: Font.Medium
                                color: Colors.foreground
                                horizontalAlignment: Text.AlignRight
                            }
                        }

                        StyledProgressBar {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 4
                            padding: 0
                            valueBarHeight: 4
                            value: Math.max(0, Math.min(1, scope.progress))
                            highlightColor: Colors.accent
                            trackColor: Qt.rgba(Colors.accent.r, Colors.accent.g, Colors.accent.b, 0.45)
                        }
                    }
                }
            }
        }
    }
}

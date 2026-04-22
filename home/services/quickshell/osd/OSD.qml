pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import qs.utils
import qs.components

Scope {
    id: scope
    property bool osdVisible: false
    property real progress: 0
    property string icon: "volume_up"
    property string label: ""

    // Icon crossfade state.
    property string iconA: "volume_up"
    property string iconB: ""
    property bool aActive: true

    onIconChanged: {
        const current = aActive ? iconA : iconB;
        if (icon === current)
            return;
        if (aActive) {
            iconB = icon;
            aActive = false;
        } else {
            iconA = icon;
            aActive = true;
        }
    }

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
        interval: Config.osdTimeout
        onTriggered: scope.osdVisible = false
    }

    // Hold the window mapped long enough for the exit animation to finish.
    Timer {
        id: exitHold
        interval: 420
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
                implicitWidth: 200
                implicitHeight: 48

                property real yOffset: scope.osdVisible ? 0 : -18
                opacity: scope.osdVisible ? 1 : 0

                // M3 emphasized easing.
                // Enter: emphasized decelerate (0.05, 0.7, 0.1, 1.0), 500ms.
                // Exit: emphasized accelerate (0.3, 0.0, 0.8, 0.15), 200ms.
                Behavior on opacity {
                    NumberAnimation {
                        duration: scope.osdVisible ? 500 : 200
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: scope.osdVisible ? [0.05, 0.7, 0.1, 1.0, 1, 1] : [0.3, 0.0, 0.8, 0.15, 1, 1]
                    }
                }
                Behavior on yOffset {
                    NumberAnimation {
                        duration: scope.osdVisible ? 500 : 200
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: scope.osdVisible ? [0.05, 0.7, 0.1, 1.0, 1, 1] : [0.3, 0.0, 0.8, 0.15, 1, 1]
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

                        MaterialIcon {
                            anchors.fill: parent
                            text: scope.iconA
                            font.pixelSize: 30
                            color: Colors.background
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            opacity: scope.aActive ? 1 : 0
                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 200
                                    easing.type: Easing.BezierSpline
                                    easing.bezierCurve: [0.2, 0, 0, 1, 1, 1]
                                }
                            }
                        }

                        MaterialIcon {
                            anchors.fill: parent
                            text: scope.iconB
                            font.pixelSize: 30
                            color: Colors.background
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            opacity: scope.aActive ? 0 : 1
                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 200
                                    easing.type: Easing.BezierSpline
                                    easing.bezierCurve: [0.2, 0, 0, 1, 1, 1]
                                }
                            }
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

                            Text {
                                text: scope.label
                                font.pixelSize: 15
                                font.weight: Font.Medium
                                color: Colors.foreground
                                Layout.fillWidth: true
                            }

                            Text {
                                text: Math.round(Math.max(0, Math.min(1, scope.progress)) * 100)
                                font.pixelSize: 15
                                font.weight: Font.Medium
                                color: Colors.foreground
                                horizontalAlignment: Text.AlignRight
                            }
                        }

                        Item {
                            id: progress
                            Layout.fillWidth: true
                            implicitHeight: 4

                            property real valueBarGap: 4
                            property real pos: Math.max(0, Math.min(1, scope.progress))

                            Rectangle {
                                id: bar
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width * progress.pos
                                height: parent.height
                                radius: height / 2
                                color: Colors.accent

                                Behavior on width {
                                    NumberAnimation {
                                        duration: 90
                                        easing.type: Easing.OutCubic
                                    }
                                }
                            }

                            Rectangle {
                                id: track
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                width: Math.max(0, (1 - progress.pos) * parent.width - progress.valueBarGap)
                                height: parent.height
                                radius: height / 2
                                color: Qt.rgba(Colors.accent.r, Colors.accent.g, Colors.accent.b, 0.45)

                                Behavior on width {
                                    NumberAnimation {
                                        duration: 90
                                        easing.type: Easing.OutCubic
                                    }
                                }
                            }

                            Rectangle {
                                id: stopDot
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                width: progress.valueBarGap
                                height: progress.valueBarGap
                                radius: height / 2
                                color: Colors.accent
                            }
                        }
                    }
                }
            }
        }
    }
}

pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import qs.components.text
import qs.utils

// Compact OSD row inside the island. Icon → segmented dot indicator → value%.
// Replaces a plain progress bar with M3E-feeling discrete pips.
Item {
    id: root

    property string icon: "volume_up"
    property real   progress: 0          // 0..1
    property color  fillColor: Colors.accent
    property color  trackColor: Colors.surfaceContainerHigh

    readonly property int dotCount: 12
    readonly property int dotSize: 5
    readonly property int dotGap: 4

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        spacing: 12

        CrossfadeIcon {
            text: root.icon
            fill: 1
            pixelSize: 22
            color: Colors.foreground
            Layout.alignment: Qt.AlignVCenter
        }

        Row {
            id: dots
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: root.dotGap

            readonly property real clamped: Math.max(0, Math.min(1, root.progress))

            Repeater {
                model: root.dotCount
                Rectangle {
                    id: dot
                    required property int index
                    width: root.dotSize
                    height: root.dotSize
                    radius: width / 2
                    readonly property bool active: (index + 1) / root.dotCount <= dots.clamped + 0.001
                    color: active ? root.fillColor : root.trackColor
                    scale: active ? 1.0 : 0.78
                    Behavior on color { ColorAnimation { duration: M3Easing.effectsDuration; easing.type: Easing.OutCubic } }
                    Behavior on scale { NumberAnimation { duration: M3Easing.durationShort3; easing.type: Easing.OutCubic } }
                }
            }
        }

        StyledText {
            Layout.alignment: Qt.AlignVCenter
            variant: StyledText.Variant.Numeric
            text: Math.round(Math.max(0, Math.min(1, root.progress)) * 100)
            horizontalAlignment: Text.AlignRight
            Layout.preferredWidth: 28
        }
    }
}

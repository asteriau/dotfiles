import QtQuick
import QtQuick.Layouts
import qs.components.controls
import qs.components.text
import qs.utils

Rectangle {
    id: root

    property string icon: ""
    property string text: ""
    property real from: 0
    property real to: 100
    property real value: 0
    property real stepSize: 1
    property string suffix: ""
    property int    decimals: 0
    property list<real> stopIndicators: [1]

    signal moved(real newValue)

    function flash() { flashAnim.restart(); }

    Layout.fillWidth: true
    implicitHeight: Math.max(56, row.implicitHeight + 16)
    color: Appearance.colors.transparent
    radius: 0

    Rectangle {
        id: flashRect
        anchors.fill: parent
        color: Appearance.colors.accent
        opacity: 0
        SequentialAnimation {
            id: flashAnim
            NumberAnimation { target: flashRect; property: "opacity"; from: 0; to: 0.22; duration: 180; easing.type: Easing.OutCubic }
            PauseAnimation  { duration: 280 }
            NumberAnimation { target: flashRect; property: "opacity"; to: 0; duration: 520; easing.type: Easing.OutCubic }
        }
    }

    RowLayout {
        id: row
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        anchors.topMargin: 8
        anchors.bottomMargin: 8
        spacing: Config.layout.gapLg

        Rectangle {
            Layout.preferredWidth: 36
            Layout.preferredHeight: 36
            Layout.alignment: Qt.AlignVCenter
            radius: 18
            color: Appearance.colors.secondaryContainer
            opacity: root.icon.length > 0 ? 1 : 0

            MaterialIcon {
                anchors.centerIn: parent
                text: root.icon
                font.pointSize: Config.typography.large
                color: Appearance.colors.m3onSecondaryContainer
            }
        }

        StyledText {
            visible: root.text.length > 0
            text: root.text
            color: Appearance.colors.foreground
            font.pixelSize: Config.typography.small
            font.weight: Font.Medium
            Layout.preferredWidth: 120
            elide: Text.ElideRight
        }

        StyledSlider {
            id: slider
            Layout.fillWidth: true
            from: root.from
            to: root.to
            stepSize: root.stepSize
            value: root.value
            configuration: StyledSlider.Configuration.S
            stopIndicatorValues: root.stopIndicators

            onMoved: {
                root.value = value;
                root.moved(value);
            }
        }

        StyledText {
            text: (root.decimals > 0 ? root.value.toFixed(root.decimals)
                                     : String(Math.round(root.value))) + root.suffix
            color: Appearance.colors.m3onSurfaceVariant
            font.pixelSize: Config.typography.smallie
            font.weight: Font.Medium
            Layout.preferredWidth: 48
            horizontalAlignment: Text.AlignRight
        }
    }
}

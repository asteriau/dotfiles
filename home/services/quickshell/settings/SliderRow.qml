import QtQuick
import QtQuick.Layouts
import qs.utils
import qs.components

RowLayout {
    id: root
    Layout.fillWidth: true
    spacing: 12

    property string icon: ""
    property string text: ""
    property real from: 0
    property real to: 100
    property real value: 0
    property real stepSize: 1
    property string suffix: ""

    signal moved(real newValue)

    MaterialIcon {
        visible: root.icon.length > 0
        text: root.icon
        font.pointSize: Config.typography.huge
        color: Colors.m3onSurfaceVariant
        Layout.preferredWidth: 24
        horizontalAlignment: Text.AlignHCenter
    }

    Text {
        visible: root.text.length > 0
        text: root.text
        color: Colors.foreground
        font.family: Config.typography.family
        font.pixelSize: Config.typography.small
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

        onMoved: {
            root.value = value;
            root.moved(value);
        }
    }

    Text {
        text: Math.round(root.value) + root.suffix
        color: Colors.m3onSurfaceVariant
        font.family: Config.typography.family
        font.pixelSize: Config.typography.smallie
        font.weight: Font.Medium
        Layout.preferredWidth: 48
        horizontalAlignment: Text.AlignRight
    }
}

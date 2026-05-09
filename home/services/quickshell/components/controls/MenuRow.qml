import QtQuick
import QtQuick.Layouts
import qs.components.text
import qs.utils

// One-line / two-line list row for sidebar context menus. Leading material
// icon, primary text (+ optional secondary), trailing slot (chevron / status
// glyph / mini-button).
Item {
    id: root

    property string iconName: ""
    property color  iconColor: Colors.m3onSurface
    property int    iconSize: 20
    property string primaryText: ""
    property string secondaryText: ""
    property bool   active: false
    property bool   expanded: false
    property Component trailing: null

    signal clicked()
    signal rightClicked()

    Layout.fillWidth: true
    implicitHeight: secondaryText.length > 0 ? 56 : 48

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: Config.layout.radiusSm
        color: ma.pressed ? Colors.colLayer2Active
            : ma.containsMouse ? Colors.colLayer2Hover
            : "transparent"
        Behavior on color { Motion.ColorFade {} }
    }

    RowLayout {
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            leftMargin: Config.layout.gapMd
            rightMargin: Config.layout.gapMd
        }
        spacing: Config.layout.gapMd

        Text {
            visible: root.iconName.length > 0
            text: root.iconName
            color: root.iconColor
            font.family: Config.typography.iconFamily
            font.pixelSize: root.iconSize
            Layout.preferredWidth: root.iconSize
            Behavior on color { Motion.ColorFade {} }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            StyledText {
                Layout.fillWidth: true
                variant: StyledText.Variant.BodySm
                text: root.primaryText
                color: Colors.m3onSurface
                font.weight: root.active ? Config.typography.weightMedium : Config.typography.weightNormal
                elide: Text.ElideRight
            }

            StyledText {
                Layout.fillWidth: true
                visible: root.secondaryText.length > 0
                variant: StyledText.Variant.Caption
                text: root.secondaryText
                color: Colors.m3onSurfaceVariant
                elide: Text.ElideRight
            }
        }

        Loader {
            active: root.trailing !== null
            sourceComponent: root.trailing
        }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: (mouse) => {
            if (mouse.button === Qt.RightButton) root.rightClicked();
            else root.clicked();
        }
    }
}

import QtQuick
import QtQuick.Layouts
import qs.utils

// Floating dialog with scrim. Card slides + scales + fades in to match
// the island's M3 emphasized show/hide motion. Children added via the
// default property go inside the card's ColumnLayout (16px spacing,
// padding = card radius).
Rectangle {
    id: root

    property bool show: false
    property real backgroundWidth: 350
    property real backgroundHeight: 540
    property real movement: 60

    signal dismiss

    default property alias contentData: contentColumn.data

    color: root.show ? Qt.rgba(0, 0, 0, 0.25) : Qt.rgba(0, 0, 0, 0)
    Behavior on color {
        ColorAnimation {
            duration: M3Easing.durationMedium3
            easing.type: Easing.BezierSpline
            easing.bezierCurve: M3Easing.emphasized
        }
    }
    visible: card.opacity > 0.001 || root.show
    radius: Config.layout.cardRadius
    clip: true

    // Outside-click dismiss.
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        hoverEnabled: true
        onPressed: root.dismiss()
        cursorShape: Qt.ArrowCursor
    }

    Rectangle {
        id: card
        anchors.horizontalCenter: parent.horizontalCenter
        radius: Config.layout.radiusLg
        color: Colors.surfaceContainerHigh

        readonly property real _cappedH: Math.min(root.backgroundHeight, root.height - Config.layout.gapLg * 2)
        y: (root.height - _cappedH) / 2

        implicitWidth: Math.min(root.backgroundWidth, root.width - Config.layout.gapMd * 2)
        implicitHeight: _cappedH

        opacity: root.show ? 1 : 0
        Behavior on opacity {
            NumberAnimation {
                duration: M3Easing.durationMedium3
                easing.type: Easing.BezierSpline
                easing.bezierCurve: M3Easing.emphasized
            }
        }

        transform: [
            Scale {
                origin.x: card.width / 2
                origin.y: 0
                xScale: root.show ? 1 : 0.92
                yScale: root.show ? 1 : 0.92
                Behavior on xScale {
                    NumberAnimation {
                        duration: M3Easing.durationLong1
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: M3Easing.emphasized
                    }
                }
                Behavior on yScale {
                    NumberAnimation {
                        duration: M3Easing.durationLong1
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: M3Easing.emphasized
                    }
                }
            },
            Translate {
                y: root.show ? 0 : -root.movement
                Behavior on y {
                    NumberAnimation {
                        duration: M3Easing.durationLong1
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: M3Easing.emphasized
                    }
                }
            }
        ]

        // Eat clicks inside the card so the scrim MouseArea below
        // doesn't dismiss when the user interacts with rows.
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            hoverEnabled: true
        }

        ColumnLayout {
            id: contentColumn
            anchors.fill: parent
            anchors.margins: card.radius
            spacing: 16
        }
    }
}

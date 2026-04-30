import QtQuick
import qs.components.text
import qs.sidebar
import qs.utils
import qs.utils.state

MouseArea {
    id: root

    visible: WeatherState.ready
    hoverEnabled: true
    acceptedButtons: Qt.NoButton

    implicitWidth:  row.implicitWidth
    implicitHeight: row.implicitHeight

    Row {
        id: row
        spacing: 4
        anchors.verticalCenter: parent.verticalCenter

        MaterialIcon {
            text: WeatherState.glyph
            pixelSize: Config.typography.normal
            color: Colors.foreground
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: Math.round(WeatherState.temp) + "°"
            font.family: Config.fontFamily
            font.pixelSize: Config.typography.small
            color: Colors.foreground
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    BarPopup {
        targetItem: root
        active: root.containsMouse
        transparent: true

        Item {
            implicitWidth:  380
            implicitHeight: 200

            WeatherWidget {
                anchors.fill: parent
            }
        }
    }
}

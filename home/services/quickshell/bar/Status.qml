import QtQuick
import QtQuick.Layouts
import qs.utils

Rectangle {
    id: root

    implicitWidth: 40
    implicitHeight: col.implicitHeight + 20

    radius: 8
    color: Colors.elevated

    ColumnLayout {
        id: col
        anchors.centerIn: parent
        spacing: 12

        Network {
            Layout.alignment: Qt.AlignHCenter
        }

        Bluetooth {
            Layout.alignment: Qt.AlignHCenter
        }
    }
}

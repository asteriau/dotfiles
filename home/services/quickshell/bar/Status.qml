import QtQuick
import QtQuick.Layouts
import qs.utils

Rectangle {
    id: root

    property bool hasContent: (net.visible ?? false) || (bt.visible ?? false)

    visible: hasContent
    implicitWidth: 38
    implicitHeight: hasContent ? col.implicitHeight + 22 : 0

    radius: 8
    color: Colors.elevated

    ColumnLayout {
        id: col
        anchors.centerIn: parent
        spacing: 10

        Network {
            id: net
            Layout.alignment: Qt.AlignHCenter
        }

        Bluetooth {
            id: bt
            Layout.alignment: Qt.AlignHCenter
        }
    }
}

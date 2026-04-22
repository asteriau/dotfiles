import QtQuick
import qs.utils

Rectangle {
    property bool vertical: false
    implicitWidth:  vertical ? 1 : 16
    implicitHeight: vertical ? 12 : 1
    color: Colors.divider
}

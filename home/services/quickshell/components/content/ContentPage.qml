import QtQuick
import QtQuick.Layouts
import qs.utils

Flickable {
    id: root

    property real baseWidth: Config.layout.contentMaxWidth
    property bool forceWidth: true
    property real bottomContentPadding: 80

    default property alias content: contentColumn.data

    clip: true
    contentHeight: contentColumn.implicitHeight + root.bottomContentPadding
    boundsBehavior: Flickable.StopAtBounds

    ColumnLayout {
        id: contentColumn
        width: root.forceWidth ? root.baseWidth
                               : Math.max(root.baseWidth, implicitWidth)
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: Config.layout.pageMargin
        spacing: Config.layout.sectionGap
    }
}

import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models

Flickable {
    id: root

    property real baseWidth: Appearance.layout.contentMaxWidth
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
        anchors.margins: Appearance.layout.pageMargin
        spacing: Appearance.layout.sectionGap
    }
}

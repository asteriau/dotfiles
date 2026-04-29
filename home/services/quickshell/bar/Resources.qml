import QtQuick
import QtQuick.Layouts
import qs.components.controls
import qs.components.text
import qs.utils
import qs.utils.state

MouseArea {
    id: root

    readonly property real warnAt: 0.8
    readonly property bool vertical: Config.bar.vertical
    readonly property bool musicPlaying: MprisState.player !== null

    // Horizontal mode mirrors ii's adaptive bar: CPU and swap collapse out
    // when a media player is active so the row stays compact next to it.
    readonly property bool showSwap: vertical
        ? ResourcesState.swapTotal > 0
        : (!musicPlaying && ResourcesState.swapTotal > 0)
    readonly property bool showCpu: true  // Always show CPU, matching ii

    hoverEnabled: true
    acceptedButtons: Qt.NoButton

    implicitWidth:  vertical ? vCol.implicitWidth : hRow.implicitWidth
    implicitHeight: vertical ? vCol.implicitHeight : Config.bar.height

    component VResource: CircularProgress {
        id: vr
        property string icon
        property real percent: 0
        value: percent
        color: percent >= root.warnAt ? Colors.red : Colors.m3onSecondaryContainer

        Item {
            anchors.centerIn: parent
            width: vr.implicitSize
            height: vr.implicitSize
            MaterialIcon {
                anchors.centerIn: parent
                text: vr.icon
                fill: 1
                pixelSize: 13
                weight: Font.DemiBold
                color: Colors.m3onSecondaryContainer
            }
        }
    }

    component HResource: RowLayout {
        id: hr
        property string icon
        property real percent: 0
        property bool active: true
        spacing: 2
        visible: active

        CircularProgress {
            id: hCirc
            Layout.alignment: Qt.AlignVCenter
            value: hr.percent
            color: hr.percent >= root.warnAt ? Colors.red : Colors.m3onSecondaryContainer

            Item {
                anchors.centerIn: parent
                width: hCirc.implicitSize
                height: hCirc.implicitSize
                MaterialIcon {
                    anchors.centerIn: parent
                    text: hr.icon
                    fill: 1
                    pixelSize: Config.typography.normal
                    weight: Font.DemiBold
                    color: Colors.m3onSecondaryContainer
                }
            }
        }

        Item {
            Layout.alignment: Qt.AlignVCenter
            implicitWidth: pctMetrics.width
            implicitHeight: pctText.implicitHeight
            TextMetrics {
                id: pctMetrics
                text: "100"
                font.family: Config.fontFamily
                font.pixelSize: Config.typography.small
            }
            Text {
                id: pctText
                anchors.centerIn: parent
                text: `${Math.round(hr.percent * 100)}`
                font.family: Config.fontFamily
                font.pixelSize: Config.typography.small
                color: Colors.foreground
            }
        }
    }

    Column {
        id: vCol
        visible: root.vertical
        spacing: 10
        anchors.horizontalCenter: parent.horizontalCenter

        VResource {
            anchors.horizontalCenter: parent.horizontalCenter
            icon: "memory"
            percent: ResourcesState.memoryUsedPercentage
        }
        VResource {
            anchors.horizontalCenter: parent.horizontalCenter
            visible: ResourcesState.swapTotal > 0
            icon: "swap_horiz"
            percent: ResourcesState.swapUsedPercentage
        }
        VResource {
            anchors.horizontalCenter: parent.horizontalCenter
            icon: "planner_review"
            percent: ResourcesState.cpuUsage
        }
    }

    RowLayout {
        id: hRow
        visible: !root.vertical
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6

        HResource {
            icon: "memory"
            percent: ResourcesState.memoryUsedPercentage
        }
        HResource {
            icon: "swap_horiz"
            percent: ResourcesState.swapUsedPercentage
            active: root.showSwap
        }
        HResource {
            icon: "planner_review"
            percent: ResourcesState.cpuUsage
            active: root.showCpu
        }
    }

    BarPopup {
        targetItem: root
        active: root.containsMouse

        Row {
            spacing: 12

            Column {
                anchors.top: parent.top
                spacing: 8
                BarPopupHeaderRow { icon: "memory"; label: "RAM" }
                Column {
                    spacing: 4
                    BarPopupValueRow { icon: "clock_loader_60"; label: "Used:";  value: ResourcesState.memUsedStr }
                    BarPopupValueRow { icon: "check_circle";    label: "Free:";  value: ResourcesState.memFreeStr }
                    BarPopupValueRow { icon: "empty_dashboard"; label: "Total:"; value: ResourcesState.memTotalStr }
                }
            }

            Column {
                visible: ResourcesState.swapTotal > 0
                anchors.top: parent.top
                spacing: 8
                BarPopupHeaderRow { icon: "swap_horiz"; label: "Swap" }
                Column {
                    spacing: 4
                    BarPopupValueRow { icon: "clock_loader_60"; label: "Used:";  value: ResourcesState.swapUsedStr }
                    BarPopupValueRow { icon: "check_circle";    label: "Free:";  value: ResourcesState.swapFreeStr }
                    BarPopupValueRow { icon: "empty_dashboard"; label: "Total:"; value: ResourcesState.swapTotalStr }
                }
            }

            Column {
                anchors.top: parent.top
                spacing: 8
                BarPopupHeaderRow { icon: "planner_review"; label: "CPU" }
                Column {
                    spacing: 4
                    BarPopupValueRow { icon: "bolt"; label: "Load:"; value: `${Math.round(ResourcesState.cpuUsage * 100)}%` }
                }
            }
        }
    }
}

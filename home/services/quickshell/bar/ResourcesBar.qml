import QtQuick
import QtQuick.Layouts
import qs.components.controls
import qs.components.effects
import qs.components.surfaces
import qs.components.text
import qs.utils
import qs.utils.state

PressablePill {
    id: root

    implicitWidth:  Config.bar.width - Config.layout.gapSm * 2
    implicitHeight: col.implicitHeight + 8

    radius: Config.layout.radiusContainer
    colorIdle: Colors.transparent
    useStateLayer: true
    pressScale: 0.98

    onClicked: popup.active = !popup.active

    Column {
        id: col
        anchors.centerIn: parent
        spacing: 6

        CircularProgress {
            implicitSize: 20
            lineWidth: 2
            value: ResourcesState.memoryUsedPercentage
            color: Colors.m3onSecondaryContainer
            enableAnimation: true

            Item {
                anchors.centerIn: parent
                width: 20; height: 20
                MaterialIcon {
                    anchors.centerIn: parent
                    text: "memory"
                    pixelSize: Config.typography.normal
                    color: Colors.m3onSecondaryContainer
                }
            }
        }

        CircularProgress {
            implicitSize: 20
            lineWidth: 2
            visible: ResourcesState.swapTotal > 0
            value: ResourcesState.swapUsedPercentage
            color: Colors.m3onSecondaryContainer
            enableAnimation: true

            Item {
                anchors.centerIn: parent
                width: 20; height: 20
                MaterialIcon {
                    anchors.centerIn: parent
                    text: "swap_horiz"
                    pixelSize: Config.typography.normal
                    color: Colors.m3onSecondaryContainer
                }
            }
        }

        CircularProgress {
            implicitSize: 20
            lineWidth: 2
            value: ResourcesState.cpuUsage
            color: Colors.m3onSecondaryContainer
            enableAnimation: true

            Item {
                anchors.centerIn: parent
                width: 20; height: 20
                MaterialIcon {
                    anchors.centerIn: parent
                    text: "planner_review"
                    pixelSize: Config.typography.normal
                    color: Colors.m3onSecondaryContainer
                }
            }
        }
    }

    BarPopup {
        id: popup
        targetItem: root
        padding: 16

        Column {
            width: 280
            spacing: 12

            StyledText {
                text: "Resources"
                font.pixelSize: Config.typography.large
                font.weight: Font.Medium
                color: Colors.accent
            }

            Column {
                width: parent.width
                spacing: 4

                BigSmallTextPair {
                    width: parent.width
                    icon: "memory"
                    bigText: (ResourcesState.memUsedStr || "0").split(" ")[0]
                    smallText: "/ " + (ResourcesState.memTotalStr || "0")
                    label: "Memory"
                }

                StyledCombinedProgressBar {
                    width: parent.width
                    valueWeights: [ResourcesState.memoryTotal, ResourcesState.swapTotal]
                    values: [ResourcesState.memoryUsedPercentage, ResourcesState.swapUsedPercentage]
                }
            }

            Column {
                width: parent.width
                spacing: 4

                BigSmallTextPair {
                    width: parent.width
                    icon: "developer_board"
                    bigText: Math.round(ResourcesState.cpuUsage * 100)
                    smallText: "%"
                    label: "CPU"
                }

                StyledCombinedProgressBar {
                    width: parent.width
                    property bool useSingleAggregate: ResourcesState.cpuCoreUsages.length > 8
                    valueWeights: useSingleAggregate ? [1.0] : (ResourcesState.cpuCoreWeights.length > 0 ? ResourcesState.cpuCoreWeights : [1.0])
                    values: useSingleAggregate ? [ResourcesState.cpuUsage] : (ResourcesState.cpuCoreUsages.length > 0 ? ResourcesState.cpuCoreUsages : [ResourcesState.cpuUsage])
                }
            }
        }
    }

    component BigSmallTextPair: RowLayout {
        id: txtPair
        property string icon: ""
        property string bigText: ""
        property string smallText: ""
        property string label: ""
        spacing: 8

        MaterialIcon {
            Layout.alignment: Qt.AlignVCenter
            text: txtPair.icon
            pixelSize: 22
            color: Colors.foreground
        }

        StyledText {
            id: bigTxt
            Layout.alignment: Qt.AlignBaseline
            font.pixelSize: Config.typography.larger
            font.weight: Font.Medium
            text: txtPair.bigText
            color: Colors.foreground
        }

        StyledText {
            id: smallTxt
            Layout.alignment: Qt.AlignBaseline
            font.pixelSize: Config.typography.small
            text: txtPair.smallText
            color: Colors.m3onSurfaceInactive
        }

        Item { Layout.fillWidth: true }

        StyledText {
            Layout.alignment: Qt.AlignBaseline
            text: txtPair.label
            font.pixelSize: Config.typography.small
            color: Colors.m3onSurfaceInactive
        }
    }
}

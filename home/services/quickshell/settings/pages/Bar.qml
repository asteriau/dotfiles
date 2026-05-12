import QtQuick
import QtQuick.Layouts
import qs.components.content
import qs.components.controls
import qs.components.text
import qs.settings
import qs.utils

ContentPage {
    ContentSection {
        title: "Position"

        Rectangle {
            objectName: "bar-position"
            Layout.fillWidth: true
            implicitHeight: 56
            color: Appearance.colors.transparent

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                anchors.topMargin: 8
                anchors.bottomMargin: 8
                spacing: 14

                Rectangle {
                    Layout.preferredWidth: 36
                    Layout.preferredHeight: 36
                    Layout.alignment: Qt.AlignVCenter
                    radius: 18
                    color: Appearance.colors.colLayer2

                    MaterialIcon {
                        anchors.centerIn: parent
                        text: "dock_to_left"
                        font.pointSize: Config.typography.large
                        color: Appearance.colors.m3onSurfaceVariant
                    }
                }

                StyledText {
                    Layout.fillWidth: true
                    text: "Position"
                    color: Appearance.colors.foreground
                    font.pixelSize: Config.typography.small
                    font.weight: Font.Medium
                }

                Row {
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 2

                    component PosBtn: Rectangle {
                        required property string value
                        required property string icon
                        property bool isFirst: false
                        property bool isLast: false
                        readonly property bool active: Config.bar.position === value
                        width: 40
                        height: 36
                        topLeftRadius: isFirst ? 18 : 6
                        bottomLeftRadius: isFirst ? 18 : 6
                        topRightRadius: isLast ? 18 : 6
                        bottomRightRadius: isLast ? 18 : 6
                        color: active
                            ? Appearance.colors.primaryContainer
                            : (ma.containsMouse ? Appearance.colors.colLayer4 : Appearance.colors.colLayer3)
                        Behavior on color { ColorAnimation { duration: Appearance.motion.duration.effects } }

                        MaterialIcon {
                            anchors.centerIn: parent
                            text: parent.icon
                            font.pointSize: Config.typography.normal
                            fill: parent.active ? 1 : 0
                            color: parent.active ? Appearance.colors.m3onPrimaryContainer : Appearance.colors.m3onSurfaceVariant
                            Behavior on color { ColorAnimation { duration: Appearance.motion.duration.effects } }
                        }

                        MouseArea {
                            id: ma
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Config.bar.position = parent.value
                        }
                    }

                    PosBtn { value: "left";   icon: "arrow_back";     isFirst: true }
                    PosBtn { value: "top";    icon: "arrow_upward" }
                    PosBtn { value: "bottom"; icon: "arrow_downward" }
                    PosBtn { value: "right";  icon: "arrow_forward";  isLast: true }
                }
            }
        }
    }

    ContentSection {
        title: "Appearance"

        SwitchRow {
            objectName: "bar-rounding"
            text: "Rounding"
            icon: "rounded_corner"
            checked: Config.bar.rounding
            onToggled: v => Config.bar.rounding = v
        }
    }

    ContentSection {
        title: "Dimensions"

        ContentSubsection {
            title: "Sidebar width"

            SliderRow {
                objectName: "bar-sidebarWidth"
                icon: "view_sidebar"
                from: 300; to: 600; value: Config.sidebar.width; stepSize: 10
                suffix: "px"
                onMoved: v => Config.sidebar.width = v
            }
        }
    }

    ContentSection {
        title: "Workspaces"

        ContentSubsection {
            title: "Workspaces shown"

            SliderRow {
                objectName: "bar-wsShown"
                icon: "grid_4x4"
                from: 4; to: 20; value: Config.workspaces.shown; stepSize: 1
                onMoved: v => Config.workspaces.shown = v
            }
        }

        SwitchRow {
            objectName: "bar-wsAppIcons"
            text: "Show app icons"
            icon: "apps"
            checked: Config.workspaces.showAppIcons
            onToggled: v => Config.workspaces.showAppIcons = v
        }

        SwitchRow {
            objectName: "bar-wsNumbers"
            text: "Always show numbers"
            icon: "format_list_numbered"
            checked: Config.workspaces.alwaysShowNumbers
            onToggled: v => Config.workspaces.alwaysShowNumbers = v
        }

        SwitchRow {
            objectName: "bar-wsMonochrome"
            text: "Monochrome icons"
            icon: "filter_b_and_w"
            checked: Config.workspaces.monochromeIcons
            onToggled: v => Config.workspaces.monochromeIcons = v
        }

        SwitchRow {
            objectName: "bar-wsTinted"
            text: "Tinted icons"
            icon: "colorize"
            checked: Config.workspaces.tintedIcons
            onToggled: v => Config.workspaces.tintedIcons = v
        }
    }
}

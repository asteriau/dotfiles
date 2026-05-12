pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.components.controls
import qs.components.text
import qs.utils

RippleButton {
    id: root
    required property QsMenuEntry menuEntry
    property bool forceIconColumn: false
    property bool forceSpecialInteractionColumn: false
    readonly property bool hasIcon: menuEntry.icon.length > 0
    readonly property bool hasSpecialInteraction: menuEntry.buttonType !== QsMenuButtonType.None

    horizontalPadding: 12

    signal dismiss
    signal openSubmenu(handle: QsMenuHandle)

    colBackground: ColorUtils.transparentize(Appearance.colors.surfaceContainerHigh, 1)
    colBackgroundHover: Appearance.colors.surfaceContainerHigh
    enabled: !menuEntry.isSeparator
    visible: !menuEntry.isSeparator

    implicitWidth: contentRow.implicitWidth + horizontalPadding * 2
    implicitHeight: visible ? 36 : 0
    Layout.fillWidth: true

    releaseAction: () => {
        if (menuEntry.hasChildren) {
            root.openSubmenu(root.menuEntry);
            return;
        }
        menuEntry.triggered();
        root.dismiss();
    }
    altAction: event => {
        event.accepted = false;
    }

    contentItem: RowLayout {
        id: contentRow
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            right: parent.right
            leftMargin: root.horizontalPadding
            rightMargin: root.horizontalPadding
        }
        spacing: 8
        visible: !root.menuEntry.isSeparator

        Item {
            visible: root.hasSpecialInteraction || root.forceSpecialInteractionColumn
            implicitWidth: 20
            implicitHeight: 20

            Loader {
                anchors.centerIn: parent
                active: root.menuEntry.buttonType === QsMenuButtonType.RadioButton

                sourceComponent: Rectangle {
                    implicitWidth: 16
                    implicitHeight: 16
                    radius: 8
                    color: "transparent"
                    border.width: 2
                    border.color: root.menuEntry.checkState === Qt.Checked ? Appearance.colors.accent : Appearance.colors.m3onSurfaceVariant

                    Rectangle {
                        anchors.centerIn: parent
                        implicitWidth: 8
                        implicitHeight: 8
                        radius: 4
                        color: Appearance.colors.accent
                        visible: root.menuEntry.checkState === Qt.Checked
                    }
                }
            }

            Loader {
                anchors.fill: parent
                active: root.menuEntry.buttonType === QsMenuButtonType.CheckBox && root.menuEntry.checkState !== Qt.Unchecked

                sourceComponent: MaterialIcon {
                    text: root.menuEntry.checkState === Qt.PartiallyChecked ? "check_indeterminate_small" : "check"
                    pixelSize: 20
                    color: Appearance.colors.foreground
                }
            }
        }

        Item {
            visible: root.hasIcon || root.forceIconColumn
            implicitWidth: 20
            implicitHeight: 20

            Loader {
                anchors.centerIn: parent
                active: root.menuEntry.icon.length > 0
                sourceComponent: IconImage {
                    asynchronous: true
                    source: root.menuEntry.icon
                    implicitSize: 20
                    mipmap: true
                }
            }
        }

        Text {
            id: label
            text: root.menuEntry.text
            font.family: Config.fontFamily
            font.pixelSize: Config.typography.smallie
            color: Appearance.colors.foreground
            verticalAlignment: Text.AlignVCenter
            Layout.fillWidth: true
        }

        Loader {
            active: root.menuEntry.hasChildren

            sourceComponent: MaterialIcon {
                text: "chevron_right"
                pixelSize: 20
                color: Appearance.colors.m3onSurfaceVariant
            }
        }
    }
}

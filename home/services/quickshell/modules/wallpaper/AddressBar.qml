import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

Rectangle {
    id: root

    required property string currentDir
    required property var pathSegments
    property bool showBreadcrumb: true

    signal navigateUp()
    signal navigate(string path)

    function focusEditor(): void {
        pathInput.text = root.currentDir;
        pathInput.forceActiveFocus();
        pathInput.selectAll();
    }

    Layout.fillWidth: true
    Layout.margins: Appearance.layout.gapSm
    Layout.preferredHeight: 44
    radius: height / 2
    color: Appearance.colors.surfaceContainer

    onCurrentDirChanged: pathInput.text = currentDir

    RowLayout {
        anchors.fill: parent
        anchors.margins: 6
        spacing: Appearance.layout.gapMd

        RippleButton {
            Layout.alignment: Qt.AlignVCenter
            implicitWidth: 32
            implicitHeight: 32
            buttonRadius: height / 2
            enabled: root.currentDir.length > 0 && root.currentDir !== "/"
            onClicked: root.navigateUp()
            contentItem: MaterialIcon {
                text: "drive_folder_upload"
                pixelSize: Appearance.typography.larger
                color: Appearance.colors.foreground
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Rectangle {
                visible: !root.showBreadcrumb
                anchors.fill: parent
                radius: height / 2
                color: Appearance.colors.surfaceContainerLow

                TextInput {
                    id: pathInput
                    anchors.fill: parent
                    anchors.leftMargin: Appearance.layout.gapLg
                    anchors.rightMargin: Appearance.layout.gapLg
                    verticalAlignment: TextInput.AlignVCenter
                    text: root.currentDir
                    color: Appearance.colors.foreground
                    selectionColor: Qt.rgba(Appearance.colors.accent.r, Appearance.colors.accent.g, Appearance.colors.accent.b, 0.4)
                    font.pixelSize: Appearance.typography.smallie
                    font.family: Config.typography.family
                    clip: true
                    selectByMouse: true

                    Keys.onReturnPressed: {
                        root.navigate(text);
                        root.showBreadcrumb = true;
                    }
                    Keys.onEscapePressed: {
                        text = root.currentDir;
                        root.showBreadcrumb = true;
                    }

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.NoButton
                        cursorShape: Qt.IBeamCursor
                    }
                }
            }

            ListView {
                id: breadcrumb
                visible: root.showBreadcrumb
                anchors.fill: parent
                orientation: ListView.Horizontal
                clip: true
                spacing: Appearance.layout.gapXs
                interactive: false
                model: root.pathSegments

                onCountChanged: positionViewAtEnd()
                Component.onCompleted: positionViewAtEnd()

                delegate: Rectangle {
                    id: seg
                    required property var modelData
                    required property int index

                    readonly property bool leftmost:  index === 0
                    readonly property bool rightmost: index === root.pathSegments.length - 1
                    readonly property bool isCurrent: rightmost
                    readonly property int  bigR:   height / 2
                    readonly property int  smallR: 4

                    width: Math.max(28, segText.implicitWidth + 20)
                    height: breadcrumb.height

                    color: isCurrent
                        ? Appearance.colors.secondaryContainer
                        : (segMa.containsMouse ? Appearance.colors.colLayer2Hover : "transparent")
                    Behavior on color { ColorAnimation { duration: Appearance.motion.duration.effects } }

                    topLeftRadius:     leftmost  ? bigR : (isCurrent ? bigR : smallR)
                    bottomLeftRadius:  leftmost  ? bigR : (isCurrent ? bigR : smallR)
                    topRightRadius:    rightmost ? bigR : (isCurrent ? bigR : smallR)
                    bottomRightRadius: rightmost ? bigR : (isCurrent ? bigR : smallR)

                    StyledText {
                        id: segText
                        anchors.centerIn: parent
                        text: seg.modelData.label
                        font.pixelSize: Appearance.typography.smaller
                        color: seg.isCurrent
                            ? Appearance.colors.m3onSecondaryContainer
                            : Appearance.colors.m3onSurfaceVariant
                    }

                    MouseArea {
                        id: segMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.navigate(seg.modelData.path)
                    }
                }
            }
        }

        RippleButton {
            Layout.alignment: Qt.AlignVCenter
            implicitWidth: 32
            implicitHeight: 32
            buttonRadius: height / 2
            toggled: !root.showBreadcrumb
            colBackgroundToggled: Appearance.colors.accent
            colRippleToggled: Appearance.colors.accentHover
            onClicked: {
                root.showBreadcrumb = !root.showBreadcrumb;
                if (!root.showBreadcrumb)
                    root.focusEditor();
            }
            contentItem: MaterialIcon {
                text: "edit"
                pixelSize: Appearance.typography.larger
                color: !root.showBreadcrumb ? Appearance.colors.m3onPrimary : Appearance.colors.foreground
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }
}

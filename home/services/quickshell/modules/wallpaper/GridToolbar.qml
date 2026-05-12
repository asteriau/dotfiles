import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

RowLayout {
    id: root

    property string searchQuery: ""
    property bool useDarkMode: false
    required property var entries

    signal searchEdited(string text)
    signal darkModeToggled(bool dark)
    signal closed()
    signal randomSelected(string path)

    function focusSearch(): void {
        searchField.forceActiveFocus();
    }

    function setSearchText(text: string): void {
        searchField.text = text;
        searchField.cursorPosition = searchField.text.length;
    }

    spacing: 6

    Rectangle {
        Layout.preferredHeight: 44
        implicitWidth: toolbarRow.implicitWidth + Appearance.layout.gapLg
        radius: height / 2
        color: Appearance.colors.surfaceContainer
        border.width: 1
        border.color: Appearance.colors.cardBorder

        RowLayout {
            id: toolbarRow
            anchors.fill: parent
            anchors.leftMargin: 6
            anchors.rightMargin: 6
            spacing: Appearance.layout.gapSm

            RippleButton {
                Layout.alignment: Qt.AlignVCenter
                implicitWidth: 36
                implicitHeight: 36
                buttonRadius: height / 2
                enabled: root.entries.length > 0
                onClicked: {
                    const images = root.entries.filter(e => !e.fileIsDir && /\.(jpg|jpeg|png|webp|bmp|gif|avif|tiff|svg|jxl)$/i.test(e.fileName));
                    if (images.length === 0) return;
                    const pick = images[Math.floor(Math.random() * images.length)];
                    root.randomSelected(pick.filePath);
                }
                contentItem: MaterialIcon {
                    text: "shuffle"
                    pixelSize: Appearance.typography.larger
                    color: Appearance.colors.foreground
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            RippleButton {
                Layout.alignment: Qt.AlignVCenter
                implicitWidth: 36
                implicitHeight: 36
                buttonRadius: height / 2
                onClicked: root.darkModeToggled(!root.useDarkMode)
                contentItem: MaterialIcon {
                    text: root.useDarkMode ? "dark_mode" : "light_mode"
                    pixelSize: Appearance.typography.larger
                    color: Appearance.colors.foreground
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            TextField {
                id: searchField
                Layout.preferredWidth: 200
                Layout.alignment: Qt.AlignVCenter
                placeholderText: activeFocus ? "Search wallpapers" : "Hit \"/\" to search"
                color: Appearance.colors.foreground
                placeholderTextColor: Appearance.colors.m3onSurfaceInactive
                selectionColor: Qt.rgba(Appearance.colors.accent.r, Appearance.colors.accent.g, Appearance.colors.accent.b, 0.4)
                selectedTextColor: Appearance.colors.foreground
                font.family: Config.typography.family
                font.pixelSize: Appearance.typography.small
                leftPadding: Appearance.layout.gapMd
                rightPadding: Appearance.layout.gapMd
                topPadding: 6
                bottomPadding: 6
                selectByMouse: true
                background: Rectangle { color: "transparent" }

                text: root.searchQuery
                onTextChanged: root.searchEdited(text)
                Keys.onEscapePressed: text = ""
            }
        }
    }

    RippleButton {
        Layout.alignment: Qt.AlignVCenter
        Layout.preferredWidth: 44
        Layout.preferredHeight: 44
        buttonRadius: height / 2
        colBackground: Appearance.colors.accent
        colBackgroundHover: Appearance.colors.accentHover
        colRipple: Appearance.colors.accentPressed
        onClicked: root.closed()
        contentItem: MaterialIcon {
            text: "close"
            pixelSize: Appearance.typography.larger
            color: Appearance.colors.m3onPrimary
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
}

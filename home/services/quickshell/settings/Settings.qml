//@ pragma UseQApplication
import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import qs.components.controls
import qs.utils

Window {
    id: settingsWindow
    visible: true
    width: 1100
    height: 760
    minimumWidth: 760
    minimumHeight: 520
    title: "Settings"
    color: Colors.background

    readonly property string _base: Qt.resolvedUrl(".")
    readonly property real contentPadding: Config.layout.pageMargin / 2

    property int currentPage: 0
    property bool navExpanded: width > 900
    readonly property var pages: [
        { name: "Bar",     icon: "dock_to_left", source: _base + "pages/Bar.qml"     },
        { name: "Theme",   icon: "palette",      source: _base + "pages/Theme.qml"   },
        { name: "General", icon: "tune",         source: _base + "pages/General.qml" },
        { name: "About",   icon: "info",         source: _base + "pages/About.qml"   }
    ]

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: settingsWindow.contentPadding
        spacing: settingsWindow.contentPadding

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: settingsWindow.contentPadding

            // Nav rail
            Item {
                Layout.fillHeight: true
                Layout.margins: 5
                Layout.preferredWidth: settingsWindow.navExpanded
                                        ? Config.layout.navRailExpanded
                                        : Config.layout.navRailCollapsed

                Behavior on Layout.preferredWidth {
                    NumberAnimation {
                        duration: M3Easing.spatialDuration
                        easing.type: Easing.OutCubic
                    }
                }

                NavRail {
                    anchors.fill: parent
                    expanded: settingsWindow.navExpanded
                    currentIndex: settingsWindow.currentPage
                    model: settingsWindow.pages
                    onNavigated: idx => settingsWindow.currentPage = idx
                    onToggleExpanded: settingsWindow.navExpanded = !settingsWindow.navExpanded
                }
            }

            // Content card
            Rectangle {
                id: contentCard
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Colors.elevated
                radius: 24 - settingsWindow.contentPadding
                clip: true

                // Two loaders crossfade between pages; flip `frontIsA` on each change.
                property bool frontIsA: true
                readonly property string currentSource:
                    settingsWindow.pages[settingsWindow.currentPage].source

                onCurrentSourceChanged: {
                    if (!loaderA.item && !loaderB.item) return;
                    const incoming = frontIsA ? loaderB : loaderA;
                    incoming.source = currentSource;
                    frontIsA = !frontIsA;
                }

                Loader {
                    id: loaderA
                    anchors.fill: parent
                    asynchronous: true
                    source: contentCard.currentSource
                    opacity: contentCard.frontIsA ? 1 : 0
                    visible: opacity > 0
                    Behavior on opacity {
                        NumberAnimation {
                            duration: M3Easing.effectsDuration
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                Loader {
                    id: loaderB
                    anchors.fill: parent
                    asynchronous: true
                    opacity: contentCard.frontIsA ? 0 : 1
                    visible: opacity > 0
                    Behavior on opacity {
                        NumberAnimation {
                            duration: M3Easing.effectsDuration
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }
        }
    }
}

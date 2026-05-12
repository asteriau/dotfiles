pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Mpris
import Quickshell.Hyprland
import qs.launcher
import qs.utils
import qs.services


Scope {
    id: scope

    required property var launcher

    // State sources
    readonly property MprisPlayer player: MprisState.player
    readonly property bool mediaActive: player !== null

    readonly property bool launcherOpen: launcher?.open ?? false

    // OSD + battery state owned by extracted child items.
    IslandOsdInputs       { id: osdInputs }
    IslandBatteryWatcher  { id: batteryWatcher }

    readonly property bool peeking: batteryWatcher.peeking

    // Hide entirely when any window on the active workspace is fullscreen
    readonly property HyprlandMonitor _hMonitor: Hyprland.monitorFor(win.screen)
    readonly property int _activeWsId: _hMonitor?.activeWorkspace?.id ?? -1
    readonly property bool fullscreenActive: WorkspaceAppData.windowList.some(w =>
        (w.fullscreen ?? 0) > 0 && (w.workspace?.id ?? -2) === _activeWsId)

    // Resolved priority: launcher > osd > battery > media > home (idle)
    readonly property string mode: {
        if (launcherOpen)             return "launcher";
        if (osdInputs.active)         return "osd";
        if (batteryWatcher.active)    return "battery";
        if (mediaActive)              return "media";
        return "home";
    }

    // Window
    PanelWindow {
        id: win
        screen: UiState.preferredMonitor
        visible: true

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        WlrLayershell.namespace: "quickshell:island"
        WlrLayershell.keyboardFocus: scope.launcherOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
        color: "transparent"
        mask: Region { item: container }

        anchors { top: true }
        margins { top: 0 }

        HyprlandFocusGrab {
            windows: [win]
            active: scope.launcherOpen
            onCleared: scope.launcher?.hide()
        }

        Keys.onPressed: event => {
            if (!scope.launcherOpen) return;
            if (event.key === Qt.Key_Escape) {
                scope.launcher.hide();
                event.accepted = true;
            } else if (event.key === Qt.Key_Down) {
                launcherView.listView.incrementCurrentIndex();
                event.accepted = true;
            } else if (event.key === Qt.Key_Up) {
                launcherView.listView.decrementCurrentIndex();
                event.accepted = true;
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                launcherView.activateCurrent();
                event.accepted = true;
            }
        }

        Shortcut {
            sequences: ["Escape"]
            enabled: scope.launcherOpen
            onActivated: scope.launcher?.hide()
        }

        implicitWidth: Math.max(Appearance.island.maxWidth, Appearance.island.launcherWidth) + 80
        implicitHeight: Math.max(Appearance.island.expandedHeightHome,
                                 Appearance.island.expandedHeightMedia,
                                 Appearance.island.expandedHeightNotif,
                                 Appearance.island.expandedHeightBattery,
                                 Appearance.island.launcherMaxHeight) + 80

        Item {
            id: container
            anchors.horizontalCenter: parent.horizontalCenter
            y: 0
            implicitWidth:  notch.implicitWidth
            implicitHeight: notch.implicitHeight

            readonly property bool mediaPeekVisible:
                pillState._displayMode === "media" && !pillState.expanded

            // Idle = nothing happening. Hide entirely with M3 emphasized
            // expand/collapse animation instead of rendering a "home" pill.
            readonly property bool idleHidden: pillState._displayMode === "home" || scope.fullscreenActive

            opacity: idleHidden ? 0 : 1
            visible: opacity > 0.001

            Behavior on opacity {
                NumberAnimation {
                    duration: Appearance.motion.duration.medium3
                    easing.bezierCurve: Appearance.motion.easing.emphasized
                }
            }

            transform: [
                Scale {
                    id: containerScale
                    origin.x: container.width / 2
                    origin.y: 0
                    xScale: container.idleHidden ? 0.6 : 1
                    yScale: container.idleHidden ? 0.6 : 1
                    Behavior on xScale {
                        NumberAnimation {
                            duration: Appearance.motion.duration.long1
                            easing.bezierCurve: Appearance.motion.easing.emphasized
                        }
                    }
                    Behavior on yScale {
                        NumberAnimation {
                            duration: Appearance.motion.duration.long1
                            easing.bezierCurve: Appearance.motion.easing.emphasized
                        }
                    }
                },
                Translate {
                    id: containerTranslate
                    y: container.idleHidden ? -container.implicitHeight : 0
                    Behavior on y {
                        NumberAnimation {
                            duration: Appearance.motion.duration.long1
                            easing.bezierCurve: Appearance.motion.easing.emphasized
                        }
                    }
                }
            ]

            QtObject {
                id: pillState

                property string _displayMode: scope.mode
                property bool _modeStable: true

                readonly property bool hoverable:
                    _displayMode === "launcher" ? false :
                    Appearance.island.hoverIdleExpand
                        ? (_displayMode !== "osd")
                        : (_displayMode === "media" || _displayMode === "battery")

                readonly property bool expanded:
                    _displayMode === "launcher" ? true :
                    (hoverable && _modeStable && (hoverHandler.hovered || scope.peeking))

                readonly property int targetW: {
                    if (_displayMode === "launcher") {
                        return LauncherSearch.query === ""
                            ? Appearance.island.launcherCollapsedWidth
                            : Appearance.island.launcherWidth;
                    }
                    if (expanded) {
                        switch (_displayMode) {
                            case "media":   return Appearance.island.expandedWidthMedia;
                            case "battery": return Appearance.island.expandedWidthBattery;
                            case "home":    return Appearance.island.expandedWidthHome;
                        }
                    }
                    switch (_displayMode) {
                        case "osd":     return Appearance.island.compactWidthOsd;
                        case "battery": return Appearance.island.compactWidthBattery;
                        case "media":   return Appearance.island.compactWidthMedia;
                        case "home":    return Appearance.island.notchClosedWidth;
                    }
                    return Appearance.island.notchClosedWidth;
                }
                readonly property int targetH: {
                    if (_displayMode === "launcher") {
                        return Math.max(Appearance.island.launcherMinHeight,
                                        Math.min(Appearance.island.launcherMaxHeight,
                                                 launcherView.desiredHeight));
                    }
                    if (!expanded) {
                        if (_displayMode === "osd") return Appearance.island.osdHeight;
                        return Appearance.island.notchClosedHeight;
                    }
                    switch (_displayMode) {
                        case "media":   return Appearance.island.expandedHeightMedia;
                        case "battery": return Appearance.island.expandedHeightBattery;
                        case "home":    return Appearance.island.expandedHeightHome;
                    }
                    return Appearance.island.notchClosedHeight;
                }
                readonly property real targetTopR:
                    _displayMode === "launcher" ? Appearance.island.launcherTopRadius
                    : _displayMode === "osd" ? Appearance.island.osdTopRadius
                    : expanded ? Appearance.island.notchOpenTopRadius
                    : Appearance.island.notchClosedTopRadius
                readonly property real targetBottomR:
                    _displayMode === "launcher" ? Appearance.island.launcherBottomRadius
                    : _displayMode === "osd" ? Appearance.island.osdBottomRadius
                    : expanded ? Appearance.island.notchOpenBottomRadius
                    : Appearance.island.notchClosedBottomRadius
            }

            Connections {
                target: scope
                function onModeChanged() {
                    pillState._modeStable = false;
                    modeStableTimer.restart();
                }
            }
            Timer {
                id: modeStableTimer
                interval: Appearance.island.swapDurationMs
                onTriggered: {
                    pillState._displayMode = scope.mode;
                    pillState._modeStable = true;
                }
            }

            IslandShadow {
                anchors.horizontalCenter: parent.horizontalCenter
                z: -1
                bodyWidth: notch.bodyWidth
                bodyHeight: notch.bodyHeight
                topRadius: notch.topRadius
                bottomRadius: notch.bottomRadius
                tint: container.mediaTint
                tintAmount: pillState._displayMode === "media" ? 1 : 0
                shadowOpacity: pillState.expanded ? 0.65 : 0.35
            }

            NotchShape {
                id: notch
                anchors.horizontalCenter: parent.horizontalCenter
                y: 0
                bodyWidth:    pillState.targetW
                bodyHeight:   pillState.targetH
                topRadius:    pillState.targetTopR
                bottomRadius: pillState.targetBottomR
                fillColor:    (pillState._displayMode === "media" && pillState.expanded)
                                  ? mediaExpanded.backdropColor
                                  : Appearance.colors.background
                layer.enabled: true
            }

            HoverHandler { id: hoverHandler }

            MouseArea {
                anchors.fill: notch
                hoverEnabled: false
                acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                enabled: !(pillState._displayMode === "media" && pillState.expanded)
                          && pillState._displayMode !== "launcher"
                onClicked: e => {
                    if (pillState._displayMode === "media" && scope.player) {
                        if (e.button === Qt.MiddleButton && scope.player.canGoNext) scope.player.next();
                        else if (scope.player.canTogglePlaying) scope.player.togglePlaying();
                    }
                }
            }

            // OSD compact (volume/brightness/mic)
            IslandOsd {
                anchors.fill: notch
                anchors.leftMargin: notch.topRadius
                anchors.rightMargin: notch.topRadius
                icon: osdInputs.icon
                label: osdInputs.label
                progress: osdInputs.progress
                opacity: pillState._displayMode === "osd" ? 1 : 0
                visible: opacity > 0
                Behavior on opacity { NumberAnimation { duration: Appearance.motion.duration.effects; easing.type: Easing.OutCubic } }
            }

            IslandBattery {
                id: batteryView
                anchors.fill: notch
                anchors.leftMargin: notch.topRadius
                anchors.rightMargin: notch.topRadius
                expanded: pillState.expanded
                opacity: pillState._displayMode === "battery" ? 1 : 0
                visible: opacity > 0
                Behavior on opacity { NumberAnimation { duration: Appearance.motion.duration.effects; easing.type: Easing.OutCubic } }
            }

            // Media expanded card (clipped to the notch body via OpacityMask
            // would be ideal; here we just inset slightly and let the curved
            // bottom corners frame the content)
            Item {
                id: mediaExpanded
                anchors.fill: notch
                readonly property bool shouldShow: pillState._displayMode === "media" && pillState.expanded
                readonly property color tintColor: card.blendedColors?.colPrimary ?? Appearance.colors.accent
                readonly property color backdropColor: card.blendedColors?.colLayer0 ?? Appearance.colors.background
                opacity: 0
                visible: shouldShow || opacity > 0

                states: State {
                    name: "visible"
                    when: mediaExpanded.shouldShow
                    PropertyChanges { target: mediaExpanded; opacity: 1 }
                }
                transitions: [
                    Transition {
                        to: "visible"
                        NumberAnimation { property: "opacity"; duration: Appearance.motion.duration.short4; easing.type: Easing.OutCubic }
                    },
                    Transition {
                        from: "visible"
                        NumberAnimation { property: "opacity"; duration: Appearance.motion.duration.effects; easing.type: Easing.OutCubic }
                    }
                ]

                IslandMediaCard {
                    id: card
                    anchors.fill: parent
                    radius: notch.bottomRadius
                    backdropMask: notch
                    contentSideInset: notch.topRadius
                }
            }

            readonly property color mediaTint: mediaExpanded.tintColor

            IslandMediaArtPeek {
                id: artPeek
                width: Appearance.island.mediaArtPeekSize
                height: Appearance.island.mediaArtPeekSize
                anchors.left: notch.left
                anchors.leftMargin: notch.topRadius + Appearance.island.mediaPeekGap
                anchors.verticalCenter: notch.verticalCenter
                opacity: container.mediaPeekVisible ? 1 : 0
                visible: opacity > 0
                Behavior on opacity { NumberAnimation { duration: Appearance.motion.duration.medium2; easing.type: Easing.OutCubic } }
            }
            
            IslandLauncher {
                id: launcherView
                anchors.fill: notch
                anchors.leftMargin: notch.topRadius
                anchors.rightMargin: notch.topRadius
                opacity: pillState._displayMode === "launcher" ? 1 : 0
                visible: opacity > 0
                onActivated: scope.launcher?.hide()
                Behavior on opacity {
                    NumberAnimation {
                        duration: Appearance.motion.duration.long1
                        easing.bezierCurve: Appearance.motion.easing.emphasized
                    }
                }
                Component.onCompleted: {
                    if (scope.launcher) scope.launcher.islandView = launcherView;
                }
            }

            IslandMediaVizPeek {
                id: vizPeek
                width: Appearance.island.mediaVizPeekWidth
                height: Appearance.island.mediaArtPeekSize
                anchors.right: notch.right
                anchors.rightMargin: notch.topRadius + Appearance.island.mediaPeekGap
                anchors.verticalCenter: notch.verticalCenter
                accentColor: container.mediaTint
                opacity: container.mediaPeekVisible ? 1 : 0
                visible: opacity > 0
                Behavior on opacity { NumberAnimation { duration: Appearance.motion.duration.medium2; easing.type: Easing.OutCubic } }
            }
        }
    }
}

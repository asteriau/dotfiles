pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models
import qs.services
import qs.modules.common.widgets

PanelWindow {
    id: root
    visible: false
    color: "transparent"
    WlrLayershell.namespace: "quickshell:regionSelector"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    exclusionMode: ExclusionMode.Ignore
    anchors {
        left: true
        right: true
        top: true
        bottom: true
    }

    enum SnipAction { Copy, Record, RecordWithSound }
    enum SelectionMode { RectCorners, Circle }
    enum Phase { Select, Post }

    property var action: RegionSelection.SnipAction.Copy
    property var selectionMode: RegionSelection.SelectionMode.RectCorners
    property var phase: RegionSelection.Phase.Select
    signal dismiss()

    property string screenshotDir: Directories.screenshotTemp
    property color overlayColor: Qt.rgba(0, 0, 0, 0.4)
    property color brightText: Theme.dark ? Appearance.colors.foreground : Appearance.colors.background
    property color brightSecondary: Theme.dark ? Appearance.colors.colSecondary : Appearance.colors.colOnSecondaryContainer
    property color selectionBorderColor: ColorUtils.mix(brightText, brightSecondary, 0.5)
    property color selectionFillColor: "#33ffffff"
    property color onBorderColor: "#ff000000"

    readonly property HyprlandMonitor hyprlandMonitor: Hyprland.monitorFor(screen)
    readonly property real monitorScale: hyprlandMonitor ? hyprlandMonitor.scale : 1
    property string screenshotPath: `${root.screenshotDir}/image-${screen.name}`
    property real dragStartX: 0
    property real dragStartY: 0
    property real draggingX: 0
    property real draggingY: 0
    property bool dragging: false
    property list<point> points: []

    property bool isCircleSelection: (root.selectionMode === RegionSelection.SelectionMode.Circle)

    property real regionWidth: Math.abs(draggingX - dragStartX)
    property real regionHeight: Math.abs(draggingY - dragStartY)
    property real regionX: Math.min(dragStartX, draggingX)
    property real regionY: Math.min(dragStartY, draggingY)

    TempScreenshotProcess {
        id: screenshotProc
        running: true
        screen: root.screen
        screenshotDir: root.screenshotDir
        screenshotPath: root.screenshotPath
        onExited: (exitCode, exitStatus) => {
            root.preparationDone = !checkRecordingProc.running;
        }
    }
    property bool isRecording: root.action === RegionSelection.SnipAction.Record || root.action === RegionSelection.SnipAction.RecordWithSound
    property bool recordingShouldStop: false
    Process {
        id: checkRecordingProc
        running: isRecording
        command: ["pidof", "wf-recorder"]
        onExited: (exitCode, exitStatus) => {
            root.preparationDone = !screenshotProc.running;
            root.recordingShouldStop = (exitCode === 0);
        }
    }
    property bool preparationDone: false
    onPreparationDoneChanged: {
        if (!preparationDone) return;
        if (root.isRecording && root.recordingShouldStop) {
            Quickshell.execDetached([Directories.recordScriptPath]);
            root.dismiss();
            return;
        }
        root.visible = true;
    }

    function getScreenshotAction() {
        switch (root.action) {
        case RegionSelection.SnipAction.Copy:           return Screenshot.Action.Copy;
        case RegionSelection.SnipAction.Record:         return Screenshot.Action.Record;
        case RegionSelection.SnipAction.RecordWithSound:return Screenshot.Action.RecordWithSound;
        default:
            console.warn("[RegionSelection] Unknown action");
            root.dismiss();
            return null;
        }
    }

    function snip() {
        if (root.regionWidth <= 0 || root.regionHeight <= 0) {
            console.warn("[RegionSelection] Invalid region size");
            root.dismiss();
            return;
        }

        root.regionX = Math.max(0, Math.min(root.regionX, root.screen.width - root.regionWidth));
        root.regionY = Math.max(0, Math.min(root.regionY, root.screen.height - root.regionHeight));
        root.regionWidth = Math.max(0, Math.min(root.regionWidth, root.screen.width - root.regionX));
        root.regionHeight = Math.max(0, Math.min(root.regionHeight, root.screen.height - root.regionY));

        const screenshotDir = Config.screenshot.savePath !== "" ? Config.screenshot.savePath : "";
        const screenshotAction = root.getScreenshotAction();
        const command = Screenshot.getCommand(
            root.regionX * root.monitorScale,
            root.regionY * root.monitorScale,
            root.regionWidth * root.monitorScale,
            root.regionHeight * root.monitorScale,
            root.screenshotPath,
            screenshotAction,
            screenshotDir
        );
        if (command) Quickshell.execDetached(command);
        root.dismiss();
    }

    mask: Region { item: mouseArea }

    Image {
        id: frozenCapture
        anchors.fill: parent
        source: root.preparationDone ? `file://${root.screenshotPath}` : ""
        cache: false
        asynchronous: false
        fillMode: Image.Stretch

        focus: root.visible
        Keys.onPressed: (event) => {
            if (event.key === Qt.Key_Escape) root.dismiss();
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        cursorShape: Qt.CrossCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        hoverEnabled: true

        onPressed: (mouse) => {
            root.dragStartX = mouse.x;
            root.dragStartY = mouse.y;
            root.draggingX = mouse.x;
            root.draggingY = mouse.y;
            root.dragging = true;
        }
        onReleased: (mouse) => {
            if (root.isCircleSelection) {
                const padding = Config.screenshot.regionCircle.padding + Config.screenshot.regionCircle.strokeWidth / 2;
                const dragPoints = (root.points.length > 0) ? root.points : [{ x: mouseArea.mouseX, y: mouseArea.mouseY }];
                const maxX = Math.max(...dragPoints.map(p => p.x));
                const minX = Math.min(...dragPoints.map(p => p.x));
                const maxY = Math.max(...dragPoints.map(p => p.y));
                const minY = Math.min(...dragPoints.map(p => p.y));
                root.regionX = minX - padding;
                root.regionY = minY - padding;
                root.regionWidth = maxX - minX + padding * 2;
                root.regionHeight = maxY - minY + padding * 2;
            }
            root.snip();
        }
        onPositionChanged: (mouse) => {
            if (!root.dragging) return;
            root.draggingX = mouse.x;
            root.draggingY = mouse.y;
            if (root.isCircleSelection) {
                const last = root.points.length > 0 ? root.points[root.points.length - 1] : null;
                if (!last || Math.hypot(mouse.x - last.x, mouse.y - last.y) >= 4) {
                    root.points.push({ x: mouse.x, y: mouse.y });
                }
            }
        }

        Loader {
            z: 2
            anchors.fill: parent
            active: root.selectionMode === RegionSelection.SelectionMode.RectCorners
            sourceComponent: RectCornersSelectionDetails {
                regionX: root.regionX
                regionY: root.regionY
                regionWidth: root.regionWidth
                regionHeight: root.regionHeight
                mouseX: mouseArea.mouseX
                mouseY: mouseArea.mouseY
                color: root.selectionBorderColor
                overlayColor: root.overlayColor
                breathingBorderOnly: false
            }
        }

        Loader {
            z: 2
            anchors.fill: parent
            active: root.selectionMode === RegionSelection.SelectionMode.Circle
            sourceComponent: CircleSelectionDetails {
                color: root.selectionBorderColor
                overlayColor: root.overlayColor
                points: root.points
            }
        }

        CursorGuide {
            z: 9999
            x: root.dragging ? root.regionX + root.regionWidth : mouseArea.mouseX
            y: root.dragging ? root.regionY + root.regionHeight : mouseArea.mouseY
            action: root.action
            selectionMode: root.selectionMode
        }

        Row {
            id: regionSelectionControls
            z: 10
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
                bottomMargin: -height
            }
            opacity: 0
            Connections {
                target: root
                function onVisibleChanged() {
                    if (!root.visible) return;
                    regionSelectionControls.anchors.bottomMargin = 8;
                    regionSelectionControls.opacity = 1;
                }
            }
            Behavior on opacity { NumberAnimation { duration: Appearance.motion.duration.short4 } }
            Behavior on anchors.bottomMargin { NumberAnimation { duration: Appearance.motion.duration.medium1; easing.type: Easing.OutCubic } }
            spacing: 6

            OptionsToolbar {
                anchors.verticalCenter: parent.verticalCenter
                selectionMode: root.selectionMode === RegionSelection.SelectionMode.Circle ? 1 : 0
                onSelectionModeChanged: {
                    root.selectionMode = (selectionMode === 1)
                        ? RegionSelection.SelectionMode.Circle
                        : RegionSelection.SelectionMode.RectCorners;
                }
                onDismiss: root.dismiss()
            }

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 48
                height: 48
                radius: Appearance.layout.radiusLg
                color: Appearance.colors.accentContainer

                MaterialIcon {
                    anchors.centerIn: parent
                    text: "close"
                    color: Appearance.colors.accentContainerText
                    pixelSize: 22
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.dismiss()
                }
            }
        }
    }
}

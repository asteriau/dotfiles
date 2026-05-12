import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    required property var screen
    required property string screenshotDir
    required property string screenshotPath
    required property bool isRecording

    readonly property bool preparationDone: !screenshotProc.running && !checkRecordingProc.running
    property bool recordingShouldStop: false

    signal ready

    onPreparationDoneChanged: if (preparationDone) ready()

    TempScreenshotProcess {
        id: screenshotProc
        running: true
        screen: root.screen
        screenshotDir: root.screenshotDir
        screenshotPath: root.screenshotPath
    }

    Process {
        id: checkRecordingProc
        running: root.isRecording
        command: ["pidof", "wf-recorder"]
        onExited: (exitCode, exitStatus) => {
            root.recordingShouldStop = (exitCode === 0);
        }
    }
}

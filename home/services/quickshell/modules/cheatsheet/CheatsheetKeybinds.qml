pragma ComponentBehavior: Bound

import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

Item {
    id: root
    property real padding: 4
    // Hug the wrapped content width (don't pin to a fixed 70% — that left a
    // huge empty gap once the bind set shrank); cap at 70% screen so a very
    // large config still scrolls. Height stays fixed so the Flow wraps into
    // columns as designed.
    implicitWidth: Math.min(flow.implicitWidth + Appearance.radius.md * 2, (QsWindow?.window?.screen.width ?? 0) * 0.7)
    implicitHeight: QsWindow?.window?.screen.height * 0.7 ?? 0

    Flickable {
        id: flickable
        anchors.fill: parent
        anchors.margins: Appearance.radius.md
        contentHeight: height
        contentWidth: flow.implicitWidth
        clip: true
        ScrollBar.horizontal: ScrollBar {
            policy: ScrollBar.AsNeeded
        }
        WheelHandler {
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            onWheel: event => {
                const dx = (event.angleDelta.y !== 0 ? event.angleDelta.y : event.angleDelta.x);
                const maxX = Math.max(0, flickable.contentWidth - flickable.width);
                flickable.contentX = Math.max(0, Math.min(maxX, flickable.contentX - dx));
            }
        }
        Flow {
            id: flow
            height: flickable.height
            flow: Flow.TopToBottom
            spacing: 10
            Repeater {
                model: [...HyprlandKeybinds.keybindCategories, ""]
                delegate: CheatsheetKeybindsCategory {
                    required property var modelData
                    categoryName: modelData
                }
            }
        }
    }
}

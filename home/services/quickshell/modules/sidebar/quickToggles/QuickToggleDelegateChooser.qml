pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import qs.modules.common
import qs.modules.sidebar.quickToggles
import qs.modules.sidebar.quickToggles.models

DelegateChooser {
    id: root
    property bool editMode: false
    required property real baseCellWidth
    required property real baseCellHeight
    required property real spacing
    required property int startingIndex

    role: "type"

    DelegateChoice {
        roleValue: "network"
        QuickToggleButton {
            required property int index
            required property var modelData
            toggleModel: NetworkToggle {}
            buttonIndex: root.startingIndex + index
            buttonData: modelData
            editMode: root.editMode
            expandedSize: modelData.size > 1
            baseCellWidth: root.baseCellWidth
            baseCellHeight: root.baseCellHeight
            cellSpacing: root.spacing
            cellSize: modelData.size
            onOpenMenu: UiState.sidebarMenu = "wifi"
        }
    }

    DelegateChoice {
        roleValue: "bluetooth"
        QuickToggleButton {
            required property int index
            required property var modelData
            toggleModel: BluetoothToggle {}
            buttonIndex: root.startingIndex + index
            buttonData: modelData
            editMode: root.editMode
            expandedSize: modelData.size > 1
            baseCellWidth: root.baseCellWidth
            baseCellHeight: root.baseCellHeight
            cellSpacing: root.spacing
            cellSize: modelData.size
            onOpenMenu: UiState.sidebarMenu = "bluetooth"
        }
    }

    DelegateChoice {
        roleValue: "notifications"
        QuickToggleButton {
            required property int index
            required property var modelData
            toggleModel: NotificationsToggle {}
            buttonIndex: root.startingIndex + index
            buttonData: modelData
            editMode: root.editMode
            expandedSize: modelData.size > 1
            baseCellWidth: root.baseCellWidth
            baseCellHeight: root.baseCellHeight
            cellSpacing: root.spacing
            cellSize: modelData.size
        }
    }

    DelegateChoice {
        roleValue: "mic"
        QuickToggleButton {
            required property int index
            required property var modelData
            toggleModel: MicToggle {}
            buttonIndex: root.startingIndex + index
            buttonData: modelData
            editMode: root.editMode
            expandedSize: modelData.size > 1
            baseCellWidth: root.baseCellWidth
            baseCellHeight: root.baseCellHeight
            cellSpacing: root.spacing
            cellSize: modelData.size
            onOpenMenu: UiState.sidebarMenu = "mic"
        }
    }

    DelegateChoice {
        roleValue: "audio"
        QuickToggleButton {
            required property int index
            required property var modelData
            toggleModel: AudioToggle {}
            buttonIndex: root.startingIndex + index
            buttonData: modelData
            editMode: root.editMode
            expandedSize: modelData.size > 1
            baseCellWidth: root.baseCellWidth
            baseCellHeight: root.baseCellHeight
            cellSpacing: root.spacing
            cellSize: modelData.size
            onOpenMenu: UiState.sidebarMenu = "volume"
        }
    }

    DelegateChoice {
        roleValue: "nightLight"
        QuickToggleButton {
            required property int index
            required property var modelData
            toggleModel: NightLightToggle {}
            buttonIndex: root.startingIndex + index
            buttonData: modelData
            editMode: root.editMode
            expandedSize: modelData.size > 1
            baseCellWidth: root.baseCellWidth
            baseCellHeight: root.baseCellHeight
            cellSpacing: root.spacing
            cellSize: modelData.size
        }
    }

    DelegateChoice {
        roleValue: "cloudflareWarp"
        QuickToggleButton {
            required property int index
            required property var modelData
            toggleModel: CloudflareWarpToggle {}
            buttonIndex: root.startingIndex + index
            buttonData: modelData
            editMode: root.editMode
            expandedSize: modelData.size > 1
            baseCellWidth: root.baseCellWidth
            baseCellHeight: root.baseCellHeight
            cellSpacing: root.spacing
            cellSize: modelData.size
        }
    }

    DelegateChoice {
        roleValue: "darkMode"
        QuickToggleButton {
            required property int index
            required property var modelData
            toggleModel: DarkModeToggle {}
            buttonIndex: root.startingIndex + index
            buttonData: modelData
            editMode: root.editMode
            expandedSize: modelData.size > 1
            baseCellWidth: root.baseCellWidth
            baseCellHeight: root.baseCellHeight
            cellSpacing: root.spacing
            cellSize: modelData.size
        }
    }
}

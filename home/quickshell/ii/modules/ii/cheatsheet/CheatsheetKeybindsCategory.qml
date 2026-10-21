pragma ComponentBehavior: Bound

import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts
import Quickshell

Rectangle {
    id: root

    required property string categoryName
    // CheatsheetKeybinds root: provides modMaskToStringList + bindMatches.
    required property var cheatsheet

    readonly property bool isCategorized: categoryName?.length > 0
    readonly property var _baseBinds: root.isCategorized
        ? HyprlandKeybinds.keybinds.filter(b => b.description?.length > 0 && b.description.substring(0, b.description.indexOf(":")) === root.categoryName)
        : HyprlandKeybinds.keybinds.filter(b => b.description?.length > 0 && b.description.indexOf(":") === -1)
    // The off-screen measuring copy sets this so the dialog hugs the full
    // keybind set: its width must not move when the query filters cards.
    property bool bypassFilter: false
    readonly property var _binds: root.bypassFilter ? root._baseBinds : root._baseBinds.filter(b => root.cheatsheet.bindMatches(b, root.categoryName))

    // Widest pill in the card; the combo column uses it so action labels
    // align. Grow-only: filtering must not collapse the column.
    property int maxComboWidth: 0

    // CheatsheetKeybinds takes the max across cards and assigns it back as
    // every card's width, so the columns are uniform.
    readonly property real naturalWidth: cardColumn.implicitWidth + 16 * 2

    color: Appearance.colors.colLayer1
    radius: Appearance.rounding.normal
    clip: true
    implicitHeight: cardColumn.implicitHeight + 16 * 2

    // Stays in layout while fading so cards glide instead of snapping when
    // one filters out; the Flow drops it once it is fully invisible.
    readonly property bool shouldShow: root._binds.length > 0
    visible: root.shouldShow || root.opacity > 0
    opacity: root.shouldShow ? 1 : 0
    Behavior on opacity {
        animation: Appearance.animation.effectsDefault.numberAnimation.createObject(this)
    }

    property var macSymbolMap: ({
        "Ctrl": "󰘴",
        "Alt": "󰘵",
        "Shift": "󰘶",
        "Space": "󱁐",
        "Tab": "↹",
        "Equal": "󰇼",
        "Minus": "",
        "Print": "",
        "BackSpace": "󰭜",
        "Delete": "⌦",
        "Return": "󰌑",
        "Period": ".",
        "Escape": "⎋"
    })
    property var functionSymbolMap: ({
        "F1": "󱊫",
        "F2": "󱊬",
        "F3": "󱊭",
        "F4": "󱊮",
        "F5": "󱊯",
        "F6": "󱊰",
        "F7": "󱊱",
        "F8": "󱊲",
        "F9": "󱊳",
        "F10": "󱊴",
        "F11": "󱊵",
        "F12": "󱊶"
    })
    property var mouseSymbolMap: ({
        "mouse_up": "󱕐",
        "mouse_down": "󱕑",
        "mouse:272": "L󰍽",
        "mouse:273": "R󰍽",
        "Scroll ↑/↓": "󱕒",
        "Page_↑/↓": "⇞/⇟"
    })

    property var keyBlacklist: ["SUPER_L", "SUPER_R"]
    property var keySubstitutions: Object.assign({
        "Super": "",
        "Mouse_up": "Scroll ↓",
        "Mouse_down": "Scroll ↑",
        "Mouse:272": "LMB",
        "Mouse:273": "RMB",
        "Mouse:275": "MouseBack",
        "Slash": "/",
        "Hash": "#",
        "Return": "Enter",
        "XF86AudioPlay": "Play/Pause",
        "XF86AudioPrev": "Prev",
        "XF86AudioNext": "Next",
        "XF86AudioMute": "Mute",
        "XF86AudioMicMute": "Mic Mute",
        "XF86AudioRaiseVolume": "Vol +",
        "XF86AudioLowerVolume": "Vol −",
        "XF86MonBrightnessUp": "Bright +",
        "XF86MonBrightnessDown": "Bright −",
        "XF86Calculator": "Calc",
        "XF86Favorites": "Fav"
    }, !!Config.options.cheatsheet.superKey ? {
        "Super": Config.options.cheatsheet.superKey
    } : {}, Config.options.cheatsheet.useMacSymbol ? macSymbolMap : {}, Config.options.cheatsheet.useFnSymbol ? functionSymbolMap : {}, Config.options.cheatsheet.useMouseSymbol ? mouseSymbolMap : {})

    // Unknown categories fall back to a generic keyboard glyph.
    readonly property var categoryIcons: ({
        "Window": "select_window",
        "App": "apps",
        "Apps": "apps",
        "Application": "apps",
        "Utilities": "build",
        "Utility": "build",
        "Shell": "desktop_windows",
        "Screenshot": "screenshot_monitor",
        "Workspace": "view_carousel",
        "Workspaces": "view_carousel",
        "Monitor": "tv",
        "Media": "music_note",
        "Volume": "volume_up",
        "Audio": "volume_up",
        "Backlight": "light_mode",
        "Brightness": "light_mode",
        "Power": "power_settings_new",
        "Session": "power_settings_new",
        "System": "settings"
    })
    readonly property string categoryIcon: root.categoryIcons[root.categoryName] ?? "keyboard"

    ColumnLayout {
        id: cardColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 16
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            MaterialSymbol {
                text: root.categoryIcon
                iconSize: Appearance.font.pixelSize.huge
                fill: 0
                color: Appearance.colors.colPrimary
            }
            StyledText {
                Layout.fillWidth: true
                font.pixelSize: Appearance.font.pixelSize.larger
                font.weight: Font.DemiBold
                color: Appearance.colors.colOnLayer0
                elide: Text.ElideRight
                text: root.isCategorized ? root.categoryName : Translation.tr("Uncategorized")
            }
        }

        Column {
            Layout.fillWidth: true
            // 0: every line owns its own trailing gap so a collapsed line
            // leaves no residual space and the lines below glide up.
            spacing: 0
            Repeater {
                model: root._baseBinds
                delegate: BindLine {
                    required property var modelData
                    keyData: modelData
                }
            }
        }
    }

    component BindLine: Item {
        id: bindLine
        required property var keyData
        readonly property bool matches: root.bypassFilter || root.cheatsheet.bindMatches(bindLine.keyData, root.categoryName)

        // `||` not `??`: keySubstitutions["Super"] defaults to "" (a real
        // empty string, not nullish) and must fall back to "Super" so the
        // modifier still shows when no custom superKey is configured.
        readonly property var modTokens: root.cheatsheet.modMaskToStringList(bindLine.keyData.modmask).map(m => root.keySubstitutions[m] || m).filter(m => m.length > 0)
        readonly property bool keyShown: !root.keyBlacklist.includes(bindLine.keyData.key)
        readonly property string keyToken: {
            const raw = bindLine.keyData.key;
            const k = StringUtils.toTitleCase(raw);
            return root.keySubstitutions[raw] || root.keySubstitutions[k] || k;
        }
        readonly property var parts: bindLine.keyShown ? [...bindLine.modTokens, bindLine.keyToken] : bindLine.modTokens

        // Collapse + fade in place. The +4 is the inter-line gap baked in
        // (Column spacing is 0), so hiding a line frees its full footprint
        // and the lines below glide up as this height animates to 0.
        implicitWidth: bindRow.implicitWidth
        width: bindLine.implicitWidth
        height: bindLine.matches ? bindRow.implicitHeight + 4 : 0
        opacity: bindLine.matches ? 1 : 0
        clip: true
        Behavior on height {
            animation: Appearance.animation.spatialDefault.numberAnimation.createObject(this)
        }
        Behavior on opacity {
            animation: Appearance.animation.effectsDefault.numberAnimation.createObject(this)
        }

        Row {
            id: bindRow
            anchors.left: parent.left
            anchors.top: parent.top
            spacing: 16

            Item {
                implicitWidth: root.maxComboWidth
                implicitHeight: pill.height
                width: root.maxComboWidth
                height: pill.height
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    id: pill
                    color: Appearance.colors.colSecondaryContainer
                    radius: Appearance.rounding.full
                    implicitWidth: pillRow.implicitWidth + 12 * 2
                    implicitHeight: pillRow.implicitHeight + 6 * 2
                    visible: bindLine.parts.length > 0
                    onImplicitWidthChanged: root.maxComboWidth = Math.max(root.maxComboWidth, implicitWidth)
                    Component.onCompleted: root.maxComboWidth = Math.max(root.maxComboWidth, implicitWidth)

                    Row {
                        id: pillRow
                        anchors.centerIn: parent
                        spacing: 6

                        Repeater {
                            model: bindLine.parts
                            delegate: Row {
                                id: tokenRow
                                required property int index
                                required property var modelData
                                readonly property bool isTrigger: bindLine.keyShown && index === bindLine.parts.length - 1
                                spacing: 6

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    visible: tokenRow.index > 0
                                    renderType: Text.NativeRendering
                                    font.family: Appearance.font.family.main
                                    font.pixelSize: Appearance.font.pixelSize.smaller
                                    color: ColorUtils.applyAlpha(Appearance.colors.colOnSurfaceVariant, 0.6)
                                    text: "+"
                                }
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    renderType: Text.NativeRendering
                                    font.family: Appearance.font.family.main
                                    font.pixelSize: Config.options.cheatsheet.fontSize.key || Appearance.font.pixelSize.smaller
                                    font.weight: tokenRow.isTrigger ? Font.DemiBold : Font.Medium
                                    color: tokenRow.isTrigger ? Appearance.colors.colOnSecondaryContainer : ColorUtils.applyAlpha(Appearance.colors.colOnSecondaryContainer, 0.72)
                                    text: tokenRow.modelData
                                }
                            }
                        }
                    }
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                renderType: Text.NativeRendering
                font.family: Appearance.font.family.main
                font.pixelSize: Config.options.cheatsheet.fontSize.comment || Appearance.font.pixelSize.smallie
                color: Appearance.colors.colOnLayer0
                text: {
                    const regex = new RegExp("\\s*" + root.categoryName + "\\s*:\\s*");
                    return bindLine.keyData.description.replace(regex, "");
                }
            }
        }
    }
}

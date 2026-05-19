pragma ComponentBehavior: Bound

import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts
import Quickshell

Column {
    id: root
    required property string categoryName
    readonly property bool isCategorized: categoryName?.length > 0
    readonly property var _binds: root.isCategorized ? HyprlandKeybinds.keybinds.filter(b => b.description?.length > 0 && b.description.substring(0, b.description.indexOf(":")) === root.categoryName) : HyprlandKeybinds.keybinds.filter(b => b.description?.length > 0 && b.description.indexOf(":") === -1)
    // Drop empty categories (e.g. "Uncategorized" when every bind is prefixed) from the Flow.
    visible: root._binds.length > 0
    property int maxBindWidth: 0
    property real columnSpacing: 40
    property real titleSpacing: 7

    property var macSymbolMap: ({
            "Ctrl": "󰘴",
            "Alt": "󰘵",
            "Shift": "󰘶",
            "Space": "󱁐",
            "Tab": "↹",
            "Equal": "󰇼",
            "Minus": "",
            "Print": "",
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
        }, !!Config.cheatsheet.superKey ? {
            "Super": Config.cheatsheet.superKey
        } : {}, Config.cheatsheet.useMacSymbol ? macSymbolMap : {}, Config.cheatsheet.useFnSymbol ? functionSymbolMap : {}, Config.cheatsheet.useMouseSymbol ? mouseSymbolMap : {})

    function modMaskToStringList(modMask: int): list<string> {
        var list = [];
        if (modMask & (1 << 2)) {
            list.push("Ctrl");
        }
        if (modMask & (1 << 6)) {
            list.push("Super");
        }
        if (modMask & (1 << 0)) {
            list.push("Shift");
        }
        if (modMask & (1 << 3)) {
            list.push("Alt");
        }
        if (modMask & (1 << 1)) {
            list.push("Caps");
        }
        if (modMask & (1 << 4)) {
            list.push("Mod2");
        }
        if (modMask & (1 << 5)) {
            list.push("Mod3");
        }
        if (modMask & (1 << 7)) {
            list.push("Mod5");
        }
        return list;
    }

    spacing: titleSpacing

    StyledText {
        variant: StyledText.Variant.Title
        text: root.isCategorized ? root.categoryName : "Uncategorized"
    }

    Column {
        spacing: 4
        Repeater {
            model: root._binds
            delegate: BindLine {
                required property var modelData
                keyData: modelData
                categoryName: root.categoryName
            }
        }
    }

    component BindLine: Row {
        id: bindLine
        required property var keyData
        property string categoryName: ""

        Row {
            spacing: 16
            Row {
                id: modRow
                Component.onCompleted: root.maxBindWidth = Math.max(root.maxBindWidth, implicitWidth)
                width: root.maxBindWidth
                spacing: 4
                Repeater {
                    model: {
                        const modList = root.modMaskToStringList(bindLine.keyData.modmask).map(mod => root.keySubstitutions[mod] || mod);
                        if (modList.length == 0)
                            return [];
                        if (Config.cheatsheet.splitButtons)
                            return modList;
                        return [modList.join(" ")];
                    }
                    delegate: KeyboardKey {
                        required property var modelData
                        key: modelData
                        pixelSize: Config.cheatsheet.fontSize.key
                    }
                }
                Text {
                    id: keybindPlus
                    anchors.verticalCenter: parent.verticalCenter
                    renderType: Text.NativeRendering
                    font.family: Appearance.typography.family
                    font.pixelSize: Appearance.typography.smaller
                    color: Appearance.colors.colOnLayer0
                    visible: !root.keyBlacklist.includes(bindLine.keyData.key) && bindLine.keyData.modmask > 0
                    text: "+"
                }
                KeyboardKey {
                    id: keybindKey
                    anchors.verticalCenter: parent.verticalCenter
                    visible: !root.keyBlacklist.includes(bindLine.keyData.key)
                    key: {
                        const raw = bindLine.keyData.key;
                        const k = StringUtils.toTitleCase(raw);
                        return root.keySubstitutions[raw] || root.keySubstitutions[k] || k;
                    }
                    pixelSize: Config.cheatsheet.fontSize.key
                }
            }
            Item {
                anchors.verticalCenter: parent.verticalCenter
                implicitWidth: commentText.implicitWidth + root.columnSpacing
                implicitHeight: commentText.implicitHeight
                Text {
                    id: commentText
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    renderType: Text.NativeRendering
                    font.family: Appearance.typography.family
                    font.pixelSize: Config.cheatsheet.fontSize.comment || Appearance.typography.smaller
                    color: Appearance.colors.colOnLayer0
                    text: {
                        const regex = new RegExp("\\s*" + bindLine.categoryName + "\\s*:\\s*");
                        return bindLine.keyData.description.replace(regex, "");
                    }
                }
            }
        }
    }
}

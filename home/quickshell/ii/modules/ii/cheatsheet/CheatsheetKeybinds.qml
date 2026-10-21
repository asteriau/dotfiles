pragma ComponentBehavior: Bound

import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    id: root

    signal closeRequested

    focus: true
    // Root holds focus so the first printable key (or "/") can hand it to the
    // field: type-to-search works before the field is ever clicked.
    Component.onCompleted: root.forceActiveFocus()

    readonly property int screenW: QsWindow?.window?.screen.width ?? 0
    readonly property int screenH: QsWindow?.window?.screen.height ?? 0

    readonly property string query: CheatsheetSearch.query
    readonly property string normalizedQuery: query.trim().toLowerCase()

    // Every card is the width of the widest card, so the columns are even.
    property real maxCardWidth: 0

    // The dialog hugs the *unfiltered* keybind set, measured off-screen by
    // `measureFlow`, so its width never shifts, shrinks or collapses as the
    // query changes. Height is a fixed screen fraction so the TopToBottom
    // Flow wraps everything into view without scrolling.
    readonly property real minWidth: searchField.implicitWidth + 24 * 2
    implicitWidth: Math.min(Math.max(measureFlow.implicitWidth + 12 * 2, root.minWidth), root.screenW * 0.95)
    implicitHeight: root.screenH * 0.82

    // Owned here, not in the cards, so the empty-state count and the cards
    // filter through one predicate.
    function modMaskToStringList(modMask: int): list<string> {
        let list = [];
        if (modMask & (1 << 2))
            list.push("Ctrl");
        if (modMask & (1 << 6))
            list.push("Super");
        if (modMask & (1 << 0))
            list.push("Shift");
        if (modMask & (1 << 3))
            list.push("Alt");
        if (modMask & (1 << 1))
            list.push("Caps");
        if (modMask & (1 << 4))
            list.push("Mod2");
        if (modMask & (1 << 5))
            list.push("Mod3");
        if (modMask & (1 << 7))
            list.push("Mod5");
        return list;
    }

    function categoryOf(bind): string {
        const d = bind.description ?? "";
        const i = d.indexOf(":");
        return i === -1 ? "" : d.substring(0, i);
    }

    // A category-name hit includes every row in that category; otherwise the
    // query must substring-match a modifier, the key, or the action text.
    function bindMatches(bind, categoryName: string): bool {
        const q = root.normalizedQuery;
        if (q === "")
            return true;
        if (categoryName.toLowerCase().includes(q))
            return true;
        // Cache the query-independent haystack on the bind.
        let blob = bind.__searchBlob;
        if (blob === undefined) {
            blob = [...root.modMaskToStringList(bind.modmask), bind.key ?? "", bind.description ?? ""].join(" ").toLowerCase();
            bind.__searchBlob = blob;
        }
        return blob.includes(q);
    }

    // -1 means "no active filter"; ≥0 is the number of matching binds.
    readonly property int matchCount: {
        if (root.normalizedQuery === "")
            return -1;
        let n = 0;
        const binds = HyprlandKeybinds.keybinds;
        for (let i = 0; i < binds.length; i++) {
            const b = binds[i];
            if ((b.description?.length ?? 0) > 0 && root.bindMatches(b, root.categoryOf(b)))
                n++;
        }
        return n;
    }
    readonly property bool isEmpty: root.matchCount === 0

    Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
            root.closeRequested();
            event.accepted = true;
            return;
        }
        // Reached only while the field lacks focus; once it has focus it
        // consumes typing, Escape and "/" itself.
        if (event.key === Qt.Key_Slash) {
            searchField.focusInput();
            event.accepted = true;
            return;
        }
        const t = event.text;
        const blocked = event.modifiers & (Qt.ControlModifier | Qt.AltModifier | Qt.MetaModifier);
        if (t.length === 1 && t.charCodeAt(0) >= 0x20 && !blocked) {
            searchField.focusInput();
            searchField.text += t;
            event.accepted = true;
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 16

        Item {
            Layout.fillWidth: true
            implicitHeight: searchField.implicitHeight

            CheatsheetSearchField {
                id: searchField
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                width: Math.min(implicitWidth, parent.width - 24 * 2)
                placeholder: Translation.tr("Search keybinds")

                Component.onCompleted: text = CheatsheetSearch.query
                onQueryChanged: q => CheatsheetSearch.query = q
                onEscapePressed: root.closeRequested()
            }
        }

        Item {
            id: viewport
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            // Off-screen, never filtered: lays out the full keybind set so
            // root.implicitWidth hugs it. Same height/spacing/card width as
            // the visible Flow, so it packs into the identical column shape.
            Flow {
                id: measureFlow
                visible: false
                height: viewport.height
                flow: Flow.TopToBottom
                spacing: 16

                Repeater {
                    model: [...HyprlandKeybinds.keybindCategories, ""]
                    delegate: CheatsheetKeybindsCategory {
                        required property var modelData
                        categoryName: modelData
                        cheatsheet: root
                        bypassFilter: true
                        width: root.maxCardWidth
                        onNaturalWidthChanged: root.maxCardWidth = Math.max(root.maxCardWidth, naturalWidth)
                        Component.onCompleted: root.maxCardWidth = Math.max(root.maxCardWidth, naturalWidth)
                    }
                }
            }

            Flow {
                id: flow
                height: viewport.height
                flow: Flow.TopToBottom
                spacing: 16
                // Survivors glide to their repacked slots on the spatial curve,
                // so the whole filter moves as one.
                move: Transition {
                    animations: [
                        Appearance.animation.spatialDefault.numberAnimation.createObject(this, {
                            properties: "x,y",
                        }),
                    ]
                }
                opacity: root.isEmpty ? 0 : 1
                Behavior on opacity {
                    animation: Appearance.animation.effectsDefault.numberAnimation.createObject(this)
                }

                Repeater {
                    model: [...HyprlandKeybinds.keybindCategories, ""]
                    delegate: CheatsheetKeybindsCategory {
                        required property var modelData
                        categoryName: modelData
                        cheatsheet: root
                        width: root.maxCardWidth
                        onNaturalWidthChanged: root.maxCardWidth = Math.max(root.maxCardWidth, naturalWidth)
                        Component.onCompleted: root.maxCardWidth = Math.max(root.maxCardWidth, naturalWidth)
                    }
                }
            }

            ColumnLayout { // Empty state
                anchors.centerIn: parent
                spacing: 8
                opacity: root.isEmpty ? 1 : 0
                visible: opacity > 0
                Behavior on opacity {
                    animation: Appearance.animation.effectsDefault.numberAnimation.createObject(this)
                }

                MaterialSymbol {
                    Layout.alignment: Qt.AlignHCenter
                    text: "search_off"
                    iconSize: Appearance.font.pixelSize.hugeass * 1.6
                    color: Appearance.colors.colOnSurfaceVariant
                }
                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    color: Appearance.colors.colOnSurfaceVariant
                    text: Translation.tr("No keybinds match \"%1\"").arg(root.query)
                }
            }
        }
    }
}

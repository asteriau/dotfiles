pragma ComponentBehavior: Bound

import qs.services
import qs.modules.common
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
    onMaxCardWidthChanged: root.scheduleLayout()

    // Cards are packed into balanced columns (see relayout) and the dialog
    // hugs the packed size, capped to a screen fraction; past the height cap
    // the body scrolls.
    readonly property int spacing: 16
    property real packedWidth: 0
    property real packedHeight: 0
    readonly property int maxColumns: Math.max(1, Math.floor((root.screenW * 0.95 - 24 * 2 - 12 * 2 + root.spacing) / (root.maxCardWidth + root.spacing)))
    readonly property real minWidth: searchField.implicitWidth + 24 * 2
    readonly property real maxBodyHeight: root.screenH * 0.82 - searchRow.implicitHeight - root.spacing
    readonly property real bodyHeight: root.isEmpty ? emptyState.implicitHeight + 24 * 2 : Math.min(root.maxBodyHeight, root.packedHeight)
    implicitWidth: Math.min(Math.max(root.packedWidth + 12 * 2, root.minWidth), root.screenW * 0.95)
    implicitHeight: searchRow.implicitHeight + root.spacing + root.bodyHeight

    function scheduleLayout() {
        layoutTimer.restart();
    }
    Timer {
        id: layoutTimer
        interval: 0
        onTriggered: root.relayout()
    }
    // Tallest card first, each into the shortest column: no column is left
    // half empty the way a fixed-height Flow leaves them.
    function relayout() {
        const shown = [];
        for (let i = 0; i < cards.count; i++) {
            const card = cards.itemAt(i);
            if (card && card.shouldShow)
                shown.push(card);
        }
        shown.sort((a, b) => b.implicitHeight - a.implicitHeight);
        const n = Math.max(1, Math.min(root.maxColumns, shown.length));
        const heights = new Array(n).fill(0);
        for (const card of shown) {
            let col = 0;
            for (let i = 1; i < n; i++)
                if (heights[i] < heights[col])
                    col = i;
            card.x = col * (root.maxCardWidth + root.spacing);
            card.y = heights[col];
            heights[col] += card.implicitHeight + root.spacing;
        }
        const used = heights.filter(h => h > 0).length;
        root.packedWidth = used > 0 ? used * (root.maxCardWidth + root.spacing) - root.spacing : 0;
        root.packedHeight = Math.max(0, Math.max(...heights) - root.spacing);
    }

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
        spacing: root.spacing

        Item {
            id: searchRow
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

            StyledFlickable {
                id: flick
                anchors.fill: parent
                clip: true
                contentWidth: width
                contentHeight: root.packedHeight

                Item {
                    id: pack
                    width: flick.width
                    height: root.packedHeight
                    opacity: root.isEmpty ? 0 : 1
                    Behavior on opacity {
                        animation: Appearance.animation.effectsDefault.numberAnimation.createObject(this)
                    }

                    Repeater {
                        id: cards
                        model: [...HyprlandKeybinds.keybindCategories, ""]
                        delegate: CheatsheetKeybindsCategory {
                            required property var modelData
                            categoryName: modelData
                            cheatsheet: root
                            width: root.maxCardWidth
                            onNaturalWidthChanged: root.maxCardWidth = Math.max(root.maxCardWidth, naturalWidth)
                            Component.onCompleted: root.maxCardWidth = Math.max(root.maxCardWidth, naturalWidth)
                            // Survivors glide to their repacked slots on the spatial curve
                            onImplicitHeightChanged: root.scheduleLayout()
                            onShouldShowChanged: root.scheduleLayout()
                            Behavior on x {
                                animation: Appearance.animation.spatialDefault.numberAnimation.createObject(this)
                            }
                            Behavior on y {
                                animation: Appearance.animation.spatialDefault.numberAnimation.createObject(this)
                            }
                        }
                    }
                }
            }
            ScrollEdgeFade {
                target: flick
                color: Appearance.colors.colLayer0
            }

            ColumnLayout { // Empty state
                id: emptyState
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

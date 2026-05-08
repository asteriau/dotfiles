import QtQuick
import qs.utils

QtObject {
    id: root

    property string currentName: ""
    property bool hasCurrent: false
    property real currentCenter: 0
    property Item currentTarget: null
    property Item anchorItem: null
    property bool targetHovered: false

    signal targetReleased

    function show(name, item) {
        currentName = name;
        currentTarget = item;
        targetHovered = true;
        updateCenter();
        hasCurrent = true;
    }

    function release(name, item) {
        if (currentName !== name || currentTarget !== item)
            return;

        targetHovered = false;
        targetReleased();
    }

    function close() {
        hasCurrent = false;
        targetHovered = false;
    }

    function updateCenter() {
        if (!currentTarget || !anchorItem)
            return;

        const point = currentTarget.mapToItem(anchorItem, currentTarget.width / 2, currentTarget.height / 2);
        currentCenter = Config.bar.vertical ? point.y : point.x;
    }
}

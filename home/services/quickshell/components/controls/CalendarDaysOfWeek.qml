pragma ComponentBehavior: Bound
import QtQuick

Row {
    id: root
    property Component delegate
    property alias model: repeater.model

    property var locale: Qt.locale()
    readonly property var firstDayOfWeek: locale.firstDayOfWeek

    Repeater {
        id: repeater
        model: Array.from({
            length: 7
        }, (_, i) => {
            const day = (root.firstDayOfWeek + i + 7 - 1) % 7 + 1
            return ({
                day: day,
                shortName: root.locale.toString(new Date(2024, 0, day), "ddd")
            })
        })
        delegate: root.delegate
    }
}

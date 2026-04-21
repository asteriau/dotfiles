import QtQuick

QtObject {
    id: root
    required property int index
    property real idx1: index
    property real idx2: index

    Behavior on idx1 {
        NumberAnimation { duration: 100; easing.type: Easing.OutSine }
    }
    Behavior on idx2 {
        NumberAnimation { duration: 300; easing.type: Easing.OutSine }
    }
}

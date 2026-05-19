import QtQuick

QtObject {
    id: root
    required property string name
    property string statusText: ""
    property string tooltipText: ""
    property string icon: "close"
    property bool hasStatusText: true
    property bool available: true
    property bool toggled: false
    required property var mainAction
    property bool hasMenu: false
    property var altAction: null
    default property list<QtObject> data
}

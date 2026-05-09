import QtQuick
import QtQuick.Layouts
import qs.utils

// Footer row for dialog buttons. Tight 4px spacing between buttons,
// trims leading/trailing padding so buttons hug the dialog edges.
RowLayout {
    Layout.fillWidth: true
    Layout.topMargin: 0
    Layout.bottomMargin: -8
    Layout.leftMargin: -8
    Layout.rightMargin: -8
    spacing: 4
}

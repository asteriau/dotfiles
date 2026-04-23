pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root
    signal show(string icon, string label, real progress)
}

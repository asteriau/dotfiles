import QtQuick
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models

// Material Symbols icon. Set `text` to a symbol name and optionally adjust `fill`,
// `grade`, `weight`, and size. Size: either set `font.pointSize:` like any Text, or
// use the opt-in `pixelSize:` property for pixel-exact sizing (used by phase-2
// retrofits where pixel sizes matter). Setting pixelSize > 0 clears pointSize to
// avoid Qt's "both point size and pixel size set" warning.
Text {
    id: root

    property real fill: 0
    property int  grade: -25
    property int  weight: 400
    // Opt-in pixel sizing. When > 0, overrides `font.pointSize`.
    property real pixelSize: 0

    readonly property int targetSize:   pixelSize > 0 ? pixelSize : font.pointSize
    readonly property int targetWeight: font.weight

    font.family: Appearance.typography.iconFamily
    font.pointSize: pixelSize > 0 ? -1 : (Config.typography.iconSize + 1)
    font.pixelSize: pixelSize > 0 ? pixelSize : -1
    font.weight: weight
    font.variableAxes: ({
        FILL: fill.toFixed(1),
        GRAD: grade,
        opsz: targetSize,
        wght: targetWeight
    })
    renderType: Text.NativeRendering
}

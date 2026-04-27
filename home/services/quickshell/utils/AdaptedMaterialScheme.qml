import QtQuick
import qs.utils

QtObject {
    id: root
    required property color color
    readonly property bool colorIsDark: color.hslLightness < 0.5

    readonly property color colLayer0: ColorMix.mix(Colors.surfaceContainerLow, root.color, colorIsDark ? 0.6 : 0.5)
    readonly property color colLayer1: ColorMix.mix(Colors.surfaceContainer, root.color, 0.5)
    readonly property color colOnLayer0: ColorMix.mix(Colors.foreground, root.color, 0.5)
    readonly property color colOnLayer1: ColorMix.mix(Colors.foreground, root.color, 0.5)
    readonly property color colSubtext: ColorMix.mix(Colors.m3onSurfaceVariant, root.color, 0.5)
    readonly property color colPrimary: ColorMix.mix(ColorMix.adaptToAccent(Colors.accent, root.color), root.color, 0.5)
    readonly property color colPrimaryHover: ColorMix.mix(ColorMix.adaptToAccent(Colors.accent, root.color), root.color, 0.3)
    readonly property color colPrimaryActive: ColorMix.mix(ColorMix.adaptToAccent(Qt.lighter(Colors.accent, 1.1), root.color), root.color, 0.3)
    readonly property color colSecondary: ColorMix.mix(ColorMix.adaptToAccent(Colors.m3onSurfaceVariant, root.color), root.color, 0.5)
    readonly property color colSecondaryContainer: ColorMix.mix(Colors.secondaryContainer, root.color, 0.15)
    readonly property color colSecondaryContainerHover: ColorMix.mix(Qt.lighter(Colors.secondaryContainer, 1.15), root.color, 0.3)
    readonly property color colSecondaryContainerActive: ColorMix.mix(Qt.lighter(Colors.secondaryContainer, 1.3), root.color, 0.5)
    readonly property color colOnPrimary: ColorMix.mix(Colors.m3onPrimary, root.color, 0.5)
    readonly property color colOnSecondaryContainer: ColorMix.mix(Colors.m3onSecondaryContainer, root.color, 0.5)
}

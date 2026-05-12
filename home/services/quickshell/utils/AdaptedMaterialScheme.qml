import QtQuick
import qs.utils

QtObject {
    id: root
    required property color color
    readonly property bool colorIsDark: color.hslLightness < 0.5

    readonly property color colLayer0: ColorMix.mix(Appearance.colors.surfaceContainerLow, root.color, colorIsDark ? 0.6 : 0.5)
    readonly property color colLayer1: ColorMix.mix(Appearance.colors.surfaceContainer, root.color, 0.5)
    readonly property color colOnLayer0: ColorMix.mix(Appearance.colors.foreground, root.color, 0.5)
    readonly property color colOnLayer1: ColorMix.mix(Appearance.colors.foreground, root.color, 0.5)
    readonly property color colSubtext: ColorMix.mix(Appearance.colors.m3onSurfaceVariant, root.color, 0.5)
    readonly property color colPrimary: ColorMix.mix(ColorMix.adaptToAccent(Appearance.colors.accent, root.color), root.color, 0.5)
    readonly property color colPrimaryHover: ColorMix.mix(ColorMix.adaptToAccent(Appearance.colors.accent, root.color), root.color, 0.3)
    readonly property color colPrimaryActive: ColorMix.mix(ColorMix.adaptToAccent(Qt.lighter(Appearance.colors.accent, 1.1), root.color), root.color, 0.3)
    readonly property color colSecondary: ColorMix.mix(ColorMix.adaptToAccent(Appearance.colors.m3onSurfaceVariant, root.color), root.color, 0.5)
    readonly property color colSecondaryContainer: ColorMix.mix(Appearance.colors.secondaryContainer, root.color, 0.15)
    readonly property color colSecondaryContainerHover: ColorMix.mix(Qt.lighter(Appearance.colors.secondaryContainer, 1.15), root.color, 0.3)
    readonly property color colSecondaryContainerActive: ColorMix.mix(Qt.lighter(Appearance.colors.secondaryContainer, 1.3), root.color, 0.5)
    readonly property color colOnPrimary: ColorMix.mix(Appearance.colors.m3onPrimary, root.color, 0.5)
    readonly property color colOnSecondaryContainer: ColorMix.mix(Appearance.colors.m3onSecondaryContainer, root.color, 0.5)
}

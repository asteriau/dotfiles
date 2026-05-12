import QtQuick
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models

QtObject {
    id: root
    required property color color
    readonly property bool colorIsDark: color.hslLightness < 0.5

    readonly property color colLayer0: ColorUtils.mix(Appearance.colors.surfaceContainerLow, root.color, colorIsDark ? 0.6 : 0.5)
    readonly property color colLayer1: ColorUtils.mix(Appearance.colors.surfaceContainer, root.color, 0.5)
    readonly property color colOnLayer0: ColorUtils.mix(Appearance.colors.foreground, root.color, 0.5)
    readonly property color colOnLayer1: ColorUtils.mix(Appearance.colors.foreground, root.color, 0.5)
    readonly property color colSubtext: ColorUtils.mix(Appearance.colors.m3onSurfaceVariant, root.color, 0.5)
    readonly property color colPrimary: ColorUtils.mix(ColorUtils.adaptToAccent(Appearance.colors.accent, root.color), root.color, 0.5)
    readonly property color colPrimaryHover: ColorUtils.mix(ColorUtils.adaptToAccent(Appearance.colors.accent, root.color), root.color, 0.3)
    readonly property color colPrimaryActive: ColorUtils.mix(ColorUtils.adaptToAccent(Qt.lighter(Appearance.colors.accent, 1.1), root.color), root.color, 0.3)
    readonly property color colSecondary: ColorUtils.mix(ColorUtils.adaptToAccent(Appearance.colors.m3onSurfaceVariant, root.color), root.color, 0.5)
    readonly property color colSecondaryContainer: ColorUtils.mix(Appearance.colors.secondaryContainer, root.color, 0.15)
    readonly property color colSecondaryContainerHover: ColorUtils.mix(Qt.lighter(Appearance.colors.secondaryContainer, 1.15), root.color, 0.3)
    readonly property color colSecondaryContainerActive: ColorUtils.mix(Qt.lighter(Appearance.colors.secondaryContainer, 1.3), root.color, 0.5)
    readonly property color colOnPrimary: ColorUtils.mix(Appearance.colors.m3onPrimary, root.color, 0.5)
    readonly property color colOnSecondaryContainer: ColorUtils.mix(Appearance.colors.m3onSecondaryContainer, root.color, 0.5)
}

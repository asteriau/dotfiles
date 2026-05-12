import QtQuick
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models

Text {
    id: root

    enum Variant {
        Body,      // 15 / Normal   / foreground
        BodySm,    // 13 / Normal   / comment
        Caption,   // 12 / Normal   / comment
        Label,     // 10 / Medium   / m3onSurfaceVariant
        Subtitle,  // 17 / DemiBold / foreground
        Title,     // 22 / Medium   / foreground (matches Appearance.typography.title)
        Display,   // 22 / Medium   / foreground
        Numeric    // 15 / Medium   / foreground
    }

    property int variant: StyledText.Variant.Body

    readonly property var _spec: {
        switch (variant) {
        case StyledText.Variant.BodySm:   return { size: Appearance.typography.smallie,  weight: Font.Normal,   color: Appearance.colors.comment }
        case StyledText.Variant.Caption:  return { size: Appearance.typography.smaller,  weight: Font.Normal,   color: Appearance.colors.comment }
        case StyledText.Variant.Label:    return { size: Appearance.typography.smallest, weight: Font.Medium,   color: Appearance.colors.m3onSurfaceVariant }
        case StyledText.Variant.Subtitle: return { size: Appearance.typography.large,    weight: Font.DemiBold, color: Appearance.colors.foreground }
        case StyledText.Variant.Title:    return { size: Appearance.typography.title,    weight: Font.Medium,   color: Appearance.colors.foreground }
        case StyledText.Variant.Display:  return { size: Appearance.typography.huge,     weight: Font.Medium,   color: Appearance.colors.foreground }
        case StyledText.Variant.Numeric:  return { size: Appearance.typography.small,    weight: Font.Medium,   color: Appearance.colors.foreground }
        default:                          return { size: Appearance.typography.small,    weight: Font.Normal,   color: Appearance.colors.foreground }
        }
    }

    font.family:    Config.typography.family
    font.pixelSize: _spec.size
    font.weight:    _spec.weight
    color:          _spec.color
    renderType: Text.NativeRendering
}

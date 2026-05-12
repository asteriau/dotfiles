{ lib }:
raw:
let
  md3ToShortName = {
    background = "background";
    primary = "accent";
    on_surface = "foreground";
    surface = "elevated";
    surface_container_lowest = "surfaceContainerLowest";
    surface_container_low = "surfaceContainerLow";
    surface_container = "surfaceContainer";
    surface_container_high = "surfaceContainerHigh";
    surface_container_highest = "surfaceContainerHighest";
    primary_container = "primaryContainer";
    on_primary = "m3onPrimary";
    on_primary_container = "m3onPrimaryContainer";
    secondary_container = "secondaryContainer";
    on_secondary_container = "m3onSecondaryContainer";
    on_surface_variant = "m3onSurfaceVariant";
    outline = "m3outline";
    outline_variant = "border";
    error = "red";
    tertiary = "mpris";
  };

  isMatugen = raw ? surface_container_lowest;

  fromMd3 = lib.mapAttrs' (k: v: lib.nameValuePair (md3ToShortName.${k} or k) v) raw;

  base = if isMatugen then fromMd3 else raw;

  fallbacks = {
    background = base.background or "#000000";
    foreground = base.foreground or "#ffffff";
    elevated = base.elevated or base.background or "#000000";
    border = base.border or base.m3outline or "#000000";
    accent = base.accent or "#ffffff";
    red = base.red or "#ff0000";
    mpris = base.mpris or base.accent or "#ffffff";
    surfaceContainerLowest = base.surfaceContainerLowest or base.background or "#000000";
    surfaceContainerLow = base.surfaceContainerLow or base.surfaceContainerLowest or "#000000";
    surfaceContainer = base.surfaceContainer or "#000000";
    surfaceContainerHigh = base.surfaceContainerHigh or "#000000";
    surfaceContainerHighest = base.surfaceContainerHighest or "#000000";
    primaryContainer = base.primaryContainer or base.accent or "#000000";
    m3onPrimary = base.m3onPrimary or base.foreground or "#ffffff";
    m3onPrimaryContainer = base.m3onPrimaryContainer or base.foreground or "#ffffff";
    secondaryContainer = base.secondaryContainer or base.surfaceContainer or "#000000";
    m3onSecondaryContainer = base.m3onSecondaryContainer or base.foreground or "#ffffff";
    accentContainer = base.accentContainer or base.primaryContainer or "#000000";
    accentText = base.accentText or base.foreground or "#ffffff";
    accentContainerText = base.accentContainerText or base.foreground or "#ffffff";
    m3onSurfaceVariant = base.m3onSurfaceVariant or base.foreground or "#ffffff";
    m3outline = base.m3outline or base.border or "#666666";
  };
in
fallbacks // base

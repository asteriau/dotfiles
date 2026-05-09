.pragma library

// Settings search index. Each entry:
//   { pageIndex, page, section, label, caption, keywords, anchorId }
// pageIndex matches order in Settings.qml `pages` array (0=Bar, 1=Theme, 2=General, 3=About).
// anchorId must match objectName on the row in the page's QML.
//
// MAINTENANCE: this index is hand-maintained. When a row is added, removed, or
// renamed in settings/pages/*.qml, update the matching entry here. The anchorId
// field must equal the row's `objectName`; if they drift, search results will
// open the right page but fail to scroll/flash the row.

var INDEX = [
    // ── Bar (0) ────────────────────────────────────────────────────────────
    { pageIndex: 0, page: "Bar", section: "Position",   label: "Bar position",        caption: "Where the bar docks: left, right, top, bottom",
      keywords: ["dock", "side", "place", "left", "right", "top", "bottom"], anchorId: "bar-position" },
    { pageIndex: 0, page: "Bar", section: "Appearance", label: "Rounding",            caption: "Round corners on the bar surface",
      keywords: ["rounded", "corner", "radius", "shape"], anchorId: "bar-rounding" },
    { pageIndex: 0, page: "Bar", section: "Dimensions", label: "Sidebar width",       caption: "Width of the right sidebar panel",
      keywords: ["panel", "size", "width", "right"], anchorId: "bar-sidebarWidth" },
    { pageIndex: 0, page: "Bar", section: "Workspaces", label: "Workspaces shown",    caption: "Number of workspace pills displayed",
      keywords: ["count", "amount", "pills"], anchorId: "bar-wsShown" },
    { pageIndex: 0, page: "Bar", section: "Workspaces", label: "Show app icons",      caption: "Render running app icons inside workspaces",
      keywords: ["apps", "windows", "icon"], anchorId: "bar-wsAppIcons" },
    { pageIndex: 0, page: "Bar", section: "Workspaces", label: "Always show numbers", caption: "Force workspace number labels even when icons present",
      keywords: ["index", "number", "labels"], anchorId: "bar-wsNumbers" },
    { pageIndex: 0, page: "Bar", section: "Workspaces", label: "Monochrome icons",    caption: "Desaturate workspace app icons",
      keywords: ["bw", "grayscale", "color"], anchorId: "bar-wsMonochrome" },
    { pageIndex: 0, page: "Bar", section: "Workspaces", label: "Tinted icons",        caption: "Tint app icons with theme accent",
      keywords: ["color", "accent", "hue"], anchorId: "bar-wsTinted" },

    // ── Theme (1) ──────────────────────────────────────────────────────────
    { pageIndex: 1, page: "Theme", section: "Source",    label: "Theme source",   caption: "Static preset or matugen-generated palette",
      keywords: ["mode", "engine", "matugen", "preset"], anchorId: "theme-source" },
    { pageIndex: 1, page: "Theme", section: "Wallpaper", label: "Wallpaper",      caption: "Background image used by matugen for color extraction",
      keywords: ["background", "image", "picker", "matugen", "bg"], anchorId: "theme-wallpaper" },
    { pageIndex: 1, page: "Theme", section: "Preset",    label: "Choose a preset",caption: "Pick a built-in theme preset",
      keywords: ["palette", "static", "json", "theme"], anchorId: "theme-presetPicker" },
    { pageIndex: 1, page: "Theme", section: "Preset",    label: "Preset name",    caption: "Manual preset basename",
      keywords: ["custom", "file", "name"], anchorId: "theme-presetName" },
    { pageIndex: 1, page: "Theme", section: "Matugen",   label: "Color scheme",   caption: "Matugen scheme algorithm",
      keywords: ["tonal", "vibrant", "expressive", "neutral", "monochrome", "fidelity"], anchorId: "theme-matugenScheme" },
    { pageIndex: 1, page: "Theme", section: "Matugen",   label: "Contrast",       caption: "Matugen contrast level (-1 to 1)",
      keywords: ["a11y", "accessibility", "tone"], anchorId: "theme-matugenContrast" },
    { pageIndex: 1, page: "Theme", section: "Matugen",   label: "Dark mode",      caption: "Dark or light variant of generated palette",
      keywords: ["light", "night", "day"], anchorId: "theme-matugenDark" },

    // ── General (2) ────────────────────────────────────────────────────────
    { pageIndex: 2, page: "General", section: "Font",      label: "Font family",    caption: "Primary UI typeface",
      keywords: ["typeface", "type", "text"], anchorId: "gen-fontFamily" },
    { pageIndex: 2, page: "General", section: "Font",      label: "Icon size",      caption: "Material Symbols base size",
      keywords: ["symbols", "glyph", "size", "px"], anchorId: "gen-iconSize" },
    { pageIndex: 2, page: "General", section: "OSD",       label: "OSD width",      caption: "On-screen display width",
      keywords: ["volume", "brightness", "popup"], anchorId: "gen-osdWidth" },
    { pageIndex: 2, page: "General", section: "OSD",       label: "OSD timeout",    caption: "Auto-hide delay for OSD",
      keywords: ["duration", "ms", "hide"], anchorId: "gen-osdTimeout" }
];

// Subsequence fuzzy match — returns score >= 0 if matches, else -1.
function _subseqScore(needle, hay) {
    if (!needle) return 0;
    var n = needle.toLowerCase();
    var h = hay.toLowerCase();
    var i = 0, j = 0, score = 0, streak = 0, firstHit = -1;
    while (i < n.length && j < h.length) {
        if (n[i] === h[j]) {
            if (firstHit < 0) firstHit = j;
            streak += 1;
            score += 2 + streak; // contiguous matches reward
            i += 1;
        } else {
            streak = 0;
        }
        j += 1;
    }
    if (i < n.length) return -1;
    // earlier match = better
    score -= firstHit * 0.1;
    return score;
}

function search(query) {
    var q = (query || "").trim();
    if (!q) return [];
    var tokens = q.toLowerCase().split(/\s+/).filter(function(t) { return t.length > 0; });
    var out = [];
    for (var i = 0; i < INDEX.length; i++) {
        var e = INDEX[i];
        var label   = e.label || "";
        var caption = e.caption || "";
        var section = e.section || "";
        var page    = e.page || "";
        var keywords = (e.keywords || []).join(" ");
        var entryScore = 0;
        var allMatched = true;
        for (var t = 0; t < tokens.length; t++) {
            var tok = tokens[t];
            var sLabel   = _subseqScore(tok, label);
            var sCaption = _subseqScore(tok, caption);
            var sSection = _subseqScore(tok, section);
            var sPage    = _subseqScore(tok, page);
            var sKeys    = _subseqScore(tok, keywords);
            var best = -1;
            if (sLabel   >= 0) best = Math.max(best, sLabel   * 4.0);
            if (sKeys    >= 0) best = Math.max(best, sKeys    * 2.5);
            if (sSection >= 0) best = Math.max(best, sSection * 1.6);
            if (sPage    >= 0) best = Math.max(best, sPage    * 1.4);
            if (sCaption >= 0) best = Math.max(best, sCaption * 1.0);
            if (best < 0) { allMatched = false; break; }
            entryScore += best;
        }
        if (allMatched) {
            out.push({ entry: e, score: entryScore });
        }
    }
    out.sort(function(a, b) { return b.score - a.score; });
    return out.map(function(r) { return r.entry; });
}

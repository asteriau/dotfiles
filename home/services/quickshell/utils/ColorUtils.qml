pragma Singleton
import Quickshell

Singleton {
    function mix(c1, c2, p = 0.5) {
        const a = Qt.color(c1);
        const b = Qt.color(c2);
        return Qt.rgba(p * a.r + (1 - p) * b.r,
                       p * a.g + (1 - p) * b.g,
                       p * a.b + (1 - p) * b.b,
                       p * a.a + (1 - p) * b.a);
    }

    function transparentize(c, p = 1) {
        const x = Qt.color(c);
        return Qt.rgba(x.r, x.g, x.b, x.a * (1 - p));
    }

    function applyAlpha(c, a) {
        const x = Qt.color(c);
        return Qt.rgba(x.r, x.g, x.b, Math.max(0, Math.min(1, a)));
    }

    function adaptToAccent(c1, c2) {
        const a = Qt.color(c1);
        const b = Qt.color(c2);
        return Qt.hsla(b.hslHue, b.hslSaturation, a.hslLightness, a.a);
    }
}

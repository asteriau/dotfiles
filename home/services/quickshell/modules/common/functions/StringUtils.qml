pragma Singleton
import Quickshell

Singleton {
    function shellSingleQuoteEscape(s) {
        return String(s).replace(/'/g, "'\\''");
    }

    function toTitleCase(s) {
        return String(s).replace(/\w\S*/g, t => t.charAt(0).toUpperCase() + t.substr(1).toLowerCase());
    }
}

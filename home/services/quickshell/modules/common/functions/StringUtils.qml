pragma Singleton
import Quickshell

Singleton {
    function shellSingleQuoteEscape(s) {
        return String(s).replace(/'/g, "'\\''");
    }
}

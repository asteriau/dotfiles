pragma Singleton

import Quickshell

Singleton {
    id: root

    readonly property var iconKeywordMap: ({
            "screenshot": "screenshot_monitor",
            "recording": "videocam",
            "battery": "battery_full",
            "power": "power",
            "charging": "bolt",
            "bluetooth": "bluetooth",
            "wifi": "wifi",
            "network": "lan",
            "volume": "volume_up",
            "mute": "volume_off",
            "mic": "mic",
            "brightness": "brightness_medium",
            "update": "system_update_alt",
            "upgrade": "upgrade",
            "download": "download",
            "upload": "upload",
            "install": "download",
            "error": "error",
            "failed": "error",
            "fail": "error",
            "warning": "warning",
            "alert": "notification_important",
            "mail": "mail",
            "email": "mail",
            "message": "chat",
            "chat": "chat",
            "call": "call",
            "phone": "call",
            "reminder": "alarm",
            "alarm": "alarm",
            "timer": "timer",
            "clock": "schedule",
            "calendar": "calendar_month",
            "event": "event",
            "music": "music_note",
            "song": "music_note",
            "playing": "play_circle",
            "spotify": "music_note",
            "video": "movie",
            "youtube": "smart_display",
            "discord": "forum",
            "slack": "forum",
            "telegram": "send",
            "whatsapp": "chat",
            "signal": "chat",
            "file": "description",
            "folder": "folder",
            "image": "image",
            "photo": "photo",
            "screenshot taken": "screenshot_monitor",
            "copied": "content_copy",
            "copy": "content_copy",
            "paste": "content_paste",
            "clipboard": "content_paste",
            "print": "print",
            "usb": "usb",
            "device": "devices",
            "connected": "link",
            "disconnected": "link_off",
            "paired": "bluetooth_connected",
            "unpaired": "bluetooth_disabled",
            "github": "code",
            "git": "commit",
            "code": "code",
            "terminal": "terminal",
            "build": "build",
            "success": "check_circle",
            "done": "check_circle",
            "completed": "check_circle",
            "finished": "check_circle"
        })

    readonly property string defaultIcon: "notifications"

    function findSuitableMaterialSymbol(str) {
        if (!str)
            return defaultIcon;
        const lower = String(str).toLowerCase();
        for (const key in iconKeywordMap) {
            if (lower.includes(key))
                return iconKeywordMap[key];
        }
        return defaultIcon;
    }

    function getFriendlyNotifTimeString(timestamp) {
        if (!timestamp)
            return "";
        const messageTime = new Date(timestamp);
        const now = new Date();
        const diffMs = now.getTime() - messageTime.getTime();

        if (diffMs < 60000)
            return "Now";

        if (messageTime.toDateString() === now.toDateString()) {
            const diffMinutes = Math.floor(diffMs / 60000);
            const diffHours = Math.floor(diffMs / 3600000);
            if (diffHours > 0)
                return `${diffHours}h`;
            return `${diffMinutes}m`;
        }

        const yesterday = new Date(now.getTime() - 86400000);
        if (messageTime.toDateString() === yesterday.toDateString())
            return "Yesterday";

        return Qt.formatDateTime(messageTime, "MMMM dd");
    }

    function processNotificationBody(body, appName) {
        if (!body)
            return "";
        return String(body).replace(/\n/g, "<br/>");
    }
}

pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import qs.utils

Singleton {
    id: root

    property var popupNotifs: []
    property var allNotifs: []
    property bool notifOverlayOpen: false

    component NotifEntry: QtObject {
        id: wrapper
        property Notification source
        property string summary: ""
        property string body: ""
        property string appName: ""
        property string appIcon: ""
        property string image: ""
        property int urgency: 0
        property int expireTimeout: -1
        property double time: 0
        property var actions: []
        property bool lastGeneration: false
        property int count: 1

        function capture() {
            if (!source)
                return;
            summary = source.summary ?? "";
            body = source.body ?? "";
            appName = source.appName ?? "";
            appIcon = source.appIcon ?? "";
            image = source.image ?? "";
            urgency = source.urgency;
            expireTimeout = source.expireTimeout;
            actions = (source.actions ?? []).map(a => ({
                        identifier: a.identifier ?? "",
                        text: a.text ?? "",
                        _src: a,
                        invoke: function () {
                            try {
                                this._src?.invoke();
                            } catch (e) {}
                        }
                    }));
        }

        function dismiss() {
            try {
                source?.dismiss();
            } catch (e) {}
        }
    }

    Component {
        id: notifEntryComponent
        NotifEntry {}
    }

    function onNewNotif(notif) {
        const incoming = {
            appName: notif.appName ?? "",
            summary: notif.summary ?? ""
        };
        const dup = (!notif.lastGeneration && incoming.appName.length > 0)
            ? allNotifs.find(e => !e.lastGeneration && e.appName === incoming.appName && e.summary === incoming.summary)
            : null;

        if (dup) {
            dup.count++;
            dup.time = Date.now();
            allNotifs = [dup, ...allNotifs.filter(e => e !== dup)];
            if (!popupNotifs.includes(dup))
                popupNotifs = [dup, ...popupNotifs];
            if (!UiState.showSidebar)
                notifOverlayOpen = true;
            try { notif.dismiss(); } catch (e) {}
            return;
        }

        const entry = notifEntryComponent.createObject(root, {
            source: notif,
            time: Date.now(),
            lastGeneration: notif.lastGeneration ?? false
        });
        entry.capture();

        allNotifs = [entry, ...allNotifs];

        if (entry.lastGeneration)
            return;

        popupNotifs = [entry, ...popupNotifs];

        if (!UiState.showSidebar)
            notifOverlayOpen = true;

        notif.closed.connect(() => {
            root.notifDismissByNotif(entry);
        });
    }

    function notifDismissByNotif(entry) {
        popupNotifs = popupNotifs.filter(n => n !== entry);
        if (popupNotifs.length === 0)
            notifOverlayOpen = false;
    }

    function notifCloseByNotif(entry) {
        popupNotifs = popupNotifs.filter(n => n !== entry);
        allNotifs = allNotifs.filter(n => n !== entry);
        entry.dismiss();
        if (popupNotifs.length === 0)
            notifOverlayOpen = false;
    }

    function dismissAll() {
        popupNotifs = [];
        notifOverlayOpen = false;
    }

    function closeAll() {
        for (const e of allNotifs)
            e.dismiss();
        allNotifs = [];
        popupNotifs = [];
        notifOverlayOpen = false;
    }

    NotificationServer {
        id: notifServer
        persistenceSupported: true
        bodySupported: true
        bodyMarkupSupported: true
        bodyHyperlinksSupported: false
        bodyImagesSupported: false
        actionsSupported: true
        actionIconsSupported: false
        imageSupported: true

        onNotification: notif => {
            notif.tracked = true;
            notif.time = Date.now();
            root.onNewNotif(notif);
        }
    }
}

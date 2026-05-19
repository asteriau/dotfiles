import QtQuick
import qs.services
import qs.modules.sidebar.quickToggles.models

QuickToggleModel {
    readonly property bool ethernet: Network.ethernetConnected
    readonly property bool wifiOn: Network.wifiEnabled
    name: "Wi-Fi"
    icon: ethernet ? "lan" : (wifiOn ? "wifi" : "wifi_off")
    statusText: ethernet ? "Ethernet" : (wifiOn ? "On" : "Off")
    tooltipText: "Wi-Fi | Right-click to configure"
    toggled: ethernet || wifiOn
    available: !ethernet
    hasMenu: true
    mainAction: () => {
                    if (Network.ethernetConnected)
                    return;
                    Network.setWifiEnabled(!Network.wifiEnabled);
                }
}

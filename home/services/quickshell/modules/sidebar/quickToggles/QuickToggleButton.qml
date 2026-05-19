import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.sidebar.quickToggles
import qs.modules.sidebar.quickToggles.models

GroupButton {
    id: root

    required property int buttonIndex
    required property var buttonData
    required property bool expandedSize
    required property real baseCellWidth
    required property real baseCellHeight
    required property real cellSpacing
    required property int cellSize

    signal openMenu

    property QuickToggleModel toggleModel
    property string name: toggleModel?.name ?? ""
    property string statusText: (toggleModel?.hasStatusText) ? (toggleModel?.statusText || (toggled
                                                                                            ? "Active" :
                                                                                              "Inactive")) :
                                                               ""
    property string tooltipText: toggleModel?.tooltipText ?? ""
    property string buttonIcon: toggleModel?.icon ?? "close"
    property bool available: toggleModel?.available ?? true
    toggled: toggleModel?.toggled ?? false
    property var mainAction: toggleModel?.mainAction ?? null
    altAction: toggleModel?.hasMenu ? (() => root.openMenu()) : (toggleModel?.altAction ?? null)

    property bool editMode: false

    baseWidth: root.baseCellWidth * cellSize + cellSpacing * (cellSize - 1)
    baseHeight: root.baseCellHeight
    enableImplicitWidthAnimation: !editMode && root.mouseArea.containsMouse
    enableImplicitHeightAnimation: !editMode && root.mouseArea.containsMouse
    Behavior on baseWidth {
        NumberAnimation {
            duration: Appearance.motion.duration.elementMove
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Appearance.motion.easing.expressiveDefaultSpatial
        }
    }
    Behavior on baseHeight {
        NumberAnimation {
            duration: Appearance.motion.duration.elementMove
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Appearance.motion.easing.expressiveDefaultSpatial
        }
    }
    opacity: 0
    Component.onCompleted: opacity = 1
    Behavior on opacity {
        NumberAnimation {
            duration: Appearance.motion.duration.effects
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Appearance.motion.easing.expressiveEffects
        }
    }

    enabled: available || editMode
    padding: 6
    horizontalPadding: padding
    verticalPadding: padding

    colBackground: Appearance.colors.colLayer2
    colBackgroundToggled: (altAction && expandedSize) ? Appearance.colors.colLayer2 :
                                                        Appearance.colors.colPrimary
    colBackgroundToggledHover: (altAction && expandedSize) ? Appearance.colors.colLayer2Hover :
                                                             Appearance.colors.colPrimaryHover
    colBackgroundToggledActive: (altAction && expandedSize) ? Appearance.colors.colLayer2Active :
                                                              Appearance.colors.colPrimaryActive
    buttonRadius: toggled ? Appearance.layout.radiusXl : height / 2
    buttonRadiusPressed: Appearance.layout.radiusLg
    property color colText: (toggled && !(altAction && expandedSize) && enabled)
                            ? Appearance.colors.colOnPrimary : Qt.rgba(Appearance.colors.colOnLayer2.r,
                                                                       Appearance.colors.colOnLayer2.g,
                                                                       Appearance.colors.colOnLayer2.b,
                                                                       enabled ? 1 : 0.3)
    property color colIcon: expandedSize ? (toggled ? Appearance.colors.colOnPrimary :
                                                      Appearance.colors.colOnLayer3) : colText

    onClicked: {
        if (root.expandedSize && root.altAction)
            root.altAction();
        else if (root.mainAction)
            root.mainAction();
    }

    contentItem: RowLayout {
        spacing: 4
        anchors {
            centerIn: root.expandedSize ? undefined : parent
            fill: root.expandedSize ? parent : undefined
            leftMargin: root.horizontalPadding
            rightMargin: root.horizontalPadding
        }

        MouseArea {
            id: iconMouseArea
            hoverEnabled: true
            acceptedButtons: (root.expandedSize && root.altAction) ? Qt.LeftButton : Qt.NoButton
            Layout.alignment: Qt.AlignHCenter
            Layout.fillHeight: true
            Layout.topMargin: root.verticalPadding
            Layout.bottomMargin: root.verticalPadding
            implicitHeight: iconBackground.implicitHeight
            implicitWidth: iconBackground.implicitWidth
            cursorShape: Qt.PointingHandCursor
            onClicked: if (root.mainAction)
                           root.mainAction()

            Rectangle {
                id: iconBackground
                anchors.fill: parent
                implicitWidth: height
                radius: root.radius - root.verticalPadding
                color: {
                    const base = root.toggled ? Appearance.colors.colPrimary : Appearance.colors.colLayer3;
                    return (root.altAction && root.expandedSize) ? base : Qt.rgba(base.r, base.g, base.b, 0);
                }
                Behavior on color {
                    ColorAnimation {
                        duration: Appearance.motion.duration.effects
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Appearance.motion.easing.expressiveEffects
                    }
                }

                MaterialIcon {
                    anchors.centerIn: parent
                    fill: root.toggled ? 1 : 0
                    pixelSize: root.expandedSize ? 22 : 24
                    color: root.colIcon
                    text: root.buttonIcon
                }

                Loader {
                    anchors.fill: parent
                    active: (root.expandedSize && root.altAction)
                    sourceComponent: Rectangle {
                        radius: iconBackground.radius
                        color: Qt.rgba(root.colIcon.r, root.colIcon.g, root.colIcon.b,
                                       iconMouseArea.containsPress ? 0.12 : iconMouseArea.containsMouse
                                                                     ? 0.05 : 0)
                        Behavior on color {
                            ColorAnimation {
                                duration: Appearance.motion.duration.effects
                                easing.type: Easing.BezierSpline
                                easing.bezierCurve: Appearance.motion.easing.expressiveEffects
                            }
                        }
                    }
                }
            }
        }

        Loader {
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true
            visible: root.expandedSize
            active: visible
            sourceComponent: Column {
                width: parent ? parent.width : implicitWidth
                spacing: -2
                Text {
                    width: parent.width
                    font.family: Config.typography.family
                    font.pixelSize: Appearance.typography.smallie
                    font.weight: Font.DemiBold
                    color: root.colText
                    elide: Text.ElideRight
                    text: root.name
                }
                Text {
                    visible: root.statusText.length > 0
                    width: parent.width
                    font.family: Config.typography.family
                    font.pixelSize: Appearance.typography.smaller
                    font.weight: Font.Thin
                    color: root.colText
                    elide: Text.ElideRight
                    text: root.statusText
                }
            }
        }
    }

    TextTooltip {
        id: tip
        targetItem: root
        targetRect: Qt.rect(root.width / 2, root.height + Appearance.layout.gapSm, 0, 0)
        targetText: root.tooltipText
        visible: false
    }

    Timer {
        id: hideTimer
        interval: 220
        onTriggered: tip.visible = false
    }

    onHoveredChanged: {
        if (root.hovered && root.tooltipText !== "") {
            hideTimer.stop();
            tip.visible = true;
        } else if (tip.visible) {
            tip.shown = false;
            hideTimer.restart();
        }
    }

    MouseArea {
        id: editModeInteraction
        visible: root.editMode
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        acceptedButtons: Qt.AllButtons

        function nextList() {
            return Config.sidebar.quickToggles.toggles.map(t => ({
                                                                     size: t.size,
                                                                     type: t.type
                                                                 }));
        }
        function commit(next) {
            Config.sidebar.quickToggles.toggles = next;
        }
        function toggleEnabled() {
            const list = Config.sidebar.quickToggles.toggles;
            const type = root.buttonData.type;
            const idx = list.findIndex(t => t && t.type === type);
            let next = nextList();
            if (idx === -1)
                next.push({
                              size: 1,
                              type: type
                          });
            else
                next.splice(root.buttonIndex, 1);
            commit(next);
        }
        function toggleSize() {
            const list = Config.sidebar.quickToggles.toggles;
            const type = root.buttonData.type;
            if (!list.some(t => t && t.type === type))
                return;
            let next = nextList();
            next[root.buttonIndex].size = 3 - next[root.buttonIndex].size;
            commit(next);
        }
        function movePositionBy(offset) {
            const list = Config.sidebar.quickToggles.toggles;
            const type = root.buttonData.type;
            const target = root.buttonIndex + offset;
            if (!list.some(t => t && t.type === type))
                return;
            if (target < 0 || target >= list.length)
                return;
            let next = nextList();
            const tmp = next[root.buttonIndex];
            next[root.buttonIndex] = next[target];
            next[target] = tmp;
            commit(next);
        }

        onReleased: event => {
                        if (event.button === Qt.LeftButton)
                        toggleEnabled();
                    }
        onPressed: event => {
                       if (event.button === Qt.RightButton)
                       toggleSize();
                   }
        onPressAndHold: event => toggleSize()
        onWheel: event => {
                     if (event.angleDelta.y < 0)
                     movePositionBy(1);
                     else if (event.angleDelta.y > 0)
                     movePositionBy(-1);
                     event.accepted = true;
                 }
    }
}

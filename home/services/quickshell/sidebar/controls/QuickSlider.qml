import QtQuick
import QtQuick.Layouts
import qs.utils

// Port of ii's QuickSlider component (inline in QuickSliders.qml). Wraps
// StyledSlider with a primary material symbol on the right of the track that
// snaps onto the handle near full, and an optional secondary symbol at
// `iconLocation` along the track.
StyledSlider {
    id: quickSlider

    required property string materialSymbol
    property string secondaryMaterialSymbol: ""
    property real iconLocation: 0.3

    signal rightClicked

    configuration: StyledSlider.Configuration.M
    stopIndicatorValues: []
    dividerValues: secondaryMaterialSymbol.length > 0 ? [iconLocation] : []

    Text {
        id: icon
        property bool nearFull: quickSlider.value >= 0.9
        anchors {
            verticalCenter: quickSlider.verticalCenter
            right: nearFull ? quickSlider.handle.right : quickSlider.right
            rightMargin: nearFull ? 14 : 8
        }
        font.family: "Material Symbols Rounded"
        font.pixelSize: 20
        font.variableAxes: ({
            "FILL": 1,
            "wght": 500,
            "opsz": 20,
            "GRAD": 0
        })
        font.hintingPreference: Font.PreferNoHinting
        renderType: Text.NativeRendering
        color: nearFull ? Colors.colOnPrimary : Colors.colOnSecondaryContainer
        text: quickSlider.materialSymbol

        Behavior on color { Motion.ElementFastColor {} }
        Behavior on anchors.rightMargin { Motion.ElementFast {} }
    }

    Text {
        id: secondaryIcon
        visible: quickSlider.secondaryMaterialSymbol.length > 0
        property real iconLocation: quickSlider.iconLocation
        property bool nearIcon: iconLocation - quickSlider.value <= 0.1
            && iconLocation - quickSlider.value > (quickSlider.handleWidth + 8 - 14) / quickSlider.effectiveDraggingWidth
        anchors {
            verticalCenter: quickSlider.verticalCenter
            right: nearIcon ? quickSlider.handle.right : quickSlider.right
            rightMargin: nearIcon
                ? 14
                : (1 - iconLocation) * quickSlider.effectiveDraggingWidth + quickSlider.rightPadding + 8
        }
        font.family: "Material Symbols Rounded"
        font.pixelSize: 20
        font.variableAxes: ({
            "FILL": 1,
            "wght": 500,
            "opsz": 20,
            "GRAD": 0
        })
        font.hintingPreference: Font.PreferNoHinting
        renderType: Text.NativeRendering
        color: quickSlider.value >= iconLocation - 0.1
            ? Colors.colOnPrimary
            : Colors.colOnSecondaryContainer
        text: quickSlider.secondaryMaterialSymbol

        Behavior on color { Motion.ElementFastColor {} }
    }

    // Eat right-click before Slider's internal grab so the handle
    // doesn't jump on context-menu open.
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        preventStealing: true
        onPressed: (mouse) => {
            mouse.accepted = true;
            quickSlider.rightClicked();
        }
    }
}

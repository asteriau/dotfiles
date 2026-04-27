import QtQuick

Canvas {
    id: root

    property real amplitudeMultiplier: 1.0
    property real frequency: 6
    property color color: "#FFFFFF"
    property real lineWidth: 3
    property real fullLength: width
    property real phaseSpeed: 1.0
    property real phase: 0

    FrameAnimation {
        running: root.visible && root.phaseSpeed > 0
        onTriggered: {
            root.phase = (Date.now() / 400.0) * root.phaseSpeed;
            root.requestPaint();
        }
    }

    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    onColorChanged: requestPaint()

    onPaint: {
        const ctx = getContext("2d");
        ctx.clearRect(0, 0, width, height);
        if (width <= 0 || height <= 0)
            return;

        const amplitude = lineWidth * amplitudeMultiplier;
        const centerY = height / 2;

        ctx.strokeStyle = color;
        ctx.lineWidth = lineWidth;
        ctx.lineCap = "round";
        ctx.lineJoin = "round";
        ctx.beginPath();

        const startX = lineWidth / 2;
        const endX = width - lineWidth / 2;
        for (let x = startX; x <= endX; x += 1) {
            const waveY = centerY + amplitude * Math.sin(frequency * 2 * Math.PI * x / fullLength + phase);
            if (x === startX)
                ctx.moveTo(x, waveY);
            else
                ctx.lineTo(x, waveY);
        }
        ctx.stroke();
    }
}

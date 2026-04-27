import QtQuick

// Generic drifting layer. Caller supplies the drifting item by id via `cluster`
// and places it as a child of the layer; DriftLayer targets animations at that
// cluster for horizontal drift, vertical bob, and optional scale breathe, and
// hosts it inside a ParallaxGroup so it inherits scene parallax.
//
// Usage:
//   DriftLayer {
//       parallaxX: scene.parallaxX
//       parallaxY: scene.parallaxY
//       cluster: c
//       yFrac: 0.22; depth: 0.2; speed: 58000; reverse: true; bobAmp: 4; bobPeriod: 13000
//       CloudCluster { id: c; cloudSize: 95; tint: scene.baseTint }
//   }
Item {
    id: lyr

    // Caller-supplied target. All animations are no-ops while null.
    property Item cluster

    // Parallax forwarded to the internal ParallaxGroup.
    property real parallaxX: 0
    property real parallaxY: 0
    property real depth: 0.4
    property real depthY: depth

    // Layout & motion.
    property real yFrac: 0.5
    property real speed: 60000
    property real layerOpacity: 1.0
    property bool reverse: false
    property real bobAmp: 6
    property int  bobPeriod: 11000
    property int  driftEasing: Easing.Linear

    // Optional scale breathe (matches CloudsScene's original 0.98↔1.02 cycle).
    property bool scaleEnabled: true
    property real scaleMin: 0.98
    property real scaleMax: 1.02
    property int  scaleMinPeriod: 7000
    property int  scaleMaxPeriod: 11000

    // Randomize initial x so layers don't march in lockstep.
    property bool staggerPhase: true

    readonly property real _clusterW: cluster ? cluster.width  : 0
    readonly property real _clusterH: cluster ? cluster.height : 0
    readonly property real _baseY: height * yFrac - _clusterH / 2

    anchors.fill: parent

    // Children placed inside the layer become children of the ParallaxGroup,
    // so absolute positioning (x/y) applies within the parallax-translated frame.
    default property alias content: para.data

    ParallaxGroup {
        id: para
        parallaxX: lyr.parallaxX
        parallaxY: lyr.parallaxY
        depth:  lyr.depth
        depthY: lyr.depthY
    }

    Binding {
        target: lyr.cluster
        property: "opacity"
        value: lyr.layerOpacity
        when: lyr.cluster !== null
    }

    NumberAnimation {
        id: driftAnim
        target: lyr.cluster
        property: "x"
        duration: lyr.speed
        loops: Animation.Infinite
        running: lyr.cluster !== null
        easing.type: lyr.driftEasing
        from: lyr.reverse ? (lyr.width + lyr._clusterW) : -lyr._clusterW
        to:   lyr.reverse ? -lyr._clusterW : (lyr.width + lyr._clusterW)
    }

    SequentialAnimation {
        running: lyr.cluster !== null
        loops: Animation.Infinite
        NumberAnimation { target: lyr.cluster; property: "y"; from: lyr._baseY;              to: lyr._baseY + lyr.bobAmp; duration: lyr.bobPeriod;     easing.type: Easing.InOutSine }
        NumberAnimation { target: lyr.cluster; property: "y"; from: lyr._baseY + lyr.bobAmp; to: lyr._baseY - lyr.bobAmp; duration: lyr.bobPeriod * 2; easing.type: Easing.InOutSine }
        NumberAnimation { target: lyr.cluster; property: "y"; from: lyr._baseY - lyr.bobAmp; to: lyr._baseY;              duration: lyr.bobPeriod;     easing.type: Easing.InOutSine }
    }

    SequentialAnimation {
        running: lyr.scaleEnabled && lyr.cluster !== null
        loops: Animation.Infinite
        NumberAnimation { target: lyr.cluster; property: "scale"; from: lyr.scaleMin; to: lyr.scaleMax; duration: lyr.scaleMinPeriod + Math.random() * (lyr.scaleMaxPeriod - lyr.scaleMinPeriod); easing.type: Easing.InOutSine }
        NumberAnimation { target: lyr.cluster; property: "scale"; from: lyr.scaleMax; to: lyr.scaleMin; duration: lyr.scaleMinPeriod + Math.random() * (lyr.scaleMaxPeriod - lyr.scaleMinPeriod); easing.type: Easing.InOutSine }
    }

    // Match the legacy CloudsScene behavior: once width resolves, lock drift
    // endpoints to concrete values and randomize starting phase.
    Component.onCompleted: {
        if (!lyr.cluster) return;
        const cw = lyr.cluster.width;
        driftAnim.from = lyr.reverse ? lyr.width + cw : -cw;
        driftAnim.to   = lyr.reverse ? -cw : lyr.width + cw;
        if (lyr.staggerPhase) {
            const span = driftAnim.to - driftAnim.from;
            lyr.cluster.x = driftAnim.from + span * Math.random();
        }
    }
}

pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls

Control {
    id: root
    padding: 0

    property var valueWeights: [1]
    property var values: [0.5]
    property var valueHighlights: ["white"]
    property var valueTroughs: []

    readonly property var normalizedValueWeights: {
        const totalWeight = valueWeights.reduce((sum, weight) => sum + weight, 0)
        return valueWeights.map(weight => weight / totalWeight)
    }

    readonly property var visualEnds: {
        let cumsum = 0;
        let positions = [];
        for (let i = 0; i < normalizedValueWeights.length; i++) {
            cumsum += normalizedValueWeights[i];
            positions.push(cumsum);
        }
        return positions;
    }

    readonly property var visualPositions: {
        let positions = [];
        let lastEnd = 0;
        for(let i = 0; i < visualEnds.length; i++) {
            const thisEnd = visualEnds[i];
            const width = thisEnd - lastEnd;
            const thisPos = lastEnd + width * values[i];
            positions.push(thisPos);
            lastEnd = visualEnds[i];
        }
        return positions;
    }

    readonly property var visualSegments: {
        let segs = [];
        let lastEnd = 0;
        for(let i = 0; i < visualEnds.length; i++) {
            const thisEnd = visualEnds[i];
            const thisPos = visualPositions[i];
            segs.push([lastEnd, thisPos]);
            segs.push([thisPos, thisEnd]);
            lastEnd = visualEnds[i];
        }
        return segs;
    }

    readonly property var segmentColors: {
        var cols = [];
        for(let i = 0; i < valueHighlights.length; i++) {
            cols.push(valueHighlights[i]);
            cols.push(valueTroughs[i]);
        }
        return cols;
    }
}

import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

PlasmaCore.SvgItem {
    id: separatorLine
    anchors {
        horizontalCenter: parent.horizontalCenter
        topMargin: PlasmaCore.Units.smallSpacing
        bottomMargin: PlasmaCore.Units.smallSpacing
    }
    elementId: "horizontal-line"
    width: parent.width - PlasmaCore.Units.gridUnit * 2
    implicitHeight: 2
    svg: PlasmaCore.Svg {
        imagePath: "widgets/line"
    }
}
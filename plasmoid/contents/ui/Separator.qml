import QtQuick 2.0
import org.kde.ksvg 1.0 as KSvg

import org.kde.kirigami 2.0 as Kirigami

KSvg.SvgItem {
    id: separatorLine
    anchors {
        horizontalCenter: parent.horizontalCenter
        topMargin: Kirigami.Units.smallSpacing
        bottomMargin: Kirigami.Units.smallSpacing
    }
    elementId: "horizontal-line"
    width: parent.width - Kirigami.Units.gridUnit * 2
    implicitHeight: 2
    svg: KSvg.Svg {
        imagePath: "widgets/line"
    }
}
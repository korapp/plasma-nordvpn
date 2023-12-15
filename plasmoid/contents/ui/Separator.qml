import QtQuick
import org.kde.ksvg as KSvg

import org.kde.kirigami as Kirigami

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
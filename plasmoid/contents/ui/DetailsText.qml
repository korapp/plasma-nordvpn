import QtQuick 2.0

import org.kde.plasma.components 3.0 as PlasmaComponents

import org.kde.kirigami 2.3 as Kirigami

Column {
    property alias model: repeater.model

    Repeater {
        id: repeater
        property int contentHeight: 0
        property int longestString: 0

        Item {
            anchors {
                left: parent.left
                right: parent.right
            }
            height: Math.max(detailNameLabel.height, detailValueLabel.height)

            PlasmaComponents.Label {
                id: detailNameLabel

                anchors {
                    left: parent.left
                    leftMargin: repeater.longestString - paintedWidth + Math.round(Kirigami.Units.gridUnit / 2)
                }
                font.pointSize: Kirigami.Theme.smallFont
                horizontalAlignment: Text.AlignRight
                text: modelData[0] + ": "
                opacity: 0.6

                Component.onCompleted: {
                    if (paintedWidth > repeater.longestString) {
                        repeater.longestString = paintedWidth
                    }
                }
            }

            PlasmaComponents.Label {
                id: detailValueLabel

                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: repeater.longestString + Math.round(Kirigami.Units.gridUnit / 2)
                }
                elide: Text.ElideRight
                font.pointSize: Kirigami.Theme.smallFont
                text: modelData[1]
                textFormat: Text.PlainText
            }
        }
    }
}
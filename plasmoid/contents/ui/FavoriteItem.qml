import QtQuick 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.3

import org.kde.plasma.core 2.1 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3

PlasmaComponents3.ToolButton {
    property var contextMenu
    property bool busy: false
    enabled: !busy
    action: Action {
        onTriggered: {
            busy = true
            nordvpn.connect(model.connectionObject)
                .finally(() => busy = false)
        }
    }
    
    contentItem: RowLayout {
        PlasmaCore.IconItem {
            source: flags.isFlagString(model.icon) ? flags.getFlagImage(model.icon) : model.icon
            implicitWidth: PlasmaCore.Units.iconSizes.medium
            implicitHeight: PlasmaCore.Units.iconSizes.medium
            enabled: !busy

            PlasmaCore.IconItem {
                visible: !!model.indicator
                source: model.indicator
                width: parent.width / 2
                height: parent.height / 2
                enabled: parent.enabled
                anchors {
                    bottom: parent.bottom
                    right: parent.right
                }
            }
            
            PlasmaComponents3.BusyIndicator {
                running: true
                visible: busy
                anchors.centerIn: parent
            }
        }
        
        Column {
            PlasmaComponents3.Label {
                text: model.title
            }
            PlasmaComponents3.Label {
                text: model.subtitle || ''
                font.pointSize: PlasmaCore.Theme.smallestFont.pointSize
            }
        }
    }

    MouseArea {
        width: parent.width
        height: parent.height
        acceptedButtons: Qt.RightButton

        onPressed: {
            if (contextMenu) {
                contextMenu.open(mouse.x, mouse.y)
            }
        }
    }
}
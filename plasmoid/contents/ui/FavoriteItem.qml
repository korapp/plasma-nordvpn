import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import org.kde.plasma.components as PlasmaComponents3

import org.kde.kirigami as Kirigami

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
        Kirigami.Icon {
            source: resolveIcon(model.icon)
            implicitWidth: Kirigami.Units.iconSizes.medium
            implicitHeight: Kirigami.Units.iconSizes.medium
            enabled: !busy

            Kirigami.Icon {
                visible: !!model.indicator
                source: resolveIcon(model.indicator)
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
                font.pointSize: Kirigami.Theme.smallFont
            }
        }
    }

    MouseArea {
        width: parent.width
        height: parent.height
        acceptedButtons: Qt.RightButton
        onPressed: mouse => contextMenu?.popup(mouse.x, mouse.y)
    }
}
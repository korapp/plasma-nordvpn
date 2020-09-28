import QtQuick 2.15
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.2
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.0

import org.kde.plasma.components 2.0 as PlasmaComponents

ScrollView {
    id: serversList
    property alias model: menuListView.model
    property string nameRole
    signal selected(var item)
    
    ListView {
        id: menuListView
        highlight: PlasmaComponents.Highlight {}  
        
        currentIndex: model.length === 1 ? 0: -1
        highlightFollowsCurrentItem: true
        highlightMoveDuration: 0
        delegate: menuItem
        clip: true 
        keyNavigationEnabled: true
        section.property: "type";
        section.delegate: sectionHeading
        section.criteria: ViewSection.FullString  
    }

    Component {
        id: sectionHeading
        PlasmaComponents.Label {
            text: section
            font.bold: true
            font.pixelSize: 20
        }
    }

    Component {
        id: menuItem
        PlasmaComponents.ListItem {
            RowLayout {
                id: itemRow
                width: parent.width
                PlasmaComponents.Label {
                    text: model[nameRole]
                    ToolTip.text: text
                    ToolTip.visible: ma.containsMouse && menuListView.width < width

                    MouseArea {
                        id: ma
                        anchors.fill: parent
                        hoverEnabled: true
                    }
                }
            }

            MouseArea {
                height: itemRow.height;
                width: itemRow.width;
                onClicked: {
                    menuListView.currentIndex = index;
                    serversList.selected(menuListView.model.get(index));
                }
            }
        }
    }
}
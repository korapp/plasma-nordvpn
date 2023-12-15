import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras

import org.kde.kirigami as Kirigami

import "../code/globals.js" as Globals

PlasmaExtras.ExpandableListItem {
    property var connectionObject: ({})
    readonly property var connectionItemModel: model

    title: model.title
    subtitle: model.subtitle
    icon: resolveIcon(model.icon)
    iconEmblem: model.indicator
    visible: model.visible
    defaultActionButtonAction: model.isConnected ? actionDisconnect : actionConnect
    customExpandedViewContent: model.isConnected ? currentConnectionDetails : detailsComponent
    
    PlasmaComponents.Menu {
        id: contextMenu
        PlasmaComponents.MenuItem {
            text: kickerI18n("Add to Favorites")
            enabled: model.pinable
            icon.name: Globals.Icons.pin
            onClicked: addFavorite(getConnection())
        }
    }

    MouseArea {
        width: parent.width
        height: parent.height
        acceptedButtons: Qt.RightButton
        onPressed: mouse => contextMenu?.popup(mouse.x, mouse.y)
    }

    Component {
        id: detailsComponent
        RowLayout {
            Kirigami.Icon {
                source: Globals.Icons.location
                enabled: false
                visible: citySelector.visible
            }
            PlasmaComponents.ComboBox {
                id: citySelector
                Layout.fillWidth: true
                enabled: !!model && model.length > 1
                visible: !!connectionItemModel.connectionObject?.country
                onActivated: connectionObject.city = currentValue
                onVisibleChanged: {
                    if (!visible) return
                    nordvpn.getCities(connectionItemModel.connectionObject.country)
                        .then(c => {
                            model = c
                            currentIndex = model.length === 1 ? 0 : -1
                        });
                }
            }
            Kirigami.Icon {
                source: Globals.Icons.vpn
                enabled: false
                visible: serverGroupSelector.visible
            }
            
            PlasmaComponents.ComboBox {
                id: serverGroupSelector
                model: connectionItemModel.connectionObject?.country ? functionalGroups : allGroups
                currentIndex: model.length === 1 ? 0 : -1
                Layout.fillWidth: true
                onActivated: connectionObject.group = currentValue
            }
        }
    }

    Component {
        id: currentConnectionDetails
        DetailsText {
            model: Object.entries(nordvpn.status)
        }
    }

    Action {
        id: actionConnect
        text: nmI18n("Connect")
        onTriggered: {
            isBusy = true
            nordvpn.connect(getConnection()).finally(() => isBusy = false)
        }
        icon.name: Globals.Icons.connect
    }

    Action {
        id: actionDisconnect
        text: nmI18n("Disconnect")
        onTriggered: {
            isBusy = true
            nordvpn.disconnect().finally(() => isBusy = false)
        }
        icon.name: Globals.Icons.disconnect
    }

    function getConnection() {
        return Object.assign({}, connectionItemModel.connectionObject, connectionObject)
    }
}
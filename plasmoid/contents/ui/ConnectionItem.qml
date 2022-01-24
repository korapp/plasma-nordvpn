import QtQuick 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.3

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

import "../code/globals.js" as Globals

PlasmaExtras.ExpandableListItem {
    property var connectionObject: ({})
    readonly property var connectionItemModel: model

    title: model.title
    subtitle: model.subtitle
    icon: flags.isFlagString(model.icon) ? flags.getFlagImage(model.icon) : model.icon
    iconEmblem: model.indicator
    visible: model.visible
    defaultActionButtonAction: model.isConnected ? actionDisconnect : actionConnect
    customExpandedViewContent: model.isConnected ? currentConnectionDetails : detailsComponent
    contextMenu: model.pinable ? itemContextMenu : null

    PlasmaComponents.ContextMenu {
        id: itemContextMenu
        function prepare() {} // Implementation required by PlasmaExtras.ExpandableListItem
        PlasmaComponents.MenuItem {
            text: kickerI18n("Add to Favorites")
            icon: Globals.Icons.pin
            onClicked: addFavorite(getConnection())
        }
    }

    Component {
        id: detailsComponent
        RowLayout {
            PlasmaCore.IconItem {
                source: Globals.Icons.location
                enabled: false
                visible: citySelector.visible
            }
            ComboBox {
                id: citySelector
                Layout.fillWidth: true
                enabled: !!model && model.length > 1
                visible: !!connectionItemModel.connectionObject.country
                onActivated: connectionObject.city = currentValue
                Component.onCompleted: {
                    nordvpn.getCities(connectionItemModel.connectionObject.country)
                        .then(c => {
                            model = c
                            currentIndex = model.length === 1 ? 0 : -1
                        });
                }
            }
            PlasmaCore.IconItem {
                source: Globals.Icons.vpn
                enabled: false
                visible: serverGroupSelector.visible
            }
            
            ComboBox {
                id: serverGroupSelector
                model: connectionItemModel.connectionObject.country ? functionalGroups : allGroups
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
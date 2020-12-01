import QtQuick 2.4
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

import "globals.js" as Globals
import "helper.js" as Helper

Item {
    id: root
    Plasmoid.icon: plasmoid.configuration.icon
    Plasmoid.compactRepresentation: CompactRepresentation {}
    Plasmoid.fullRepresentation: FullRepresentation {}
    Plasmoid.toolTipSubText: nordvpn.textStatus
    Plasmoid.status: nordvpn.isServiceRunning ? PlasmaCore.Types.ActiveStatus : PlasmaCore.Types.PassiveStatus

    Plasmoid.switchWidth: units.gridUnit * 14
    Plasmoid.switchHeight: plasmoid.formFactor === PlasmaCore.Types.Vertical ? 1 : units.gridUnit * 10

    property ListModel favoriteConnections: ListModel {}
    property NordVPN nordvpn: NordVPN {}

    Component.onCompleted: {
        updateFavoritesModel();
    }

    Plasmoid.onContextualActionsAboutToShow: {
        plasmoid.clearActions()

        if (nordvpn.isConnected) {
            plasmoid.setAction(
                "disconnect",
                i18n("Disconnect"),
                Globals.Icons.disconnect
            )
        } else {
            plasmoid.setAction(
                "quick_connect",
                i18n("Quick connect"),
                Globals.Icons.connect
            )
        }

        Helper.forEach(favoriteConnections, (f, i) => {
            plasmoid.setAction(
                i,
                f.text,
                Globals.Icons.favorite
            )
        })
    }

    function action_disconnect() {
        nordvpn.disconnect()
    }

    function action_quick_connect() {
        nordvpn.connect()
    }

    function actionTriggered(action) {
        nordvpn.connect(buildConnectionString(favoriteConnections.get(action)))
    }

    function getFavorites() {
        return plasmoid.configuration.favoriteConnections.map(JSON.parse) || [];
    }

    function addOrRemoveFromFavorites(connection) {
        const selectionString = strigifySelection(connection)
        console.debug("addOrRemoveFromFavorites: ", selectionString)
        const connections = plasmoid.configuration.favoriteConnections
        const filteredConnections = connections.filter(c => c !== selectionString)
        if (filteredConnections.length === connections.length) {
            connections.push(selectionString)
            plasmoid.configuration.favoriteConnections = connections
        } else {
            plasmoid.configuration.favoriteConnections = filteredConnections
        }
        console.debug("favorites: ", plasmoid.configuration.favoriteConnections)
        updateFavoritesModel();
    }

    function isSavedAsFavorite(item) {
        for (var i = 0; i < favoriteConnections.count; i++) {
            if (favoriteConnections.get(i).text === item.text) {
                return true;
            }
        }
        return false;
    }

    function updateFavoritesModel() {
        favoriteConnections.clear();
        favoriteConnections.append(getFavorites());
    }

    function buildConnectionString({ majorServer, minorServer, specialServer }) {
        return [
            majorServer && majorServer.id,
            minorServer && minorServer.id,
            specialServer &&  '--group ' + specialServer.id
        ].filter(Boolean).join(' ')
    }

    function strigifySelection(selection) {
        return JSON.stringify(selection, (key, value) => {
            if (value) { 
                return value
            }
        })
    }
}
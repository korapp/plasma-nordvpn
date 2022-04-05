import QtQuick 2.4
import QtQuick.Layouts 1.1

import Qt.labs.platform 1.1

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

import "../code/globals.js" as Globals
import "../code/countries.js" as Country

Item {
    id: root
    Plasmoid.compactRepresentation: CompactRepresentation {}
    Plasmoid.fullRepresentation: FullRepresentation {}
    Plasmoid.toolTipSubText: getTooltipText()
    Plasmoid.status: nordvpn.isServiceRunning ? PlasmaCore.Types.ActiveStatus : PlasmaCore.Types.PassiveStatus

    Plasmoid.switchWidth: PlasmaCore.Units.gridUnit * 14
    Plasmoid.switchHeight: PlasmaCore.Units.gridUnit * 14

    readonly property var actionConnect: ["quick_connect", nmI18n("Connect"), Globals.Icons.connect]
    readonly property var actionDisconnect: ["disconnect", nmI18n("Disconnect"), Globals.Icons.disconnect]

    property var favoriteConnections: []

    NordVPN {
        id: nordvpn
        onError: {
            if (plasmoid.configuration.showNotifications) {
                createNotification(message)
            }
        }
    }

    Component.onCompleted: {
        loadFavorites()
    }

    Plasmoid.onContextualActionsAboutToShow: {
        plasmoid.clearActions()

        if (nordvpn.isConnected) {
            plasmoid.setAction(...actionDisconnect)
        } else {
            plasmoid.setAction(...actionConnect)
        }

        plasmoid.setActionSeparator("")

        favoriteConnections.forEach((f, i) => plasmoid.setAction(
            i,
            Object.values(f).filter(Boolean).join(" > "),
            (f.group && Globals.Icons[f.group]) || (f.country && flags.getLegacyFlagUrl(f.country)) || Globals.Icons.globe
        ))
    }

    PlasmaCore.Svg {
        id: flags
        imagePath: Qt.resolvedUrl("../images/flags.svgz")
        multipleImages: true

        readonly property string flagPrefix: "flag:"
        readonly property string legacyIconsDir: skipUrlSchema(StandardPaths.locate(
            StandardPaths.GenericDataLocation,
            "kf5/locale/countries/",
            StandardPaths.LocateDirectory
        ))

        function isFlagString(iconString) {
            return iconString && iconString.startsWith(flagPrefix)
        }

        function getFlagImage(flagName) {
            const countryCode = isFlagString(flagName) ? flagName.slice(flagPrefix.length) : flagName
            return image(Qt.size(48,48), countryCode)
        }

        function getFlagName(countryName) {
            return flagPrefix + Country.codes[countryName]
        }

        function getLegacyFlagUrl(countryName) {
            return legacyIconsDir + Country.codes[countryName].toLowerCase() + "/flag.png"
        }
    }

    function skipUrlSchema(urlString) {
        return /(?:.*:\/\/)?(.*)/.exec(urlString)[1]
    }

    function getFavoriteIcon(f) {
        if (f.group) {
            return Globals.Icons[f.group]
        } else if (f.country) {
            return flags.getLegacyFlagUrl(f.country)
        }
        return Globals.Icons.globe
    }

    Exec {
        id: cmd
    }

    PlasmaCore.DataSource {
        id: notificationSource
        engine: "notifications"
        connectedSources: "org.freedesktop.Notifications"
    }

    function createNotification(text, { appName = plasmoid.title, appIcon = plasmoid.icon } = {}) {        
        const service = notificationSource.serviceForSource("notification");
        const operation = service.operationDescription("createNotification");

        operation.appName = appName
        operation.appIcon = appIcon
        operation.body = text
        operation.expireTimeout = 5000

        service.startOperationCall(operation);
    }

    function getTooltipText() {
        return nordvpn.isConnected ? `${nordvpn.status.Country}, ${nordvpn.status.City}` : nordvpn.status.Status || ''
    }

    function action_disconnect() {
        nordvpn.disconnect()
    }

    function action_quick_connect() {
        nordvpn.connect()
    }

    function actionTriggered(action) {
        nordvpn.connect(favoriteConnections[action])
    }

    function readFavorites() {
        if (!plasmoid.configuration.favoriteConnections) {
            return []
        }
        return JSON.parse(plasmoid.configuration.favoriteConnections)
    }

    function saveFavorites(favorites) {
        plasmoid.configuration.favoriteConnections = stringify(favorites)
    }

    function addFavorite(connection) {
        favoriteConnections.push(connection)
        saveFavorites(favoriteConnections)
    }

    function deleteFavorite(index) {
        favoriteConnections.splice(index, 1)        
        saveFavorites(favoriteConnections)
    }

    function loadFavorites() {
        favoriteConnections = readFavorites()
    }

    function stringify(object) {
        return JSON.stringify(object, (key, value) => value || undefined)
    }

    function nmI18n(...args) {
        return i18nd("plasma_applet_org.kde.plasma.networkmanagement", ...args)
    }

    function nmI18nc(...args) {
        return i18ndc("plasma_applet_org.kde.plasma.networkmanagement", ...args)
    }

    function kickerI18n(...args) {
        return i18nd("plasma_applet_org.kde.plasma.kicker", ...args)
    }

}
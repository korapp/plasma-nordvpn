import QtQuick
import QtQuick.Layouts

import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.ksvg as KSvg
import org.kde.notification

import org.kde.kirigami as Kirigami

import "../code/globals.js" as Globals
import "../code/countries.js" as Country

PlasmoidItem {
    id: root
    compactRepresentation: CompactRepresentation {}
    fullRepresentation: FullRepresentation {}
    toolTipSubText: getTooltipText()
    switchWidth: Kirigami.Units.gridUnit * 14
    switchHeight: Kirigami.Units.gridUnit * 14

    Plasmoid.status: nordvpn.isServiceRunning && (nordvpn.isConnected || !plasmoid.configuration.hideWhenDisconnected)
        ? PlasmaCore.Types.ActiveStatus
        : PlasmaCore.Types.PassiveStatus
    Plasmoid.icon: Qt.resolvedUrl("../images/nordvpn.svgz")

    readonly property list<QtObject> staticContextualActions: [
        PlasmaCore.Action {
            text: nmI18n("Connect")
            icon.name: Globals.Icons.connect
            visible: !nordvpn.isConnected
            onTriggered: nordvpn.connect()
        },
        PlasmaCore.Action {
            text: nmI18n("Disconnect")
            icon.name: Globals.Icons.disconnect
            visible: nordvpn.isConnected
            onTriggered: nordvpn.disconnect()
        }
    ]

    property var favoriteConnections: []

    NordVPN {
        id: nordvpn
        onError: (message) => {
            if (plasmoid.configuration.showNotifications) {
                createNotification(message)
            }
        }
    }

    Component.onCompleted: {
        loadFavorites()
    }

    onContextualActionsAboutToShow: {
        const favActions = favoriteConnections.map(f => createPlasmaAction({
            text: Object.values(f).filter(Boolean).join(" > "),
            icon: getFavoriteIcon(f),
            onTriggered: nordvpn.connect.bind(f)
        }))
        Plasmoid.contextualActions = [...staticContextualActions, ...favActions]
    }

    KSvg.Svg {
        id: flags
        imagePath: Qt.resolvedUrl("../images/flags.svgz")
        multipleImages: true

        readonly property string flagPrefix: "flag:"

        function isFlagString(iconString) {
            return iconString && iconString.startsWith(flagPrefix)
        }

        function getFlagImage(flagName, size = Qt.size(48,48)) {
            const countryCode = isFlagString(flagName) ? flagName.slice(flagPrefix.length) : flagName
            return image(size, countryCode)
        }

        function getFlagName(countryName) {
            return flagPrefix + Country.codes[countryName]
        }
    }

    function resolveIcon(source) {
        return flags.isFlagString(source) ? flags.getFlagImage(source) : source
    }

    function getFavoriteIcon(f, flag) {
        return (f.group && Globals.Icons[f.group])
            || (flag && f.country && flags.getFlagName(f.country))
            || Globals.Icons.globe
    }

    Component {
        id: notificationComponent
        Notification {
            componentName: "plasma_workspace"
            eventId: "notification"
            title: plasmoid.title
            iconName: plasmoid.icon
            autoDelete: true
        }
    }

    function createNotification(text) {        
        notificationComponent.createObject(root, { text })?.sendEvent()
    }

    function getTooltipText() {
        return nordvpn.isConnected ? `${nordvpn.status.Country}, ${nordvpn.status.City}` : nordvpn.status.Status || ''
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

    Component {
        id: actionComponent
        PlasmaCore.Action {}
    }

    function createPlasmaAction({text, icon, visible = true, onTriggered} = {}) {
        const action = actionComponent.createObject(root, {
            text: text,
            'icon.name': icon
        })
        action.onTriggered.connect(onTriggered)
        return action
    }

    function stringify(object) {
        return JSON.stringify(object, (key, value) => value || undefined)
    }

    function nmI18n(...args) {
        return i18nd("plasma_applet_org.kde.plasma.networkmanagement", ...args)
    }

    function kickerI18n(...args) {
        return i18nd("plasma_applet_org.kde.plasma.kicker", ...args)
    }

}
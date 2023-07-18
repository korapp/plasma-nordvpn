import QtQuick 2.0

import "../code/countries.js" as Countries
import "../code/globals.js" as Globals

QtObject {
    property NordVPN source
    readonly property ListModel servers: ListModel {}
    property var allGroups: []
    property var functionalGroups: []
    
    readonly property var geoGroups: ['africa', 'asia', 'europe', 'america']
    readonly property var serverItemModel: ({
        title: '',
        subtitle: '',
        icon: '',
        indicator: '',
        connectionObject: {},
        isConnected: false,
        visible: true,
        pinable: true
    })

    function getCurrentConnectionItem() {
        if (!source.isConnected) {
            return createModel({
                visible: false,
                pinable: false
            })
        }
        return createModel({
            title: source.status.Country + ', ' + source.status.City,
            subtitle: nmI18n("Connected, ⬇ %1/s, ⬆ %2/s", ...parseTransferInfo(source.status.Transfer)),
            icon: flags.getFlagName(source.status.Country),
            isConnected: true,
            pinable: false
        })
    }

    function parseTransferInfo(text) {
        return text ? text.match(/\d+.\d+\s\w+/g) : []
    }

    function isGeoGroup(group) {
        return geoGroups.some(f => group.toLowerCase().includes(f))
    }

    function createModel(props = {}) {
        return Object.assign({}, serverItemModel, props)
    }

    function createQuickItemModel() {
        return createModel({
            title: i18n("Auto"),
            icon: Globals.Icons.quickconnect
        })
    }

    function createCountryModel(c) {
        return createModel({
            title: c,
            subtitle: Countries.codes[c],
            icon: flags.getFlagName(c),
            connectionObject: {
                country: c
            }
        })
    }

    function createFavoriteModel(f) {
        return createModel({
            icon: getFavoriteIcon(f, true),
            indicator: f.group && f.country ? flags.getFlagName(f.country) : '',
            title: f.group || f.city || f.country || i18n("Auto"),
            subtitle: f.group ? f.city || f.country : f.city ? f.country : '',
            connectionObject: f
        });
    }

    function loadData() {
        servers.clear()
        servers.append(getCurrentConnectionItem())
        servers.append(createQuickItemModel())

        source.getGroups().then(groups => {
            allGroups = groups
            functionalGroups = groups.filter(g => !isGeoGroup(g))
        })
        source.getCountries().then(c => servers.append(c.map(createCountryModel)))
        source.onStatusChanged.connect(updateCurrentConnectionItem)
    }

    function clear() {
        servers.clear()
        allGroups.length = 0
        functionalGroups.length = 0
        source.onStatusChanged.disconnect(updateCurrentConnectionItem)
    }

    function updateCurrentConnectionItem() {
        servers.set(0, getCurrentConnectionItem())
    }
}

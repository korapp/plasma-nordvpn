/*
NordVPN Commands:
    account        Shows account information
    cities         Shows a list of cities where servers are available
    connect, c     Connects you to VPN
    countries      Shows a list of countries where servers are available
    disconnect, d  Disconnects you from VPN
    groups         Shows a list of available server groups
    login          Logs you in
    logout         Logs you out
    rate           Rate your last connection quality (1-5)
    register       Registers a new user account
    set, s         Sets a configuration option
    settings       Shows current settings
    status         Shows connection status
    whitelist      Adds or removes an option from a whitelist
    help, h        Shows a list of commands or help for one command
*/

import QtQuick 2.2

import org.kde.plasma.core 2.0 as PlasmaCore

import "helper.js" as Helper

Item {
    property var status: ({})
    property var textStatus: ""
    property bool isConnected: false
    property bool isBusy: false
    property bool isServiceRunning: false 
    property var functionalGroups: []
    property ListModel servers: ListModel {}

    property var geoGroups: ['africa', 'asia', 'europe', 'america']

    signal connectionStateChange()

    PlasmaCore.DataSource {
        id: notification
        engine: "executable"
        connectedSources: []

        onNewData: {
             disconnectSource(sourceName)
        }

        function show(message) {
            const cmd = `kdialog --icon="/var/lib/nordvpn/icon.svg" --title="NordVPN" --passivepopup "${message}" 5`
            console.debug(cmd)
            connectSource(cmd)
        }
    }

    PlasmaCore.DataSource {
        id: statusSource
        engine: "executable"
        connectedSources: ["nordvpn status"]
        interval: 1000

        onNewData: {
            updateStatus(data)
        }
    }

    PlasmaCore.DataSource {
        id: execSource
        engine: "executable"
        connectedSources: []

        property var callbacks: ({})

        onNewData: {
            const stdout = data.stdout
            if (callbacks[sourceName] !== undefined) {
                if (!data["exit code"]) {
                    callbacks[sourceName].resolve(stdout)
                } else {
                    callbacks[sourceName].reject(stdout)
                }
            }

            exited(sourceName, stdout)
            disconnectSource(sourceName)
        }

        function exec(command) {
            return new Promise((resolve, reject) => {
                const cmd = 'nordvpn ' + command
                callbacks[cmd] = { resolve, reject }
                console.debug(cmd)
                connectSource(cmd)
            })
        }

        signal exited(string sourceName, string stdout)
    }

    function _connect(server, group) {
        isBusy = true
        if (server) {
            if (group) {
                return execSource.exec("connect " + server + " --group " + group)
            } else {
                return execSource.exec("connect " + server)
            }
        }
        return execSource.exec("connect")
    }

    function connect(server, group) {
        return _connect(server, group)
            .then(message => {
                isBusy = false
                return message
            })
            .catch(handleConnectionError)
    }

    function disconnect() {
        isBusy = true
        return execSource.exec("disconnect")
            .then(() => {
                isBusy = false
                return message
            })
            .catch(handleConnectionError)
    }

    function handleConnectionError(error) {
        console.error(error)
        notification.show(Helper.cleanStdout(error))
        isBusy = false
        throw error;
    }

    function getCountries() {
        return execSource.exec("countries").then(Helper.parseStdoutList)
    }

    function getCities(country) {
        return execSource.exec("cities " + country).then(Helper.parseStdoutList)
    }

    function getCitiesAsModel(country) {
        return getCities(country).then(c => Helper.mapStringsToModelObjects(c, { type: 'Cities' }));
    }

    function getGroups() {
        return execSource.exec("groups").then(Helper.parseStdoutList)
    }

    function updateStatus(data) {
        const isRunning = !data["exit code"]
        const stdout = Helper.cleanStdout(data.stdout)
        textStatus = stdout

        if (isRunning) { 
            status = Helper.parseStdoutProperties(stdout)
            const connected = status.Status === "Connected";
            if (connected != isConnected) {
                connectionStateChange(textStatus)
            }
            isConnected = connected
            if (!isServiceRunning) {
                loadLists();
            }
        }
        isServiceRunning = isRunning
    }

    function nonGeoGroupFilter(group) {
        return !geoGroups.some(f => group.id.toLowerCase().includes(f))
    }

    function loadLists() {
        servers.clear()
        Promise
            .all([
                getGroups(),
                getCountries()
            ])
            .then(([g, c]) => {
                const groups = Helper.mapStringsToModelObjects(g, { type: 'Special' });
                const countries = Helper.mapStringsToModelObjects(c, { type: 'Countries' });
                const nonGeoGroups = groups.filter(nonGeoGroupFilter);
                servers.append(groups);
                servers.append(countries); 
                functionalGroups = nonGeoGroups;
            })
    }
}
import QtQuick 2.0

import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    readonly property alias status: p.status
    readonly property alias errorMessage: p.errorMessage
    readonly property alias message: p.message
    readonly property alias isConnected: p.isConnected
    readonly property alias isServiceRunning: p.isServiceRunning

    readonly property var connect: p.connect
    readonly property var disconnect: p.disconnect
    readonly property var getCities: p.getCities
    readonly property var getCountries: p.getCountries
    readonly property var getGroups: p.getGroups
    readonly property var getSpecialGroups: p.getSpecialGroups
    readonly property var getGeoGroups: p.getGeoGroups
    readonly property bool isBusy: p.isConnecting || p.isOperationInProgress

    signal error(string message)

    PlasmaCore.DataSource {
        id: statusSource
        engine: "executable"
        connectedSources: ["nordvpn status"]
        interval: p.isOperationInProgress ? 0 : 1000
        onNewData: p.updateStatus(data)
    }

    Exec {
        id: execSource
    }
      
    QtObject {
        id: p
        property var status: ({})
        property string textStatus: ""
        property string errorMessage: ""
        property string message: ""
        property bool isOperationInProgress: false
        property bool isServiceRunning: false      
        readonly property bool isConnected: status.Status === "Connected"
        readonly property bool isConnecting: ["Reconnecting", "Connecting"].includes(status.Status) 

        function connect({ country, city, group } = {}) {
            var connectionString = 'nordvpn connect '
            if (arguments) {
                connectionString += buildConnectionString({ country, city, group })
            }
            
            return execBlockingCommand(connectionString)
        }

        function buildConnectionString({ country, city, group }) {
            const g = group ? '--group ' + formatArgument(group) : ''
            return `${formatArgument(country)} ${formatArgument(city) || ''} ${g}`
        }

        function disconnect() {
            return execBlockingCommand("nordvpn disconnect")
        }

        function execBlockingCommand(command) {
            isOperationInProgress = true
            return execSource.exec(command)
                //.then(() => message)
                .catch(handleConnectionError)
                .finally(() => isOperationInProgress = false)
        }

        function getCountries() {
            return get("countries")
        }

        function getCities(country) {
            return get(`cities ${formatArgument(country)}`)
        }

        function getGroups() {
            return get("groups")
        }

        function get(resource) {
            return execSource.exec(`nordvpn ${resource}`).then(processStdoutValues)
        }        

        // Format NordVPN names
        function prettyName(name) {
            return name && name.replace(/_/g, ' ');
        }

        // Format NordVPN id
        function formatArgument(name) {
            return name ? name.replace(/\s/g, '_') : ''
        }
        
        // Log, display and rethrow error
        function handleConnectionError(e) {
            const ce = cleanStdout(e)
            console.error(ce)
            error(ce)
            throw ce
        }

        // Trim white spaces and progress 'animation' characters: \|/-
        function cleanStdout(text) {
            return text && text.trim().replace(/^[|\/\\-\s]+/, '');
        }

        // Split raw NordVPN response to actual response and side message
        function splitOutputs(stdout) {
            const outputs = stdout && stdout.split(/^-\s*/gm);
            if (outputs.length > 1) {
                return {
                    message: outputs[1],
                    rawValue: outputs[2]
                }
            }
            return {
                message: '',
                rawValue: outputs[0]
            }
        }

        // Parse text properties into object
        function parseStdoutProperties(text) {
            if (!text) {
                return {}
            }
            const lines = text.split('\n');
            const entries = lines.map(l => l.split(':').map(e => e.trim()));
            return objectfromEntries(entries);
        }

        function objectfromEntries(entries) {
            return entries.reduce((obj, prop) => (obj[prop[0]] = prop[1], obj), {});
        }

        // Parse string values to list
        function processStdoutValues(text) {
            const rawValue = splitOutputs(text).rawValue;
            const cleanValue = cleanStdout(rawValue);
            return cleanValue.split(', ').map(prettyName);
        }
        
        function updateStatus(data) {
            const isRunning = !data["exit code"]
            if (!isRunning) {
                errorMessage = cleanStdout(data.stderr || data.stdout)
                textStatus = ""
                status = {}
            } else {
                const stdout = splitOutputs(data.stdout)
                const newTextStatus = cleanStdout(stdout.rawValue)
                message = stdout.message
                errorMessage = ""
                if (textStatus != newTextStatus) {                  
                    textStatus = newTextStatus
                    status = Qt.binding(() => parseStdoutProperties(textStatus))
                }
            }
            isServiceRunning = isRunning           
        }
    }
    
}
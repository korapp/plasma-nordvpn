import QtQuick

import org.kde.plasma.plasma5support as P5Support

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

    P5Support.DataSource {
        id: statusSource
        engine: "executable"
        connectedSources: ["nordvpn status"]
        interval: {
            if (p.isOperationInProgress) return 0
            if (p.isServiceRunning) return 1000
            return Math.random() * 5000 + 5000 | 0
        }
        onNewData: (_, data) => p.updateStatus(data)
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
            return `${g} ${formatArgument(country)} ${formatArgument(city)}`
        }

        function disconnect() {
            return execBlockingCommand("nordvpn disconnect")
        }

        function execBlockingCommand(command) {
            isOperationInProgress = true
            return execSource.exec(command)
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
            return execSource
                .exec(`nordvpn ${resource}`)
                .then(parseStdout)
                .then(s => parseStdoutValues(s.value))
        }        

        // Format NordVPN names
        function prettyName(name) {
            const minorWords = ['And', 'Of']
            return name.split('_').map(w => minorWords.includes(w) 
                ? w.toLowerCase()
                : w.replace(/[a-z].+[A-Z]/g, x => x.toLowerCase())
            ).join(' ')
        }

        // Format NordVPN id
        function formatArgument(name) {
            return name ? '"' + name.replace(/\s/g, '_') + '"' : ''
        }
        
        // Log, display and rethrow error
        function handleConnectionError(e) {
            const ce = parseStdout(e).value
            console.error(ce)
            error(ce)
            throw ce
        }

        // Split raw NordVPN response to actual response and side message
        function parseStdout(stdout) {
            const [value, message = ''] = stdout && stdout
                .split(/\r[-\\|/\s]+\r/)
                .map(s => s.trim())
                .filter(Boolean)
                .reverse()

            return { message, value }
        }

        // Parse text properties into object
        function parseStdoutProperties(text) {
            if (!text) {
                return {}
            }
            const lines = text.split('\n');
            const entries = lines.map(l => l.split(': '));
            return objectFromEntries(entries);
        }

        function objectFromEntries(entries) {
            return entries.reduce((obj, prop) => (obj[prop[0]] = prop[1], obj), {});
        }

        // Parse string values to list
        function parseStdoutValues(text) {
            return text.split(/\n/).map(prettyName);
        }
        
        function updateStatus(data) {
            const isRunning = !data["exit code"]
            if (!isRunning) {
                errorMessage = parseStdout(data.stderr || data.stdout).value
                message = ""
                textStatus = ""
                status = {}
            } else {
                const stdout = parseStdout(data.stdout)
                const newTextStatus = stdout.value
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

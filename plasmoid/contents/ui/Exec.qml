import QtQuick 2.0

import org.kde.plasma.core 2.0 as PlasmaCore

import "../code/polyfills.js" as Polyfills

PlasmaCore.DataSource {
    engine: "executable"

    readonly property var callbacks: ({})

    onNewData: {
        const { stdout } = data
        if (callbacks[sourceName] !== undefined) {
            if (!data["exit code"]) {
                callbacks[sourceName].resolve(stdout)
            } else {
                callbacks[sourceName].reject(stdout)
            }
            delete callbacks[sourceName]
        }
        disconnectSource(sourceName)
    }

    function exec(cmd) {
        if (callbacks[cmd]) {
            return callbacks[cmd].promise
        }
        let resolve, reject, promise = new Promise((_resolve, _reject) => {
            resolve = _resolve
            reject = _reject
        })
        callbacks[cmd] = { resolve, reject, promise }
        connectSource(cmd)
        return promise
    }
}
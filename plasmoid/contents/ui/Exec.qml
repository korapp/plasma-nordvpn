import QtQuick 2.0

import org.kde.plasma.plasma5support 2.0 as P5Support

import "../code/polyfills.js" as Polyfills

P5Support.DataSource {
    engine: "executable"

    readonly property var callbacks: ({})

    onNewData: function (sourceName, data) {
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
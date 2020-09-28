import QtQuick 2.15

import "helper.js" as Helper

Item {
    id: selection
    property var majorServer: null;
    property var minorServer: null;
    property var specialServer: null;
    property string text: ''

    signal change()

    function getProperties() {
        return {
            majorServer,
            minorServer,
            specialServer,
            text
        }
    }

    function setServers(s) {
        majorServer = s.majorServer
        minorServer = s.minorServer
        specialServer = s.specialServer
        updateText();
        change();
    }

    function setMajorServer(s) {
        majorServer = s;
        minorServer = null;
        updateText();
        change()
    }

    function setMinorServer(s) {
        minorServer = s;
        updateText();
        change();
    }

    function setSpecialServer(s) {
        specialServer = s;
        updateText();
        change();
    }

    function updateText() {
        selection.text = Helper.createBreadcrumbs([majorServer, minorServer, specialServer])
    }
}
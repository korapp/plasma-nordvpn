import QtQuick

import org.kde.plasma.components as PlasmaComponents3
import org.kde.ksvg as KSvg

import org.kde.kirigami as Kirigami

import "../code/countries.js" as Countries

MouseArea {
    hoverEnabled: true
    acceptedButtons: Qt.LeftButton | Qt.MiddleButton
    readonly property int minSize: Math.min(width, height)
    
    KSvg.SvgItem {
        svg: KSvg.Svg {
            imagePath: plasmoid.icon
        }  
        enabled: nordvpn.isConnected
        opacity: enabled ? 1 : 0.6
        width: minSize
        height: minSize

        anchors.centerIn: parent

        Kirigami.Icon {
            visible: plasmoid.configuration.showCountryIndicator && nordvpn.isConnected
            source: visible ? flags.getFlagImage(Countries.codes[nordvpn.status.Country], Qt.size(width, height)) : ''
            enabled: true
            roundToIconSize: false

            anchors.right: parent.right
            anchors.bottom: parent.bottom

            implicitWidth: parent.width / 2
            implicitHeight: parent.height / 2
        }

        PlasmaComponents3.BusyIndicator {
            running: true
            visible: nordvpn.isBusy
            anchors.fill: parent
        }
    }

    onClicked: function (mouse) {
        if (plasmoid.configuration.toggleConnectionOnMiddleButton && mouse.button === Qt.MiddleButton) {
            toggleConnection()
        } else {
            toggleExpanded()
        }
    }

    function toggleConnection() {
        nordvpn.isConnected ? nordvpn.disconnect() : nordvpn.connect()
    }

    function toggleExpanded() {
        root.expanded = !root.expanded
    }
}
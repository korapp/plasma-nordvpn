import QtQuick 2.0
import QtQuick.Layouts 1.3

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

Item {
    property bool useCustomIcon: Boolean(plasmoid.icon.includes('.'))

    PlasmaCore.IconItem {
        id: icon
        source: plasmoid.icon
        anchors.fill: parent
        enabled: nordvpn.isConnected
        visible: !useCustomIcon
    }

    PlasmaCore.SvgItem{
        property int size: Math.min(parent.height, parent.width)
        anchors.centerIn: parent
        opacity: nordvpn.isConnected ? 1 : 0.6
        svg: svgIcon
        width: size
        height: size
        visible: useCustomIcon
    }

    PlasmaCore.Svg {
        id: svgIcon
        imagePath: Qt.resolvedUrl(plasmoid.icon)
    }

    PlasmaComponents.BusyIndicator {
        running: true
        visible: nordvpn.isBusy
        anchors.fill: parent
    }

    MouseArea {
        id: mouseArea
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        anchors.fill: parent
        hoverEnabled: true

        onClicked: {
            if (plasmoid.configuration.toggleConnectionOnMiddleButton && mouse.button === Qt.MiddleButton) {
                quickConnectOrDisconnect()
            } else {
                toggleExpanded()
            }
        }

        function quickConnectOrDisconnect() {
            nordvpn.isConnected ? nordvpn.disconnect() : nordvpn.connect()
        }

        function toggleExpanded() {
            plasmoid.expanded = !plasmoid.expanded
        }
    }
}
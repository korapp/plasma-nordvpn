import QtQuick 2.0
import QtQuick.Layouts 1.3

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import "globals.js" as Globals

ColumnLayout {
    property alias message: errorMessage.text

    PlasmaCore.IconItem {
        source: Globals.Icons.error
        width: units.iconSizes.large
        height: units.iconSizes.large
        Layout.alignment: Qt.AlignCenter
    }

    PlasmaComponents.Label {
        id: errorMessage
        Layout.alignment: Qt.AlignCenter
    }
}
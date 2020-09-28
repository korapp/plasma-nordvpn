import QtQuick 2.3
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.1

import org.kde.kirigami 2.4 as Kirigami

import "globals.js" as Globals

Kirigami.FormLayout {
    id: generalPage

    property alias cfg_icon: iconSelector.icon
    property alias cfg_toggleConnectionOnMiddleButton: toggleConnectionOnMiddleButton.checked

    RowLayout {
        ButtonGroup {
            id: iconSelector
            property string icon
            exclusive: true
            onClicked: {
                icon = button.value
            }            
        }
        Kirigami.FormData.label: i18n ("Icon:")
        RowLayout {
            id: iconSelectorButtons
            Button {
                id: customIcon
                icon.source: "../images/nordvpn.svg"
                icon.height: 80
                icon.width: 80
                checked: value === iconSelector.icon
                ButtonGroup.group: iconSelector
                property string value: icon.source
            }
            
            Button {
                id: systemIcon
                icon.name: Globals.Icons.main
                icon.height: 80
                icon.width: 80
                checked: value === iconSelector.icon
                ButtonGroup.group: iconSelector
                property string value: icon.name
            }
        }
    }

    CheckBox {
        id: toggleConnectionOnMiddleButton
        text: i18n("Toggle connection on middle mouse button")
        Kirigami.FormData.label: i18n ("Compact view:")
    }
}
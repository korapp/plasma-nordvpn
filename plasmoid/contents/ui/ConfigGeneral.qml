import QtQuick 2.0
import QtQuick.Controls 2.0

import org.kde.kirigami 2.3 as Kirigami

Kirigami.FormLayout {
    id: generalPage

    property alias cfg_toggleConnectionOnMiddleButton: toggleConnectionOnMiddleButton.checked
    property alias cfg_showCountryIndicator: showCountryIndicator.checked
    property alias cfg_hideWhenDisconnected: hideWhenDisconnected.checked
    property alias cfg_showNotifications: showNotifications.checked

    CheckBox {
        id: toggleConnectionOnMiddleButton
        Kirigami.FormData.label: i18n("Toggle connection on middle mouse button")
    }

    CheckBox {
        id: showCountryIndicator
        Kirigami.FormData.label: i18n("Show country indicator")
    }

    CheckBox {
        id: hideWhenDisconnected
        Kirigami.FormData.label: i18n("Hide when VPN is disconnected")
    }

    CheckBox {
        id: showNotifications
        Kirigami.FormData.label: i18n("Show notifications")
    }
}
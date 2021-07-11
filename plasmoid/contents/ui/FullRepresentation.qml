import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import QtQuick.Controls.Styles 1.4

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

import "globals.js" as Globals
import "helper.js" as Helper

Item {
    Layout.preferredHeight: 500 * units.devicePixelRatio
    Layout.preferredWidth: 640 * units.devicePixelRatio

    property var minorServerList: []
    
    ServerSelection {
        id: serverSelection
        onChange: {
            favoriteCheckBox.checked = root.isSavedAsFavorite(serverSelection)
        }
    }

    function majorServerSelected(s) {
        if (s.type === 'Countries') {
            loadMinorServerList(s);
        } else {
            minorServerList.length = 0;
            serverSelection.setSpecialServer();
        }
        serverSelection.setMajorServer(s);
    }

    function loadMinorServerList(major) {
        return nordvpn
            .getCitiesAsModel(major.id)
            .then(cities => {
                minorServerList = cities
            });
    }

    function favoriteSelected(item) {
        loadMinorServerList(item.majorServer).then(() => {
            serverSelection.setServers(item);
        })
    }

    function setComboBoxSelectedItem(combo, item) {
        const index = item ? combo.model.findIndex(m => m && m.id === item.id) : -1
        combo.currentIndex = index;
    }

    Message {
        id: errorView
        visible: !nordvpn.isServiceRunning
        message: nordvpn.textStatus
        anchors.centerIn: parent
    }

    ColumnLayout {
        visible: nordvpn.isServiceRunning
        anchors.fill: parent

        RowLayout{
            Layout.fillHeight: false
            PlasmaComponents.TextField {
                Layout.fillWidth: true
                id: filter
                placeholderText: i18n("Search...")
                clearButtonShown: true
                focus: true
                onAccepted: () => nordvpn.connect(text)
            }
            StackLayout {
                Layout.fillWidth: false
                id: quickConnectButtons
                currentIndex: nordvpn.isConnected ? 1 : 0
                
                PlasmaComponents.Button {
                    id: connect
                    text: i18n("Quick connect")
                    iconSource: Globals.Icons.quickconnect
                    onClicked: nordvpn.connect()
                }
                
                PlasmaComponents.Button {
                    id: disconnect
                    text: i18n("Disconnect")
                    iconSource: Globals.Icons.disconnect
                    onClicked: nordvpn.disconnect()
                }
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignTop
            
            ColumnLayout {
                Layout.alignment: Qt.AlignTop
                Layout.maximumWidth: 180
                Layout.minimumWidth: 180
                
                PlasmaComponents.TabBar {
                    id: tabBar
                    currentTab: favoriteView.model.count ? favoriteView : groupsView
                    
                    PlasmaComponents.TabButton {
                        text: i18n("Servers")
                        tab: groupsView
                    }

                    PlasmaComponents.TabButton {
                        text: i18n("Favorites")
                        tab: favoriteView
                        visible: root.favoriteConnections.count
                    }
                }

                PlasmaComponents.TabGroup {
                    id: tabGroup
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    
                    currentTab: tabBar.currentTab
                    
                    ServersList {
                        id: favoriteView
                        model: PlasmaCore.SortFilterModel {
                            sourceModel: root.favoriteConnections
                            filterRole: "text"
                            filterRegExp: filter.text
                        }
                        nameRole: "text"
                        onSelected: favoriteSelected(item)
                    }
                
                    ServersList {
                        id: groupsView
                        model: PlasmaCore.SortFilterModel {
                            sourceModel: nordvpn.servers
                            filterRole: "text"
                            filterRegExp: filter.text
                        }
                        nameRole: "text"
                        onSelected: majorServerSelected(item)
                    }
                }
            }

            ColumnLayout {
                Layout.alignment: Qt.AlignTop

                RowLayout {
                    Layout.fillHeight: false
                    PlasmaComponents.Label {
                        text: serverSelection.text || i18n("Select server")
                        Layout.fillWidth: true
                    }
                    PlasmaComponents.CheckBox {
                        id: favoriteCheckBox
                        style: CheckBoxStyle {
                            indicator: PlasmaComponents.ToolButton {
                                iconSource: Globals.Icons.favorite
                                enabled: control.checked
                            }
                        }
                        onClicked: addOrRemoveFromFavorites(serverSelection.getProperties())
                    }
                }

                ColumnLayout{
                    property bool enabled: (serverSelection.majorServer && serverSelection.majorServer.type === 'Countries')
                    
                    ComboBox {
                        id: minorServer
                        model: [null, ...minorServerList]
                        textRole: "text"
                        displayText: currentText || i18n('Any city')
                        Layout.fillWidth: true
                        onActivated: serverSelection.setMinorServer(model[index])
                        enabled: parent.enabled
                        Connections {
                            target: serverSelection
                            onChange: () => setComboBoxSelectedItem(minorServer, serverSelection.minorServer)
                        }
                    }

                    ComboBox {
                        id: specialServer
                        model: [null, ...nordvpn.functionalGroups]
                        textRole: "text"
                        displayText: currentText || i18n('Any server')
                        Layout.fillWidth: true
                        onActivated: serverSelection.setSpecialServer(model[index])
                        enabled: parent.enabled
                        Connections {
                            target: serverSelection
                            onChange: () => setComboBoxSelectedItem(specialServer, serverSelection.specialServer)
                        }
                    }
                }

                PlasmaComponents.Button {
                    text: i18n("Connect")
                    onClicked: nordvpn.connect(root.buildConnectionString(serverSelection))
                    iconSource: Globals.Icons.connect
                    enabled: serverSelection.majorServer
                    Layout.alignment: Qt.AlignRight
                }

                PlasmaComponents.Label {
                    text: nordvpn.textStatus
                    Layout.fillWidth: true
                }
            }
        }
        
        PlasmaComponents.Label {
            id: statusBar
            Layout.alignment: Qt.AlignCenter
            enabled: false
            visible: !!nordvpn.message
            text: nordvpn.message
            elide: Text.ElideRight
        }
    }
}

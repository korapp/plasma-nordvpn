import QtQuick 2.7
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.5

import org.kde.plasma.core 2.1 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents // for Highlight, ContextMenu, MenuItem
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.extras 2.0 as PlasmaExtras

import "../code/globals.js" as Globals

PlasmaComponents3.Page {
    readonly property var appletInterface: plasmoid.self
    
    property ListModel favorites: ListModel {}
    property alias servers: nordVpnModel.servers
    property alias allGroups: nordVpnModel.allGroups
    property alias functionalGroups: nordVpnModel.functionalGroups

    NordVPNModel {
        id: nordVpnModel
        source: nordvpn
    }
    
    Connections {
        target: plasmoid
        onExpandedChanged: {
            if (expanded) {
                loadFavorites()
                root.onFavoriteConnectionsChanged.connect(loadFavorites)
                nordVpnModel.loadData()
            } else {
                nordVpnModel.clear()
                root.onFavoriteConnectionsChanged.disconnect(loadFavorites)
                favorites.clear()
            }
        }
    }

    function loadFavorites() {
        favorites.clear()
        favorites.append(root.favoriteConnections.map(nordVpnModel.createFavoriteModel))
    }

    function addFavorite(connection) {
        root.addFavorite(connection)
        favorites.append(nordVpnModel.createFavoriteModel(connection))
    }

    function deleteFavorite(index) {
        favorites.remove(index)
        root.deleteFavorite(index)
    }

    footer: PlasmaComponents3.Label {
        id: statusBar
        Layout.alignment: Qt.AlignCenter
        Layout.preferredWidth: parent.width
        maximumLineCount: 1
        enabled: false
        visible: !!nordvpn.message
        text: nordvpn.message
        elide: Text.ElideRight
    }

    PlasmaExtras.PlaceholderMessage {
        text: nordvpn.errorMessage
        iconName: Globals.Icons.error
        visible: !!text
        width: parent.width
        anchors.centerIn: parent
    }

    ColumnLayout {
        anchors.fill: parent
        visible: nordvpn.isServiceRunning

        PlasmaComponents3.ScrollView {
            Layout.fillWidth: true
            implicitHeight: PlasmaCore.Units.iconSizes.large
            visible: favorites.count > 0
            ListView {
                currentIndex: -1
                orientation: ListView.Horizontal
                boundsBehavior: Flickable.StopAtBounds
                model: favorites
                delegate: FavoriteItem {
                    contextMenu: PlasmaComponents.ContextMenu {
                        PlasmaComponents.MenuItem {
                            text: kickerI18n("Remove from Favorites")
                            icon: Globals.Icons.unpin
                            onClicked: deleteFavorite(index)
                        }
                    }
                }
                add: Transition {
                    NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: PlasmaCore.Units.longDuration }
                    NumberAnimation { property: "scale"; from: 0.0; to: 1.0; duration: PlasmaCore.Units.longDuration }
                }
                remove: Transition {
                    NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: PlasmaCore.Units.longDuration }
                    NumberAnimation { property: "scale"; from: 1.0; to: 0.0; duration: PlasmaCore.Units.longDuration }
                }   
            }
        }
        PlasmaComponents3.TextField {
            Layout.fillWidth: true
            id: filter
            placeholderText: nmI18nc("text field placeholder text", "Search…") // Plasma 5.23 uses ellipsis character
            clearButtonShown: true
            focus: plasmoid.expanded
            onAccepted: serverList.currentItem.defaultActionButtonAction.trigger()
            Keys.onUpPressed: serverList.decrementCurrentIndex()
            Keys.onDownPressed: serverList.incrementCurrentIndex()
        }

        PlasmaComponents3.ScrollView {
            Layout.fillHeight: true
            Layout.fillWidth: true
            
            ListView {
                id: serverList
                currentIndex: -1
                spacing: PlasmaCore.Units.smallSpacing
                boundsBehavior: Flickable.StopAtBounds
                highlight: PlasmaComponents.Highlight {}  
                highlightFollowsCurrentItem: true
                highlightMoveDuration: 0
                highlightResizeDuration: 0
                delegate: ConnectionItem {
                    width: serverList.width
                }
                clip: true
                keyNavigationEnabled: true
                section.property: "isConnected"
                section.delegate: Separator {}
                model: PlasmaCore.SortFilterModel {
                    sourceModel: servers
                    filterString: filter.text
                    sortRole: "title"
                    sortOrder: Qt.DescendingOrder
                    filterCallback: function(row) {
                        const item = sourceModel.get(row)
                        return textMaches(item.title, filter.text) || textMaches(item.subtitle, filter.text)
                    }

                    function textMaches(text, search) {
                        return !!text && text.toLowerCase().startsWith(search.toLowerCase())
                    }
                }
                add: Transition {
                    NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: PlasmaCore.Units.longDuration }
                }
                onCountChanged: {
                    // select single result
                    currentIndex = count === 1 ? 0 : -1
                }
            }
        }
    }
}

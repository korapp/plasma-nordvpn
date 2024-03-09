import QtQuick

import org.kde.notification

QtObject {
    property list<QtObject> children: [
        Component {
            id: notificationComponent
            Notification {
                componentName: "plasma_workspace"
                eventId: "notification"
                title: plasmoid.title
                iconName: plasmoid.icon
                autoDelete: true

                function setActions(actions) {
                    this.actions = actions.map(a => createAction(this, a))
                }
            }
        },
        Component {
            id: notificationActionComponent
            NotificationAction {}
        }
    ]

    function show(text, actions) {
        create(text, actions).sendEvent()
    }

    function create(text, actions) {        
        const notification = notificationComponent.createObject(root, { text })
        if (actions) notification.setActions(actions)
        return notification
    }

    function createAction(notification, { label, onActivated } = {}) {
        const action = notificationActionComponent.createObject(notification, { label })
        action.onActivated.connect(onActivated)
        return action
    }
}
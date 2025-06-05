import QtQuick
import CustomModels 1.0
import Qt5Compat.GraphicalEffects

Item {
    Rectangle {
        id: refreshRectangle
        anchors.right: parent.right
        anchors.top: parent.top
        border.width: 1
        border.color: themeLoader.item.popoutBorderColor
        width: 30
        height: 30
        radius: 50
        color: themeLoader.item.popoutBackgroundColor
        z: 2
        clip: true

        Text {
            z: 3
            id: refreshText
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 20
            font.bold: true
            font.family: "Verdana"
            font.pixelSize: 10
            text: qsTr("Refresh RetroAchievements Data")
            color: themeLoader.item.popoutTextColor
            visible: false
            opacity: 0.0

            Behavior on opacity {
                NumberAnimation {
                    duration: 250
                }
            }

            Behavior on anchors.leftMargin {
                NumberAnimation {
                    duration: 250
                }
            }
        }

        Image {
            z: 4
            id: refreshImage
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 5
            width: 20
            height: 20
            source: "./images/refresh.svg"
            asynchronous: true
        }

        ColorOverlay {
            anchors.fill: refreshImage
            source: refreshImage
            color: themeLoader.item.missableIconColor
        }

        MouseArea {
            anchors.fill: parent
            onEntered: refreshRectangle.state = "hovered"
            onExited: refreshRectangle.state = ""
            hoverEnabled: true
            onClicked: {
                Ra2snes.refreshRAData();
            }
        }

        states: [
            State {
                name: "hovered"
                PropertyChanges {
                    target: refreshRectangle
                    width: refreshText.width + 38
                }
                PropertyChanges {
                    target: refreshText
                    visible: true
                    anchors.leftMargin: 10
                    opacity: 1.0
                }
                PropertyChanges {
                    target: refreshImage
                }
            }
        ]

        transitions: [
            Transition {
                from: ""
                to: "hovered"
                PropertyAnimation {
                    target: refreshRectangle
                    property: "width"
                    duration: 50
                }
            },
            Transition {
                from: "hovered"
                to: ""
                PropertyAnimation {
                    target: refreshRectangle
                    property: "width"
                    duration: 200
                }
            }
        ]
    }
}

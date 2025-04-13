import QtQuick
import QtQuick.Controls.Material
import CustomModels 1.0

ApplicationWindow {
    id: updateDialog
    visible: true
    width: 250
    height: 150
    maximumWidth: 250
    maximumHeight: 150
    minimumWidth: 250
    minimumHeight: 150
    title: "Updater"
    color: themeLoader.item.mainWindowDarkAccentColor
    Material.theme: themeLoader.item.darkScrollBar ? Material.Dark : Material.Light
    Material.accent: themeLoader.item.accentColor

    Column {
        spacing: 6
        anchors.centerIn: parent
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("A new update is available!")
            color: themeLoader.item.nonErrorMessageTextColor
            font.family: "Verdana"
            font.pixelSize: 13
            font.bold: true
        }
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            Text {
                text: qsTr("Current Version: ")
                horizontalAlignment: Text.AlignHCenter
                color: themeLoader.item.basicTextColor
                font.family: "Verdana"
                font.pixelSize: 13
            }
            Text {
                text: Ra2snes.version
                horizontalAlignment: Text.AlignHCenter
                color: themeLoader.item.linkColor
                font.bold: true
                font.family: "Verdana"
                font.pixelSize: 13
            }
        }
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            Text {
                text: qsTr("Latest Verison: ")
                horizontalAlignment: Text.AlignHCenter
                color: themeLoader.item.basicTextColor
                font.family: "Verdana"
                font.pixelSize: 13
            }
            Text {
                text: Ra2snes.latestVersion
                horizontalAlignment: Text.AlignHCenter
                color: themeLoader.item.linkColor
                font.bold: true
                font.family: "Verdana"
                font.pixelSize: 13
            }
        }
        Text {
            text: qsTr("Program will restart while updating.")
            horizontalAlignment: Text.AlignHCenter
            color: themeLoader.item.errorMessageTextColor
            font.family: "Verdana"
            font.pixelSize: 13
        }

        Row {
            spacing: 20
            anchors.horizontalCenter: parent.horizontalCenter

            Button {
                id: update
                text: qsTr("Update")
                width: 80
                background: Rectangle {
                    id: updateBG
                    color: themeLoader.item.buttonBackgroundColor
                    border.color: themeLoader.item.buttonBorderColor
                    radius: 2
                    border.width: 1
                }
                contentItem: Text {
                    id: updateText
                    text: qsTr("Update")
                    color: themeLoader.item.selectedLink
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                MouseArea {
                    id: updateArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        Ra2snes.beginUpdate();
                        updateDialog.close();
                    }
                    onEntered: update.state = "hovered"
                    onExited: update.state = ""
                }

                states: [
                    State {
                        name: "hovered"
                        PropertyChanges {
                            target: updateBG
                            color: themeLoader.item.highlightedButtonBackgroundColor
                            border.color: themeLoader.item.highlightedButtonBorderColor
                        }
                        PropertyChanges {
                            target: updateText
                            color: themeLoader.item.highlightedButtonTextColor
                        }
                    }
                ]

                transitions: [
                    Transition {
                        from: ""
                        to: "hovered"
                        ColorAnimation {
                            target: updateBG
                            property: "color"
                            duration: 200
                        }
                        ColorAnimation {
                            target: updateBG
                            property: "border.color"
                            duration: 200
                        }
                        ColorAnimation {
                            target: updateText
                            property: "color"
                            duration: 200
                        }
                    },
                    Transition {
                        from: "hovered"
                        to: ""
                        ColorAnimation {
                            target: updateBG
                            property: "color"
                            duration: 200
                        }
                        ColorAnimation {
                            target: updateBG
                            property: "border.color"
                            duration: 200
                        }
                        ColorAnimation {
                            target: updateText
                            property: "color"
                            duration: 200
                        }
                    }
                ]
            }

            Button {
                id: skip
                text: qsTr("Skip")
                width: 80
                background: Rectangle {
                    id: skipBG
                    color: themeLoader.item.buttonBackgroundColor
                    border.color: themeLoader.item.buttonBorderColor
                    radius: 2
                    border.width: 1
                }
                onClicked: {
                    updateDialog.close()
                }
                contentItem: Text {
                    id: skipText
                    text: qsTr("Skip")
                    color: themeLoader.item.selectedLink
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                MouseArea {
                    id: skipArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        updateDialog.close();
                    }
                    onEntered: skip.state = "hovered"
                    onExited: skip.state = ""
                }

                states: [
                    State {
                        name: "hovered"
                        PropertyChanges {
                            target: skipBG
                            color: themeLoader.item.highlightedButtonBackgroundColor
                            border.color: themeLoader.item.highlightedButtonBorderColor
                        }
                        PropertyChanges {
                            target: skipText
                            color: themeLoader.item.highlightedButtonTextColor
                        }
                    }
                ]

                transitions: [
                    Transition {
                        from: ""
                        to: "hovered"
                        ColorAnimation {
                            target: skipBG
                            property: "color"
                            duration: 200
                        }
                        ColorAnimation {
                            target: skipBG
                            property: "border.color"
                            duration: 200
                        }
                        ColorAnimation {
                            target: skipText
                            property: "color"
                            duration: 200
                        }
                    },
                    Transition {
                        from: "hovered"
                        to: ""
                        ColorAnimation {
                            target: skipBG
                            property: "color"
                            duration: 200
                        }
                        ColorAnimation {
                            target: skipBG
                            property: "border.color"
                            duration: 200
                        }
                        ColorAnimation {
                            target: skipText
                            property: "color"
                            duration: 200
                        }
                    }
                ]
            }
        }
    }
}

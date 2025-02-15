import QtQuick 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15
import CustomModels 1.0

ApplicationWindow {
    id: window
    width: 600
    height: 600
    minimumWidth: 600
    minimumHeight: 600
    visible: true
    title: qsTr("ra2snes - login")
    Material.theme: Material.Dark
    Material.accent: "#ffffff"

    background: Rectangle {
        color: "#1a1a1a"
    }

    property string loginFailed: ""

    function signIn(username, password, remember) {
        Ra2snes.signIn(username, password, remember);
    }

    function showErrorMessage(error) {
        window.loginFailed = error;
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: signin_group
            Layout.preferredWidth: 320
            Layout.preferredHeight: 320
            Layout.alignment: Qt.AlignHCenter
            color: "#222222"
            border.width: 2
            border.color: "#161616"
            radius: 6
            Column {
                spacing: 20
                anchors.bottom: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottomMargin: 20
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottomMargin: 20
                    height: 42
                    spacing: 10
                    Image {
                        source: "./images/ra-icon.png"
                        height: 42
                        width: 76
                    }
                    Image {
                        source: "./images/logo.png"
                        width: 42
                        height: 42
                    }
                    Image {
                        source: {
                            if(Ra2snes.console === "SNES")
                                "./images/Super_Famicom_logo.png"
                            else ""
                        }
                        width: 48
                        height: 34
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                Text {
                    text: "Sign in to RetroAchievements"
                    font.family: "Verdana"
                    font.pixelSize: 18
                    color: "#c8c8c8"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 0

                Text {
                    id: username_label
                    text: qsTr("Username")
                    font.family: "Verdana"
                    font.pixelSize: 13
                    color: "#2c97fa"
                }

                TextField {
                    id: username_input
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop
                    font.family: "Verdana"
                    font.pixelSize: 13
                    color: "#c8c8c8"
                    background: Rectangle {
                        color: "#161616"
                        border.width: 1
                        border.color: username_input.focus ? "#ffffff" : "#4b4b4b"
                        radius: 4
                    }
                    Layout.bottomMargin: -10
                }

                Text {
                    id: password_label
                    text: qsTr("Password")
                    font.family: "Verdana"
                    font.pixelSize: 13
                    color: "#2c97fa"
                }

                TextField {
                    id: password_input
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop
                    font.family: "Verdana"
                    font.pixelSize: 13
                    color: "#c8c8c8"
                    echoMode: TextInput.Password
                    background: Rectangle {
                        color: "#161616"
                        border.width: 1
                        border.color: password_input.focus ? "#ffffff" : "#4b4b4b"
                        radius: 4
                    }
                    Layout.bottomMargin: -8
                }

                Row {
                    id: checkbox_row
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop
                    spacing: 8

                    CheckBox {
                        id: remember_checkbox
                        width: 14
                        height: 14

                        indicator: Rectangle {
                            width: 14
                            height: 14
                            radius: 2
                            color: remember_checkbox.checked ? "#005cc8" : "#ffffff"
                            border.color: remember_checkbox.checked ? "#005cc8" : "#4f4f4f"

                            Text {
                                anchors.centerIn: parent
                                text: remember_checkbox.checked ? "\u2713" : ""
                                color: "#ffffff"
                                font.pixelSize: 12
                            }
                        }
                    }

                    Text {
                        text: qsTr("Remember Me")
                        font.family: "Verdana"
                        font.pixelSize: 13
                        color: "#2c97fa"
                        verticalAlignment: Text.AlignVCenter
                    }
                    Layout.topMargin: 0
                }

                Button {
                    id: signin_button
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop
                    text: qsTr("Sign in")
                    font.family: "Verdana"
                    font.pixelSize: 13
                    background: Rectangle {
                        id: buttonBackground
                        color: "#161616"
                        border.width: 1
                        border.color: "#2a2a2a"
                        radius: 4
                    }
                    contentItem: Text {
                        id: buttonText
                        text: qsTr("Sign in")
                        color: "#cc9900"
                        font.family: "Verdana"
                        font.pixelSize: 13
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    Layout.topMargin: 5
                    Layout.bottomMargin: -10

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            window.signIn(username_input.text, password_input.text, remember_checkbox.checked);
                        }
                        onEntered: signin_button.state = "hovered"
                        onExited: signin_button.state = ""
                    }

                    states: [
                        State {
                            name: "hovered"
                            PropertyChanges {
                                target: buttonBackground
                                color: "#333333"
                                border.color: "#c8c8c8"
                            }
                            PropertyChanges {
                                target: buttonText
                                color: "#eeeeee"
                            }
                        }
                    ]

                    transitions: [
                        Transition {
                            from: ""
                            to: "hovered"
                            ColorAnimation {
                                target: buttonBackground
                                property: "color"
                                duration: 200
                            }
                            ColorAnimation {
                                target: buttonBackground
                                property: "border.color"
                                duration: 200
                            }
                            ColorAnimation {
                                target: buttonText
                                property: "color"
                                duration: 200
                            }
                        },
                        Transition {
                            from: "hovered"
                            to: ""
                            ColorAnimation {
                                target: buttonBackground
                                property: "color"
                                duration: 200
                            }
                            ColorAnimation {
                                target: buttonBackground
                                property: "border.color"
                                duration: 200
                            }
                            ColorAnimation {
                                target: buttonText
                                property: "color"
                                duration: 200
                            }
                        }
                    ]
                }
                Item {
                    id: errorMessagePlaceholder
                    Layout.preferredHeight: 13
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 5

                    Text {
                        id: errorMessage
                        text: window.loginFailed
                        font.family: "Verdana"
                        font.pixelSize: 13
                        color: "#ff0000"
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
        }
    }
    Connections {
        target: Ra2snes
        function onLoginFailed(error) {
            window.showErrorMessage(error);
        }
    }
}

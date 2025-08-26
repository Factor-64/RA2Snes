import QtQuick
import QtQuick.Controls.Material
import QtQuick.Layouts
import CustomModels 1.0
import Qt.labs.folderlistmodel

ApplicationWindow {
    id: window
    width: 600
    height: 600
    minimumWidth: 600
    minimumHeight: 600
    visible: true
    title: "RA2Snes - v" + Ra2snes.version
    property var themes: ["Dark", "Black", "Light"]
    property string baseDir: {
        if(Ra2snes.appDirPath[0] === "/")
            "file://" + Ra2snes.appDirPath;
        else
            "file:///" + Ra2snes.appDirPath;
    }
    property string themeDir: baseDir + "/themes"

    FolderListModel {
        id: themeModel
        folder: window.themeDir
        nameFilters: ["*.qml"]
    }

    Timer {
        id: themeListTimer
        interval: 3000
        repeat: false
        running: true
        onTriggered: {
            window.loadThemes();
        }
    }

    function loadThemes()
    {
        if(themeModel.count > 0)
        {
            for(var i = 0; i < themeModel.count; i++)
            {
                var fullString = themeModel.get(i, "fileURL").toString();
                var start = fullString.lastIndexOf("/") + 1;
                var end = fullString.lastIndexOf(".");
                var theme = fullString.substring(start, end)
                if(window.themes.indexOf(theme) < 0 && theme !== "" && theme.substring(0,5) !== "file:")
                    window.themes.push(theme);
            }
        }
    }

    Loader {
        id: themeLoader
        source: "./themes/Dark.qml"
        onSourceChanged: {
            if(themeLoader.item === null)
            {
                themeLoader.source = "./themes/Dark.qml";
                Ra2snes.setTheme("Dark");
            }
        }
        active: true
        Component.onCompleted: {
            mainLoader.active = true;
        }
    }

    function setupTheme()
    {
        var defaultThemes = window.themes.slice(0, 3);
        if(defaultThemes.indexOf(Ra2snes.theme) < 0)
            themeLoader.source = (window.themeDir + "/" + Ra2snes.theme + ".qml");
        else themeLoader.source = ("./themes/" + Ra2snes.theme + ".qml");
    }

    Material.theme: themeLoader.item.darkScrollBar ? Material.Dark : Material.Light
    Material.accent: themeLoader.item.accentColor

    background: Rectangle {
        color: themeLoader.item.backgroundColor
    }

    property string loginFailed: ""

    function signIn(username, password, remember) {
        Ra2snes.signIn(username, password, remember);
    }

    function showErrorMessage(error) {
        window.loginFailed = error;
    }

    Loader {
        id: mainLoader
        active: false
        anchors.fill: parent
        sourceComponent: mainLayout
    }

    Component {
        id: mainLayout
        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            Rectangle {
                id: signin_group
                Layout.preferredWidth: 320
                Layout.preferredHeight: 320
                Layout.alignment: Qt.AlignHCenter
                color: themeLoader.item.mainWindowBackgroundColor
                border.width: 2
                border.color: themeLoader.item.mainWindowBorderColor
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
                            source: "./images/ra-icon.svg"
                            width: 114
                            height: 55
                            asynchronous: true
                        }
                        Image {
                            source: "./images/logo.png"
                            width: 55
                            height: 55
                            asynchronous: true
                        }
                        Image {
                            source: {
                                if(Ra2snes.console === "SNES")
                                    "./images/sfc.svg"
                                else ""
                            }
                            width: 76
                            height: 55
                            asynchronous: true
                        }
                    }
                    Text {
                        text: "Sign in to RetroAchievements"
                        font.family: "Verdana"
                        font.pixelSize: 18
                        color: themeLoader.item.highlightedButtonBorderColor
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
                        color: themeLoader.item.basicTextColor
                    }

                    TextField {
                        id: username_input
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignTop
                        font.family: "Verdana"
                        font.pixelSize: 13
                        color: themeLoader.item.selectedLink
                        background: Rectangle {
                            color: themeLoader.item.mainWindowDarkAccentColor
                            border.width: 1
                            border.color: username_input.focus ? themeLoader.item.checkBoxCheckColor : themeLoader.item.statusUnfinishedTextColor
                            radius: 4
                        }
                        Layout.bottomMargin: -10
                    }

                    Text {
                        id: password_label
                        text: qsTr("Password")
                        font.family: "Verdana"
                        font.pixelSize: 13
                        color: themeLoader.item.basicTextColor
                    }

                    TextField {
                        id: password_input
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignTop
                        font.family: "Verdana"
                        font.pixelSize: 13
                        color: themeLoader.item.selectedLink
                        echoMode: TextInput.Password
                        background: Rectangle {
                            color: themeLoader.item.mainWindowDarkAccentColor
                            border.width: 1
                            border.color: password_input.focus ? themeLoader.item.checkBoxCheckColor : themeLoader.item.statusUnfinishedTextColor
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
                                color: remember_checkbox.checked ? themeLoader.item.checkBoxCheckedColor : themeLoader.item.checkBoxUnCheckedColor
                                border.color: remember_checkbox.checked ? themeLoader.item.checkBoxCheckedBorderColor : themeLoader.item.checkBoxUnCheckedBorderColor

                                Text {
                                    anchors.centerIn: parent
                                    text: remember_checkbox.checked ? "\u2713" : ""
                                    color: themeLoader.item.checkBoxCheckColor
                                    font.pixelSize: 12
                                }
                            }
                        }

                        Text {
                            text: qsTr("Remember Me")
                            font.family: "Verdana"
                            font.pixelSize: 13
                            color: themeLoader.item.basicTextColor
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
                            color: themeLoader.item.mainWindowDarkAccentColor
                            border.width: 1
                            border.color: themeLoader.item.buttonBorderColor
                            radius: 4
                        }
                        contentItem: Text {
                            id: buttonText
                            text: qsTr("Sign in")
                            color: themeLoader.item.linkColor
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
                                    color: themeLoader.item.highlightedButtonBackgroundColor
                                    border.color: themeLoader.item.highlightedButtonBorderColor
                                }
                                PropertyChanges {
                                    target: buttonText
                                    color: themeLoader.item.highlightedButtonTextColor
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
                            color: themeLoader.item.errorMessageTextColor
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                        }
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

    Component.onCompleted: {
        setupTheme();
        themeListTimer.start();
    }
}

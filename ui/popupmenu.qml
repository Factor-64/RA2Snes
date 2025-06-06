import QtQuick
import QtQuick.Controls.Material
import CustomModels 1.0
import Qt5Compat.GraphicalEffects

Item {
    Rectangle {
        id: hamburgerRectangle
        width: 32
        height: 32
        color: themeLoader.item.mainWindowDarkAccentColor
        z: 20

        Image {
            id: hamburger
            anchors.centerIn: parent
            width: 32
            height: 32
            source: "./images/hamburger.svg"
            asynchronous: true
        }

        ColorOverlay {
            anchors.fill: hamburger
            source: hamburger
            color: themeLoader.item.hamburgerIconColor
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true

            onEntered: {
                hamburgerRectangle.color = themeLoader.item.popupBackgroundColor;
                menuPopup.open();
            }
        }
    }

    Popup {
        id: menuPopup
        x: hamburgerRectangle.x - width + hamburgerRectangle.width
        y: hamburgerRectangle.y + hamburgerRectangle.height
        z: 20
        width: 150
        height: popupColumn.implicitHeight + 8
        clip: true
        background: Rectangle {
            id: menuPopupBG
            width: parent.width
            height: parent.height + 8
            color: themeLoader.item.popupBackgroundColor
        }
        onOpened: {
            popupContainer.x = x - 300;
            popupContainer.y = y - 60;
            popupContainer.height = mainWindow.height;
            popupContainer.enabled = true;
        }

        function changeModeColor() {
            if(changeCheckBox.enabled && !changeCheckBox.checked)
            {
                if(UserInfoModel.hardcore)
                    mode.color = themeLoader.item.softcoreTextColor;
                else mode.color = themeLoader.item.hardcoreTextColor;
            }
            else mode.color = themeLoader.item.popupItemDisabled;
        }
        enter: Transition {
            NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 0}
        }
        exit: Transition {
            NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 0}
        }

        Popup {
            id: themePopup
            x: -162
            y: themeRect.y - 12
            z: 22
            width: 150
            clip: true
            height: (mainWindow.themes.length * 24) + 8
            background: Rectangle {
                id: themePopupBG
                color: themeLoader.item.popupBackgroundColor
            }
            ListView {
                id: themesList
                anchors.fill: parent
                anchors.topMargin: -8
                model: mainWindow.themes
                spacing: 0
                z: 5
                delegate: Rectangle {
                    id: themeDel
                    width: themePopup.width
                    anchors.left: parent.left
                    anchors.leftMargin: -12
                    height: 24
                    color: themeLoader.item.popupBackgroundColor

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        id: themeName
                        text: modelData
                        font.family: "Verdana"
                        font.pixelSize: 13
                        color: themeLoader.item.selectedLink
                        verticalAlignment: Text.AlignVCenter
                    }
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            Ra2snes.setTheme(themeName.text);
                            mainWindow.setupTheme();
                            menuPopupBG.color = themeLoader.item.popupBackgroundColor;
                            themePopupBG.color = themeLoader.item.popupBackgroundColor;
                            compactRect.color = themeLoader.item.popupBackgroundColor;
                            changeRect.color = themeLoader.item.popupBackgroundColor;
                            modeRect.color = themeLoader.item.popupBackgroundColor;
                            themeRect.color = themeLoader.item.popupHighlightColor;
                            theme.color = themeLoader.item.linkColor;
                            signoutRect.color = themeLoader.item.popupBackgroundColor;
                            menuPopup.changeModeColor();
                            signout.color = themeLoader.item.selectedLink;
                            compactMode.color = themeLoader.item.selectedLink;
                            hamburgerRectangle.color = themeLoader.item.popupBackgroundColor;
                            for(let i = 0; i < themesList.contentItem.children.length; i++) {
                                let item = themesList.contentItem.children[i];
                                item.color = themeLoader.item.popupBackgroundColor;
                                item.children.forEach(child => {
                                    if(child.color !== undefined)
                                        child.color = themeLoader.item.selectedLink;
                                });
                            }
                            themeDel.color = themeLoader.item.popupHighlightColor;
                            themeName.color = themeLoader.item.linkColor;
                        }
                        onEntered: {
                            themeDel.color = themeLoader.item.popupHighlightColor;
                            themeName.color = themeLoader.item.linkColor;
                            themeRect.color = themeLoader.item.popupHighlightColor;
                            theme.color = themeLoader.item.linkColor;
                        }

                        onExited: {
                            themeDel.color = themeLoader.item.popupBackgroundColor;
                            themeName.color = themeLoader.item.selectedLink;
                        }
                    }
                }
            }
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true

                onExited: {
                    themePopup.close();
                }
            }
            onOpened: {
                themeRect.color = themeLoader.item.popupHighlightColor;
                theme.color = themeLoader.item.linkColor;
            }
            enter: Transition {
                NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 0}
            }
            exit: Transition {
                NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 0}
            }

            function updateComboBox()
            {
                themesList.model = mainWindow.themes;
                height = (mainWindow.themes.length * 24) + 8;
                mainWindow.loadedThemes = true;
            }
            Component.onCompleted: {
                mainWindow.themesUpdated.connect(updateComboBox);
            }
        }

        Column {
            id: popupColumn
            anchors.fill: parent
            spacing: 0
            anchors.topMargin: -8

            Rectangle {
                id: changeRect
                width: menuPopup.width
                anchors.left: parent.left
                anchors.leftMargin: -12
                height: 24
                color: themeLoader.item.popupBackgroundColor
                Row {
                    spacing: 4
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter

                    Connections {
                        id: disableSwitch
                        target: Ra2snes
                        function onDisableModeSwitching()
                        {
                            mainWindow.setupFinished = false;
                            changeCheckBox.enabled = false;
                            signoutArea.enabled = false;
                            compactCheckBox.enabled = false;
                            compactMouseArea.enabled = false;
                            compactMode.color = themeLoader.item.popupItemDisabled;
                            autoHardcore.color = themeLoader.item.popupItemDisabled;
                            signout.color = themeLoader.item.popupItemDisabled;
                            modeMouse.enabled = false;
                            autoArea.enabled = false;
                            menuPopup.changeModeColor();

                        }
                    }

                    Connections {
                        target: Ra2snes
                        function onEnableModeSwitching()
                        {
                            mainWindow.setupFinished = true;
                            changeCheckBox.enabled = true;

                            signoutArea.enabled = true;
                            signout.color = themeLoader.item.selectedLink;
                            compactCheckBox.enabled = true;
                            compactMouseArea.enabled = true;
                            compactMode.color = themeLoader.item.selectedLink;
                            autoHardcore.color = themeLoader.item.selectedLink;
                            autoArea.enabled = true;
                            modeMouse.enabled = !changeCheckBox.checked;
                            menuPopup.changeModeColor();
                        }
                    }

                    CheckBox {
                        id: changeCheckBox
                        width: 14
                        height: 14

                        indicator: Rectangle {
                            width: 14
                            height: 14
                            radius: 2
                            color: changeCheckBox.checked ? themeLoader.item.checkBoxCheckedColor : themeLoader.item.checkBoxUnCheckedColor;
                            border.color: changeCheckBox.checked ? themeLoader.item.checkBoxCheckedBorderColor : themeLoader.item.checkBoxCheckedBorderColor

                            Text {
                                anchors.centerIn: parent
                                text: changeCheckBox.checked ? "\u2713" : ""
                                color: themeLoader.item.checkBoxCheckColor
                                font.pixelSize: 12
                            }
                        }

                        onCheckedChanged: {
                            menuPopup.changeModeColor();
                            modeMouse.enabled = !changeCheckBox.checked;
                            Ra2snes.autoChange(changeCheckBox.checked);
                        }
                        Component.onCompleted: {
                            changeCheckBox.checked = UserInfoModel.autohardcore;
                        }
                    }

                    Text {
                        id: autoHardcore
                        text: qsTr("Auto Hardcore")
                        font.family: "Verdana"
                        font.pixelSize: 13
                        color: themeLoader.item.selectedLink
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                MouseArea {
                    id: autoArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        changeCheckBox.checked = !changeCheckBox.checked
                    }
                    onEntered: {
                        changeRect.color = themeLoader.item.popupHighlightColor;
                        autoHardcore.color = themeLoader.item.linkColor;
                        themeRect.color = themeLoader.item.popupBackgroundColor;
                        theme.color = themeLoader.item.selectedLink;
                        themePopup.close();
                    }

                    onExited: {
                        changeRect.color = themeLoader.item.popupBackgroundColor;
                        autoHardcore.color = themeLoader.item.selectedLink;
                    }
                }
            }

            Rectangle {
                id: modeRect
                width: menuPopup.width
                anchors.left: parent.left
                anchors.leftMargin: -12
                height: 24
                color: themeLoader.item.popupBackgroundColor
                Text {
                    id: mode
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    text: {
                        if(UserInfoModel.hardcore)
                            qsTr("Softcore Mode");
                        else qsTr("Hardcore Mode");
                    }
                    font.family: "Verdana"
                    font.pixelSize: 13
                    color: {
                        menuPopup.changeModeColor();
                    }
                    verticalAlignment: Text.AlignVCenter
                }
                MouseArea {
                    id: modeMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: true
                    onClicked: {
                        Ra2snes.changeMode();
                    }
                    onEntered: {
                        modeRect.color = themeLoader.item.popupHighlightColor;
                        themeRect.color = themeLoader.item.popupBackgroundColor;
                        theme.color = themeLoader.item.selectedLink;
                        themePopup.close();
                    }

                    onExited: {
                        modeRect.color = themeLoader.item.popupBackgroundColor;
                    }
                }
            }

            Rectangle {
                id: sep1
                height: 5
                width: parent.width + 12
                color: themeLoader.item.popupBackgroundColor
                anchors.left: parent.left
                anchors.leftMargin: -6

                Rectangle {
                    id: sep11
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: 2
                    anchors.bottomMargin: 2
                    height: 1
                    width: parent.width
                    color: themeLoader.item.popupLineColor
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: {
                        themeRect.color = themeLoader.item.popupBackgroundColor;
                        theme.color = themeLoader.item.selectedLink;
                        themePopup.close();
                    }
                }
            }

            Rectangle {
                id: compactRect
                width: menuPopup.width
                anchors.left: parent.left
                anchors.leftMargin: -12
                height: 24
                color: themeLoader.item.popupBackgroundColor
                Row {
                    spacing: 4
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter

                    CheckBox {
                        id: compactCheckBox
                        width: 14
                        height: 14
                        enabled: mainWindow.loadedThemes

                        indicator: Rectangle {
                            width: 14
                            height: 14
                            radius: 2
                            color: compactCheckBox.checked ? themeLoader.item.checkBoxCheckedColor : themeLoader.item.checkBoxUnCheckedColor;
                            border.color: compactCheckBox.checked ? themeLoader.item.checkBoxCheckedBorderColor : themeLoader.item.checkBoxCheckedBorderColor
                            Text {
                                anchors.centerIn: parent
                                text: compactCheckBox.checked ? "\u2713" : ""
                                color: themeLoader.item.checkBoxCheckColor
                                font.pixelSize: 12
                            }
                        }

                        onCheckedChanged: {
                            mainWindow.compact = compactCheckBox.checked;
                        }
                        Component.onCompleted: {
                            compactCheckBox.checked = mainWindow.compact;
                        }
                    }

                    Text {
                        id: compactMode
                        text: qsTr("Compact Mode")
                        font.family: "Verdana"
                        font.pixelSize: 13
                        color: themeLoader.item.selectedLink
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                MouseArea {
                    id: compactMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        compactCheckBox.checked = !compactCheckBox.checked
                    }
                    onEntered: {
                        compactRect.color = themeLoader.item.popupHighlightColor;
                        compactMode.color = themeLoader.item.linkColor;
                        themeRect.color = themeLoader.item.popupBackgroundColor;
                        theme.color = themeLoader.item.selectedLink;
                        themePopup.close();
                    }

                    onExited: {
                        compactRect.color = themeLoader.item.popupBackgroundColor;
                        compactMode.color = themeLoader.item.selectedLink;

                        compactMouseArea.enabled = true;
                    }
                }
            }
            Rectangle {
                id: themeRect
                width: menuPopup.width
                anchors.left: parent.left
                anchors.leftMargin: -12
                height: 24
                color: themeLoader.item.popupBackgroundColor
                Text {
                    id: theme
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("Theme: ") + Ra2snes.theme;
                    font.family: "Verdana"
                    font.pixelSize: 13
                    color: themeLoader.item.selectedLink
                    verticalAlignment: Text.AlignVCenter
                }
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: {
                        themeRect.color = themeLoader.item.popupHighlightColor;
                        theme.color = themeLoader.item.linkColor;
                        themePopup.open();
                    }

                    onExited: {
                        if(!themePopup.visible)
                        {
                            themeRect.color = themeLoader.item.popupBackgroundColor;
                            theme.color = themeLoader.item.selectedLink;
                        }
                    }
                }
            }
            Rectangle {
                id: sep2
                height: 5
                width: parent.width + 12
                color: themeLoader.item.popupBackgroundColor
                anchors.left: parent.left
                anchors.leftMargin: -6

                Rectangle {
                    id: sep21
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: 2
                    anchors.bottomMargin: 2
                    height: 1
                    width: parent.width
                    color: themeLoader.item.popupLineColor
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: {
                        themeRect.color = themeLoader.item.popupBackgroundColor;
                        theme.color = themeLoader.item.selectedLink;
                        themePopup.close();
                    }
                }
            }

            Rectangle {
                id: signoutRect
                width: menuPopup.width
                anchors.left: parent.left
                anchors.leftMargin: -12
                height: 24
                color: themeLoader.item.popupBackgroundColor
                Text {
                    id: signout
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("Sign Out")
                    font.family: "Verdana"
                    font.pixelSize: 13
                    color: themeLoader.item.selectedLink
                    verticalAlignment: Text.AlignVCenter
                }
                MouseArea {
                    id: signoutArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        Ra2snes.signOut();
                    }
                    onEntered: {
                        signoutRect.color = themeLoader.item.popupHighlightColor;
                        signout.color = themeLoader.item.linkColor;
                        themeRect.color = themeLoader.item.popupBackgroundColor;
                        theme.color = themeLoader.item.selectedLink;
                        themePopup.close();
                    }

                    onExited: {
                        signoutRect.color = themeLoader.item.popupBackgroundColor;
                        signout.color = themeLoader.item.selectedLink;
                    }
                }
            }
        }
    }
    MouseArea {
        hoverEnabled: true
        id: popupContainer
        x: 0
        y: 0
        width: 800
        height: 0
        z: 19
        enabled: false
        onEntered: {
            enabled = false;
            themeRect.color = themeLoader.item.popupBackgroundColor;
            theme.color = themeLoader.item.selectedLink;
            hamburgerRectangle.color = themeLoader.item.mainWindowDarkAccentColor;
            themePopup.close();
            menuPopup.close();
        }
    }
}

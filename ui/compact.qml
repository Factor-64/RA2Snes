import QtQuick
import QtQuick.Controls.Material
import QtQuick.Layouts
import CustomModels 1.0
import QtQuick.Effects

Rectangle {
    id: contentForm
    implicitHeight: contentColumn.implicitHeight
    color: themeLoader.item.mainWindowBackgroundColor
    border.width: 2
    border.color: themeLoader.item.mainWindowBorderColor
    radius: 6
    anchors.margins: 10
    clip: false

    ColumnLayout {
        id: contentColumn
        anchors.fill: parent
        spacing: 6
        Rectangle {
            color: themeLoader.item.mainWindowDarkAccentColor
            Layout.fillWidth: true
            implicitHeight: 108

            Row {
                spacing: 0
                Rectangle {
                    color: themeLoader.item.mainWindowDarkAccentColor
                    width: contentColumn.width/2 - 32
                    implicitHeight: 108
                    clip: true
                    Column {
                        id: userRow
                        spacing: 4
                        anchors.leftMargin: 20
                        anchors.rightMargin: 20
                        anchors.topMargin: 10
                        anchors.bottomMargin: 20
                        anchors.left: parent.left
                        anchors.top: parent.top
                        Row {
                            spacing: 6
                            Image {
                                id: userpfp
                                source: UserInfoModel.pfp
                                width: 32
                                height: 32
                            }
                            Text {
                                id: user
                                text: UserInfoModel.username
                                color: themeLoader.item.linkColor
                                font.bold: true
                                font.family: "Verdana"
                                font.pixelSize: 24
                                MouseArea {
                                    id: mouseAreaUser
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        Qt.openUrlExternally(UserInfoModel.link)
                                    }
                                    onEntered: user.state = "hovered"
                                    onExited: user.state = ""
                                }

                                states: [
                                    State {
                                        name: "hovered"
                                        PropertyChanges {
                                            target: user
                                            color: themeLoader.item.selectedLink
                                        }
                                    }
                                ]

                                transitions: [
                                    Transition {
                                        from: ""
                                        to: "hovered"
                                        ColorAnimation {
                                            target: user
                                            property: "color"
                                            duration: 200
                                        }
                                    },
                                    Transition {
                                        from: "hovered"
                                        to: ""
                                        ColorAnimation {
                                            target: user
                                            property: "color"
                                            duration: 200
                                        }
                                    }
                                ]
                            }
                        }

                        Column {
                            spacing: 0
                            Row {
                                Text {
                                    text: qsTr("Points: ")
                                    color: themeLoader.item.basicTextColor
                                    font.bold: true
                                    font.family: "Verdana"
                                    font.pixelSize: 13
                                }
                                Text {
                                    text: {
                                        if(UserInfoModel.hardcore)
                                            "" + UserInfoModel.hardcore_score;
                                        else
                                            "" + UserInfoModel.softcore_score;
                                    }
                                    font.family: "Verdana"
                                    font.pixelSize: 13
                                    color: themeLoader.item.basicTextColor
                                }
                            }
                            Row {
                                Text {
                                    text: qsTr("Mode: ")
                                    color: themeLoader.item.basicTextColor
                                    font.bold: true
                                    font.family: "Verdana"
                                    font.pixelSize: 13
                                }
                                Text {
                                    text: {
                                        if(UserInfoModel.hardcore)
                                            qsTr("Hardcore");
                                        else
                                            qsTr("Softcore");
                                    }
                                    font.family: "Verdana"
                                    font.pixelSize: 13
                                    color: {
                                        if(UserInfoModel.hardcore)
                                            themeLoader.item.hardcoreTextColor;
                                        else
                                            themeLoader.item.softcoreTextColor;
                                    }
                                }
                            }
                        }
                    }
                }
                Rectangle {
                    id: gameRectangle
                    color: themeLoader.item.mainWindowDarkAccentColor
                    width: contentColumn.width/2 - 22
                    implicitHeight: 108
                    clip: true
                    onWidthChanged: {
                        if(gameRectangle.width - 30 <= gameColumn.width)
                        {
                            gameColumn.anchors.left = left;
                            gameColumn.anchors.right = undefined;
                        }
                        else
                        {
                            gameColumn.anchors.left = undefined;
                            gameColumn.anchors.right = right;
                        }
                    }

                    Column {
                        id: gameColumn
                        spacing: 0
                        anchors.rightMargin: 20
                        anchors.topMargin: 10
                        anchors.leftMargin: 10
                        anchors.bottomMargin: 20
                        anchors.top: parent.top
                        width: 292
                        onWidthChanged: {
                            if(gameRectangle.width - 30 <= gameColumn.width)
                            {
                                anchors.left = parent.left;
                            }
                            else
                            {
                                anchors.right = parent.right;
                            }
                        }

                        Row {
                            spacing: 10
                            Image {
                                source: GameInfoModel.image_icon_url
                                width: 32
                                height: 32
                                MouseArea {
                                    id: mouseAreaGameIcon
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        Qt.openUrlExternally(GameInfoModel.game_link)
                                    }
                                    onEntered: game.state = "hovered"
                                    onExited: game.state = ""
                                }
                                states: [
                                    State {
                                        name: "hovered"
                                        PropertyChanges {
                                            target: game
                                            color: themeLoader.item.selectedLink
                                        }
                                    }
                                ]

                                transitions: [
                                    Transition {
                                        from: ""
                                        to: "hovered"
                                        ColorAnimation {
                                            target: game
                                            property: "color"
                                            duration: 200
                                        }
                                    },
                                    Transition {
                                        from: "hovered"
                                        to: ""
                                        ColorAnimation {
                                            target: game
                                            property: "color"
                                            duration: 200
                                        }
                                    }
                                ]
                            }
                            Column {
                                Layout.fillWidth: true
                                spacing: 0

                                Text {
                                    id: game
                                    text: GameInfoModel.title
                                    color: themeLoader.item.linkColor
                                    font.family: "Verdana"
                                    font.pixelSize: 13

                                    MouseArea {
                                        id: mouseAreaGame
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onClicked: {
                                            Qt.openUrlExternally(GameInfoModel.game_link)
                                        }
                                        onEntered: game.state = "hovered"
                                        onExited: game.state = ""

                                        ToolTip {
                                            visible: mouseAreaGame.containsMouse
                                            text: GameInfoModel.md5hash
                                        }
                                    }

                                    states: [
                                        State {
                                            name: "hovered"
                                            PropertyChanges {
                                                target: game
                                                color: themeLoader.item.selectedLink
                                            }
                                        }
                                    ]

                                    transitions: [
                                        Transition {
                                            from: ""
                                            to: "hovered"
                                            ColorAnimation {
                                                target: game
                                                property: "color"
                                                duration: 200
                                            }
                                        },
                                        Transition {
                                            from: "hovered"
                                            to: ""
                                            ColorAnimation {
                                                target: game
                                                property: "color"
                                                duration: 200
                                            }
                                        }
                                    ]
                                }
                                Row {
                                    Layout.fillWidth: true
                                    spacing: 4
                                    Image {
                                        source: GameInfoModel.console_icon
                                        width: 18
                                        height: 18
                                    }
                                    Text {
                                        text: GameInfoModel.console
                                        font.family: "Verdana"
                                        font.pixelSize: 13
                                        color: themeLoader.item.basicTextColor
                                    }
                                }
                            }
                        }
                        Column {
                            id: gameInfo
                            visible: false
                            Row {
                                spacing: 6
                                Rectangle {
                                    id: missableRectangle
                                    width: 20
                                    height: 20
                                    radius: 50
                                    border.width: 1
                                    border.color: themeLoader.item.popoutBorderColor
                                    color: themeLoader.item.mainWindowBackgroundColor

                                    Image {
                                        id: missableImage
                                        anchors.centerIn: parent
                                        width: 14
                                        height: 14
                                        source: "./images/missable.svg"
                                        layer.enabled: true
                                        layer.effect: MultiEffect {
                                            colorization: 1.0
                                            colorizationColor: themeLoader.item.missableIconColor
                                        }
                                    }
                                }
                                Row {
                                    Text {
                                        text: GameInfoModel.missable_count
                                        font.family: "Verdana"
                                        font.pixelSize: 13
                                        color: themeLoader.item.basicTextColor
                                        Layout.fillWidth: true
                                    }
                                    Text {
                                        text: qsTr(" missable achievements")
                                        font.family: "Verdana"
                                        font.pixelSize: 13
                                        color: themeLoader.item.basicTextColor
                                        Layout.fillWidth: true
                                    }
                                }
                            }
                            Row {
                                spacing: 8
                                Column {
                                    Row {
                                        Text {
                                            text: GameInfoModel.completion_count
                                            font.bold: true
                                            font.family: "Verdana"
                                            font.pixelSize: 13
                                            color: themeLoader.item.basicTextColor
                                        }
                                        Text {
                                            text: qsTr(" of ")
                                            font.family: "Verdana"
                                            font.pixelSize: 13
                                            color: themeLoader.item.basicTextColor
                                        }
                                        Text {
                                            text: GameInfoModel.achievement_count;
                                            font.family: "Verdana"
                                            font.pixelSize: 13
                                            color: themeLoader.item.basicTextColor
                                        }
                                        Text {
                                            text: qsTr(" achievements")
                                            font.family: "Verdana"
                                            font.pixelSize: 13
                                            color: themeLoader.item.basicTextColor
                                        }
                                    }
                                    Row {
                                        Text {
                                            text: GameInfoModel.point_count
                                            font.bold: true
                                            font.family: "Verdana"
                                            font.pixelSize: 13
                                            color: themeLoader.item.basicTextColor
                                        }
                                        Text {
                                            text: qsTr(" of ")
                                            font.family: "Verdana"
                                            font.pixelSize: 13
                                            color: themeLoader.item.basicTextColor
                                        }
                                        Text {
                                            text: GameInfoModel.point_total
                                            font.family: "Verdana"
                                            font.pixelSize: 13
                                            color: themeLoader.item.basicTextColor
                                        }
                                        Text {
                                            text: qsTr(" points")
                                            font.family: "Verdana"
                                            font.pixelSize: 13
                                            color: themeLoader.item.basicTextColor
                                        }
                                    }
                                }

                            }
                        }
                    }
                }
            }

            Item {
                id: errorMessagePlaceholder
                Layout.preferredHeight: 13
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.fill: parent
                anchors.topMargin: 80
                anchors.leftMargin: 20
                z: 1

                Text {
                    id: errorMessage
                    text: mainWindow.modeFailed
                    font.family: "Verdana"
                    font.pixelSize: 13
                    color: themeLoader.item.errorMessageTextColor
                    width: parent.width
                    opacity: 1
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 500
                        }
                    }

                    Timer {
                        id: fadeOutTimer
                        interval: 5000
                        running: false
                        repeat: false
                        onTriggered: {
                            errorMessage.opacity = 0.0
                        }
                    }

                    function showErrorMessage(error, iserror) {
                        mainWindow.modeFailed = error;
                        if(themeLoader.item)
                        {
                            if(iserror)
                                errorMessage.color = themeLoader.item.errorMessageTextColor;
                            else
                                errorMessage.color = themeLoader.item.nonErrorMessageTextColor;
                        }
                        else
                        {
                            if(iserror)
                                errorMessage.color = "#ff0000";
                            else
                                errorMessage.color = "#00ff00";
                        }
                        errorMessage.opacity = 1;
                        fadeOutTimer.restart();
                    }

                    Connections {
                        target: Ra2snes
                        function onDisplayMessage(error, iserror) {
                            errorMessage.showErrorMessage(error, iserror);
                        }
                    }
                }
            }
            ProgressBar {
                id: progressBar
                visible: gameInfo.visible
                anchors.left: parent.left
                anchors.leftMargin: 1
                anchors.bottom: parent.bottom
                width: parent.width - 2
                height: 8
                z: 1
                value: {
                    let val = (GameInfoModel.completion_count / GameInfoModel.achievement_count);
                    if(val >= 0)
                        return Math.min(Math.max(val, 0), 1);
                    else return 0;
                }
                Item {
                    z: 1
                    width: progressBar.width + 2
                    height: progressBar.height
                    anchors.left: parent.left
                    anchors.leftMargin: -1
                    Rectangle {
                        width: parent.width
                        height: parent.height / 2
                        color: themeLoader.item.progressBarBackgroundColor
                    }
                    Rectangle {
                        width: parent.width
                        height: parent.height
                        radius: 6
                        color: themeLoader.item.progressBarBackgroundColor
                        anchors.bottom: parent.bottom
                    }
                }
                Item {
                    z: 2
                    width: (progressBar.width + 2) * progressBar.value
                    height: progressBar.height
                    anchors.left: parent.left
                    anchors.leftMargin: -1
                    Rectangle {
                        width: parent.width
                        height: parent.height / 2
                        color: themeLoader.item.progressBarColor
                    }
                    Rectangle {
                        id: roundedBar
                        width: parent.width
                        height: parent.height
                        radius: 6
                        color: themeLoader.item.progressBarColor
                        anchors.bottom: parent.bottom
                    }
                    Rectangle {
                        width: {
                            if(roundedBar.width) 5;
                            else 0;
                        }
                        height: {
                            if(roundedBar.width < (progressBar.width - 3))
                                parent.height;
                            else roundedBar.width - parent.width
                        }
                        anchors.left: roundedBar.right
                        anchors.leftMargin: -4
                        color: themeLoader.item.progressBarColor
                        anchors.top: parent.top
                    }
                }
            }
            Text {
                visible: gameInfo.visible
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                anchors.rightMargin: 20
                anchors.bottomMargin: 18
                text: {
                    if(GameInfoModel.mastered)
                        qsTr("Mastered");
                    else if(GameInfoModel.beaten)
                        qsTr("Beaten");
                    else qsTr("Unfinished");
                }
                font.family: "Verdana"
                font.pixelSize: 18
                color: {
                   if(GameInfoModel.mastered)
                       themeLoader.item.statusMasteredTextColor;
                   else if(GameInfoModel.beaten)
                       themeLoader.item.statusBeatenTextColor;
                   else themeLoader.item.statusUnfinishedTextColor;
                }
            }
            Rectangle {
                    id: hamburgerRectangle
                    width: 32
                    height: 32
                    color: themeLoader.item.mainWindowDarkAccentColor
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.topMargin: 10
                    anchors.rightMargin: 20
                    z: 20

                    Image {
                        id: hamburger
                        anchors.centerIn: parent
                        width: 32
                        height: 32
                        source: "./images/hamburger.svg"
                        layer.enabled: true
                        layer.effect: MultiEffect {
                            colorization: 1.0
                            colorizationColor: themeLoader.item.hamburgerIconColor
                        }
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
                height: popupColumn.implicitHeight
                background: Rectangle {
                    id: menuPopupBG
                    width: parent.width
                    height: parent.height + 8
                    color: themeLoader.item.popupBackgroundColor
                }
                onOpened: {
                    menuPopup.focus = true;
                    popupContainer.x = x - 200;
                    popupContainer.y = y - 60;
                    popupContainer.width = mainWindow.width;
                    popupContainer.height = mainWindow.height;
                    popupContainer.z = 19
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
                                target: Ra2snes
                                function onDisableModeSwitching()
                                {
                                    changeCheckBox.enabled = false;
                                    mode.color = themeLoader.item.popupItemDisabled;
                                }
                            }

                            Connections {
                                target: Ra2snes
                                function onEnableModeSwitching()
                                {
                                    changeCheckBox.enabled = true;
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
                                    color: {
                                        if(changeCheckBox.enabled)
                                            autoHardcore.color = themeLoader.item.selectedLink;
                                        else
                                            autoHardcore.color = themeLoader.item.popupItemDisabled;
                                        changeCheckBox.checked ? themeLoader.item.checkBoxCheckedColor : themeLoader.item.checkBoxUnCheckedColor;
                                    }
                                    border.color: changeCheckBox.checked ? themeLoader.item.checkBoxCheckedBorderColor : themeLoader.item.checkBoxCheckedBorderColor

                                    Text {
                                        anchors.centerIn: parent
                                        text: changeCheckBox.checked ? "\u2713" : ""
                                        color: themeLoader.item.checkBoxCheckColor
                                        font.pixelSize: 12
                                    }
                                }

                                onCheckedChanged: {
                                    mainWindow.setupFinished = false;
                                    if(themeLoader.item)
                                        menuPopup.changeModeColor();
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
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                if(changeCheckBox.enabled)
                                    changeCheckBox.checked = !changeCheckBox.checked
                            }
                            onEntered: {
                                if(changeCheckBox.enabled)
                                {
                                    changeRect.color = themeLoader.item.popupHighlightColor;
                                    autoHardcore.color = themeLoader.item.linkColor;
                                }
                                themeRect.color = themeLoader.item.popupBackgroundColor;
                                theme.color = themeLoader.item.selectedLink;
                                themePopup.close();
                            }

                            onExited: {
                                if(changeCheckBox.enabled)
                                {
                                    changeRect.color = themeLoader.item.popupBackgroundColor;
                                    autoHardcore.color = themeLoader.item.selectedLink;
                                }
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
                            text: qsTr("Change Mode")
                            font.family: "Verdana"
                            font.pixelSize: 13
                            color: {
                                menuPopup.changeModeColor();
                            }
                            verticalAlignment: Text.AlignVCenter
                        }
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                if(changeCheckBox.enabled)
                                {
                                    mainWindow.setupFinished = false;
                                    Ra2snes.changeMode();
                                }
                            }
                            onEntered: {
                                if(changeCheckBox.enabled)
                                {
                                    modeRect.color = themeLoader.item.popupHighlightColor;
                                    themeRect.color = themeLoader.item.popupBackgroundColor;
                                    theme.color = themeLoader.item.selectedLink;
                                    themePopup.close();
                                }
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

                                indicator: Rectangle {
                                    width: 14
                                    height: 14
                                    radius: 2
                                    border.color: compactCheckBox.checked ? themeLoader.item.checkBoxCheckedBorderColor : themeLoader.item.checkBoxCheckedBorderColor

                                    Text {
                                        anchors.centerIn: parent
                                        text: compactCheckBox.checked ? "\u2713" : ""
                                        color: themeLoader.item.checkBoxCheckColor
                                        font.pixelSize: 12
                                    }
                                }

                                onCheckedChanged: {
                                    if(compactCheckBox.checked)
                                        mainWindow.compact = true;
                                    else
                                        mainWindow.compact = false;
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
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                if(compactCheckBox.enabled)
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

            Item {
                id: popupContainer
                x: 0
                y: 0
                width: 0
                height: 0
                z: 0
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true

                    onEntered: {
                        x = 0;
                        y = 0;
                        z = 0;
                        width = 0;
                        height = 0;
                        hamburgerRectangle.color = themeLoader.item.mainWindowDarkAccentColor;
                        themePopup.close();
                        menuPopup.close();
                    }
                }
            }
        }

        Loader {
            id: listViewLoader
            Layout.fillWidth: true
            Layout.leftMargin: 20
            Layout.bottomMargin: 10
            Layout.rightMargin: 20
            Layout.topMargin: 10
            sourceComponent: listViewComponent
            active: false
        }

        Connections {
            target: Ra2snes
            function onAchievementModelReady() {
                sortedAchievementModel.clearMissableFilter();
                sortedAchievementModel.clearUnlockedFilter();
                sortedAchievementModel.sortByNormal();
                listViewLoader.active = true;
                gameInfo.visible = true;
                let val =(GameInfoModel.completion_count / GameInfoModel.achievement_count);
                if(val >= 0)
                    progressBar.value = Math.min(Math.max(val, 0), 1);
                else progressBar.value = 0;
                mainWindow.setupFinished = true;
                achievementlist.visible = true;
            }
        }

        Connections {
            target: Ra2snes
            function onClearedAchievements() {
                listViewLoader.active = false;
                achievementlist.visible = false;
                mainWindow.setupFinished = false;
                gameInfo.visible = false;
            }
        }

        Component {
            id: listViewComponent

            Flow {
                id: sortingSettingsFlow
                spacing: 6
                Layout.fillWidth: true
                Layout.leftMargin: 20
                Layout.bottomMargin: 10
                Layout.rightMargin: 20
                Layout.topMargin: 10

                RowLayout {
                    id: sortingTextRow
                    spacing: 6
                    Layout.fillWidth: true
                    Text{
                        text: qsTr("Sort:")
                        font.family: "Verdana"
                        font.pixelSize: 13
                        color: themeLoader.item.basicTextColor
                        Layout.fillWidth: true
                    }
                    Text{
                        id: normal
                        text: qsTr("Normal")
                        font.family: "Verdana"
                        font.pixelSize: 13
                        color: themeLoader.item.linkColor
                        Layout.fillWidth: true
                        MouseArea {
                            id: mouseAreaNormal
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                sortedAchievementModel.sortByNormal()
                            }
                            onEntered: normal.state = "hovered"
                            onExited: normal.state = ""
                        }

                        states: [
                            State {
                                name: "hovered"
                                PropertyChanges {
                                    target: normal
                                    color: themeLoader.item.selectedLink
                                }
                            }
                        ]

                        transitions: [
                            Transition {
                                from: ""
                                to: "hovered"
                                ColorAnimation {
                                    target: normal
                                    property: "color"
                                    duration: 200
                                }
                            },
                            Transition {
                                from: "hovered"
                                to: ""
                                ColorAnimation {
                                    target: normal
                                    property: "color"
                                    duration: 200
                                }
                            }
                        ]
                    }
                    Text{
                        text: "-"
                        font.family: "Verdana"
                        font.pixelSize: 13
                        color: themeLoader.item.basicTextColor
                        Layout.fillWidth: true
                    }
                    Text{
                        id: points
                        text: qsTr("Points")
                        font.family: "Verdana"
                        font.pixelSize: 13
                        color: themeLoader.item.linkColor
                        Layout.fillWidth: true
                        MouseArea {
                            id: mouseAreaPoints
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                sortedAchievementModel.sortByPoints()
                            }
                            onEntered: points.state = "hovered"
                            onExited: points.state = ""
                        }

                        states: [
                            State {
                                name: "hovered"
                                PropertyChanges {
                                    target: points
                                    color: themeLoader.item.selectedLink
                                }
                            }
                        ]

                        transitions: [
                            Transition {
                                from: ""
                                to: "hovered"
                                ColorAnimation {
                                    target: points
                                    property: "color"
                                    duration: 200
                                }
                            },
                            Transition {
                                from: "hovered"
                                to: ""
                                ColorAnimation {
                                    target: points
                                    property: "color"
                                    duration: 200
                                }
                            }
                        ]
                    }
                    Text{
                        text: "-"
                        font.family: "Verdana"
                        font.pixelSize: 13
                        color: themeLoader.item.basicTextColor
                        Layout.fillWidth: true
                    }
                    Text{
                        id: title
                        text: qsTr("Title")
                        font.family: "Verdana"
                        font.pixelSize: 13
                        color: themeLoader.item.linkColor
                        Layout.fillWidth: true
                        MouseArea {
                            id: mouseAreaTitleSort
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                sortedAchievementModel.sortByTitle()
                            }
                            onEntered: title.state = "hovered"
                            onExited: title.state = ""
                        }

                        states: [
                            State {
                                name: "hovered"
                                PropertyChanges {
                                    target: title
                                    color: themeLoader.item.selectedLink
                                }
                            }
                        ]

                        transitions: [
                            Transition {
                                from: ""
                                to: "hovered"
                                ColorAnimation {
                                    target: title
                                    property: "color"
                                    duration: 200
                                }
                            },
                            Transition {
                                from: "hovered"
                                to: ""
                                ColorAnimation {
                                    target: title
                                    property: "color"
                                    duration: 200
                                }
                            }
                        ]
                    }
                    Text{
                        text: "-"
                        font.family: "Verdana"
                        font.pixelSize: 13
                        color: themeLoader.item.basicTextColor
                        Layout.fillWidth: true
                    }
                    Text{
                        id: type
                        text: qsTr("Type")
                        font.family: "Verdana"
                        font.pixelSize: 13
                        color: themeLoader.item.linkColor
                        Layout.fillWidth: true
                        MouseArea {
                            id: mouseAreaType
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                sortedAchievementModel.sortByType()
                            }
                            onEntered: type.state = "hovered"
                            onExited: type.state = ""
                        }

                        states: [
                            State {
                                name: "hovered"
                                PropertyChanges {
                                    target: type
                                    color: themeLoader.item.selectedLink
                                }
                            }
                        ]

                        transitions: [
                            Transition {
                                from: ""
                                to: "hovered"
                                ColorAnimation {
                                    target: type
                                    property: "color"
                                    duration: 200
                                }
                            },
                            Transition {
                                from: "hovered"
                                to: ""
                                ColorAnimation {
                                    target: type
                                    property: "color"
                                    duration: 200
                                }
                            }
                        ]
                    }
                    Text{
                        text: "-"
                        font.family: "Verdana"
                        font.pixelSize: 13
                        color: themeLoader.item.basicTextColor
                        Layout.fillWidth: true
                    }
                    Text{
                        id: time
                        text: qsTr("Latest")
                        font.family: "Verdana"
                        font.pixelSize: 13
                        color: themeLoader.item.linkColor
                        Layout.fillWidth: true
                        MouseArea {
                            id: mouseAreaTime
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                sortedAchievementModel.sortByTime()
                            }
                            onEntered: time.state = "hovered"
                            onExited: time.state = ""
                        }

                        states: [
                            State {
                                name: "hovered"
                                PropertyChanges {
                                    target: time
                                    color: themeLoader.item.selectedLink
                                }
                            }
                        ]

                        transitions: [
                            Transition {
                                from: ""
                                to: "hovered"
                                ColorAnimation {
                                    target: time
                                    property: "color"
                                    duration: 200
                                }
                            },
                            Transition {
                                from: "hovered"
                                to: ""
                                ColorAnimation {
                                    target: time
                                    property: "color"
                                    duration: 200
                                }
                            }
                        ]
                    }
                    Text{
                        text: "-"
                        font.family: "Verdana"
                        font.pixelSize: 13
                        color: themeLoader.item.basicTextColor
                        Layout.fillWidth: true
                    }
                    Text{
                        id: primed
                        text: qsTr("Primed")
                        font.family: "Verdana"
                        font.pixelSize: 13
                        color: themeLoader.item.linkColor
                        Layout.fillWidth: true
                        MouseArea {
                            id: mouseAreaPrime
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                sortedAchievementModel.sortByPrimed()
                            }
                            onEntered: primed.state = "hovered"
                            onExited: primed.state = ""
                        }

                        states: [
                            State {
                                name: "hovered"
                                PropertyChanges {
                                    target: primed
                                    color: themeLoader.item.selectedLink
                                }
                            }
                        ]

                        transitions: [
                            Transition {
                                from: ""
                                to: "hovered"
                                ColorAnimation {
                                    target: primed
                                    property: "color"
                                    duration: 200
                                }
                            },
                            Transition {
                                from: "hovered"
                                to: ""
                                ColorAnimation {
                                    target: primed
                                    property: "color"
                                    duration: 200
                                }
                            }
                        ]
                    }
                    Text{
                        text: "-"
                        font.family: "Verdana"
                        font.pixelSize: 13
                        color: themeLoader.item.basicTextColor
                        Layout.fillWidth: true
                    }
                    Text{
                        id: progress
                        text: qsTr("Progress")
                        font.family: "Verdana"
                        font.pixelSize: 13
                        color: themeLoader.item.linkColor
                        Layout.fillWidth: true
                        MouseArea {
                            id: mouseAreaProgress
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                sortedAchievementModel.sortByPercent()
                            }
                            onEntered: progress.state = "hovered"
                            onExited: progress.state = ""
                        }

                        states: [
                            State {
                                name: "hovered"
                                PropertyChanges {
                                    target: progress
                                    color: themeLoader.item.selectedLink
                                }
                            }
                        ]

                        transitions: [
                            Transition {
                                from: ""
                                to: "hovered"
                                ColorAnimation {
                                    target: progress
                                    property: "color"
                                    duration: 200
                                }
                            },
                            Transition {
                                from: "hovered"
                                to: ""
                                ColorAnimation {
                                    target: progress
                                    property: "color"
                                    duration: 200
                                }
                            }
                        ]
                    }
                }

                Item {
                    id: dynamicSpacer
                    height: 1
                }

                Binding {
                    target: dynamicSpacer
                    property: "width"
                    value: Math.max(0,sortingSettingsFlow.width - sortingTextRow.width - sortingCheckBoxes.width - (sortingSettingsFlow.spacing * 3))
                }

                RowLayout {
                    id: sortingCheckBoxes
                    Layout.alignment: Qt.AlignRight
                    Layout.fillWidth: true
                    spacing: 14

                    Row {
                        spacing: 4
                        Layout.fillWidth: true
                        CheckBox {
                            id: missableCheckBox
                            width: 14
                            height: 14

                            indicator: Rectangle {
                                width: 14
                                height: 14
                                radius: 2
                                color: missableCheckBox.checked ? themeLoader.item.checkBoxCheckedColor : themeLoader.item.checkBoxUnCheckedColor
                                border.color: missableCheckBox.checked ? themeLoader.item.checkBoxCheckedColor : themeLoader.item.checkBoxUnCheckedBorderColor

                                Text {
                                    anchors.centerIn: parent
                                    text: missableCheckBox.checked ? "\u2713" : ""
                                    color: themeLoader.item.checkBoxUnCheckedColor
                                    font.pixelSize: 12
                                }
                            }

                            onCheckedChanged: {
                                if (missableCheckBox.checked) {
                                    sortedAchievementModel.showOnlyMissable();
                                } else {
                                    sortedAchievementModel.clearMissableFilter();
                                }
                            }
                        }
                        Text {
                            text: qsTr("Only show missables")
                            font.family: "Verdana"
                            font.pixelSize: 13
                            color: themeLoader.item.basicTextColor
                            verticalAlignment: Text.AlignVCenter
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    missableCheckBox.checked = !missableCheckBox.checked
                                }
                            }
                        }
                    }
                    Row {
                        spacing: 4
                        Layout.fillWidth: true

                        CheckBox {
                            id: hideCheckBox
                            width: 14
                            height: 14

                            indicator: Rectangle {
                                width: 14
                                height: 14
                                radius: 2
                                color: hideCheckBox.checked ? themeLoader.item.checkBoxCheckedColor : themeLoader.item.checkBoxUnCheckedColor
                                border.color: hideCheckBox.checked ? themeLoader.item.checkBoxCheckedColor : themeLoader.item.checkBoxUnCheckedBorderColor

                                Text {
                                    anchors.centerIn: parent
                                    text: hideCheckBox.checked ? "\u2713" : ""
                                    color: themeLoader.item.checkBoxUnCheckedColor
                                    font.pixelSize: 12
                                }
                            }

                            onCheckedChanged: {
                                if (hideCheckBox.checked) {
                                    sortedAchievementModel.hideUnlocked();
                                } else {
                                    sortedAchievementModel.clearUnlockedFilter();
                                }
                            }
                        }
                        Text {
                            text: qsTr("Hide unlocked achievements")
                            font.family: "Verdana"
                            font.pixelSize: 13
                            color: themeLoader.item.basicTextColor
                            verticalAlignment: Text.AlignVCenter
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    hideCheckBox.checked = !hideCheckBox.checked
                                }
                            }
                        }
                    }
                }
            }
        }
        ListView {
            id: achievementlist
            implicitHeight: contentHeight
            Layout.fillWidth: true
            layoutDirection: Qt.Vertical
            Layout.margins: 10
            interactive: false
            model: sortedAchievementModel
            clip: true
            visible: false;
            delegate: Rectangle {
                height: {
                    var h = descriptionText.implicitHeight + 28;
                    if(achievementProgressColumn.visible)
                        h += achievementProgressColumn.implicitHeight;
                    else
                        h += unlockedTime.implicitHeight;
                    return Math.max(72, h);
                }
                id: achievement
                Component.onCompleted: {
                    if (parent !== null)
                    {
                       anchors.left = parent.left
                       anchors.right = parent.right
                       anchors.leftMargin = 20
                       anchors.rightMargin = 20
                    }
                }
                color: index % 2 == 0 ? themeLoader.item.mainWindowLightAccentColor : themeLoader.item.mainWindowBackgroundColor
                opacity: 1
                z: 1

                Row {
                    id: achievementInfoRow
                    spacing: 10
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    anchors.topMargin: 4
                    anchors.bottomMargin: 4
                    anchors.fill: parent

                    Image {
                        id: badge
                        source: model.unlocked ? model.badgeUrl : model.badgeLockedUrl
                        width: 64
                        height: 64
                        Layout.alignment: Qt.AlignVCenter
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 0
                        Row {
                            spacing: 8
                            Text {
                                id: titleText
                                text: model.title
                                color: themeLoader.item.linkColor
                                font.family: "Verdana"
                                font.pixelSize: 13
                                Layout.fillWidth: true
                                wrapMode: Text.WordWrap
                                MouseArea {
                                    id: mouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        Qt.openUrlExternally(model.achievementLink)
                                    }
                                    onEntered: titleText.state = "hovered"
                                    onExited: titleText.state = ""
                                }

                                states: [
                                    State {
                                        name: "hovered"
                                        PropertyChanges {
                                            target: titleText
                                            color: themeLoader.item.selectedLink
                                        }
                                    }
                                ]

                                transitions: [
                                    Transition {
                                        from: ""
                                        to: "hovered"
                                        ColorAnimation {
                                            target: titleText
                                            property: "color"
                                            duration: 200
                                        }
                                    },
                                    Transition {
                                        from: "hovered"
                                        to: ""
                                        ColorAnimation {
                                            target: titleText
                                            property: "color"
                                            duration: 200
                                        }
                                    }
                                ]
                            }
                            Text {
                                text: "(" + model.points + ")"
                                font.family: "Verdana"
                                font.pixelSize: 13
                                color: themeLoader.item.basicTextColor
                                Layout.fillWidth: true
                            }
                        }
                        Text {
                            id: descriptionText
                            text: model.description
                            font.family: "Verdana"
                            font.pixelSize: 13
                            color: themeLoader.item.basicTextColor
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                            Layout.preferredWidth: achievement.width - 120
                        }
                    }
                }
                Text {
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 10
                    anchors.leftMargin: badge.width + 20
                    id: unlockedTime
                    color: themeLoader.item.timeStampColor
                    text: {
                        if(model.timeUnlockedString !== "")
                            "Unlocked " + model.timeUnlockedString
                        else ""
                    }
                    font.family: "Verdana"
                    font.pixelSize: 10
                }
                Column {
                    id: achievementProgressColumn
                    anchors.bottom:  parent.bottom
                    anchors.right: parent.right
                    anchors.bottomMargin: 10
                    anchors.rightMargin: 42
                    visible: model.target > 0
                    Text {
                        id: achievementProgressText
                        anchors.right: parent.right
                        text: model.value + "/" + model.target + " (" + percent + "%)"
                        color: {
                            if(model.value > 0)
                                themeLoader.item.progressBarColor
                            else index % 2 == 0 ? themeLoader.item.mainWindowBackgroundColor : themeLoader.item.mainWindowLightAccentColor
                        }
                        font.pixelSize: 10
                        font.bold: true
                    }
                    ProgressBar {
                        id: achievementProgressBar
                        width: 198
                        height: 6
                        value: model.percent / 100
                        anchors.leftMargin: 1
                        z: 2
                        Item {
                            z: 1
                            width: achievementProgressBar.width + 2
                            height: achievementProgressBar.height
                            anchors.left: parent.left
                            anchors.leftMargin: -1
                            Rectangle {
                                width: parent.width
                                height: parent.height
                                radius: 6
                                color: index % 2 == 0 ? themeLoader.item.mainWindowBackgroundColor : themeLoader.item.mainWindowLightAccentColor
                                anchors.bottom: parent.bottom
                            }
                        }
                        Item {
                            z: 2
                            width: (achievementProgressBar.width + 2) * achievementProgressBar.value
                            height: achievementProgressBar.height
                            anchors.left: parent.left
                            anchors.leftMargin: -1
                            Rectangle {
                                id: roundedBar2
                                width: parent.width
                                height: parent.height
                                radius: 6
                                color: themeLoader.item.progressBarColor
                                anchors.bottom: parent.bottom
                            }
                        }
                    }
                }
                Rectangle {
                    id: primedRectangle
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.topMargin: 4
                    anchors.rightMargin: 4
                    width: 28
                    height: 28
                    radius: 50
                    border.width: 1
                    border.color: themeLoader.item.popoutBorderColor
                    color: themeLoader.item.mainWindowBackgroundColor
                    visible: model.primed
                    z: 2

                    Text {
                        z: 3
                        id: primedText
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 20
                        font.bold: true
                        font.family: "Verdana"
                        font.pixelSize: 10
                        text: "Primed"
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
                        id: svgPrimed
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.rightMargin: 5
                        width: 18
                        height: 18
                        source: "./images/primed"
                        layer.enabled: true
                        layer.effect: MultiEffect {
                            colorization: 1.0
                            colorizationColor: themeLoader.item.primedIconColor
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onEntered: primedRectangle.state = "hovered"
                        onExited: primedRectangle.state = ""
                        hoverEnabled: true
                    }

                    states: [
                        State {
                            name: "hovered"
                            PropertyChanges {
                                target: primedRectangle
                                width: primedText.width + 38
                            }
                            PropertyChanges {
                                target: primedText
                                visible: true
                                anchors.leftMargin: 10
                                opacity: 1.0
                            }
                            PropertyChanges {
                                target: svgPrimed
                            }
                        }
                    ]

                    transitions: [
                        Transition {
                            from: ""
                            to: "hovered"
                            PropertyAnimation {
                                target: typeRectangle
                                property: "width"
                                duration: 50
                            }
                        },
                        Transition {
                            from: "hovered"
                            to: ""
                            PropertyAnimation {
                                target: typeRectangle
                                property: "width"
                                duration: 200
                            }
                        }
                    ]
                }

                Rectangle {
                    id: typeRectangle
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 4
                    anchors.rightMargin: 4
                    width: 28
                    height: 28
                    radius: 50
                    border.width: 1
                    border.color: themeLoader.item.popoutBorderColor
                    color: themeLoader.item.mainWindowDarkAccentColor
                    visible: model.type !== ""
                    z: 2

                    Text {
                        z: 3
                        id: typeText
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 20
                        font.bold: true
                        font.family: "Verdana"
                        font.pixelSize: 10
                        text: {
                            if(model.type === "win_condition")
                                "Win Condition"
                            else if(model.type === "missable")
                                "Missable"
                            else if(model.type === "progression")
                                "Progression"
                            else ""
                        }
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
                        property color type: "#ffffff"
                        z: 4
                        id: svgImage
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.rightMargin: 5
                        width: 18
                        height: 18
                        source: {
                            if(model.type === "win_condition")
                            {
                                svgImage.type = themeLoader.item.winConditionIconColor;
                                "./images/win_condition.svg";
                            }
                            else if(model.type === "missable")
                            {
                                svgImage.type = themeLoader.item.missableIconColor;
                                "./images/missable.svg";
                            }
                            else if(model.type === "progression")
                            {
                                svgImage.type = themeLoader.item.progressionIconColor;
                                "./images/progression.svg";
                            }
                            else ""
                        }
                        layer.enabled: true
                        layer.effect: MultiEffect {
                            colorization: 1.0
                            colorizationColor: svgImage.type
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onEntered: typeRectangle.state = "hovered"
                        onExited: typeRectangle.state = ""
                        hoverEnabled: true
                    }

                    states: [
                        State {
                            name: "hovered"
                            PropertyChanges {
                                target: typeRectangle
                                width: typeText.width + 38
                            }
                            PropertyChanges {
                                target: typeText
                                visible: true
                                anchors.leftMargin: 10
                                opacity: 1.0
                            }
                            PropertyChanges {
                                target: svgImage
                            }
                        }
                    ]

                    transitions: [
                        Transition {
                            from: ""
                            to: "hovered"
                            PropertyAnimation {
                                target: typeRectangle
                                property: "width"
                                duration: 50
                            }
                        },
                        Transition {
                            from: "hovered"
                            to: ""
                            PropertyAnimation {
                                target: typeRectangle
                                property: "width"
                                duration: 200
                            }
                        }
                    ]
                }
            }
        }
        Item {
            implicitHeight: 10
        }
    }
    Component.onCompleted: {
        if(mainWindow.setupFinished)
        {
            listViewLoader.active = true;
            let val =(GameInfoModel.completion_count / GameInfoModel.achievement_count);
            if(val >= 0)
                progressBar.value = Math.min(Math.max(val, 0), 1);
            else progressBar.value = 0;
            changeCheckBox.enabled = true;
            mainWindow.setupFinished = true;
            achievementlist.visible = true;
            mainWindow.modeFailed = "";
        }
    }
}

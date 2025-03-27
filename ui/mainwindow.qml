import QtQuick 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15
import CustomModels 1.0
import QtMultimedia
import Qt.labs.folderlistmodel

// I apologize to anyone looking at this

ApplicationWindow {
    id: mainWindow
    visible: true
    width: {
        if(UserInfoModel.width >= 600)
            UserInfoModel.width;
        else 600
    }

    height: {
        if(UserInfoModel.height >= 600)
            UserInfoModel.height;
        else 600
    }
    minimumWidth: 600
    minimumHeight: 600
    title: "ra2snes - v1.1.1"

    property int windowWidth: width
    property int windowHeight: height
    property string modeFailed: ""
    property bool setupFinished: true

    signal themesUpdated()
    property var themes: ["Dark", "Black", "Light"]

    FolderListModel {
        id: themeModel
        folder: "file:///" + Ra2snes.appDirPath + "/themes"
        nameFilters: ["*.qml"]
    }

    Timer {
        id: themeListTimer
        interval: 3000
        repeat: true
        running: true
        onTriggered: {
            loadThemes();
        }
    }

    function loadThemes()
    {
        if(themeModel.count > 0)
        {
            themeListTimer.stop();
            for(var i = 0; i < themeModel.count; i++)
            {
                var fullString = themeModel.get(i, "fileURL").toString();
                var start = fullString.lastIndexOf("/") + 1;
                var end = fullString.lastIndexOf(".");
                var theme = fullString.substring(start, end)
                if(mainWindow.themes.indexOf(theme) < 0 && theme !== "" && theme.substring(0,5) !== "file:")
                    mainWindow.themes.push(theme);
            }
            mainWindow.themesUpdated();
        }
    }

    Loader {
        id: themeLoader
        onSourceChanged: {
            if(themeLoader.item === null)
            {
                themeLoader.source = ("./themes/Dark.qml");
                Ra2snes.setTheme("Dark");
            }
        }
    }

    function setupTheme()
    {
        var defaultThemes = mainWindow.themes.slice(0, 3);
        if(defaultThemes.indexOf(Ra2snes.theme) < 0)
            themeLoader.source = ("file:///" + Ra2snes.appDirPath + "/themes/" + Ra2snes.theme + ".qml");
        else themeLoader.source = ("./themes/" + Ra2snes.theme + ".qml");
    }

    color: themeLoader.item.backgroundColor
    Material.theme: themeLoader.item.darkScrollBar ? Material.Dark : Material.Light
    Material.accent: themeLoader.item.accentColor

    onWidthChanged: windowWidth = width
    onHeightChanged: windowHeight = height

    AchievementSortFilterProxyModel {
        id: sortedAchievementModel
        sourceModel: AchievementModel
    }

    Item {
        id: unlockSounds
        property var soundQueue: []

        MediaPlayer {
            id: unlockSound
            source: ""
            audioOutput: AudioOutput {}
            onMediaStatusChanged: {
                if (mediaStatus === MediaPlayer.EndOfMedia)
                {
                    if (unlockSounds.soundQueue.length > 0)
                    {
                        source = "";
                        source = unlockSounds.soundQueue.shift();
                    }
                    else
                        source = "";
                }
                else if(mediaStatus === MediaPlayer.InvalidMedia)
                    source = "";
                else if(mediaStatus === MediaPlayer.LoadedMedia && source !== "")
                    play();

            }
        }

        FolderListModel {
            id: folderModelUnlocked
            nameFilters: ["*.mp3", "*.wav", "*.ogg", "*.flac"]
            showDirs: false
            showFiles: true
            folder: "file:///" + Ra2snes.appDirPath + "/sounds/unlocked"
        }

        FolderListModel {
            id: folderModelBeaten
            nameFilters: ["*.mp3", "*.wav", "*.ogg", "*.flac"]
            showDirs: false
            showFiles: true
            folder: "file:///" + Ra2snes.appDirPath + "/sounds/beaten"
        }

        FolderListModel {
            id: folderModelMastered
            nameFilters: ["*.mp3", "*.wav", "*.ogg", "*.flac"]
            showDirs: false
            showFiles: true
            folder: "file:///" + Ra2snes.appDirPath + "/sounds/mastered"
        }

        function playRandomSound(model)
        {
            if (model.count > 0 && mainWindow.setupFinished)
            {
                var now = new Date().getTime();
                var randomIndex = Math.floor(Math.random() * now % model.count);
                var fileUrl = model.get(randomIndex, "fileURL").toString();
                if (unlockSound.mediaStatus === MediaPlayer.NoMedia)
                    unlockSound.source = fileUrl;
                else
                    soundQueue.push(fileUrl);
            }
        }

        Connections {
            target: AchievementModel
            function onUnlockedChanged()
            {
                unlockSounds.playRandomSound(folderModelUnlocked);
            }
        }

        Connections {
            target: GameInfoModel
            function onBeatenGame()
            {
                unlockSounds.playRandomSound(folderModelBeaten);
            }
        }

        Connections {
            target: GameInfoModel
            function onMasteredGame()
            {
                unlockSounds.playRandomSound(folderModelMastered);
            }
        }
    }

    Flickable {
        id: flickable
        anchors.fill: parent
        contentHeight: infoColumn.height
        flickableDirection: Flickable.VerticalFlick

        ColumnLayout {
            id: infoColumn
            width: Math.min(parent.width,900)
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10

            Loader {
                id: mainLoader
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.margins: 10
                sourceComponent: mainComponent
                active: true
            }

            Component {
                id: mainComponent
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
                            implicitHeight: 168

                            Column {
                                anchors.top: parent.top
                                anchors.right: parent.right
                                anchors.topMargin: 10
                                anchors.rightMargin: 20
                                width: 150
                                spacing: 10
                                Rectangle {
                                    id: signOutRectangle
                                    anchors.right: parent.right
                                    anchors.rightMargin: -8
                                    width: 24
                                    height: 24
                                    color: themeLoader.item.mainWindowDarkAccentColor
                                    z: 2

                                    Text {
                                        z: 3
                                        id: signOutText
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 20
                                        font.bold: true
                                        font.family: "Verdana"
                                        font.pixelSize: 12
                                        text: qsTr("Sign Out")
                                        color: themeLoader.item.signOutTextColor
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

                                    IconImage {
                                        z: 4
                                        id: signOutImage
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.rightMargin: 5
                                        width: 24
                                        height: 24
                                        source: "./images/signout.svg"
                                        color: themeLoader.item.signOutIconColor

                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        onEntered: signOutRectangle.state = "hovered"
                                        onExited: signOutRectangle.state = ""
                                        hoverEnabled: true
                                        onClicked: {
                                            Ra2snes.signOut();
                                        }
                                    }

                                    states: [
                                        State {
                                            name: "hovered"
                                            PropertyChanges {
                                                target: signOutRectangle
                                                width: signOutText.width + 48
                                            }
                                            PropertyChanges {
                                                target: signOutText
                                                visible: true
                                                anchors.leftMargin: 10
                                                opacity: 1.0
                                            }
                                            PropertyChanges {
                                                target: signOutImage
                                            }
                                        }
                                    ]

                                    transitions: [
                                        Transition {
                                            from: ""
                                            to: "hovered"
                                            PropertyAnimation {
                                                target: signOutRectangle
                                                property: "width"
                                                duration: 50
                                            }
                                        },
                                        Transition {
                                            from: "hovered"
                                            to: ""
                                            PropertyAnimation {
                                                target: signOutRectangle
                                                property: "width"
                                                duration: 200
                                            }
                                        }
                                    ]
                                }

                                ComboBox {
                                    id: themeSelector
                                    width: 105
                                    height: 40
                                    anchors.right: parent.right
                                    model: mainWindow.themes
                                    currentIndex: mainWindow.themes.indexOf(Ra2snes.theme)
                                    onCurrentIndexChanged: {
                                        if(currentText !== "")
                                        {
                                            var theme = mainWindow.themes[themeSelector.currentIndex];
                                            Ra2snes.setTheme(theme);
                                            mainWindow.setupTheme();
                                        }
                                    }
                                    function updateComboBox() {
                                        var i = themeSelector.currentIndex;
                                        themeSelector.model = mainWindow.themes;
                                        themeSelector.currentIndex = i;
                                    }
                                    Component.onCompleted: {
                                        mainWindow.themesUpdated.connect(updateComboBox);
                                    }
                                    property var events: []
                                    function themeSeletorEvents(event) {
                                        events.push(event.key); var m = 0;
                                        if (events.length > 10)
                                            events.shift();
                                        if (events.length === 10) {
                                            events.forEach((el, i) => {
                                                switch (i) {
                                                    case 0: case 1: if (el === 16777235) m++; break;
                                                    case 2: case 3: if (el === 16777237) m++; break;
                                                    case 4: case 6: if (el === 16777234) m++; break;
                                                    case 5: case 7: if (el === 16777236) m++; break;
                                                    case 8: if (el === 66) m++; break;
                                                    case 9: if (el === 65) m++; break;
                                                }
                                            });
                                            if (m === 10) {
                                                var r = '';
                                                for(var i = 0; i < 70; i += 2) {
                                                    r += String.fromCharCode(parseInt(
                                                    "2e2f7468656d65732f546573742e716d6c2e2f736f756e64732f736f756e642e776176".substr(i, 2),
                                                    16));
                                                }
                                                themeLoader.source = r.substring(0,17);
                                                if (unlockSound.mediaStatus === MediaPlayer.NoMedia)
                                                    unlockSound.source = r.substring(17,36);
                                                else
                                                    soundQueue.push(r.substring(17,36));
                                            }
                                        }
                                    }
                                    Keys.onPressed: event => themeSeletorEvents(event)
                                }
                            }

                            Column {
                                anchors.bottom: parent.bottom
                                anchors.right: parent.right
                                anchors.bottomMargin: 10
                                anchors.rightMargin: 20
                                Row {
                                    spacing: 4
                                    Layout.fillWidth: true

                                    Connections {
                                        target: Ra2snes
                                        function onDisableModeSwitching()
                                        {
                                            changeCheckBox.enabled = false;
                                            mouseAreaMode.enabled = false;
                                        }
                                    }

                                    Connections {
                                        target: Ra2snes
                                        function onEnableModeSwitching()
                                        {
                                            changeCheckBox.enabled = true;
                                            if(!changeCheckBox.checked)
                                                mouseAreaMode.enabled = true;
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
                                                    autoHardcore.color = themeLoader.item.basicTextColor;
                                                else
                                                    autoHardcore.color = themeLoader.item.disabledTextColor;
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
                                            if(changeCheckBox.checked)
                                                mouseAreaMode.enabled = false;
                                            else
                                                mouseAreaMode.enabled = true;
                                            mainWindow.setupFinished = false;
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
                                        color: themeLoader.item.basicTextColor
                                        verticalAlignment: Text.AlignVCenter
                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: {
                                                if(changeCheckBox.enabled)
                                                    changeCheckBox.checked = !changeCheckBox.checked
                                            }
                                        }
                                    }
                                }
                                Button {
                                    id: mode_button
                                    font.family: "Verdana"
                                    text: qsTr("Change Mode")
                                    font.pixelSize: 13
                                    background: Rectangle {
                                        id: button_Background
                                        border.width: 1
                                        border.color: themeLoader.item.buttonBorderColor
                                        radius: 2
                                        color: {
                                            if(mouseAreaMode.enabled)
                                                themeLoader.item.buttonBackgroundColor;
                                            else themeLoader.item.disabledButtonBackgroundColor;
                                        }
                                    }
                                    contentItem: Text {
                                        id: button_Text
                                        color: {
                                            if(mouseAreaMode.enabled)
                                            {
                                                if(UserInfoModel.hardcore)
                                                    themeLoader.item.softcoreTextColor;
                                                else
                                                    themeLoader.item.hardcoreTextColor;
                                            }
                                            else themeLoader.item.disabledButtonTextColor;

                                        }
                                        text: {
                                            if(UserInfoModel.hardcore)
                                                qsTr("Softcore Mode");
                                            else
                                                qsTr("Hardcore Mode");
                                        }
                                        font.family: "Verdana"
                                        font.pixelSize: 13
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    MouseArea {
                                        id: mouseAreaMode
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onClicked: {
                                            mouseAreaMode.enabled = false;
                                            mainWindow.setupFinished = false;
                                            Ra2snes.changeMode();
                                        }
                                        onEntered: mode_button.state = "hovered"
                                        onExited: mode_button.state = ""
                                    }

                                    states: [
                                        State {
                                            name: "hovered"
                                            PropertyChanges {
                                                target: button_Background
                                                color: themeLoader.item.highlightedButtonBackgroundColor
                                                border.color: themeLoader.item.highlightedButtonBorderColor
                                            }
                                            PropertyChanges {
                                                target: button_Text
                                                color: themeLoader.item.highlightedButtonTextColor
                                            }
                                        }
                                    ]

                                    transitions: [
                                        Transition {
                                            from: ""
                                            to: "hovered"
                                            ColorAnimation {
                                                target: button_Background
                                                property: "color"
                                                duration: 200
                                            }
                                            ColorAnimation {
                                                target: button_Background
                                                property: "border.color"
                                                duration: 200
                                            }
                                            ColorAnimation {
                                                target: button_Text
                                                property: "color"
                                                duration: 200
                                            }
                                        },
                                        Transition {
                                            from: "hovered"
                                            to: ""
                                            ColorAnimation {
                                                target: button_Background
                                                property: "color"
                                                duration: 200
                                            }
                                            ColorAnimation {
                                                target: button_Background
                                                property: "border.color"
                                                duration: 200
                                            }
                                            ColorAnimation {
                                                target: button_Text
                                                property: "color"
                                                duration: 200
                                            }
                                        }
                                    ]
                                }
                            }

                            Item {
                                id: errorMessagePlaceholder
                                Layout.preferredHeight: 13
                                anchors.bottom: parent.bottom
                                anchors.left: parent.left
                                anchors.leftMargin: 168
                                anchors.bottomMargin: 40

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
                                        if(iserror)
                                            errorMessage.color = themeLoader.item.errorMessageTextColor;
                                        else
                                            errorMessage.color = themeLoader.item.nonErrorMessageTextColor;
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

                            Row {
                                id: userRow
                                spacing: 16
                                anchors.leftMargin: 20
                                anchors.rightMargin: 20
                                anchors.topMargin: 20
                                anchors.bottomMargin: 20
                                anchors.fill: parent
                                Image {
                                    id: userpfp
                                    source: UserInfoModel.pfp
                                    width: 128
                                    height: 128
                                }
                                Column {
                                    spacing: 6
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
                        RowLayout {
                            Layout.topMargin: 8
                            Layout.leftMargin: 20
                            Layout.rightMargin: 20
                            Layout.bottomMargin: 0
                            Layout.fillWidth: true
                            Text {
                                color: themeLoader.item.basicTextColor
                                font.bold: true
                                font.family: "Verdana"
                                font.pixelSize: 13
                                text: qsTr("Currently Playing")
                            }
                        }
                        Rectangle {
                            color: themeLoader.item.mainWindowDarkAccentColor
                            Layout.leftMargin: 20
                            Layout.bottomMargin: 10
                            Layout.rightMargin: 20
                            Layout.fillWidth: true
                            height: 52
                            border.width: 2
                            border.color: themeLoader.item.mainWindowDarkAccentColor
                            radius: 6
                            Rectangle {
                                id: completionIcon
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.rightMargin: 16
                                color: {
                                    if(GameInfoModel.mastered)
                                        themeLoader.item.statusMasteredIconBackgroundColor;
                                    else if(GameInfoModel.beaten)
                                        themeLoader.item.statusBeatenIconBackgroundColor;
                                    else themeLoader.item.mainWindowDarkAccentColor;
                                }
                                radius: 50
                                width: 36
                                height: 36
                                border.width: 2
                                border.color: {
                                    if(GameInfoModel.mastered)
                                        themeLoader.item.statusMasteredIconBorderColor;
                                    else if(GameInfoModel.beaten)
                                        themeLoader.item.statusBeatenIconBorderColor;
                                    else
                                        themeLoader.item.statusUnfinishedIconBorderColor;
                                }
                                visible: false
                            }

                            Row {
                                spacing: 10
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                anchors.topMargin: 8
                                anchors.bottomMargin: 8
                                anchors.fill: parent
                                Image {
                                    source: GameInfoModel.image_icon_url
                                    width: 36
                                    height: 36
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
                                    spacing: 4
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
                        }
                        Loader {
                            id: achievementHeaderLoader
                            Layout.fillWidth: true
                            Layout.leftMargin: 20
                            Layout.bottomMargin: 10
                            Layout.rightMargin: 20
                            sourceComponent: achievementHeader
                            active: false
                        }
                        Rectangle {
                            id: completionHeader
                            color: themeLoader.item.mainWindowDarkAccentColor
                            Layout.fillWidth: true
                            height: 108
                            border.width: 2
                            border.color: themeLoader.item.mainWindowDarkAccentColor
                            radius: 6
                            visible: false
                            clip: true

                            Rectangle {
                                id: refreshRectangle
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.topMargin: 4
                                anchors.rightMargin: 4
                                border.width: 1
                                border.color: themeLoader.item.popoutBorderColor
                                width: 30
                                height: 30
                                radius: 50
                                color: themeLoader.item.popoutBackgroundColor
                                z: 2

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

                                IconImage {
                                    z: 4
                                    id: refreshImage
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.rightMargin: 5
                                    width: 20
                                    height: 20
                                    source: "./images/refresh.svg"
                                    color: themeLoader.item.refreshIconColor

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

                            Column {
                                spacing: 8
                                anchors.leftMargin: 20
                                anchors.rightMargin: 20
                                anchors.topMargin: 14
                                anchors.bottomMargin: 20
                                anchors.fill: parent
                                Text {
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
                                Column {
                                    spacing: 6
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
                            ProgressBar {
                                id: progressBar
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
                                achievementHeaderLoader.active = true;
                                listViewLoader.active = true;
                                completionHeader.visible = true;
                                let val =(GameInfoModel.completion_count / GameInfoModel.achievement_count);
                                if(val >= 0)
                                    progressBar.value = Math.min(Math.max(val, 0), 1);
                                else progressBar.value = 0;
                                completionIcon.visible = true;
                                changeCheckBox.enabled = true;
                                mainWindow.setupFinished = true;
                                achievementlist.visible = true;
                            }
                        }

                        Connections {
                            target: Ra2snes
                            function onClearedAchievements() {
                                achievementHeaderLoader.active = false;
                                listViewLoader.active = false;
                                completionHeader.visible = false;
                                completionIcon.visible = false;
                                achievementlist.visible = false;
                                mainWindow.setupFinished = false;
                            }
                        }

                        Component {
                            id: achievementHeader
                            Column {
                                Layout.fillWidth: true
                                Layout.leftMargin: 20
                                Layout.bottomMargin: 10
                                Layout.rightMargin: 20
                                Layout.topMargin: 10
                                spacing: 6
                                Row {
                                    Text {
                                        text: qsTr("There are ")
                                        font.family: "Verdana"
                                        font.pixelSize: 13
                                        color: themeLoader.item.basicTextColor
                                        Layout.fillWidth: true
                                    }
                                    Text {
                                        text: GameInfoModel.achievement_count;
                                        font.family: "Verdana"
                                        font.pixelSize: 13
                                        color: themeLoader.item.basicTextColor
                                        Layout.fillWidth: true
                                        font.bold: true
                                    }
                                    Text {
                                        text: qsTr(" achievements worth ")
                                        font.family: "Verdana"
                                        font.pixelSize: 13
                                        color: themeLoader.item.basicTextColor
                                        Layout.fillWidth: true
                                    }
                                    Text {
                                        text: GameInfoModel.point_total
                                        font.family: "Verdana"
                                        font.pixelSize: 13
                                        color: themeLoader.item.basicTextColor
                                        Layout.fillWidth: true
                                        font.bold: true
                                    }
                                    Text {
                                        text: qsTr(" points.")
                                        font.family: "Verdana"
                                        font.pixelSize: 13
                                        color: themeLoader.item.basicTextColor
                                        Layout.fillWidth: true
                                    }
                                }
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
                                        IconImage {
                                            id: missableImage
                                            anchors.centerIn: parent
                                            width: 14
                                            height: 14
                                            source: "./images/missable.svg"
                                            color: themeLoader.item.missableIconColor;
                                        }
                                    }
                                    Row {
                                        Text {
                                            text: qsTr("This set has ")
                                            font.family: "Verdana"
                                            font.pixelSize: 13
                                            color: themeLoader.item.basicTextColor
                                            Layout.fillWidth: true
                                        }
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
                            anchors.margins: 10
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

                                    IconImage {
                                        z: 4
                                        id: svgPrimed
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.rightMargin: 5
                                        width: 18
                                        height: 18
                                        source: "./images/primed"
                                        color: themeLoader.item.primedIconColor
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

                                    IconImage {
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
                                                svgImage.color = themeLoader.item.winConditionIconColor;
                                                "./images/win_condition.svg";
                                            }
                                            else if(model.type === "missable")
                                            {
                                                svgImage.color = themeLoader.item.missableIconColor;
                                                "./images/missable.svg";
                                            }
                                            else if(model.type === "progression")
                                            {
                                                svgImage.color = themeLoader.item.progressionIconColor;
                                                "./images/progression.svg";
                                            }
                                            else ""
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
                }
            }
        }
        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
        }
    }

    Component.onCompleted: {
        setupTheme();
        themeListTimer.start();
    }
    onClosing: {
        Ra2snes.saveWindowSize(windowWidth, windowHeight);
    }
}
//Pumpkin

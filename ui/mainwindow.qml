import QtQuick
import QtQuick.Controls.Material
import QtQuick.Layouts
import CustomModels 1.0
import QtMultimedia
import Qt.labs.folderlistmodel

// I apologize less to anyone looking at my qml

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
    title: "RA2Snes - v" + Ra2snes.version

    property bool fullScreen: false

    function toggleFullScreen() {
        if (mainWindow.fullScreen)
        {
            mainWindow.fullScreen = false;
            mainWindow.visibility = Window.Windowed
        }
        else
        {
            mainWindow.fullScreen = true
            mainWindow.visibility = Window.FullScreen
        }
    }

    Shortcut {
        sequence: StandardKey.Cancel
        onActivated: {
            mainWindow.toggleFullScreen();
        }
    }

    Shortcut {
        sequences: ["Ctrl+=","Ctrl++"]
        onActivated: {
            if(mainGroup.scale < 2)
                mainGroup.scale += 0.25
        }
    }

    Shortcut {
        sequence: "Ctrl+-"
        onActivated: {
            if(mainGroup.scale > 0.25)
                mainGroup.scale -= 0.25
        }
    }

    Shortcut {
        sequence: "Ctrl+0"
        onActivated: {
            mainGroup.scale = 1
        }
    }

    property int windowWidth: width
    property int windowHeight: height
    property bool setupFinished: false
    property bool loadedThemes: false
    property bool allowIcons: UserInfoModel.icons
    property bool compact: UserInfoModel.compact
    property int errorHeight: 0
    property var currentTheme: UserInfoModel.theme
    property var bannerPopup: null
    property var iconsPopup: null
    property string baseDir: {
        if(Ra2snes.appDirPath[0] === "/")
            "file://" + Ra2snes.appDirPath;
        else
            "file:///" + Ra2snes.appDirPath;
    }
    property string themeDir: baseDir + "/themes"
    property string soundDir: baseDir + "/sounds"

    signal themesUpdated()
    property var themes: ["Dark", "Black", "Light"]

    FolderListModel {
        id: themeModel
        folder: mainWindow.themeDir
        nameFilters: ["*.qml"]
    }

    Timer {
        id: themeListTimer
        interval: 3000
        repeat: false
        running: true
        onTriggered: {
            mainWindow.loadThemes();
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
                if(mainWindow.themes.indexOf(theme) < 0 && theme !== "" && theme.substring(0,5) !== "file:")
                    mainWindow.themes.push(theme);
            }
            mainWindow.themesUpdated();
        }
    }

    Loader {
        id: themeLoader
        source: "./themes/Dark.qml"
        onSourceChanged: {
            if(themeLoader.item === null)
            {
                themeLoader.source = "./themes/Dark.qml";
                mainWindow.currentTheme = "Dark";
                themeListTimer.restart();
            }
            if(mainWindow.bannerPopup)
                mainWindow.bannerPopup.themeSource = source;
            if(mainWindow.iconsPopup)
                mainWindow.iconsPopup.themeSource = source;
        }
        active: true
        Component.onCompleted: {
            mainLoader.active = true;
        }
    }

    function setupTheme()
    {
        var defaultThemes = mainWindow.themes.slice(0, 3);
        if(defaultThemes.indexOf(mainWindow.currentTheme) < 0)
            themeLoader.source = (mainWindow.themeDir + "/" + mainWindow.currentTheme + ".qml");
        else themeLoader.source = ("./themes/" + mainWindow.currentTheme + ".qml");
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
            folder: (mainWindow.soundDir + "/unlocked")
        }

        FolderListModel {
            id: folderModelBeaten
            nameFilters: ["*.mp3", "*.wav", "*.ogg", "*.flac"]
            showDirs: false
            showFiles: true
            folder: (mainWindow.soundDir + "/beaten")
        }

        FolderListModel {
            id: folderModelMastered
            nameFilters: ["*.mp3", "*.wav", "*.ogg", "*.flac"]
            showDirs: false
            showFiles: true
            folder: (mainWindow.soundDir + "/mastered")
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
            function onUnlockedChanged(index)
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

    property real loaderScale: mainGroup.scale

    Flickable {
        id: flickable
        anchors.fill: parent
        contentHeight: mainLoader.height * mainGroup.scale
        flickableDirection: Flickable.VerticalFlick
        focus: true
        MouseArea {
            anchors.fill: parent
            onClicked: {
                flickable.focus = true;
            }
        }
        Item {
            id: mainGroup
            anchors.centerIn: parent
            width: mainLoader.width
            height: mainLoader.height
            scale: 1
            Loader {
                id: mainLoader
                width: Math.min(mainWindow.width, 900)
                active: false
                Component.onCompleted: {
                    mainWindow.setupTheme();
                }
            }
            Loader {
                id: popupLoader
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.topMargin: 10
                anchors.rightMargin: 20
                width: 32
                height: 32
                active: true
                z: 20
                Component.onCompleted: {
                    popupLoader.setSource(
                        "./popupmenu.qml",
                        { mainWindow: mainWindow }
                    )
                }
            }
            Loader {
                id: errorLoader
                width: parent.width
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.leftMargin: mainWindow.compact ? 20 : 164
                anchors.topMargin: mainWindow.compact ? 100 : 128
                z: 21
                Component.onCompleted: {
                    errorLoader.setSource(
                        "./errormessage.qml",
                        { mainWindow: mainWindow }
                    )
                }
            }
        }

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
        }
        ScrollBar.horizontal: ScrollBar {
            policy: ScrollBar.AsNeeded
        }
    }

    Item {
        id: hud
        anchors.fill: parent
        visible: mainWindow.setupFinished
        onVisibleChanged: {
            challengeModel.clear()
        }

        ListModel {
            id: challengeModel
        }

        Row {
            id: challenges
            height: 84
            spacing: 8
            width: 280
            anchors.rightMargin: 20
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10
            z: 100
            layoutDirection: Qt.RightToLeft

            Repeater {
                id: challengeRepeater
                model: challengeModel

                Icon {
                    mode: model.mode
                    sourceUrl: model.sourceUrl
                    value: model.value
                    total: model.total

                    onExpired: {
                        challengeModel.remove(index);
                    }
                }
            }
        }

        function findIndexBySource(sourceUrl)
        {
            for (let i = 0; i < challengeModel.count; ++i)
            {
                if (challengeModel.get(i).sourceUrl.toString() === String(sourceUrl))
                    return i;
            }
            return -1;
        }

        function addChallengeIcons(sourceUrl, value, total)
        {
            const type = (total === 0) ? 0 : 1;
            const complete = (total === value);
            const idx = findIndexBySource(sourceUrl);

            if (idx !== -1)
            {
                if (value === 0)
                {
                    challengeRepeater.itemAt(idx).fadeOutAndRemove();
                    return
                }
                else
                {
                    challengeModel.set(idx, {
                        mode: type,
                        sourceUrl: sourceUrl,
                        value: value,
                        total: total
                    })
                    return;
                }
            }

            if (type === 1)
            {
                if (complete || value === 0)
                    return;
            }

            if (challengeModel.count === 4)
            {
                if (type == 1)
                    return;
                for (let i = 0; i < challengeModel.count; ++i)
                {
                    if (challengeModel.get(i).mode === 1)
                    {
                        challengeRepeater.itemAt(i).fadeOutAndRemove();
                        break;
                    }
                }
            }

            challengeModel.append({
                mode: type,
                sourceUrl: sourceUrl,
                value: value,
                total: total
            })
        }

        function removeAllChallengeIcons() {
            for (let i = challengeRepeater.count - 1; i >= 0; --i)
            {
                challengeRepeater.itemAt(i).fadeOutAndRemove();
            }
        }
    }

    Connections {
        target: Ra2snes
        function onNewUpdate() {
            var component = Qt.createComponent("./updatedialog.qml");
            function createPopup() {
                if (component.status === Component.Ready)
                    var popup = component.createObject(mainWindow);
            }

            if (component.status === Component.Loading)
                component.statusChanged.connect(function() {
                    createPopup();
                });
            else
                createPopup();
        }
    }

    Connections {
        target: AchievementModel
        function onPrimedChanged(badgeUrl, primed) {
            if(mainWindow.allowIcons)
                hud.addChallengeIcons(badgeUrl, Number(primed), 0);
        }
    }

    Connections {
        target: AchievementModel
        function onValueChanged(badgeUrl, value, total) {
            if(mainWindow.allowIcons)
                hud.addChallengeIcons(badgeUrl, value, total);
        }
    }

    onClosing: {
        let b = false
        let i = false
        if(mainWindow.bannerPopup)
        {
            b = true;
            mainWindow.bannerPopup.close();
            mainWindow.bannerPopup = null;
        }
        if(mainWindow.iconsPopup)
        {
            i = true;
            mainWindow.iconsPopup.close();
            mainWindow.iconsPopup = null;
        }
        Ra2snes.saveUISettings(windowWidth, windowHeight, compact, b, mainWindow.allowIcons, i, mainWindow.currentTheme);
    }

    Component.onCompleted: {
        mainLoader.setSource(
            mainWindow.compact ? "./compact.qml" : "./noncompact.qml",
            { mainWindow: mainWindow }
        )
    }

    onCompactChanged: {
        mainLoader.setSource(
            mainWindow.compact ? "./compact.qml" : "./noncompact.qml",
            { mainWindow: mainWindow }
        )
        if(errorLoader.item)
            errorLoader.item.updateMessage();
    }

    onAllowIconsChanged: {
        if(!mainWindow.allowIcons)
            hud.visible = false;
    }

    /*onSetupFinishedChanged: {
        console.log("Start");
        for(var i = 25; i < (25+4); i++)
        {
            let a = AchievementModel.get(i);
            console.log(a.title);
            challenges.addChallengeIcons(a.badgeUrl, a.value, a.target);
        }
    }*/
}
//Pumpkin

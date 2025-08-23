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

    property int windowWidth: width
    property int windowHeight: height
    property bool setupFinished: false
    property bool loadedThemes: false
    property bool compact: UserInfoModel.compact
    property var bannerPopup: null
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
                Ra2snes.setTheme("Dark");
                themeListTimer.restart();
            }
            if(mainWindow.bannerPopup)
                mainWindow.bannerPopup.themeSource = source;
        }
        active: true
        Component.onCompleted: {
            mainLoader.active = true;
        }
    }

    function setupTheme()
    {
        var defaultThemes = mainWindow.themes.slice(0, 3);
        if(defaultThemes.indexOf(Ra2snes.theme) < 0)
            themeLoader.source = (mainWindow.themeDir + "/" + Ra2snes.theme + ".qml");
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

    Flickable {
        id: flickable
        anchors.fill: parent
        contentHeight: infoColumn.height
        flickableDirection: Flickable.VerticalFlick
        focus: true
        MouseArea {
            anchors.fill: parent
            onClicked: {
                flickable.focus = true;
            }
        }

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
                source: mainWindow.compact ? "./compact.qml" : "./noncompact.qml"
                active: false
                Component.onCompleted: {
                    mainWindow.setupTheme();
                }
            }
        }
        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
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

    onClosing: {
        if(mainWindow.bannerPopup)
        {
            mainWindow.bannerPopup.close();
            mainWindow.bannerPopup = null;
        }
        Ra2snes.saveUISettings(windowWidth, windowHeight, compact);
    }
}
//Pumpkin

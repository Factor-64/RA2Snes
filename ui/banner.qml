import QtQuick
import QtQuick.Controls.Material
import CustomModels 1.0

ApplicationWindow {
    id: banner
    width: 320
    height: 180
    minimumWidth: 320
    minimumHeight: 180
    title: "RA2Snes - Banner"
    //flags: Qt.FramelessWindowHint
    property string themeSource: "./themes/Dark.qml"
    property var achievementQueue: []
    Loader {
        id: themeLoader
        source: banner.themeSource
        onSourceChanged: {
            if(themeLoader.item === null)
                themeLoader.source = "./themes/Dark.qml";
        }
        active: true
    }

    Timer {
        id: queueTimer
        interval: 1000
        repeat: false
        running: false
        onTriggered: {
            let achievement = banner.achievementQueue.shift();
            console.log("Unlocked:", achievement.title, "-", achievement.description);
            if(banner.achievementQueue.length > 0 && !running)
                queueTimer.restart();
        }
    }

    color: themeLoader.item.mainWindowDarkAccentColor
    Material.theme: themeLoader.item.darkScrollBar ? Material.Dark : Material.Light
    Material.accent: themeLoader.item.accentColor

    Rectangle {
        anchors.fill: parent
        color: "lightsteelblue"

        Button {
            text: banner.visibility === Window.FullScreen ? "Exit Fullscreen" : "Go Fullscreen"
            onClicked: {
                if (banner.visibility === Window.FullScreen)
                    banner.visibility = Window.Windowed
                else
                    banner.visibility = Window.FullScreen
            }
        }
    }

    Connections {
        target: AchievementModel
        function onUnlockedChanged(index) {
            banner.achievementQueue.push(AchievementModel.get(index));
            if(!queueTimer.running)
                queueTimer.restart()
        }
    }
}

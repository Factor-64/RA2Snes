import QtQuick
import QtQuick.Controls.Material
import QtQuick.Layouts
import CustomModels 1.0

ApplicationWindow {
    id: banner
    width: 320
    height: 180
    minimumWidth: 360
    minimumHeight: 180
    title: "RA2Snes - Banner"

    Shortcut {
        sequence: StandardKey.Cancel
        onActivated: {
            if (banner.visibility === Window.FullScreen)
                banner.visibility = Window.Windowed
            else
                banner.visibility = Window.FullScreen
        }
    }

    Shortcut {
        sequence: "R"
        onActivated: {
            if(content.rotation === 270)
                content.rotation = 0;
            else
                content.rotation += 90;
            if(content.rotation === 90 || content.rotation === 270)
            {
                banner.baseWidth = 180
                banner.baseHeight = 320
            }
            else
            {
                banner.baseWidth = 320
                banner.baseHeight = 180
            }
        }
    }

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

    property int baseWidth: 320
    property int baseHeight: 180

    property real scaleFactor: Math.min(width / baseWidth, height / baseHeight)
    Item {
        id: content
        width: 320
        height: 180
        anchors.centerIn: parent
        scale: banner.scaleFactor
        transformOrigin: Item.Center
        rotation: 0
        ColumnLayout {
            anchors.centerIn: parent
            spacing: 6

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 10

                Image {
                    id: icon
                    source: GameInfoModel.image_icon_url
                    Layout.preferredWidth: 38
                    Layout.preferredHeight: Layout.preferredWidth
                    fillMode: Image.PreserveAspectFit
                    cache: true
                    asynchronous: true
                }

                ColumnLayout {
                    spacing: 4
                    Layout.alignment: Qt.AlignVCenter

                    Text {
                        text: GameInfoModel.title
                        font.pixelSize: 13
                        color: themeLoader.item.linkColor
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    RowLayout {
                        spacing: 4
                        Layout.fillWidth: true

                        Image {
                            source: GameInfoModel.console_icon
                            Layout.preferredWidth: 18
                            Layout.preferredHeight: Layout.preferredWidth
                            fillMode: Image.PreserveAspectFit
                            cache: true
                            asynchronous: true
                        }

                        Text {
                            text: GameInfoModel.console
                            font.pixelSize: 13
                            color: themeLoader.item.basicTextColor
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }
                }
            }

            Text {
                text: Ra2snes.richPresence
                font.pixelSize: 11
                color: themeLoader.item.basicTextColor
                wrapMode: Text.WordWrap
                Layout.alignment: Qt.AlignHCenter
                Layout.maximumWidth: parent.width
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

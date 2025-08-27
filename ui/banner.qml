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
        sequence: "Ctrl+R"
        onActivated: {
            let content = content1;
            if(content2.visible)
                content = content2
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

    color: themeLoader.item.mainWindowDarkAccentColor
    Material.theme: themeLoader.item.darkScrollBar ? Material.Dark : Material.Light
    Material.accent: themeLoader.item.accentColor

    property int baseWidth: 320
    property int baseHeight: 180

    property real scaleFactor: Math.min(width / baseWidth, height / baseHeight)
    Item {
        id: content1
        width: 320
        height: 180
        anchors.centerIn: parent
        scale: banner.scaleFactor
        transformOrigin: Item.Center
        rotation: 0
        visible: true
        property real layoutScale: 1.0

        function resetLayout() {
            content1.layoutScale = 1.0;
        }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 6
            onImplicitWidthChanged: {
                if(implicitWidth < 300) {
                    content1.layoutScale += 0.05;
                }
                else if(implicitWidth > 320 && content1.layoutScale > 0.0) {
                    content1.layoutScale -= 0.05;
                }
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 10

                Image {
                    source: GameInfoModel.image_icon_url
                    Layout.preferredWidth: 38 * content1.layoutScale
                    Layout.preferredHeight: Layout.preferredWidth
                    fillMode: Image.PreserveAspectFit
                    cache: true
                    asynchronous: true
                    smooth: true
                }

                ColumnLayout {
                    spacing: 4
                    Layout.alignment: Qt.AlignVCenter

                    Text {
                        text: GameInfoModel.title
                        font.pixelSize: 13 * content1.layoutScale
                        color: themeLoader.item.linkColor
                        Layout.fillWidth: true
                        font.family: "Verdana"
                        onTextChanged: {
                            content1.resetLayout();
                        }
                    }

                    RowLayout {
                        spacing: 4
                        Layout.fillWidth: true

                        Image {
                            id: consoleIcon
                            source: GameInfoModel.console_icon
                            Layout.preferredWidth: 18 * content1.layoutScale
                            Layout.preferredHeight: Layout.preferredWidth
                            fillMode: Image.PreserveAspectFit
                            cache: true
                            asynchronous: true
                        }

                        Text {
                            id: consoleName
                            text: GameInfoModel.console
                            font.pixelSize: 13 * content1.layoutScale
                            color: themeLoader.item.basicTextColor
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                            font.family: "Verdana"
                        }
                    }
                }
            }

            Text {
                text: Ra2snes.richPresence
                font.pixelSize: 11 * content1.layoutScale
                color: themeLoader.item.basicTextColor
                wrapMode: Text.WordWrap
                Layout.alignment: Qt.AlignLeft
                Layout.maximumWidth: parent.width
                font.family: "Verdana"
            }
        }
    }

    Item {
        id: content2
        width: 320
        height: 180
        anchors.centerIn: parent
        scale: banner.scaleFactor
        transformOrigin: Item.Center
        rotation: 0
        visible: !content1.visible

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 0

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 8

                Image {
                    id: badge
                    Layout.preferredWidth: 64
                    Layout.preferredHeight: 64
                    fillMode: Image.PreserveAspectFit
                    cache: true
                    asynchronous: true
                    smooth: false
                }

                ColumnLayout {
                    spacing: 0
                    Layout.alignment: Qt.AlignVCenter

                    RowLayout {
                        spacing: 4
                        Layout.fillWidth: true

                        Text {
                            id: titleText
                            font.pixelSize: 13
                            font.family: "Verdana"
                            color: themeLoader.item.linkColor
                            Layout.maximumWidth: 214 - points.implicitWidth
                            elide: Text.ElideRight
                        }

                        Text {
                            id: points
                            font.pixelSize: 13
                            font.family: "Verdana"
                            color: themeLoader.item.basicTextColor
                        }
                    }

                    Text {
                        id: description
                        font.pixelSize: 13
                        color: themeLoader.item.basicTextColor
                        elide: Text.ElideRight
                        wrapMode: Text.WordWrap
                        Layout.maximumWidth: 240
                        maximumLineCount: 2
                        font.family: "Verdana"
                    }

                    Item {
                        Layout.preferredHeight: {
                            let h = 36 - description.implicitHeight
                            if(h < 0)
                                0;
                            else
                                h;
                        }
                    }

                    Text {
                        id: unlockedTime
                        font.pixelSize: 10
                        color: themeLoader.item.timeStampColor
                        wrapMode: Text.WordWrap
                        Layout.alignment: Qt.AlignLeft
                        Layout.maximumWidth: parent.width
                        font.family: "Verdana"
                    }
                }
            }
        }
    }

    function runQueue()
    {
        let achievement = banner.achievementQueue.shift();
        let len = banner.achievementQueue.length
        badge.source = achievement.badgeUrl;
        titleText.text = achievement.title;
        points.text = "(" + achievement.points + ")";
        description.text = achievement.description;
        unlockedTime.text = achievement.timeUnlockedString;
        content1.visible = false;
        if(len > 1)
            queueTimer.interval = 1000;
        //queueTimer.restart();
    }

    Timer {
        id: queueTimer
        interval: 3000
        repeat: false
        running: false
        onTriggered: {
            if(banner.achievementQueue.length === 0)
                content1.visible = true;
            else
                banner.runQueue();
        }
    }

    Connections {
        target: AchievementModel
        function onUnlockedChanged(index) {
            banner.achievementQueue.push(AchievementModel.get(index));
            if(!queueTimer.running)
                banner.runQueue();
        }
    }

    /*Component.onCompleted: {
        banner.achievementQueue.push(AchievementModel.get(8));
        banner.runQueue();
    }*/
}

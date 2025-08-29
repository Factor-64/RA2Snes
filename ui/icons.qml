import QtQuick
import QtQuick.Controls.Material
import CustomModels 1.0

ApplicationWindow {
    id: icons
    width: 320
    height: 180
    minimumWidth: 360
    minimumHeight: 180
    title: "RA2Snes - Icons"

    Shortcut {
        sequence: StandardKey.Cancel
        onActivated: {
            if (icons.visibility === Window.FullScreen)
                icons.visibility = Window.Windowed
            else
                icons.visibility = Window.FullScreen
        }
    }

    Shortcut {
        sequence: "Ctrl+R"
        onActivated: {
            if(hud.rotation === 270)
                hud.rotation = 0;
            else
                hud.rotation += 90;
            if(hud.rotation === 90 || hud.rotation === 270)
            {
                icons.baseWidth = 180
                icons.baseHeight = 320
            }
            else
            {
                icons.baseWidth = 320
                icons.baseHeight = 180
            }
        }
    }

    property string themeSource: "./themes/Dark.qml"
    property var achievementQueue: []
    Loader {
        id: themeLoader
        source: icons.themeSource
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
        id: hud
        width: 320
        height: 180
        anchors.centerIn: parent
        scale: icons.scaleFactor

        onVisibleChanged: {
            challenges.removeAllChallengeIcons();
        }

        Row {
            id: challenges
            height: 84
            spacing: 8
            width: 280
            anchors.centerIn: parent
            z: 100
            layoutDirection: Qt.RightToLeft
            SequentialAnimation {
                id: seq
                property var targetItem: null

                PropertyAnimation { target: seq.targetItem; property: "opacity"; to: 0; duration: 200 }
                ScriptAction { script: seq.targetItem.destroy() }
                onFinished: challenges.runNextRemoval();
            }

            property var activeIcons: {}
            property var iconsType: [2,2,2,2]

            /*function printActiveIcons()
            {
                for (let key in activeIcons)
                    console.log(key, activeIcons[key]);
            }*/

            function addChallengeIcons(sourceUrl, value, total)
            {
                if (!activeIcons)
                    activeIcons = {};
                const currentCount = challenges.children.length;
                //type 0 = primed, type 1 = score
                const type = (total === 0 && value === 0)
                if(currentCount === 4)
                {
                    if(type)
                        return;
                    var index = 5;
                    for(var i = 0; i < 4; i++)
                    {
                        if(iconsType[i] === 1)
                            index = i;
                    }
                    if(index === 5)
                        return;
                    removeChallengeIcon(index);
                }
                else
                {
                    const complete = (total === value);
                    const has = activeIcons.hasOwnProperty(sourceUrl);
                    //console.log(sourceUrl, value, total, has, type, complete);
                    if(has)
                    {
                        if(type)
                        {
                            removeChallengeIcon(activeIcons[sourceUrl]);
                            return;
                        }
                        else
                        {
                            updateScore(activeIcons[sourceUrl], value, total);
                            return;
                        }
                    }
                    else if(!type && complete)
                        return;
                }
                iconsType[currentCount] = type;
                var imageCode;
                if(type)
                {
                    imageCode = `
                        import QtQuick
                        Column {
                            id: wrapper${currentCount}
                            opacity: 0

                            SequentialAnimation {
                                running: true
                                PropertyAnimation { target: wrapper${currentCount}; property: "opacity"; to: 1; duration: 200 }
                            }

                            Item {
                                height: 16
                            }

                            Image {
                                source: "${sourceUrl}"
                                width: 64
                                height: 64
                                smooth: false
                                fillMode: Image.PreserveAspectFit
                            }
                        }
                    `;
                }
                else
                {
                    imageCode = `
                        import QtQuick
                        Column {
                            id: wrapper${currentCount}
                            opacity: 0

                            SequentialAnimation {
                                running: true
                                PropertyAnimation { target: wrapper${currentCount}; property: "opacity"; to: 1; duration: 200 }
                            }

                            Timer {
                                objectName: "timer${currentCount}"
                                interval: 15000
                                repeat: false
                                running: true
                                onTriggered: {
                                    challenges.removeChallengeIcon(${currentCount});
                                }
                            }

                            Text {
                                objectName: "icon${currentCount}"
                                text: "${value}/${total}"
                                font.bold: true
                                font.family: "Verdana"
                                font.pixelSize: 13
                                color: themeLoader.item.progressBarColor
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Image {
                                source: "${sourceUrl}"
                                width: 64
                                height: 64
                                smooth: false
                                fillMode: Image.PreserveAspectFit
                                cache: true
                                asynchronous: true
                            }
                        }
                    `;
                }

                const imageItem = Qt.createQmlObject(imageCode, challenges, "dynamicImage");
                if (imageItem)
                    activeIcons[sourceUrl] = currentCount;
            }

            property var removalQueue: []

            function removeChallengeIcon(index)
            {
                for (let key in activeIcons)
                {
                    if(activeIcons[key] === index)
                    {
                        delete activeIcons[key];
                        break;
                    }
                }
                iconsType[index] = 2;
                //printActiveIcons();
                const child = challenges.children[index];
                if (!child) return;
                removalQueue.push(child);
                if (!seq.running)
                    runNextRemoval();
                return;
            }

            function runNextRemoval()
            {
                if (removalQueue.length === 0) return;
                seq.targetItem = removalQueue.shift();
                seq.start();
            }

            function removeAllChallengeIcons()
            {
                for(var i = 0; i < challenges.children.length; i++)
                {
                    const child = challenges.children[i];
                    if (!child) return;
                    seq.targetItem = child;
                    seq.start();
                }
            }

            function updateScore(index, value, total)
            {
                const child = challenges.children[index];
                const label = child.children.find(item => item.objectName === `icon${index}`);
                if (label) label.text = `${value}/${total}`;
                const timer = child.children.find(item => item.objectName === `timer${index}`);
                if (timer)
                {
                    if(value === total)
                        timer.interval = 10000;
                    timer.restart();
                }
            }
        }
    }

    Connections {
        target: AchievementModel
        function onPrimedChanged(badgeUrl) {
            challenges.addChallengeIcons(badgeUrl, 0, 0);
        }
    }

    Connections {
        target: AchievementModel
        function onValueChanged(badgeUrl, value, total) {
            challenges.addChallengeIcons(badgeUrl, value, total);
        }
    }
}

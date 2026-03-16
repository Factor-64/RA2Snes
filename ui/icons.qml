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

            function findChild(sourceUrl)
            {
                var child = null;
                for (let i = 0; i < challenges.children.length; i++)
                {
                    child = challenges.children[i];
                    if (!child) continue;
                    if (String(child.sourceUrl) === String(sourceUrl))
                        return child;
                }
                return null;
            }

            function findNotPrime()
            {
                var child = null;
                for (let i = 0; i < challenges.children.length; i++)
                {
                    child = challenges.children[i];
                    if (!child) continue;
                    else if (child.type === 1)
                        return child;
                }
                return null;
            }

            function addChallengeIcons(sourceUrl, value, total)
            {
                const type = (total === 0) ? 0 : 1;
                var currentCount = challenges.children.length;
                const complete = (total === value);
                const child = findChild(sourceUrl);

                if (child)
                {
                    if (value === 0)
                    {
                        child.fadeOutAndRemove();
                        return;
                    }
                    else
                    {
                        child.value = value;
                        child.total = total;
                        if (complete)
                            child.restartTimer(10000);
                        else
                            child.restartTimer();
                        return;
                    }
                }

                if (type === 1)
                {
                    if (complete) return;
                    else if(value === 0) return;
                }

                if (currentCount === 4)
                {
                    if(type === 1) return;
                    const notprime = findNotPrime();
                    if(!notprime) return;
                    notprime.fadeOutAndRemove();
                }

                const icon = challengeIconComponent.createObject(challenges, {
                    mode: type,
                    sourceUrl: sourceUrl,
                    value: value,
                    total: total
                });
            }

            function removeAllChallengeIcons()
            {
                for (let i = 0; i < challenges.children.length; i++)
                {
                    const child = challenges.children[i];
                    if (!child) continue;
                    child.fadeOutAndRemove();
                }
            }

            Component {
                id: challengeIconComponent
                Icon { }
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

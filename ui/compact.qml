import QtQuick
import QtQuick.Controls.Material
import QtQuick.Layouts
import CustomModels 1.0
import Qt5Compat.GraphicalEffects

Rectangle {
    id: contentForm
    implicitHeight: contentColumn.implicitHeight
    color: themeLoader.item.mainWindowBackgroundColor
    border.width: 2
    border.color: themeLoader.item.mainWindowBorderColor
    radius: 6
    anchors.margins: 10
    clip: false
    Layout.fillWidth: true
    property var mainWindow

    ColumnLayout {
        id: contentColumn
        anchors.fill: parent
        spacing: 6
        Rectangle {
            id: playRect
            color: themeLoader.item.mainWindowDarkAccentColor
            Layout.fillWidth: true
            implicitHeight: 128
            Row {
                id: topRow
                spacing: 0
                Rectangle {
                    id: userRect
                    color: themeLoader.item.mainWindowDarkAccentColor
                    width: Math.min((playRect.width / 2), (user.implicitWidth + 78))
                    implicitHeight: 108
                    clip: true
                    Column {
                        id: userRow
                        spacing: 4
                        anchors.leftMargin: 20
                        anchors.topMargin: 10
                        anchors.left: parent.left
                        anchors.top: parent.top
                        Row {
                            spacing: 6
                            Image {
                                id: userpfp
                                source: UserInfoModel.pfp
                                width: 32
                                height: 32
                                cache: true
                                asynchronous: true
                            }
                            Text {
                                id: user
                                text: UserInfoModel.username
                                color: themeLoader.item.linkColor
                                elide: Text.ElideRight
                                font.bold: true
                                font.family: "Verdana"
                                font.pixelSize: 24
                                width: userRect.width - 58
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
                    width: Math.max((playRect.width / 2) - 56, (playRect.width - userRect.width - 56))
                    implicitHeight: 108
                    clip: true

                    Column {
                        id: gameColumn
                        spacing: 0
                        anchors.topMargin: 10
                        property bool implic: true
                        anchors.leftMargin: {
                            let lm = gameRectangle.width - gameRow.implicitWidth;;
                            if(!implic)
                                lm -= 22;
                            if(lm > 4)
                                lm;
                            else
                                4;
                        }
                        anchors.top: parent.top
                        anchors.left: parent.left
                        Row {
                            id: gameRow
                            spacing: 10
                            Image {
                                cache: true
                                asynchronous: true
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
                                    elide: Text.ElideRight
                                    width: {
                                        if(implicitWidth + 48 > gameRectangle.width)
                                        {
                                            gameColumn.implic = false;
                                            gameRectangle.width - 48;
                                        }
                                        else
                                        {
                                            gameColumn.implic = true;
                                            implicitWidth;
                                        }
                                    }

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
                                        cache: true
                                        asynchronous: true
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
                                        asynchronous: true
                                        layer.enabled: true
                                        layer.effect: ColorOverlay {
                                            color: themeLoader.item.missableIconColor
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
            Loader {
                id: progressLoader
                anchors.topMargin: 20
                anchors.left: parent.left
                anchors.leftMargin: 1
                anchors.bottom: parent.bottom
                source: "./progressbar.qml"
                width: parent.width - 2
                height: 8
                visible: gameInfo.visible
            }

            Text {
                visible: gameInfo.visible
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                anchors.rightMargin: 20
                anchors.bottomMargin: 12
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

            Loader {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.topMargin: 42
                anchors.rightMargin: 22
                width: 30
                height: 30
                source: "./refreshbutton.qml"
                active: gameInfo.visible
            }
        }

        Loader {
            id: sorting
            Layout.fillWidth: true
            Layout.leftMargin: 20
            Layout.bottomMargin: 10
            Layout.rightMargin: 20
            Layout.topMargin: 10
            source: "./sorting.qml"
            active: false
        }
        Loader {
            id: listview
            Layout.fillWidth: true
            Layout.margins: 10
            source: "./listview.qml"
            active: false
        }

        Connections {
            target: Ra2snes
            function onAchievementModelReady() {
                sortedAchievementModel.clearMissableFilter();
                sortedAchievementModel.clearUnlockedFilter();
                sortedAchievementModel.sortByNormal();
                sorting.active = true;
                gameInfo.visible = true;
                contentForm.mainWindow.setupFinished = true;
                listview.active = true;
            }
        }

        Connections {
            target: Ra2snes
            function onClearedAchievements() {
                sorting.active = false;
                listview.active = false;
                contentForm.mainWindow.setupFinished = false;
                gameInfo.visible = false;
            }
        }
    }

    Component.onCompleted: {
        if(contentForm.mainWindow.setupFinished)
        {
            sorting.active = true;
            listview.active = true;
            gameInfo.visible = true;
        }
    }
}

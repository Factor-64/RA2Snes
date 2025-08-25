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
    property var mainWindow

    ColumnLayout {
        id: contentColumn
        anchors.fill: parent
        spacing: 6
        Rectangle {
            color: themeLoader.item.mainWindowDarkAccentColor
            Layout.fillWidth: true
            implicitHeight: 168

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
                    cache: true
                    asynchronous: true
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
            implicitHeight:
            {
                if(Ra2snes.richPresence != "")
                     62 + rich.height;
                else 52;
            }
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
            Column {
                spacing: 6
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                anchors.topMargin: 8
                anchors.bottomMargin: 8
                anchors.fill: parent
                Row {
                    spacing: 10
                    Image {
                        source: GameInfoModel.image_icon_url
                        width: 36
                        height: 36
                        cache: true
                        asynchronous: true
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
                Text {
                    id: rich
                    text: Ra2snes.richPresence
                    font.family: "Verdana"
                    font.pixelSize: 11
                    color: themeLoader.item.basicTextColor
                    width: parent.width - 56
                    wrapMode: Text.WordWrap
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
            implicitHeight: 108
            border.width: 2
            border.color: themeLoader.item.mainWindowDarkAccentColor
            radius: 6
            visible: false
            clip: true

            Loader {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.topMargin: 10
                anchors.rightMargin: 10
                width: 30
                height: 30
                source: "./refreshbutton.qml"
                active: true
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
            Loader {
                anchors.left: parent.left
                anchors.leftMargin: 1
                anchors.bottom: parent.bottom
                width: parent.width - 2
                height: 8
                source: "./progressbar.qml"
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
                        color: themeLoader.item.popoutBackgroundColor

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
                achievementHeaderLoader.active = true;
                listview.active = true;
                completionHeader.visible = true;
                completionIcon.visible = true;
                contentForm.mainWindow.setupFinished = true;
                sorting.active = true;
            }
        }

        Connections {
            target: Ra2snes
            function onClearedAchievements() {
                achievementHeaderLoader.active = false;
                listview.active = false;
                completionHeader.visible = false;
                completionIcon.visible = false;
                sorting.active = false;
                contentForm.mainWindow.setupFinished = false;
            }
        }
    }
    Component.onCompleted: {
        if(contentForm.mainWindow.setupFinished)
        {
            achievementHeaderLoader.active = true;
            listview.active = true;
            completionHeader.visible = true;
            completionIcon.visible = true;
            sorting.active = true;
        }
    }
}

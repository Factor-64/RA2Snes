import QtQuick
import QtQuick.Controls.Material
import CustomModels 1.0

ApplicationWindow {
    id: banner
    visible: true
    width: 320
    height: 180
    minimumWidth: 320
    minimumHeight: 180
    title: "RA2Snes - Banner"
    //flags: Qt.FramelessWindowHint
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
    onClosing: {
        mainWindow.bannerOpen = false;
    }
}

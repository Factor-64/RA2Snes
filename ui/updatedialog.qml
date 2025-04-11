import QtQuick
import QtQuick.Controls.Material
import QtQuick.Layouts
import CustomModels 1.0

ApplicationWindow {
    id: updateDialog
    visible: true
    width: 250
    height: 150
    maximumWidth: 250
    maximumHeight: 150
    minimumWidth: 250
    minimumHeight: 150
    title: "Updater"
    color: themeLoader.item.backgroundColor
    Material.theme: themeLoader.item.darkScrollBar ? Material.Dark : Material.Light
    Material.accent: themeLoader.item.accentColor

    Column {
        anchors.centerIn: parent

        Text {
            text: "A new update is available!"
            horizontalAlignment: Text.AlignHCenter
            color: themeLoader.item.basicTextColor
        }
        Text {
            text: "Application Version: " + Ra2snes.version
            horizontalAlignment: Text.AlignHCenter
            color: themeLoader.item.basicTextColor
        }
        Text {
            text: "Latest Version: " + Ra2snes.latestVersion
            horizontalAlignment: Text.AlignHCenter
            color: themeLoader.item.basicTextColor
        }

        Row {
            spacing: 20
            anchors.horizontalCenter: parent.horizontalCenter

            Button {
                text: "Yes"
                onClicked: {
                    // Handle update logic here
                    console.log("User chose to update!")
                    updateDialog.close()
                }
            }

            Button {
                text: "No"
                onClicked: {
                    // Handle skip logic here
                    console.log("User chose not to update!")
                    updateDialog.close()
                }
            }
        }
    }
}

import QtQuick
import CustomModels 1.0

Item {
    Text {
        id: errorMessage
        text: mainWindow.modeFailed
        font.family: "Verdana"
        font.pixelSize: 13
        color: themeLoader.item.errorMessageTextColor
        width: parent.width
        opacity: 1
        Behavior on opacity {
            NumberAnimation {
                duration: 500
            }
        }

        Timer {
            id: fadeOutTimer
            interval: 5000
            running: false
            repeat: false
            onTriggered: {
                errorMessage.opacity = 0.0
            }
        }

        function showErrorMessage(error, iserror) {
            mainWindow.modeFailed = error;
            if(iserror)
                errorMessage.color = themeLoader.item.errorMessageTextColor;
            else
                errorMessage.color = themeLoader.item.nonErrorMessageTextColor;
            errorMessage.opacity = 1;
            fadeOutTimer.restart();
        }

        Connections {
            target: Ra2snes
            function onDisplayMessage(error, iserror) {
                errorMessage.showErrorMessage(error, iserror);
            }
        }

        Component.onCompleted: {
            if(!fadeOutTimer.running)
                mainWindow.modeFailed = "";
        }
    }
}


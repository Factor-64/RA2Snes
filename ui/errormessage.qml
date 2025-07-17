import QtQuick
import CustomModels 1.0

Item {
    id: outer
    Text {
        id: errorMessage
        font.family: "Verdana"
        font.pixelSize: 13
        color: themeLoader.item.basicTextColor
        width: parent.width
        wrapMode: Text.WordWrap
        opacity: 0
        Behavior on opacity {
            NumberAnimation {
                duration: 500
            }
        }
        onHeightChanged: {
            if(mainWindow.compact)
                outer.parent.errorHeight = height;
        }

        function showRichPresence() {
            if(errorMessage.color == themeLoader.item.basicTextColor && mainWindow.compact)
            {
                errorMessage.color = themeLoader.item.basicTextColor;
                errorMessage.font.pixelSize = 11;
                errorMessage.text = Ra2snes.richPresence;
                errorMessage.opacity = 1;
            }
            else
            {
                errorMessage.text = "";
                errorMessage.opacity = 0;
            }
        }

        Component.onCompleted: {
            errorMessage.showRichPresence();
        }

        NumberAnimation {
            id: fadeAnimation
            target: errorMessage
            property: "opacity"
            to: 0.0
            duration: 500
            onStopped: {
                errorMessage.text = "";
                errorMessage.color = themeLoader.item.basicTextColor;
                errorMessage.showRichPresence();
            }
        }

        Timer {
            id: fadeOutTimer
            interval: 5000
            running: false
            repeat: false
            onTriggered: {
                fadeAnimation.start();
            }
        }

        function showErrorMessage(error, iserror) {
            errorMessage.font.pixelSize = 13;
            if(iserror)
                errorMessage.color = themeLoader.item.errorMessageTextColor;
            else
                errorMessage.color = themeLoader.item.nonErrorMessageTextColor;
            errorMessage.text = error;
            errorMessage.opacity = 1;
            fadeOutTimer.restart();
        }

        Connections {
            target: Ra2snes
            function onUpdatedRichText()
            {
                errorMessage.showRichPresence();
            }
        }

        Connections {
            target: Ra2snes
            function onDisplayMessage(error, iserror) {
                errorMessage.showErrorMessage(error, iserror);
            }
        }
    }
}


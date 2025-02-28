import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    // Main Window
    property color mainWindowBackgroundColor: "#222222"
    property color mainWindowDarkAccentColor: "#161616"
    property color mainWindowLightAccentColor: "#282828"
    property color mainWindowBorderColor: "#161616"

    // Generic Text
    property color basicTextColor: "#2c97fa"
    property color disabledTextColor: "#eeeeee"
    property color timeStampColor: "#7e7e7e"
    property color linkColor: "#cc9900"
    property color selectedLink: "#c8c8c8"
    property color signOutTextColor: "#ff0000"
    property color hardcoreTextColor: "#ff0000"
    property color softcoreTextColor: "#00ff00"
    property color errorMessageTextColor: "#ff0000"
    property color nonErrorMessageTextColor: "#00ff00"

    // Buttons
    property color buttonBackgroundColor: "#222222"
    property color buttonBorderColor: "#2a2a2a"
    property color disabledButtonBackgroundColor: "#888888"
    property color disabledButtonTextColor: "#bbbbbb"
    property color highlightedButtonBackgroundColor: "#333333"
    property color highlightedButtonBorderColor: "#c8c8c8"
    property color highlightedButtonTextColor: "#eeeeee"

    // Checkboxes
    property color checkBoxCheckedColor: "#005cc8"
    property color checkBoxCheckedBorderColor: "#005cc8"
    property color checkBoxUnCheckedColor: "#ffffff"
    property color checkBoxUnCheckedBorderColor: "#4f4f4f"
    property color checkBoxCheckColor: "#ffffff"

    // Game Status
    property color statusUnfinishedIconBorderColor: "#52525b"
    property color statusUnfinishedTextColor: "#4b4b4b"
    property color statusBeatenIconBackgroundColor: "#d4d4d4"
    property color statusBeatenIconBorderColor: "#52525b"
    property color statusBeatenTextColor: "#d4d4d4"
    property color statusMasteredIconBackgroundColor: "#eab308"
    property color statusMasteredIconBorderColor: "#ffd700"
    property color statusMasteredTextColor: "#ffd700"

    // Misc
    property color backgroundColor: "#1a1a1a"
    property color accentColor: "#bbbbbb"
    property bool darkScrollBar: true
    property color popoutTextColor: "#e5e5e5"
    property color popoutBackgroundColor: "#161616"
    property color popoutBorderColor: "#161616"
    property bool darkThemeSVGImages: true
    property color progressBarColor: "#eab308"
    property color progressBarBackgroundColor: "#2a2a2a"

    function getRandomColor() {
        var randomColor = Math.floor(Math.random() * 16777215).toString(16);
        return "#" + randomColor.padStart(6, '0');
    }

    function getRandomBool() {
        return Math.random() < 0.5;
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            mainWindowBackgroundColor = getRandomColor();
            mainWindowDarkAccentColor = getRandomColor();
            mainWindowLightAccentColor = getRandomColor();
            mainWindowBorderColor = getRandomColor();
            basicTextColor = getRandomColor();
            disabledTextColor = getRandomColor();
            timeStampColor = getRandomColor();
            linkColor = getRandomColor();
            selectedLink = getRandomColor();
            signOutTextColor = getRandomColor();
            hardcoreTextColor = getRandomColor();
            softcoreTextColor = getRandomColor();
            errorMessageTextColor = getRandomColor();
            nonErrorMessageTextColor = getRandomColor();
            buttonBackgroundColor = getRandomColor();
            buttonBorderColor = getRandomColor();
            disabledButtonBackgroundColor = getRandomColor();
            disabledButtonTextColor = getRandomColor();
            highlightedButtonBackgroundColor = getRandomColor();
            highlightedButtonBorderColor = getRandomColor();
            highlightedButtonTextColor = getRandomColor();
            checkBoxCheckedColor = getRandomColor();
            checkBoxCheckedBorderColor = getRandomColor();
            checkBoxUnCheckedColor = getRandomColor();
            checkBoxUnCheckedBorderColor = getRandomColor();
            checkBoxCheckColor = getRandomColor();
            statusUnfinishedIconBorderColor = getRandomColor();
            statusUnfinishedTextColor = getRandomColor();
            statusBeatenIconBackgroundColor = getRandomColor();
            statusBeatenIconBorderColor = getRandomColor();
            statusBeatenTextColor = getRandomColor();
            statusMasteredIconBackgroundColor = getRandomColor();
            statusMasteredIconBorderColor = getRandomColor();
            statusMasteredTextColor = getRandomColor();
            backgroundColor = getRandomColor();
            accentColor = getRandomColor();
            popoutTextColor = getRandomColor();
            popoutBackgroundColor = getRandomColor();
            progressBarColor = getRandomColor();
            progressBarBackgroundColor = getRandomColor();
            popoutBorderColor = getRandomColor();
            darkScrollBar = getRandomBool();
            darkThemeSVGImages = getRandomBool();
        }
    }

    property int ms: 1000;

    Behavior on mainWindowBackgroundColor { ColorAnimation { duration: ms } }
    Behavior on mainWindowDarkAccentColor { ColorAnimation { duration: ms } }
    Behavior on mainWindowLightAccentColor { ColorAnimation { duration: ms } }
    Behavior on mainWindowBorderColor { ColorAnimation { duration: ms } }
    Behavior on basicTextColor { ColorAnimation { duration: ms } }
    Behavior on disabledTextColor { ColorAnimation { duration: ms } }
    Behavior on timeStampColor { ColorAnimation { duration: ms } }
    Behavior on linkColor { ColorAnimation { duration: ms } }
    Behavior on selectedLink { ColorAnimation { duration: ms } }
    Behavior on signOutTextColor { ColorAnimation { duration: ms } }
    Behavior on hardcoreTextColor { ColorAnimation { duration: ms } }
    Behavior on softcoreTextColor { ColorAnimation { duration: ms } }
    Behavior on errorMessageTextColor { ColorAnimation { duration: ms } }
    Behavior on nonErrorMessageTextColor { ColorAnimation { duration: ms } }
    Behavior on buttonBackgroundColor { ColorAnimation { duration: ms } }
    Behavior on buttonBorderColor { ColorAnimation { duration: ms } }
    Behavior on disabledButtonBackgroundColor { ColorAnimation { duration: ms } }
    Behavior on disabledButtonTextColor { ColorAnimation { duration: ms } }
    Behavior on highlightedButtonBackgroundColor { ColorAnimation { duration: ms } }
    Behavior on highlightedButtonBorderColor { ColorAnimation { duration: ms } }
    Behavior on highlightedButtonTextColor { ColorAnimation { duration: ms } }
    Behavior on checkBoxCheckedColor { ColorAnimation { duration: ms } }
    Behavior on checkBoxCheckedBorderColor { ColorAnimation { duration: ms } }
    Behavior on checkBoxUnCheckedColor { ColorAnimation { duration: ms } }
    Behavior on checkBoxUnCheckedBorderColor { ColorAnimation { duration: ms } }
    Behavior on checkBoxCheckColor { ColorAnimation { duration: ms } }
    Behavior on statusUnfinishedIconBorderColor { ColorAnimation { duration: ms } }
    Behavior on statusUnfinishedTextColor { ColorAnimation { duration: ms } }
    Behavior on statusBeatenIconBackgroundColor { ColorAnimation { duration: ms } }
    Behavior on statusBeatenIconBorderColor { ColorAnimation { duration: ms } }
    Behavior on statusBeatenTextColor { ColorAnimation { duration: ms } }
    Behavior on statusMasteredIconBackgroundColor { ColorAnimation { duration: ms } }
    Behavior on statusMasteredIconBorderColor { ColorAnimation { duration: ms } }
    Behavior on statusMasteredTextColor { ColorAnimation { duration: ms } }
    Behavior on backgroundColor { ColorAnimation { duration: ms } }
    Behavior on accentColor { ColorAnimation { duration: ms } }
    Behavior on popoutTextColor { ColorAnimation { duration: ms } }
    Behavior on popoutBackgroundColor { ColorAnimation { duration: ms } }
    Behavior on popoutBorderColor { ColorAnimation { duration: ms } }
    Behavior on progressBarColor { ColorAnimation { duration: ms } }
    Behavior on progressBarBackgroundColor { ColorAnimation { duration: ms } }
}
// Default Light Theme
import QtQuick 2.15

Item {
	//Main Window
	property color mainWindowBackgroundColor: "#fefefe"
	property color mainWindowDarkAccentColor: "#f0f0f0"
	property color mainWindowLightAccentColor: "#e5e5e5"
	property color mainWindowBorderColor: "#ececec"
	
	//Generic Text
	property color basicTextColor: "#2c97fa"
	
	property color disabledTextColor: "#eeeeee"
	
	property color timeStampColor: "#7e7e7e"
	
	property color linkColor: "#cc9900"
	property color selectedLink: "#000000"
	
	property color hardcoreTextColor: "#ff0000"
    property color softcoreTextColor: "#00ff00"
	
	property color errorMessageTextColor: "#ff0000"
    property color nonErrorMessageTextColor: "#00ff00"
	
	//Buttons
	property color buttonBackgroundColor: "#dddddd"
    property color buttonBorderColor: "#d6d6d6"

	property color highlightedButtonBackgroundColor: "#f0f0f0"
	property color highlightedButtonBorderColor: "#424242"
	property color highlightedButtonTextColor: "#333333"
	
	//Popup
	property color popupBackgroundColor: "#e6e6e6"
	property color popupHighlightColor: "#f0f0f0"
	property color popupItemDisabled: "#ffffff"
	property color popupLineColor: "#bebebe"

	//Checkboxes
	property color checkBoxCheckedColor: "#005cc8"
	property color checkBoxCheckedBorderColor: "#005cc8"
	
	property color checkBoxUnCheckedColor: "#ffffff"
	property color checkBoxUnCheckedBorderColor: "#4f4f4f"
	
	property color checkBoxCheckColor: "#ffffff"
	
	//Game Status
	property color statusUnfinishedIconBorderColor: "#52525b"
	property color statusUnfinishedTextColor: "#4b4b4b"
	
	property color statusBeatenIconBackgroundColor: "#d4d4d4"
	property color statusBeatenIconBorderColor: "#52525b"
	property color statusBeatenTextColor: "#d4d4d4"
	
	property color statusMasteredIconBackgroundColor: "#eab308"
	property color statusMasteredIconBorderColor: "#ffd700"
	property color statusMasteredTextColor: "#ffd700"
	
	//Icons
	property color missableIconColor: "#000000"
    property color progressionIconColor: "#000000"
    property color winConditionIconColor: "#000000"
    property color primedIconColor: "#000000"
	property color hamburgerIconColor: "#000000"
	property color refreshIconColor: "#000000"
	
	//Misc
	property color backgroundColor: "#f8f8f8"
	property color accentColor: "#000000"
	property bool darkScrollBar: false
	
	property color popoutTextColor: "#737373"
	property color popoutBackgroundColor: "#fafafa"
	property color popoutBorderColor: "#d4d4d4"
	
	property color progressBarColor: "#eab308"
	property color progressBarBackgroundColor: "#e5e5e5"
}

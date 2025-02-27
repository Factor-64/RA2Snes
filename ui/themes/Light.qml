// Default Light Theme
import QtQuick 2.15

Item {
	//Main Window
	property color mainWindowBackgroundColor: "#222222"
	property color mainWindowDarkAccentColor: "#161616"
	property color mainWindowLightAccentColor: "#282828"
	property color mainWindowBorderColor: "#161616"
	
	//Generic Text
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
	
	//Buttons
	property color buttonBackgroundColor: "#222222"
	property color buttonBorderColor: "#2a2a2a"
	
	property color disabledButtonBackgroundColor: "#888888"
	property color disabledButtonTextColor: "#bbbbbb"
	
	property color highlightedButtonBackgroundColor: "#333333"
	property color highlightedButtonBorderColor: "#c8c8c8"
	property color highlightedButtonTextColor: "#eeeeee"
	
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
	
	//Misc
	property color backgroundColor: "#1a1a1a"
	property color accentColor: "#f8f8f8"
	property bool darkScrollBar: true
	
	property color popoutTextColor: "#e5e5e5"
	property color popoutBackgroundColor: "#161616"
	property bool darkThemeSVGImages: true
	
	property color progressBarColor: "#eab308"
	property color progressBarBackgroundColor: "#2a2a2a"
}

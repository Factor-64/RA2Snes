import QtQuick
import QtQuick.Controls.Material
import CustomModels 1.0
import Qt5Compat.GraphicalEffects

Item {
    id: dropdown
    property var mainWindow
    Rectangle {
        id: hamburgerRectangle
        width: 32
        height: 32
        color: themeLoader.item.mainWindowDarkAccentColor
        z: 120

        Image {
            id: hamburger
            anchors.centerIn: parent
            width: 32
            height: 32
            source: "./images/hamburger.svg"
            asynchronous: true
            layer.enabled: true
            layer.effect: ColorOverlay {
                color: themeLoader.item.hamburgerIconColor
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                hamburgerRectangle.color = themeLoader.item.popupBackgroundColor;
                menuPopup.open();
            }

            onEntered: {
                hamburgerRectangle.color = themeLoader.item.popupBackgroundColor;
                menuPopup.open();
            }
        }
    }

    Popup {
        id: menuPopup
        x: {
            switch(scale) {
                case 1:
                    return -118;
                case 1.25:
                    return -103;
                case 1.5:
                    return -93;
                case 1.75:
                    return -86;
                case 2:
                    return -80.5;
                case 0.75:
                    return -144;
                case 0.5:
                    return -192;
                case 0.25:
                    return -345;
            }
        }
        y: {
            switch(scale) {
                case 1:
                    return 32;
                case 1.25:
                    return 63;
                case 1.50:
                    return 82;
                case 1.75:
                    return 99;
                case 2:
                    return 108;
                case 0.75:
                    return -21;
                case 0.5:
                    return -130;
                case 0.25:
                    return -445;
            }
        }
        z: 121
        scale: dropdown.mainWindow.loaderScale
        width: 150
        height: (popupColumn.implicitHeight + 8)
        clip: true
        background: Rectangle {
            id: menuPopupBG
            color: themeLoader.item.popupBackgroundColor
        }

        onOpened: {
            popupContainer.x = (-1*(dropdown.mainWindow.width / 2));
            popupContainer.height = dropdown.mainWindow.height;
            popupContainer.width = dropdown.mainWindow.width;
            popupContainer.enabled = true;
        }

        function changeModeColor() {
            if(changeCheckBox.enabled && !changeCheckBox.checked)
            {
                if(UserInfoModel.hardcore)
                    mode.color = themeLoader.item.softcoreTextColor;
                else mode.color = themeLoader.item.hardcoreTextColor;
            }
            else mode.color = themeLoader.item.popupItemDisabled;
        }

        enter: Transition {
            NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 0}
        }
        exit: Transition {
            NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 0}
        }

        Popup {
            id: themePopup
            x: {
                switch(scale) {
                    case 1:
                        return -150;
                    case 1.25:
                        return -135;
                    case 1.50:
                        return -125;
                    case 1.75:
                        return -117.5;
                    case 2:
                        return -112.5;
                    case 0.75:
                        return -175;
                    case 0.5:
                        return -224;
                    case 0.25:
                        return -374;
                }
            }
            y: {
                switch(scale) {
                    case 1:
                        return themeRect.y - 4;
                    case 1.25:
                        return themeRect.y + 6.5;
                    case 1.50:
                        return themeRect.y + 13;
                    case 1.75:
                        return themeRect.y + 18.5;
                    case 2:
                        return themeRect.y + 22;
                    case 0.75:
                        return themeRect.y - 22;
                    case 0.5:
                        return themeRect.y - 56;
                    case 0.25:
                        return themeRect.y - 160;
                }
            }
            scale: menuPopup.scale;
            z: 122
            width: 150
            clip: true
            height: (dropdown.mainWindow.themes.length * 24) + 8
            background: Rectangle {
                id: themePopupBG
                color: themeLoader.item.popupBackgroundColor
            }

            function closeThemes()
            {
                themeRect.color = themeLoader.item.popupBackgroundColor;
                theme.color = themeLoader.item.selectedLink;
                themePopup.close();
            }

            ListView {
                id: themesList
                anchors.fill: parent
                anchors.topMargin: -8
                model: dropdown.mainWindow.themes
                spacing: 0
                z: 5
                delegate: Rectangle {
                    id: themeDel
                    width: themePopup.width
                    anchors.left: parent.left
                    anchors.leftMargin: -12
                    height: 24
                    color: themeLoader.item.popupBackgroundColor

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        id: themeName
                        text: modelData
                        font.family: "Verdana"
                        font.pixelSize: 13
                        color: themeLoader.item.selectedLink
                        verticalAlignment: Text.AlignVCenter
                    }
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true

                        function resetColors(item, skip) {
                            for (let i = 0; i < item.children.length; i++) {
                                let child = item.children[i];
                                let s = skip;

                                if (child instanceof CheckBox)
                                    s = true
                                else if (child instanceof Rectangle)
                                {
                                     if (!s)
                                     {
                                        if(child.height !== 1)
                                            child.color = themeLoader.item.popupBackgroundColor;
                                        else
                                            child.color = themeLoader.item.popupLineColor;
                                     }
                                     else
                                         return;
                                }
                                else if (child instanceof Text)
                                    child.color = themeLoader.item.selectedLink;

                                if (child.children && child.children.length > 0) {
                                    resetColors(child, s);
                                }
                            }
                        }
                        onClicked: {
                            dropdown.mainWindow.currentTheme = themeName.text;
                            dropdown.mainWindow.setupTheme();
                            resetColors(popupColumn, false);
                            resetColors(themesList, false);
                            menuPopup.changeModeColor();
                            hamburgerRectangle.color = themeLoader.item.popupBackgroundColor;

                            themeDel.color = themeLoader.item.popupHighlightColor;
                            themeName.color = themeLoader.item.linkColor;
                            themeRect.color = themeLoader.item.popupHighlightColor;
                            theme.color = themeLoader.item.linkColor;
                        }
                        onEntered: {
                            themeDel.color = themeLoader.item.popupHighlightColor;
                            themeName.color = themeLoader.item.linkColor;
                            themeRect.color = themeLoader.item.popupHighlightColor;
                            theme.color = themeLoader.item.linkColor;
                        }

                        onExited: {
                            themeDel.color = themeLoader.item.popupBackgroundColor;
                            themeName.color = themeLoader.item.selectedLink;
                        }
                    }
                }
            }
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true

                onExited: {
                    themePopup.close();
                }
            }
            onOpened: {
                themeRect.color = themeLoader.item.popupHighlightColor;
                theme.color = themeLoader.item.linkColor;
            }
            enter: Transition {
                NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 0}
            }
            exit: Transition {
                NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 0}
            }

            function updateComboBox()
            {
                themesList.model = dropdown.mainWindow.themes;
                themePopup.height = (dropdown.mainWindow.themes.length * 24) + 8;
                dropdown.mainWindow.loadedThemes = true;
            }
            Component.onCompleted: {
                dropdown.mainWindow.themesUpdated.connect(updateComboBox);
            }

        }

        contentItem: Column {
            id: popupColumn
            spacing: 0
            anchors.fill: parent
            anchors.topMargin: 4

            Rectangle {
                id: changeRect
                width: parent.width
                height: 24
                color: themeLoader.item.popupBackgroundColor
                Row {
                    spacing: 4
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    Connections {
                        id: disableSwitch
                        target: Ra2snes
                        function onDisableModeSwitching()
                        {
                            dropdown.mainWindow.setupFinished = false;
                            changeCheckBox.enabled = false;
                            signoutArea.enabled = false;
                            autoHardcore.color = themeLoader.item.popupItemDisabled;
                            signout.color = themeLoader.item.popupItemDisabled;
                            modeMouse.enabled = false;
                            autoArea.enabled = false;
                            menuPopup.changeModeColor();
                        }
                    }

                    Connections {
                        target: Ra2snes
                        function onEnableModeSwitching()
                        {
                            dropdown.mainWindow.setupFinished = true;
                            changeCheckBox.enabled = true;
                            signoutArea.enabled = true;
                            signout.color = themeLoader.item.selectedLink;
                            autoHardcore.color = themeLoader.item.selectedLink;
                            autoArea.enabled = true;
                            modeMouse.enabled = !changeCheckBox.checked;
                            menuPopup.changeModeColor();
                        }
                    }

                    CheckBox {
                        id: changeCheckBox
                        width: 14
                        height: 14

                        indicator: Rectangle {
                            width: 14
                            height: 14
                            radius: 2
                            color: changeCheckBox.checked ? themeLoader.item.checkBoxCheckedColor : themeLoader.item.checkBoxUnCheckedColor;
                            border.color: changeCheckBox.checked ? themeLoader.item.checkBoxCheckedBorderColor : themeLoader.item.checkBoxCheckedBorderColor

                            Text {
                                anchors.centerIn: parent
                                text: changeCheckBox.checked ? "\u2713" : ""
                                color: themeLoader.item.checkBoxCheckColor
                                font.pixelSize: 12
                            }
                        }

                        onCheckedChanged: {
                            menuPopup.changeModeColor();
                            modeMouse.enabled = !changeCheckBox.checked;
                            Ra2snes.autoChange(changeCheckBox.checked);
                        }
                        Component.onCompleted: {
                            changeCheckBox.checked = UserInfoModel.autohardcore;
                        }
                    }

                    Text {
                        id: autoHardcore
                        text: qsTr("Auto Hardcore")
                        font.family: "Verdana"
                        font.pixelSize: 13
                        color: themeLoader.item.selectedLink
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                MouseArea {
                    id: autoArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        changeCheckBox.checked = !changeCheckBox.checked
                    }
                    onEntered: {
                        changeRect.color = themeLoader.item.popupHighlightColor;
                        autoHardcore.color = themeLoader.item.linkColor;
                        themePopup.closeThemes();
                    }

                    onExited: {
                        changeRect.color = themeLoader.item.popupBackgroundColor;
                        if(enabled)
                            autoHardcore.color = themeLoader.item.selectedLink;
                    }
                }
            }

            Rectangle {
                id: modeRect
                width: parent.width
                height: 24
                color: themeLoader.item.popupBackgroundColor
                Text {
                    id: mode
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    text: {
                        if(UserInfoModel.hardcore)
                            qsTr("Softcore Mode");
                        else qsTr("Hardcore Mode");
                    }
                    font.family: "Verdana"
                    font.pixelSize: 13
                    Component.onCompleted: {
                        menuPopup.changeModeColor();
                    }

                    verticalAlignment: Text.AlignVCenter
                }
                MouseArea {
                    id: modeMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: true
                    onClicked: {
                        Ra2snes.changeMode();
                    }
                    onEntered: {
                        modeRect.color = themeLoader.item.popupHighlightColor;
                        themePopup.closeThemes();
                    }

                    onExited: {
                        modeRect.color = themeLoader.item.popupBackgroundColor;
                    }
                }
            }

            Rectangle {
                id: sep1
                height: 5
                width: parent.width - 20
                color: themeLoader.item.popupBackgroundColor
                anchors.left: parent.left
                anchors.leftMargin: 10

                Rectangle {
                    id: sep11
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: 2
                    anchors.bottomMargin: 2
                    height: 1
                    width: parent.width
                    color: themeLoader.item.popupLineColor
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: {
                        themePopup.closeThemes();
                    }
                }
            }

            Rectangle {
                id: compactRect
                width: parent.width
                height: 24
                color: themeLoader.item.popupBackgroundColor
                Row {
                    spacing: 4
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter

                    CheckBox {
                        id: compactCheckBox
                        width: 14
                        height: 14
                        enabled: dropdown.mainWindow.loadedThemes
                        checked: dropdown.mainWindow.compact

                        indicator: Rectangle {
                            width: 14
                            height: 14
                            radius: 2
                            color: compactCheckBox.checked ? themeLoader.item.checkBoxCheckedColor : themeLoader.item.checkBoxUnCheckedColor;
                            border.color: compactCheckBox.checked ? themeLoader.item.checkBoxCheckedBorderColor : themeLoader.item.checkBoxCheckedBorderColor
                            Text {
                                anchors.centerIn: parent
                                text: compactCheckBox.checked ? "\u2713" : ""
                                color: themeLoader.item.checkBoxCheckColor
                                font.pixelSize: 12
                            }
                        }
                    }

                    Text {
                        id: compactMode
                        text: qsTr("Compact Mode")
                        font.family: "Verdana"
                        font.pixelSize: 13
                        color: themeLoader.item.selectedLink
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                MouseArea {
                    id: compactMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        dropdown.mainWindow.compact = !dropdown.mainWindow.compact
                    }
                    onEntered: {
                        compactRect.color = themeLoader.item.popupHighlightColor;
                        compactMode.color = themeLoader.item.linkColor;
                        themePopup.closeThemes();
                    }

                    onExited: {
                        compactRect.color = themeLoader.item.popupBackgroundColor;
                        if(enabled)
                            compactMode.color = themeLoader.item.selectedLink;
                    }
                }
            }

            Rectangle {
                id: fullscreenRect
                width: parent.width
                height: 24
                color: themeLoader.item.popupBackgroundColor
                Text {
                    id: fullscreen
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    text: {
                        if(!dropdown.mainWindow.fullScreen)
                            qsTr("FullScreen");
                        else qsTr("Windowed");
                    }
                    font.family: "Verdana"
                    font.pixelSize: 13
                    color: themeLoader.item.selectedLink
                    verticalAlignment: Text.AlignVCenter
                }
                MouseArea {
                    id: fullscreenMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: true
                    onClicked: {
                        dropdown.mainWindow.toggleFullScreen();
                    }
                    onEntered: {
                        fullscreenRect.color = themeLoader.item.popupHighlightColor;
                        fullscreen.color = themeLoader.item.linkColor;
                        themePopup.closeThemes();
                    }

                    onExited: {
                        fullscreen.color = themeLoader.item.selectedLink;
                        fullscreenRect.color = themeLoader.item.popupBackgroundColor;
                    }
                }
            }

            Rectangle {
                id: themeRect
                width: parent.width
                height: 24
                color: themeLoader.item.popupBackgroundColor
                Text {
                    id: theme
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("Theme: ") + dropdown.mainWindow.currentTheme;
                    font.family: "Verdana"
                    font.pixelSize: 13
                    color: themeLoader.item.selectedLink
                    verticalAlignment: Text.AlignVCenter
                }
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: {
                        themeRect.color = themeLoader.item.popupHighlightColor;
                        theme.color = themeLoader.item.linkColor;
                        themePopup.open();
                    }

                    onExited: {
                        if(!themePopup.visible)
                        {
                            themeRect.color = themeLoader.item.popupBackgroundColor;
                            theme.color = themeLoader.item.selectedLink;
                        }
                    }
                }
            }

            Rectangle {
                id: sep2
                height: 5
                width: parent.width - 20
                color: themeLoader.item.popupBackgroundColor
                anchors.left: parent.left
                anchors.leftMargin: 10

                Rectangle {
                    id: sep21
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: 2
                    anchors.bottomMargin: 2
                    height: 1
                    width: parent.width
                    color: themeLoader.item.popupLineColor
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: {
                       themePopup.closeThemes();
                    }
                }
            }

            Rectangle {
                id: iconsRect
                width: parent.width
                height: 24
                color: themeLoader.item.popupBackgroundColor
                Row {
                    spacing: 4
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter

                    CheckBox {
                        id: iconsCheckBox
                        width: 14
                        height: 14
                        checked: dropdown.mainWindow.allowIcons

                        indicator: Rectangle {
                            width: 14
                            height: 14
                            radius: 2
                            color: iconsCheckBox.checked ? themeLoader.item.checkBoxCheckedColor : themeLoader.item.checkBoxUnCheckedColor;
                            border.color: iconsCheckBox.checked ? themeLoader.item.checkBoxCheckedBorderColor : themeLoader.item.checkBoxCheckedBorderColor
                            Text {
                                anchors.centerIn: parent
                                text: iconsCheckBox.checked ? "\u2713" : ""
                                color: themeLoader.item.checkBoxCheckColor
                                font.pixelSize: 12
                            }
                        }
                    }

                    Text {
                        id: iconsMode
                        text: qsTr("Window Icons")
                        font.family: "Verdana"
                        font.pixelSize: 13
                        color: themeLoader.item.selectedLink
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                MouseArea {
                    id: iconsMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        dropdown.mainWindow.allowIcons = !dropdown.mainWindow.allowIcons
                    }
                    onEntered: {
                        iconsRect.color = themeLoader.item.popupHighlightColor;
                        iconsMode.color = themeLoader.item.linkColor;
                        themePopup.closeThemes();
                    }

                    onExited: {
                        iconsRect.color = themeLoader.item.popupBackgroundColor;
                        if(enabled)
                            iconsMode.color = themeLoader.item.selectedLink;
                    }
                }
            }

            Rectangle {
                id: iconBannerRect
                width: parent.width
                height: 24
                color: themeLoader.item.popupBackgroundColor
                Row {
                    spacing: 4
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter

                    CheckBox {
                        id: iconBannerCheckBox
                        width: 14
                        height: 14

                        indicator: Rectangle {
                            width: 14
                            height: 14
                            radius: 2
                            color: iconBannerCheckBox.checked ? themeLoader.item.checkBoxCheckedColor : themeLoader.item.checkBoxUnCheckedColor;
                            border.color: iconBannerCheckBox.checked ? themeLoader.item.checkBoxCheckedBorderColor : themeLoader.item.checkBoxCheckedBorderColor
                            Text {
                                anchors.centerIn: parent
                                text: iconBannerCheckBox.checked ? "\u2713" : ""
                                color: themeLoader.item.checkBoxCheckColor
                                font.pixelSize: 12
                            }
                        }
                        function openBanner() {
                            if (dropdown.mainWindow.iconsPopup)
                                return;

                            var component = Qt.createComponent("./icons.qml");

                            function createPopup() {
                                if (component.status === Component.Ready) {
                                    dropdown.mainWindow.iconsPopup = component.createObject(null);
                                    dropdown.mainWindow.iconsPopup.visible = true;
                                    dropdown.mainWindow.iconsPopup.themeSource = themeLoader.source;

                                    dropdown.mainWindow.iconsPopup.onClosing.connect(function() {
                                        dropdown.mainWindow.iconsPopup = null;
                                        checked = false;
                                    });

                                    dropdown.mainWindow.iconsPopup.onVisibilityChanged.connect(function() {
                                        if(dropdown.mainWindow.iconsPopup)
                                            iconBannerFSRect.iconsMode = (dropdown.mainWindow.iconsPopup.visibility !== Window.Windowed ? true : false)
                                    });
                                }
                            }

                            if (component.status === Component.Loading)
                                component.statusChanged.connect(createPopup);
                            else
                                createPopup();
                        }

                        onCheckedChanged: {
                            if (checked && !dropdown.mainWindow.iconsPopup)
                                openBanner();
                            else if (!checked && dropdown.mainWindow.iconsPopup) {
                                dropdown.mainWindow.iconsPopup.close();
                                dropdown.mainWindow.iconsPopup = null;
                            }
                        }
                        Component.onCompleted: {
                            checked = UserInfoModel.iconspopup;
                            if (checked && !dropdown.mainWindow.iconsPopup)
                                openBanner();
                        }
                    }

                    Text {
                        id: iconBannerEn
                        text: qsTr("Popout Icons")
                        font.family: "Verdana"
                        font.pixelSize: 13
                        color: themeLoader.item.selectedLink
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                MouseArea {
                    id: iconBannerMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        iconBannerCheckBox.checked = !iconBannerCheckBox.checked
                    }
                    onEntered: {
                        iconBannerRect.color = themeLoader.item.popupHighlightColor;
                        iconBannerEn.color = themeLoader.item.linkColor;
                        themePopup.closeThemes();
                    }

                    onExited: {
                        iconBannerRect.color = themeLoader.item.popupBackgroundColor;
                        iconBannerEn.color = themeLoader.item.selectedLink;
                    }
                }
            }

            Rectangle {
                id: iconBannerFSRect
                width: parent.width
                height: 24
                color: themeLoader.item.popupBackgroundColor
                property bool iconsMode: false
                Text {
                    id: iconBannerFS
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    text: {
                        if(!iconBannerFSRect.iconsMode)
                            qsTr("FullScreen Popout");
                        else qsTr("Windowed Popout");
                    }
                    font.family: "Verdana"
                    font.pixelSize: 13
                    color: themeLoader.item.selectedLink
                    verticalAlignment: Text.AlignVCenter
                    onColorChanged: {
                        iconBannerFSMouse.checkEnabled();
                    }
                }
                MouseArea {
                    id: iconBannerFSMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    function checkEnabled() {
                        if(dropdown.mainWindow.iconsPopup)
                        {
                            iconBannerFS.color = themeLoader.item.selectedLink;
                            return true;
                        }
                        else
                        {
                            iconBannerFS.color = themeLoader.item.popupItemDisabled
                            return false;
                        }
                    }

                    enabled: {
                        checkEnabled();
                    }

                    onClicked: {
                        if(iconBannerFSRect.iconsMode)
                            dropdown.mainWindow.iconsPopup.visibility = Window.Windowed;
                        else
                            dropdown.mainWindow.iconsPopup.visibility = Window.FullScreen;
                    }
                    onEntered: {
                        iconBannerFS.color = themeLoader.item.linkColor;
                        iconBannerFSRect.color = themeLoader.item.popupHighlightColor;
                        themePopup.closeThemes();
                    }

                    onExited: {
                        iconBannerFSRect.color = themeLoader.item.popupBackgroundColor;
                        if(enabled)
                            iconBannerFS.color = themeLoader.item.selectedLink;
                    }
                }
            }

            Rectangle {
                id: sep4
                height: 5
                width: parent.width - 20
                color: themeLoader.item.popupBackgroundColor
                anchors.left: parent.left
                anchors.leftMargin: 10

                Rectangle {
                    id: sep41
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: 2
                    anchors.bottomMargin: 2
                    height: 1
                    width: parent.width
                    color: themeLoader.item.popupLineColor
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: {
                       themePopup.closeThemes();
                    }
                }
            }

            Rectangle {
                id: bannerRect
                width: parent.width
                height: 24
                color: themeLoader.item.popupBackgroundColor
                Row {
                    spacing: 4
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter

                    CheckBox {
                        id: bannerCheckBox
                        width: 14
                        height: 14

                        indicator: Rectangle {
                            width: 14
                            height: 14
                            radius: 2
                            color: bannerCheckBox.checked ? themeLoader.item.checkBoxCheckedColor : themeLoader.item.checkBoxUnCheckedColor;
                            border.color: bannerCheckBox.checked ? themeLoader.item.checkBoxCheckedBorderColor : themeLoader.item.checkBoxCheckedBorderColor
                            Text {
                                anchors.centerIn: parent
                                text: bannerCheckBox.checked ? "\u2713" : ""
                                color: themeLoader.item.checkBoxCheckColor
                                font.pixelSize: 12
                            }
                        }
                        function openBanner() {
                            if (dropdown.mainWindow.bannerPopup)
                                return;

                            var component = Qt.createComponent("./banner.qml");

                            function createPopup() {
                                if (component.status === Component.Ready) {
                                    dropdown.mainWindow.bannerPopup = component.createObject(null);
                                    dropdown.mainWindow.bannerPopup.visible = true;
                                    dropdown.mainWindow.bannerPopup.themeSource = themeLoader.source;

                                    dropdown.mainWindow.bannerPopup.onClosing.connect(function() {
                                        dropdown.mainWindow.bannerPopup = null;
                                        checked = false;
                                        bannerFSRect.bannerMode = false;
                                    });

                                    dropdown.mainWindow.bannerPopup.onVisibilityChanged.connect(function() {
                                        if(dropdown.mainWindow.bannerPopup)
                                            bannerFSRect.bannerMode = (dropdown.mainWindow.bannerPopup.visibility !== Window.Windowed ? true : false)
                                    });
                                }
                            }

                            if (component.status === Component.Loading)
                                component.statusChanged.connect(createPopup);
                            else
                                createPopup();
                        }

                        onCheckedChanged: {
                            if (checked && !dropdown.mainWindow.bannerPopup)
                                openBanner();
                            else if (!checked && dropdown.mainWindow.bannerPopup) {
                                dropdown.mainWindow.bannerPopup.close();
                                dropdown.mainWindow.bannerPopup = null;
                            }
                        }
                        Component.onCompleted: {
                            checked = UserInfoModel.banner;
                            if (checked && !dropdown.mainWindow.bannerPopup)
                                openBanner();
                        }
                    }

                    Text {
                        id: bannerEn
                        text: qsTr("Enable Banner")
                        font.family: "Verdana"
                        font.pixelSize: 13
                        color: themeLoader.item.selectedLink
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                MouseArea {
                    id: bannerMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        bannerCheckBox.checked = !bannerCheckBox.checked
                    }
                    onEntered: {
                        bannerRect.color = themeLoader.item.popupHighlightColor;
                        bannerEn.color = themeLoader.item.linkColor;
                        themePopup.closeThemes();
                    }

                    onExited: {
                        bannerRect.color = themeLoader.item.popupBackgroundColor;
                        bannerEn.color = themeLoader.item.selectedLink;
                    }
                }
            }

            Rectangle {
                id: bannerFSRect
                width: parent.width
                height: 24
                color: themeLoader.item.popupBackgroundColor
                property bool bannerMode: false
                Text {
                    id: bannerFS
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    text: {
                        if(!bannerFSRect.bannerMode)
                            qsTr("FullScreen Banner");
                        else qsTr("Windowed Banner");
                    }
                    font.family: "Verdana"
                    font.pixelSize: 13
                    color: themeLoader.item.selectedLink
                    verticalAlignment: Text.AlignVCenter
                    onColorChanged: {
                        bannerFSMouse.checkEnabled();
                    }
                }
                MouseArea {
                    id: bannerFSMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    function checkEnabled() {
                        if(dropdown.mainWindow.bannerPopup)
                        {
                            bannerFS.color = themeLoader.item.selectedLink;
                            return true;
                        }
                        else
                        {
                            bannerFS.color = themeLoader.item.popupItemDisabled
                            return false;
                        }
                    }

                    enabled: {
                        checkEnabled();
                    }

                    onClicked: {
                        if(bannerFSRect.bannerMode)
                            dropdown.mainWindow.bannerPopup.visibility = Window.Windowed;
                        else
                            dropdown.mainWindow.bannerPopup.visibility = Window.FullScreen;
                    }
                    onEntered: {
                        bannerFS.color = themeLoader.item.linkColor;
                        bannerFSRect.color = themeLoader.item.popupHighlightColor;
                        themePopup.closeThemes();
                    }

                    onExited: {
                        bannerFSRect.color = themeLoader.item.popupBackgroundColor;
                        if(enabled)
                            bannerFS.color = themeLoader.item.selectedLink;
                    }
                }
            }

            Rectangle {
                id: sep3
                height: 5
                width: parent.width - 20
                color: themeLoader.item.popupBackgroundColor
                anchors.left: parent.left
                anchors.leftMargin: 10

                Rectangle {
                    id: sep31
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: 2
                    anchors.bottomMargin: 2
                    height: 1
                    width: parent.width
                    color: themeLoader.item.popupLineColor
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: {
                        themePopup.closeThemes();
                    }
                }
            }

            Rectangle {
                id: ignoreRect
                width: parent.width
                height: 24
                color: themeLoader.item.popupBackgroundColor
                Row {
                    spacing: 4
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter

                    CheckBox {
                        id: ignoreCheckBox
                        width: 14
                        height: 14
                        enabled: dropdown.mainWindow.loadedThemes

                        indicator: Rectangle {
                            width: 14
                            height: 14
                            radius: 2
                            color: ignoreCheckBox.checked ? themeLoader.item.checkBoxCheckedColor : themeLoader.item.checkBoxUnCheckedColor;
                            border.color: ignoreCheckBox.checked ? themeLoader.item.checkBoxCheckedBorderColor : themeLoader.item.checkBoxCheckedBorderColor
                            Text {
                                anchors.centerIn: parent
                                text: ignoreCheckBox.checked ? "\u2713" : ""
                                color: themeLoader.item.checkBoxCheckColor
                                font.pixelSize: 12
                            }
                        }

                        onCheckedChanged: {
                            Ra2snes.ignoreUpdates(ignoreCheckBox.checked);
                        }
                        Component.onCompleted: {
                            ignoreCheckBox.checked = Ra2snes.ignore;
                        }
                        Connections {
                            target: Ra2snes
                            function onIgnoreChanged() { ignoreCheckBox.checked = Ra2snes.ignore; }
                        }

                    }

                    Text {
                        id: ignore
                        text: qsTr("Ignore Updates")
                        font.family: "Verdana"
                        font.pixelSize: 13
                        color: themeLoader.item.selectedLink
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                MouseArea {
                    id: ignoreMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        ignoreCheckBox.checked = !ignoreCheckBox.checked
                    }
                    onEntered: {
                        ignoreRect.color = themeLoader.item.popupHighlightColor;
                        ignore.color = themeLoader.item.linkColor;
                        themePopup.closeThemes();
                    }

                    onExited: {
                        ignoreRect.color = themeLoader.item.popupBackgroundColor;
                        ignore.color = themeLoader.item.selectedLink;

                        ignoreMouseArea.enabled = true;
                    }
                }
            }

            Rectangle {
                id: signoutRect
                width: parent.width
                height: 24
                color: themeLoader.item.popupBackgroundColor
                Text {
                    id: signout
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("Sign Out")
                    font.family: "Verdana"
                    font.pixelSize: 13
                    color: themeLoader.item.selectedLink
                    verticalAlignment: Text.AlignVCenter
                }
                MouseArea {
                    id: signoutArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        Ra2snes.signOut();
                    }
                    onEntered: {
                        signoutRect.color = themeLoader.item.popupHighlightColor;
                        signout.color = themeLoader.item.linkColor;
                        themePopup.closeThemes();
                    }

                    onExited: {
                        signoutRect.color = themeLoader.item.popupBackgroundColor;
                        if(enabled)
                            signout.color = themeLoader.item.selectedLink;
                    }
                }
            }
        }
    }
    MouseArea {
        hoverEnabled: true
        id: popupContainer
        x: 0
        y: 0
        width: 0
        height: 0
        z: 119
        enabled: false
        onEntered: {
            enabled = false;
            themeRect.color = themeLoader.item.popupBackgroundColor;
            theme.color = themeLoader.item.selectedLink;
            hamburgerRectangle.color = themeLoader.item.mainWindowDarkAccentColor;
            themePopup.close();
            menuPopup.close();
        }
    }
}

import QtQuick
import QtQuick.Controls.Material
import CustomModels 1.0

ProgressBar {
    id: progressBar
    z: 1
    value: {
        let val = (GameInfoModel.completion_count / GameInfoModel.achievement_count);
        if(val >= 0)
            return Math.min(Math.max(val, 0), 1);
        else return 0;
    }
    Item {
        z: 1
        width: progressBar.width + 2
        height: progressBar.height
        anchors.left: parent.left
        anchors.leftMargin: -1
        Rectangle {
            width: parent.width
            height: parent.height / 2
            color: themeLoader.item.progressBarBackgroundColor
        }
        Rectangle {
            width: parent.width
            height: parent.height
            radius: 6
            color: themeLoader.item.progressBarBackgroundColor
            anchors.bottom: parent.bottom
        }
    }
    Item {
        z: 2
        width: (progressBar.width + 2) * progressBar.value
        height: progressBar.height
        anchors.left: parent.left
        anchors.leftMargin: -1
        Rectangle {
            width: parent.width
            height: parent.height / 2
            color: themeLoader.item.progressBarColor
        }
        Rectangle {
            id: roundedBar
            width: parent.width
            height: parent.height
            radius: 6
            color: themeLoader.item.progressBarColor
            anchors.bottom: parent.bottom
        }
        Rectangle {
            width: {
                if(roundedBar.width) 5;
                else 0;
            }
            height: {
                if(roundedBar.width < (progressBar.width - 3))
                    parent.height;
                else roundedBar.width - parent.width
            }
            anchors.left: roundedBar.right
            anchors.leftMargin: -4
            color: themeLoader.item.progressBarColor
            anchors.top: parent.top
        }
    }
}
            


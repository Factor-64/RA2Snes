import QtQuick

Column {
    id: root
    property alias sourceUrl: iconImage.source
    property int mode: 0 // 0 = primed, 1 = score
    property int value: 0
    property int total: 0
    signal expired()

    SequentialAnimation on opacity {
        running: true
        PropertyAnimation { from: 0; to: 1; duration: 200 }
    }

    // Spacer for primed mode
    Item {
        height: root.mode === 0 ? 16 : 0
    }

    // Score label (only in score mode)
    Text {
        id: scoreLabel
        visible: root.mode === 1
        text: root.value + "/" + root.total
        font.bold: true
        font.family: "Verdana"
        font.pixelSize: 13
        color: themeLoader.item.progressBarColor
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Image {
        id: iconImage
        width: 64
        height: 64
        smooth: false
        fillMode: Image.PreserveAspectFit
        cache: true
        asynchronous: true
    }

    // Expiry timer (only in score mode)
    Timer {
        id: expiryTimer
        interval: 20000
        repeat: false
        running: root.mode === 1
        onTriggered:
        {
            interval = 20000;
            root.fadeOutAndRemove();
        }
    }

    function restartTimer(newInterval)
    {
        if (mode === 1)
        {
            if (newInterval) expiryTimer.interval = newInterval;
            expiryTimer.restart();
        }
    }

    SequentialAnimation {
        id: fadeOutAnim
        running: false
        PropertyAnimation { target: root; property: "opacity"; to: 0; duration: 200 }
        ScriptAction { script: root.expired() }
    }

    function fadeOutAndRemove() {
        fadeOutAnim.start()
    }

}

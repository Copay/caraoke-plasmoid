import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasma5support as P5Support
import org.kde.plasma.extras as PlasmaExtras

MouseArea {
    id: lyricPanel
    Layout.minimumHeight: row.implicitHeight
    Layout.preferredWidth: plasmoid.configuration.twidth
    clip: true
    property font currentFont: plasmoid.configuration.tfont
    TextMetrics {
        id: trueTextSizer
        font: currentFont
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 0
        property var slideAnimation
        function setclip() {
            row.anchors.centerIn = undefined;
            if (slideAnimation)
                slideAnimation.destroy();
            row.x = 0;
            slideAnimation = slidani.createObject(this, {
                duration: currentTimeRange[1] ? (currentTimeRange[1] - currentTimeRange[0]) : 0
            });
            slideAnimation.start();
        }
        function setnoclip() {
            if (slideAnimation)
                slideAnimation.destroy();
            row.anchors.centerIn = parent;
            row.x = null;
        }
    }

    AnimationController {
        id: controller
        SequentialAnimation {
            id: seq
        }
    }
    Component.onCompleted: {
        updateAnim();
    }
    Component {
        id: numani
        NumberAnimation {
            property: "t"
            from: 0
            to: 1
        }
    }
    Component {
        id: twi
        TextWithTime {
            textFont: currentFont
            unhighlightedTextColor: plasmoid.configuration.tunhighlightedColorDefault ? PlasmaCore.Theme.disabledTextColor : plasmoid.configuration.tunhighlightedColor
            highlightedTextColor: plasmoid.configuration.thighlightedColorDefault ? PlasmaCore.Theme.highlightedTextColor : plasmoid.configuration.thighlightedColor
        }
    }
    Component {
        id: slidani
        SmoothedAnimation {
            from: 0
            to: lyricPanel.width - trueTextSizer.width
            target: row
            property: "x"
            easing.type: Easing.InOutCubic
            velocity: -1
            onStopped: () => {
                this.destroy();
            }
        }
    }
    function updateAnim() {
        let tmprow = row.children;
        let tmpanim = seq.animations;
        for (let i = 0; i < tmprow.length; i++) {
            tmprow[i].destroy();
            tmpanim[i].destroy();
        }
        if (!currentLyricStr || !currentLyricStr.length)
            return;
        let anim = [];
        let rowdata = [];
        for (let a = 0; a < currentLyricStr.length; a++) {
            rowdata.push(twi.createObject(row, {
                texts: currentLyricStr[a]
            }));
            anim.push(numani.createObject(lyricPanel, {
                target: rowdata[a],
                duration: currentTimeList[2 * a + 1] - currentTimeList[2 * a]
            }));
        }
        row.children = rowdata;
        seq.animations = anim;
        controller.progress = 0;
        controller.reload();
            if (lyricPanel.width < trueTextSizer.width) {
                row.setclip();
            } else {
                row.setnoclip();
            }
        return currentTimeList[currentTimeList.length-1] || 0
    }
    Connections {
        target: root
        function onCurrentItemChanged() {
            changeLyricSelectionTimer.interval = lyricPanel.updateAnim() || 0;
            changeLyricSelectionTimer.running = true;
        }
        function onLyricUpdated() {
            lyricPanel.updateAnim();
        }
        function onCurrentTimeChanged() {
            controller.progress = currentTimeRange[1] ? (currentTime - currentTimeRange[0]) / (currentTimeRange[1] - currentTimeRange[0]) : 0;
        }
    }
}

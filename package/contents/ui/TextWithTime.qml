import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasma5support as P5Support
import Qt5Compat.GraphicalEffects

Item {
    property string texts
    property var t
    property var unhighlightedTextColor: plasmoid.configuration.dunhighlightedColorDefault ? PlasmaCore.Theme.disabledTextColor : plasmoid.configuration.dunhighlightedColor
    property var highlightedTextColor: plasmoid.configuration.dhighlightedColorDefault ? PlasmaCore.Theme.highlightedTextColor : plasmoid.configuration.dhighlightedColor
    property font textFont
    width: mask.width
    height: mask.height
    Text {
        id: mask
        text: texts
        font: textFont
    }
    Rectangle {
        id: bg
        anchors.top: mask.top
        anchors.bottom: mask.bottom
        anchors.left: mask.left
        anchors.right: mask.right
        color: unhighlightedTextColor
        Rectangle {
            id: left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            width: parent.width * t
            color: highlightedTextColor
        }
        visible: false
    }

    OpacityMask {
        anchors.fill: bg
        source: bg
        maskSource: mask
    }
}

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasma5support as P5Support

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
        visible: false
    }
    Canvas {
        id: canvas
        width: mask.width
        height: mask.height
        onPaint: {
            let ctx = getContext('2d');
            ctx.textAlign = 'left';
            ctx.textBaseline = 'middle';
            ctx.font = textFont.weight + ' ' + textFont.pointSize + 'pt "' + textFont.family + '"';
            //if(t===0) {
            ctx.fillStyle = unhighlightedTextColor;
            ctx.fillText(texts, 0, height / 2);
            ctx.fillStyle = highlightedTextColor;
            //}
            ctx.save();
            ctx.beginPath();
            ctx.clearRect(0, 0, width * t, height);
            ctx.rect(0, 0, width * t, height);
            ctx.clip();
            ctx.fillText(texts, 0, height / 2);
            ctx.restore();
        }
    }
    onTChanged: {
        canvas.requestPaint();
    }
}

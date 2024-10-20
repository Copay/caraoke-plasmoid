import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Dialogs
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.plasma.plasmoid

KCM.SimpleKCM {
    property alias cfg_twidth: twidth.value
    property alias cfg_tfont: tfontDialog.selectedFont
    property alias cfg_thighlightedColorDefault: thighlightedColorDefault.checked
    property alias cfg_thighlightedColor: tcolorDialogForHC.selectedColor
    property alias cfg_tunhighlightedColorDefault: tunhighlightedColorDefault.checked
    property alias cfg_tunhighlightedColor: tcolorDialogForUHC.selectedColor

    Kirigami.FormLayout {
        id: page

        QQC2.SpinBox {
            id: twidth
            Kirigami.FormData.label: "taskbar widght's width"
            from: 100
            to: 5000
        }

        QQC2.Button {
            text: `${tfontDialog.selectedFont.family} ${tfontDialog.selectedFont.styleName} ${tfontDialog.selectedFont.pointSize}`
            Kirigami.FormData.label: "taskbar font"
            onClicked: tfontDialog.open()
        }
        FontDialog {
            id: tfontDialog
            selectedFont: plasmoid.configuration.tfont
            onAccepted: {
                console.log(selectedFont)
            }
        }
        QQC2.CheckBox {
            id: thighlightedColorDefault
            checked: plasmoid.configuration.thighlightedColorDefault
            Kirigami.FormData.label: "Default for highlighted color"
        }
        QQC2.Button {
            text: tcolorDialogForHC.selectedColor
            Kirigami.FormData.label: "highlighted color"
            enabled: !thighlightedColorDefault.checked
            onClicked: tcolorDialogForHC.open()
        }
        ColorDialog {
            id: tcolorDialogForHC
            selectedColor: plasmoid.configuration.thighlightedColor
        }

        QQC2.CheckBox {
            id: tunhighlightedColorDefault
            checked: plasmoid.configuration.tunhighlightedColorDefault
            Kirigami.FormData.label: "Default for unhighlighted color"
        }
        QQC2.Button {
            text: tcolorDialogForUHC.selectedColor
            Kirigami.FormData.label: "unhighlighted color"
            enabled: !tunhighlightedColorDefault.checked
            onClicked: tcolorDialogForUHC.open()
        }
        ColorDialog {
            id: tcolorDialogForUHC
            selectedColor: plasmoid.configuration.tunhighlightedColor
        }
    }
}

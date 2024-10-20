import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Dialogs
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.plasma.plasmoid

KCM.SimpleKCM {
    property alias cfg_dwidth: dwidth.value
    property alias cfg_dfont: fontDialog.selectedFont
    property alias cfg_dhighlightedColorDefault: dhighlightedColorDefault.checked
    property alias cfg_dhighlightedColor: colorDialogForHC.selectedColor
    property alias cfg_dunhighlightedColorDefault: dunhighlightedColorDefault.checked
    property alias cfg_dunhighlightedColor: colorDialogForUHC.selectedColor

    Kirigami.FormLayout {
        id: page

        QQC2.SpinBox {
            id: dwidth
            Kirigami.FormData.label: "desktop widght's width"
            from: 100
            to: 5000
        }

        QQC2.Button {
            text: `${fontDialog.selectedFont.family} ${fontDialog.selectedFont.styleName} ${fontDialog.selectedFont.pointSize}`
            Kirigami.FormData.label: "desktop font"
            onClicked: fontDialog.open()
        }
        FontDialog {
            id: fontDialog
            selectedFont: plasmoid.configuration.dfont
            onAccepted: {
                console.log(JSON.stringify(selectedFont))
            }
        }
        QQC2.CheckBox {
            id: dhighlightedColorDefault
            checked: plasmoid.configuration.dhighlightedColorDefault
            Kirigami.FormData.label: "Default for highlighted color"
        }
        QQC2.Button {
            text: colorDialogForHC.selectedColor
            Kirigami.FormData.label: "highlighted color"
            enabled: !dhighlightedColorDefault.checked
            onClicked: colorDialogForHC.open()
        }
        ColorDialog {
            id: colorDialogForHC
            selectedColor: plasmoid.configuration.dhighlightedColor
        }

        QQC2.CheckBox {
            id: dunhighlightedColorDefault
            checked: plasmoid.configuration.dunhighlightedColorDefault
            Kirigami.FormData.label: "Default for unhighlighted color"
        }
        QQC2.Button {
            text: colorDialogForUHC.selectedColor
            Kirigami.FormData.label: "unhighlighted color"
            enabled: !dunhighlightedColorDefault.checked
            onClicked: colorDialogForUHC.open()
        }
        ColorDialog {
            id: colorDialogForUHC
            selectedColor: plasmoid.configuration.dunhighlightedColor
        }
    }
}

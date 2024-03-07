import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Dialogs
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.plasma.plasmoid

KCM.SimpleKCM {
    property alias cfg_dwidth: dwidth.value
    property alias cfg_dfont: fontDialog.selectedFont
    property alias cfg_dfontWeight: dfontWeight.value
    property alias cfg_dfontSize: dfontSize.value
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
            text: fontDialog.selectedFont.family
            Kirigami.FormData.label: "desktop font's family"
            onClicked: fontDialog.open()
        }
        FontDialog {
            id: fontDialog
            selectedFont: plasmoid.configuration.dfont
        }
        QQC2.SpinBox {
            id: dfontWeight
            Kirigami.FormData.label: "font's weight"
            from: 0
            to: 1000
        }
        QQC2.SpinBox {
            id: dfontSize
            Kirigami.FormData.label: "font's size"
            from: 10
            to: 100
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

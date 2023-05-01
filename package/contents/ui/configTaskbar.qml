import QtQuick 2.0
import QtQuick.Controls 2.5 as QQC2
import QtQuick.Dialogs 1.1
import org.kde.kirigami 2.4 as Kirigami

Kirigami.FormLayout {
    id: page
  
    property alias cfg_twidth: twidth.value
    property alias cfg_tfont: tfontDialog.currentFont
    property alias cfg_tfontWeight: tfontWeight.value
    property alias cfg_tfontSize: tfontSize.value
    property alias cfg_thighlightedColorDefault: thighlightedColorDefault.checked
    property alias cfg_thighlightedColor: tcolorDialogForHC.currentColor
    property alias cfg_tunhighlightedColorDefault: tunhighlightedColorDefault.checked
    property alias cfg_tunhighlightedColor: tcolorDialogForUHC.currentColor

    QQC2.SpinBox {
        id: twidth
        Kirigami.FormData.label: "taskbar widght's width"
        from: 100
        to: 5000
    }

    QQC2.Button {
        text: tfontDialog.currentFont.family
        Kirigami.FormData.label: "taskbar font's family"
        onClicked: tfontDialog.open()
    }
    FontDialog {
        id: tfontDialog
        currentFont: plasmoid.configuration.tfont
    }
    QQC2.SpinBox {
        id: tfontWeight
        Kirigami.FormData.label: "font's weight"
        from: 0
        to: 99
    }
    QQC2.SpinBox {
        id: tfontSize
        Kirigami.FormData.label: "font's size"
        from: 10
        to: 100
    }
    QQC2.CheckBox {
        id: thighlightedColorDefault
        checked: plasmoid.configuration.thighlightedColorDefault
        Kirigami.FormData.label: "Default for highlighted color"
    }
    QQC2.Button {
        text: tcolorDialogForHC.currentColor
        Kirigami.FormData.label: "highlighted color"
        enabled: !thighlightedColorDefault.checked
        onClicked: tcolorDialogForHC.open()
    }
    ColorDialog {
        id: tcolorDialogForHC
        currentColor: plasmoid.configuration.thighlightedColor
    }

    QQC2.CheckBox {
        id: tunhighlightedColorDefault
        checked: plasmoid.configuration.tunhighlightedColorDefault
        Kirigami.FormData.label: "Default for unhighlighted color"
    }
    QQC2.Button {
        text: tcolorDialogForUHC.currentColor
        Kirigami.FormData.label: "unhighlighted color"
        enabled: !tunhighlightedColorDefault.checked
        onClicked: tcolorDialogForUHC.open()
    }
    ColorDialog {
        id: tcolorDialogForUHC
        currentColor: plasmoid.configuration.tunhighlightedColor
    }
}

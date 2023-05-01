import QtQuick 2.0
import QtQuick.Controls 2.5 as QQC2
import QtQuick.Dialogs 1.1
import org.kde.kirigami 2.4 as Kirigami

Kirigami.FormLayout {
    id: page
  
    property alias cfg_dwidth: dwidth.value
    property alias cfg_dfont: fontDialog.currentFont
    property alias cfg_dfontWeight: dfontWeight.value
    property alias cfg_dfontSize: dfontSize.value
    property alias cfg_dhighlightedColorDefault: dhighlightedColorDefault.checked
    property alias cfg_dhighlightedColor: colorDialogForHC.currentColor
    property alias cfg_dunhighlightedColorDefault: dunhighlightedColorDefault.checked
    property alias cfg_dunhighlightedColor: colorDialogForUHC.currentColor

    QQC2.SpinBox {
        id: dwidth
        Kirigami.FormData.label: "desktop widght's width"
        from: 100
        to: 5000
    }

    QQC2.Button {
        text: fontDialog.currentFont.family
        Kirigami.FormData.label: "desktop font's family"
        onClicked: fontDialog.open()
    }
    FontDialog {
        id: fontDialog
        currentFont: plasmoid.configuration.dfont
    }
    QQC2.SpinBox {
        id: dfontWeight
        Kirigami.FormData.label: "font's weight"
        from: 0
        to: 99
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
        text: colorDialogForHC.currentColor
        Kirigami.FormData.label: "highlighted color"
        enabled: !dhighlightedColorDefault.checked
        onClicked: colorDialogForHC.open()
    }
    ColorDialog {
        id: colorDialogForHC
        currentColor: plasmoid.configuration.dhighlightedColor
    }

    QQC2.CheckBox {
        id: dunhighlightedColorDefault
        checked: plasmoid.configuration.dunhighlightedColorDefault
        Kirigami.FormData.label: "Default for unhighlighted color"
    }
    QQC2.Button {
        text: colorDialogForUHC.currentColor
        Kirigami.FormData.label: "unhighlighted color"
        enabled: !dunhighlightedColorDefault.checked
        onClicked: colorDialogForUHC.open()
    }
    ColorDialog {
        id: colorDialogForUHC
        currentColor: plasmoid.configuration.dunhighlightedColor
    }
}

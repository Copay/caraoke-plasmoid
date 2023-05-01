import QtQuick 2.0
import QtQuick.Controls 2.5 as QQC2
import org.kde.kirigami 2.4 as Kirigami

Kirigami.FormLayout {
    id: page
  
    property alias cfg_refreshRate: refreshRate.value

    QQC2.SpinBox {
        id: refreshRate
        Kirigami.FormData.label: "refresh rate (ms)"
        from: 10
        to: 5000
    }
}

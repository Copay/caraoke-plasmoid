import QtQuick 2.15
import QtQuick.Controls 2.5 as QQC2
import org.kde.kirigami 2.4 as Kirigami

Kirigami.FormLayout {
    id: page
  
    property alias cfg_refreshRate: refreshRate.value
    property alias cfg_apiServerAddress: apiServerAddress.text

    QQC2.SpinBox {
        id: refreshRate
        Kirigami.FormData.label: "refresh rate (ms)"
        from: 10
        to: 5000
    }

    QQC2.TextField {
        id: apiServerAddress
        Kirigami.FormData.label: "API server address"
        validator: RegularExpressionValidator {
            regularExpression: /https?\/\/[-a-z0-9]+(\.[-a-z0-9]*\.(com|cn|edu|hk))/
        }
    }
}

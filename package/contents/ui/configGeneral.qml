import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.plasma.plasmoid

KCM.SimpleKCM {

    property alias cfg_refreshRate: refreshRate.value
    property alias cfg_apiServerAddress: apiServerAddress.text
    property alias cfg_playerFilter: playerFilter.text
    Kirigami.FormLayout {
        id: page

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
                regularExpression: /https?\/\/[-a-z0-9]+(\.[-a-z0-9]*\..*)/
            }
        }
        QQC2.TextField {
            id: playerFilter
            Kirigami.FormData.label: "Allowed players"
            placeholderText: "Gapless|NeteaseCloudMusicGtk4"
        }
    }
}

import QtQuick 2.0
import org.kde.plasma.configuration 2.0

ConfigModel {
    ConfigCategory {
        name: i18n("General")
        icon: "configure"
        source: "configGeneral.qml"
    }
    ConfigCategory {
        name: i18n("Desktop Widget")
        icon: "configure"
        source: "configDesktop.qml"
    }
    ConfigCategory {
        name: i18n("Taskbar Widget")
        icon: "configure"
        source: "configTaskbar.qml"
    }
}
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Universal 2.15
import "../Constants"

Menu {
    // Ugly but required hack for automatic menu width, otherwise long texts are being cut
    width: {
        let result = 0
        let padding = 0

        for (let i = 0; i < count; ++i) {
            let item = itemAt(i)
            result = Math.max(item.contentItem.implicitWidth, result)
            padding = Math.max(item.padding, padding)
        }

        return result + padding * 2
    }

    MenuItem {
        id: disable_action
        text: qsTr("Disable %1", "TICKER").arg(ticker)
        onTriggered: API.app.disable_coins([ticker])
        enabled: General.canDisable(ticker)
    }

    MenuItem {
        text: qsTr("Disable and Delete %1", "TICKER").arg(ticker)
        onTriggered: {
            const cloneTicker = General.clone(ticker)
            API.app.disable_coins([ticker])
            API.app.settings_pg.remove_custom_coin(cloneTicker)
            restart_modal.open()
        }
        enabled: disable_action.enabled && API.app.get_coin_info(ticker).is_custom_coin
    }

    MenuItem {
        readonly property string coin_type: API.app.get_coin_info(ticker).type
        enabled: !prevent_coin_disabling.running && General.isParentCoin(ticker)
        text: enabled ? ticker === "KMD" ? qsTr("Disable all Smartchains") :
                                           qsTr("Disable %1 and all %2 assets").arg(ticker).arg(coin_type) : "-"
        onTriggered: {
            const coins_to_disable = API.app.enabled_coins.filter(c => c.type === coin_type && !General.isParentCoin(c.ticker)).map(c => c.ticker)

            // Disable children assets
            if(coins_to_disable.length > 0)
                API.app.disable_coins(coins_to_disable)

            // Disable the parent asset
            if(ticker !== "KMD")
                API.app.disable_coins([ticker])
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/


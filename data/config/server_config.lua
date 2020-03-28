ServerConfig                        = {}
ServerConfig.EnableDebug            = true

ServerConfig.ExtendedPermissions    = {
    ['safe.item.*'] = {
        'safe.item.add',
        'safe.item.remove',
        'safe.item.buy'
    },
    ['safe.weapon.*'] = {
        'safe.weapon.add',
        'safe.weapon.remove',
        'safe.weapon.buy'
    },
    ['safe.dirtymoney.*'] = {
        'safe.dirtymoney.add',
        'safe.dirtymoney.remove'
    }
}
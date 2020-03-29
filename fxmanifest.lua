fx_version 'adamant'

game 'gta5'

description 'Job script created by Tigo#9999'
name 'ESX Jobs'
author 'TigoDevelopment'
contact 'me@tigodev.com'
version '1.0.0'

server_scripts {
    '@async/async.lua',
    '@mysql-async/lib/MySQL.lua',
    '@es_extended/locale.lua',

    'locales/nl.lua',

    'data/config/server_config.lua',

    'server/classes/permissions.lua',
    'server/classes/job.lua',

    'server/common.lua',

    'shared/functions.lua',

    'server/loadJob.lua',
    'server/functions.lua',

    'server/main.lua',

    'server/menus/safe_items.lua',
}

client_scripts {
    '@es_extended/locale.lua',

    'locales/nl.lua',

    'data/config/client_config.lua',

    'client/common.lua',

    'shared/functions.lua',
    'client/functions.lua',

    'client/menus/safe_items.lua',

    'client/main.lua'
}

dependencies {
    'es_extended',
    'mysql-async',
    'async',
}
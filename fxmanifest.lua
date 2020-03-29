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

    'client/handlers/menu_default.lua',

    'client/menus/safe_items.lua',

    'client/main.lua'
}

files {
    'html/index.html',

    'html/css/menu_default.css',
    'html/js/mustache.min.js',
    'html/js/menu_default.js',

    'html/img/headers/*.jpg',
    'html/img/headers/*.png',

    -- Fonts
    'html/fonts/BebasNeue/BebasNeueBold.otf',
    'html/fonts/BebasNeue/BebasNeueBook.otf',
    'html/fonts/BebasNeue/BebasNeueLight.otf',
    'html/fonts/BebasNeue/BebasNeueRegular.otf',
    'html/fonts/BebasNeue/BebasNeueThin.otf'
}

ui_page {
    'html/index.html'
}

dependencies {
    'es_extended',
    'mysql-async',
    'async',
}
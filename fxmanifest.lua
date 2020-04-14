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

    'shared/locale.lua',
    'locales/nl.lua',
    'locales/en.lua',

    'data/config/client_config.lua',
    'data/config/server_config.lua',

    'shared/classes/permissions.lua',
    'server/classes/account.lua',
    'server/classes/item.lua',
    'server/classes/weapon.lua',
    'server/classes/job.lua',
    'server/classes/sellableItem.lua',
    'server/classes/showroom.lua',

    'server/common.lua',

    'shared/formats.lua',
    'shared/functions.lua',

    'server/loadJob.lua',
    'server/functions.lua',

    'server/main.lua',

    'server/menus/safe_items.lua',
    'server/menus/wardrobe.lua',
    'server/menus/safe_weapons.lua',
    'server/menus/action_menu.lua',
    'server/menus/showroom.lua',
    'server/menus/catalogues.lua',
    'server/menus/sells.lua'
}

client_scripts {
    'shared/locale.lua',
    'locales/nl.lua',
    'locales/en.lua',

    'data/config/client_config.lua',

    'shared/classes/permissions.lua',

    'client/common.lua',

    'shared/formats.lua',
    'shared/functions.lua',

    'client/functions.lua',

    'client/handlers/menu_default.lua',
    'client/handlers/menu_dialog.lua',

    'client/menus/safe_items.lua',
    'client/menus/wardrobe.lua',
    'client/menus/safe_weapons.lua',
    'client/menus/parkings.lua',
    'client/menus/vehicles.lua',
    'client/menus/action_menu.lua',
    'client/menus/showroom.lua',
    'client/menus/catalogues.lua',
    'client/menus/sells.lua',

    'client/main.lua'
}

files {
    'html/index.html',

    'html/css/menu_default.css',
    'html/css/menu_dialog.css',
    'html/js/mustache.min.js',
    'html/js/menus.js',

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
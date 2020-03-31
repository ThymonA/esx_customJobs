Jobs.RegisterServerCallback('esx_jobs:getPlayerWeapons', function(xPlayer, xJob, callback)
    if (xPlayer == nil and callback ~= nil) then
        callback({
            weapons = {}
        })

        return
    end

    if (not xJob.memberHasPermission(xPlayer.identifier, 'safe.weapon.add')) then
        callback({
            weapons = {}
        })

        return
    end

    if (callback ~= nil) then
        callback({
            weapons = xPlayer.loadout or {}
        })
    end
end)

Jobs.RegisterServerCallback('esx_jobs:storeWeapon', function(xPlayer, xJob, callback, weapon)
    weapon = weapon or 'unknown'

    if (xPlayer == nil and callback ~= nil) then
        callback({
            done = false,
            message = 'error_no_player'
        })

        return
    end

    if (not xJob.memberHasPermission(xPlayer.identifier, 'safe.weapon.add')) then
        callback({
            done = false,
            message = 'error_no_permission'
        })

        return
    end

    for _, weaponItem in pairs(xPlayer.loadout or {}) do
        if (string.lower(weaponItem.name) == string.lower(weapon)) then
            xPlayer.removeWeapon(weaponItem.name)
            xJob.addWeapon(weaponItem.name, 1)

            xJob.logIdentifierToDiscord(xPlayer.identifier,
                _U('safe_weapon_added_webhook', xPlayer.name, weaponItem.label),
                _U('safe_weapon_added_webhook_description', xPlayer.name, weaponItem.label),
                'weapon',
                3066993)

            callback({ done = true })
            return
        end
    end

    callback({
        done = false,
        message = 'error_no_action'
    })
end)

Jobs.RegisterServerCallback('esx_jobs:getJobWeapons', function(xPlayer, xJob, callback)
    if (xPlayer == nil and callback ~= nil) then
        callback({
            weapons = {}
        })

        return
    end

    if (not xJob.memberHasPermission(xPlayer.identifier, 'safe.weapon.remove')) then
        callback({
            weapons = {}
        })

        return
    end

    local weapons = {}

    for _, weapon in pairs(xJob.getWeapons() or {}) do
        if (weapon.count > 0) then
            table.insert(weapons, {
                name = weapon.name,
                count = weapon.count,
                label = weapon.label
            })
        end
    end

    if (callback ~= nil) then
        callback({
            weapons = weapons or {}
        })
    end
end)

Jobs.RegisterServerCallback('esx_jobs:getWeapon', function(xPlayer, xJob, callback, weapon)
    weapon = weapon or 'unknown'

    if (xPlayer == nil and callback ~= nil) then
        callback({
            done = false,
            message = 'error_no_player'
        })

        return
    end

    if (not xJob.memberHasPermission(xPlayer.identifier, 'safe.weapon.remove')) then
        callback({
            done = false,
            message = 'error_no_permission'
        })

        return
    end

    if (xPlayer.hasWeapon(weapon)) then
        callback({
            done = false,
            message = 'error_has_weapon'
        })

        return
    end

    local xWeapon = xJob.getWeapon(weapon)

    if (xWeapon == nil or xWeapon.count <= 0) then
        callback({
            done = false,
            message = 'error_no_weapon_organization'
        })

        return
    end

    xJob.removeWeapon(weapon, 1)
    xPlayer.addWeapon(weapon, 250)

    xJob.logIdentifierToDiscord(xPlayer.identifier,
        _U('safe_weapon_removed_webhook', xPlayer.name, xWeapon.label),
        _U('safe_weapon_removed_webhook_description', xPlayer.name, xWeapon.label),
        'weapon',
        15158332)

    callback({ done = true })
end)

Jobs.RegisterServerCallback('esx_jobs:getBuyableWeapons', function(xPlayer, xJob, callback)
    if (xPlayer == nil and callback ~= nil) then
        callback({
            weapons = {}
        })

        return
    end

    if (not xJob.memberHasPermission(xPlayer.identifier, 'safe.weapon.buy')) then
        callback({
            weapons = {}
        })

        return
    end

    if (callback ~= nil) then
        local weapons = {}

        for _, weapon in pairs(xJob.getBuyableItemsByType('weapons') or {}) do
            local xWeapon = Jobs.GetWeapon(weapon.weapon)
            local jobWeapon = xJob.getWeapon(weapon.weapon)
            local weaponCount = 0

            if (jobWeapon ~= nil) then
                weaponCount = jobWeapon.count
            end

            table.insert(weapons, {
                name = xWeapon.name or 'unknown',
                ammo = xWeapon.ammo or 0,
                label = xWeapon.label or 'Unknown',
                components = xWeapon.components or {},
                tintIndex = xWeapon.tintIndex or 0,
                count = weaponCount or 0,
                price = weapon.price or 0
            })
        end

        callback({
            weapons = weapons
        })
    end
end)

Jobs.RegisterServerCallback('esx_jobs:buyWeapon', function(xPlayer, xJob, callback, weapon, count)
    weapon = weapon or 'unknown'
    count = tonumber(count) or 0

    if (xPlayer == nil and callback ~= nil) then
        callback({
            done = false,
            message = 'error_no_player'
        })

        return
    end

    if (not xJob.memberHasPermission(xPlayer.identifier, 'safe.weapon.buy')) then
        callback({
            done = false,
            message = 'error_no_permission'
        })

        return
    end

    local buyableWeapons = xJob.getBuyableItemsByType('weapons') or {}

    for _, buyableWeapon in pairs(buyableWeapons or {}) do
        if (string.lower(buyableWeapon.weapon) == string.lower(weapon)) then
            local price = buyableWeapon.price or 0

            if (count > 10) then
                callback({
                    done = false,
                    message = 'error_buy_limit'
                })

                return
            end

            if ((count * price) > ((xJob.getBank() or {}).money or 0)) then
                callback({
                    done = false,
                    message = 'error_no_money_organization'
                })

                return
            end

            xJob.removeAccountMoney('bank', (count * price))
            xJob.addWeapon(buyableWeapon.weapon, count)

            local xWeapon = xJob.getWeapon(buyableWeapon.weapon)
            local label = xWeapon.label or buyableWeapon.weapon or 'unknown'

            xJob.logIdentifierToDiscord(xPlayer.identifier,
                _U('safe_weapon_buy_webhook', xPlayer.name, xJob.label),
                _U('safe_weapon_buy_webhook_description', xPlayer.name, Jobs.Formats.NumberToFormattedString(count), label,
                    Jobs.Formats.NumberToCurrancy(price),
                    Jobs.Formats.NumberToCurrancy(count * price)),
                'weapon',
                3066993)

            callback({ done = true })
            return
        end
    end

    callback({
        done = false,
        message = 'error_no_action'
    })

    return
end)
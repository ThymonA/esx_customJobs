Jobs.RegisterServerCallback('esx_customjobs:getSellCategories',  function(xPlayer, xJob, callback, categoryType)
    categoryType = string.lower(categoryType or 'unknown')

    if ((not xJob.memberHasPermission(xPlayer.identifier, 'sells.sell.cars') and categoryType == 'car') or
        (not xJob.memberHasPermission(xPlayer.identifier, 'sells.sell.aircrafts') and categoryType == 'aircraft') or
        (not xJob.memberHasPermission(xPlayer.identifier, 'sells.sell.weapons') and categoryType == 'weapon') or
        (not xJob.memberHasPermission(xPlayer.identifier, 'sells.sell.items') and categoryType == 'item')) then
        TriggerClientEvent('esx:showNotification', xPlayer.source, _U('error_no_permission'))
        return
    end

    if (not xJob.memberHasPermission(xPlayer.identifier, 'sells.sell.cars') and
        not xJob.memberHasPermission(xPlayer.identifier, 'sells.sell.aircrafts') and
        not xJob.memberHasPermission(xPlayer.identifier, 'sells.sell.weapons') and
        not xJob.memberHasPermission(xPlayer.identifier, 'sells.sell.items')) then
        TriggerClientEvent('esx:showNotification', xPlayer.source, _U('error_no_permission'))
        return
    end

    if (categoryType ~= 'car' and categoryType ~= 'aircraft' and categoryType ~= 'weapon' and categoryType ~= 'item') then
        TriggerClientEvent('esx:showNotification', xPlayer.source, _U('error_invalid_type'))
        return
    end

    if ((categoryType == 'car' and not xJob.hasAnySellableCar()) or
        (categoryType == 'aircraft' and not xJob.hasAnySellableAircraft()) or
        (categoryType == 'weapon' and not xJob.hasAnySellableWeapon()) or
        (categoryType == 'item' and not xJob.hasAnySellableItem())) then
        TriggerClientEvent('esx:showNotification', xPlayer.source, _U('error_empty_type'))
        callback({})
        return
    end

    local results = {}
    local categories = xJob.getSellableCategories(true)
    local items = xJob.getSellableItemsByType(categoryType)

    for _, item in pairs(items or {}) do
        local category = item.category or 'unknown'

        if (results ~= nil and results[category] == nil) then
            results[category] = {
                name = category,
                label = categories[category] or 'Unknown',
                count = 1
            }
        else
            results[category].count = results[category].count + 1
        end
    end

    callback(results)
end)

Jobs.RegisterServerCallback('esx_customjobs:getCategoryObjects',  function(xPlayer, xJob, callback, categoryType, selectedCategory)
    categoryType = string.lower(categoryType or 'unknown')
    selectedCategory = string.lower(selectedCategory or 'unknown')

    if ((not xJob.memberHasPermission(xPlayer.identifier, 'sells.sell.cars') and categoryType == 'car') or
        (not xJob.memberHasPermission(xPlayer.identifier, 'sells.sell.aircrafts') and categoryType == 'aircraft') or
        (not xJob.memberHasPermission(xPlayer.identifier, 'sells.sell.weapons') and categoryType == 'weapon') or
        (not xJob.memberHasPermission(xPlayer.identifier, 'sells.sell.items') and categoryType == 'item')) then
        TriggerClientEvent('esx:showNotification', xPlayer.source, _U('error_no_permission'))
        return
    end

    if (not xJob.memberHasPermission(xPlayer.identifier, 'sells.sell.cars') and
        not xJob.memberHasPermission(xPlayer.identifier, 'sells.sell.aircrafts') and
        not xJob.memberHasPermission(xPlayer.identifier, 'sells.sell.weapons') and
        not xJob.memberHasPermission(xPlayer.identifier, 'sells.sell.items')) then
        TriggerClientEvent('esx:showNotification', xPlayer.source, _U('error_no_permission'))
        return
    end

    if (categoryType ~= 'car' and categoryType ~= 'aircraft' and categoryType ~= 'weapon' and categoryType ~= 'item') then
        TriggerClientEvent('esx:showNotification', xPlayer.source, _U('error_invalid_type'))
        return
    end

    if ((categoryType == 'car' and not xJob.hasAnySellableCar()) or
        (categoryType == 'aircraft' and not xJob.hasAnySellableAircraft()) or
        (categoryType == 'weapon' and not xJob.hasAnySellableWeapon()) or
        (categoryType == 'item' and not xJob.hasAnySellableItem())) then
        TriggerClientEvent('esx:showNotification', xPlayer.source, _U('error_empty_type'))
        callback({})
        return
    end

    local results = {}
    local categories = xJob.getSellableCategories(true)
    local items = xJob.getSellableItemsByType(categoryType)

    for _, item in pairs(items or {}) do
        local category = item.category or 'unknown'

        if (results ~= nil and results[category] == nil) then
            results[category] = {
                name = category,
                label = categories[category] or 'Unknown',
                count = 1,
                items = {}
            }
        else
            results[category].count = results[category].count + 1
        end

        table.insert(results[category].items, item)
    end

    if (results ~= nil and results[selectedCategory] ~= nil) then
        callback(results[selectedCategory].items)
    else
        callback({})
    end
end)
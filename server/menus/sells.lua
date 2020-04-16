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

Jobs.RegisterServerEvent('esx_customjobs:setCurrentVehicleSell', function(xPlayer, xJob, vehicleInfo)
    if (not xJob.memberHasPermission(xPlayer.identifier, 'sells.sell.cars')) then
        TriggerClientEvent('esx:showNotification', xPlayer.source, _U('error_no_permission'))
        return
    end

    local code = vehicleInfo.code or 'unknown'
    local position = vehicleInfo.position or { x = 0, y = 0, z = 0, h = 0 }
    local hash = vehicleInfo.hash or 'unknown'
    local vehicleJobInfo = xJob.getSellableVehicle(code)
    local vehicleProps = vehicleInfo.props or {}

    if (vehicleJobInfo == nil or vehicleJobInfo == {} or vehicleProps == nil or vehicleProps == {}) then
        TriggerClientEvent('esx_jobs:removeSellingVehicle', xPlayer.source, true)
        return
    end

    local newVehicleInfo = {
        key = Jobs.RandomString(24),
        code = code,
        position = position,
        hash = hash,
        job = xJob.name,
        jobLabel = xJob.label,
        price = vehicleJobInfo.sellPrice or 0,
        type = vehicleJobInfo.type or 'unknown',
        sellerId = xPlayer.source or 0,
        seller = {
            id = xPlayer.source,
            name = xPlayer.name,
            identifier = xPlayer.identifier
        },
        vehicleProps = vehicleProps
    }

    if (Jobs.VehicleSales == nil) then
        Jobs.VehicleSales = {}
    end

    table.insert(Jobs.VehicleSales, newVehicleInfo)

    TriggerClientEvent('esx_jobs:updateSellVehicle', -1, newVehicleInfo.key, 'update', newVehicleInfo)
end)

Jobs.RegisterServerEvent('esx_customjobs:buyVehicle', function(xPlayer, xJob, key)
    if (Jobs.BuyInProgress == nil) then
        Jobs.BuyInProgress = {}
    end

    if (Jobs.BuyInProgress[key] == nil or not (Jobs.BuyInProgress[key] or false)) then
        Jobs.BuyInProgress[key] = true
    elseif((Jobs.BuyInProgress[key] or false)) then
        TriggerClientEvent('esx:showNotification', xPlayer.source, _U('error_current_transaction'))
        return
    end

    local storedInformation = Jobs.GetVehicleForSale(key)

    if (storedInformation == nil or storedInformation == {}) then
        TriggerClientEvent('esx:showNotification', xPlayer.source, _U('error_vehicle_not_for_sale'))
        Jobs.BuyInProgress[key] = false
        return
    end

    local vehCode = storedInformation.code or 'unknown'
    local jobVehicleInfo = xJob.getSellableVehicle(vehCode)
    local price = jobVehicleInfo.sellPrice or 0
    local vehType = storedInformation.type or 'unknown'

    if (price <= 0 or string.lower(vehType) == 'unknown' or jobVehicleInfo == nil or jobVehicleInfo == {}) then
        TriggerClientEvent('esx:showNotification', xPlayer.source, _U('error_vehicle_not_for_sale'))
        Jobs.BuyInProgress[key] = false
        return
    end

    local playerBank = xPlayer.getAccount('bank')

    if (playerBank == nil or playerBank.money < price) then
        TriggerClientEvent('esx:showNotification', xPlayer.source, _U('error_no_money'))
        Jobs.BuyInProgress[key] = false
        return
    end

    local vehicleProps = storedInformation.vehicleProps or {}

    if (vehicleProps == nil or vehicleProps == {}) then
        TriggerClientEvent('esx:showNotification', xPlayer.source, _U('error_vehicle_not_for_sale'))
        Jobs.BuyInProgress[key] = false
        return
    end

    vehicleProps.model = storedInformation.hash or 0

    if (vehicleProps.model == nil or vehicleProps.model == 0) then
        TriggerClientEvent('esx:showNotification', xPlayer.source, _U('error_vehicle_not_for_sale'))
        Jobs.BuyInProgress[key] = false
        return
    end

    Jobs.GeneratePlate(function(plate)
        vehicleProps.plate = plate

        MySQL.Async.execute('INSERT INTO `owned_vehicles` (`owner`, `plate`, `vehicle`, `type`, `job`, `stored`) VALUES (@owner, @plate, @vehicle, @type, @job, @stored)', {
            ['@owner'] = xPlayer.identifier,
            ['@plate'] = plate,
            ['@vehicle'] = json.encode(vehicleProps),
            ['@type'] = vehType,
            ['@job'] = '',
            ['@stored'] = true
        },function(rowChanged)
            xJob.addAccountMoney('bank', price)
            xPlayer.removeAccountMoney('bank', price)

            TriggerClientEvent('esx:showNotification', xPlayer.source, _U('vehicle_buyed', Jobs.Formats.NumberToCurrancy(price), xJob.label))
            TriggerClientEvent('esx:showNotification', ((storedInformation.seller or {}).id or 0), _U('vehicle_sold', Jobs.Formats.NumberToCurrancy(price)))
            TriggerClientEvent('esx_jobs:removeSellingVehicle', ((storedInformation.seller or {}).id or 0))
            TriggerClientEvent('esx_jobs:updateSellVehicle', -1, key)

            Jobs.RemoveVehicleForSale(key)

            local sellerIdentifier = (storedInformation.seller or {}).identifier or 'unknown'
            local vehicleCode = jobVehicleInfo.code or 'unknown'
            local sellerName = (storedInformation.seller or {}).name or 'Unknown'
            local vehicleLabel = jobVehicleInfo.label or 'Unknown'

            local title = _U('vehicle_sold_title', sellerName, xPlayer.name)
            local description = _U('vehicle_sold_description', sellerName, xPlayer.name, vehicleLabel, plate, Jobs.Formats.NumberToCurrancy(price))
            local footer = sellerIdentifier .. ' | ' .. vehicleCode .. ' | ' .. plate .. ' | ' .. xPlayer.identifier

            xJob.logToDiscord(title, description, footer, 'sale', 15105570)

            Jobs.BuyInProgress[key] = nil
        end)
    end)
end)

Jobs.RegisterServerEvent('esx_customjobs:testDriveVehicle', function(xPlayer, xJob, key)
    if (Jobs.BuyInProgress == nil) then
        Jobs.BuyInProgress = {}
    end

    if (Jobs.BuyInProgress[key] == nil or not (Jobs.BuyInProgress[key] or false)) then
        Jobs.BuyInProgress[key] = true
    elseif((Jobs.BuyInProgress[key] or false)) then
        TriggerClientEvent('esx:showNotification', xPlayer.source, _U('error_current_transaction'))
        return
    end

    local storedInformation = Jobs.GetVehicleForSale(key)

    if (storedInformation == nil or storedInformation == {}) then
        TriggerClientEvent('esx:showNotification', xPlayer.source, _U('error_vehicle_not_for_sale'))
        Jobs.BuyInProgress[key] = false
        return
    end

    local vehCode = storedInformation.code or 'unknown'
    local jobVehicleInfo = xJob.getSellableVehicle(vehCode)

    if (jobVehicleInfo == nil or jobVehicleInfo == {}) then
        TriggerClientEvent('esx:showNotification', xPlayer.source, _U('error_vehicle_not_for_sale'))
        Jobs.BuyInProgress[key] = false
        return
    end

    local vehicleType = jobVehicleInfo.type or 'unknown'
    local testDrive = xJob.getTestDriveByType(vehicleType)

    if (testDrive == nil or testDrive == {}) then
        TriggerClientEvent('esx:showNotification', xPlayer.source, _U('error_no_test_drive'))
        Jobs.BuyInProgress[key] = false
        return
    end

    local duration = testDrive.duration or 0
    local position = testDrive.position or { x = 0, y = 0, z = 0, h = 0 }

    TriggerClientEvent('esx_jobs:startTestDriveVehicle', xPlayer.source, key, duration, position, storedInformation.props or {})
    TriggerClientEvent('esx:showNotification', xPlayer.source, _U('vehicle_test', Jobs.Formats.NumberToFormattedString(duration), xJob.label))
    TriggerClientEvent('esx:showNotification', ((storedInformation.seller or {}).id or 0), _U('vehicle_rent_test', Jobs.Formats.NumberToFormattedString(duration)))
    TriggerClientEvent('esx_jobs:removeSellingVehicle', ((storedInformation.seller or {}).id or 0))
    TriggerClientEvent('esx_jobs:updateSellVehicle', -1, key)

    Jobs.RemoveVehicleForSale(key)
end)

Jobs.RegisterServerEvent('esx_customjobs:declineVehicle', function(xPlayer, xJob, key)
    if (Jobs.BuyInProgress == nil) then
        Jobs.BuyInProgress = {}
    end

    if (Jobs.BuyInProgress[key] == nil or not (Jobs.BuyInProgress[key] or false)) then
        Jobs.BuyInProgress[key] = true
    elseif((Jobs.BuyInProgress[key] or false)) then
        TriggerClientEvent('esx:showNotification', xPlayer.source, _U('error_current_transaction'))
        return
    end

    local storedInformation = Jobs.GetVehicleForSale(key)

    if (storedInformation == nil or storedInformation == {}) then
        TriggerClientEvent('esx:showNotification', xPlayer.source, _U('error_vehicle_not_for_sale'))
        Jobs.BuyInProgress[key] = false
        return
    end

    local vehCode = storedInformation.code or 'unknown'
    local jobVehicleInfo = xJob.getSellableVehicle(vehCode)

    if (jobVehicleInfo == nil or jobVehicleInfo == {}) then
        TriggerClientEvent('esx:showNotification', xPlayer.source, _U('error_vehicle_not_for_sale'))
        Jobs.BuyInProgress[key] = false
        return
    end

    TriggerClientEvent('esx:showNotification', xPlayer.source, _U('vehicle_decline_order'))
    TriggerClientEvent('esx:showNotification', ((storedInformation.seller or {}).id or 0), _U('decline_order'))
    TriggerClientEvent('esx_jobs:removeSellingVehicle', ((storedInformation.seller or {}).id or 0))
    TriggerClientEvent('esx_jobs:updateSellVehicle', -1, key)

    Jobs.RemoveVehicleForSale(key)
end)

Jobs.GeneratePlate = function(cb)
    local length = ServerConfig.PlateLength or 6
    local spaceBetween = ServerConfig.SpaceBetweenPlate or false
    local plate = Jobs.GenerateLicense(nil, length, spaceBetween)

    Jobs.DoesPlateExists(plate, function(results)
        if (not results) then
            cb(plate)
        else
            cb(Jobs.GeneratePlate(cb))
        end
    end)
end

Jobs.DoesPlateExists = function(plate, cb)
    MySQL.Async.fetchAll('SELECT COUNT(*) AS `count` FROM `owned_vehicles` WHERE `plate` = @plate', {
        ['@place'] = plate
    }, function(results)

        if (((results[1] or {}).count or 0) == 0) then
            results = false
        else
            results = true
        end

        cb(results)
    end)
end
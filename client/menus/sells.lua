Jobs.RegisterMenu('sells', function()
    if (not Jobs.HasAnyPermission({ 'sells.sell.cars', 'sells.sell.aircrafts', 'sells.sell.weapons', 'sells.sell.items' })) then
        return
    end

    local elements = {}

    if (Jobs.HasPermission('sells.sell.cars') and (Jobs.GetCurrentJobValue().hasSellableCar or false)) then
        table.insert(elements, { label = _U('sell_car'), value = 'car' })
    end

    if (Jobs.HasPermission('sells.sell.aircrafts') and (Jobs.GetCurrentJobValue().hasSellableAircraft or false)) then
        table.insert(elements, { label = _U('sell_aircraft'), value = 'aircraft' })
    end

    if (Jobs.HasPermission('sells.sell.weapons') and (Jobs.GetCurrentJobValue().hasBuyableWeapon or false)) then
        table.insert(elements, { label = _U('sell_weapon'), value = 'weapon' })
    end

    if (Jobs.HasPermission('sells.sell.items') and (Jobs.GetCurrentJobValue().hasSellableItem or false)) then
        table.insert(elements, { label = _U('sell_item'), value = 'item' })
    end

    Jobs.ESX.UI.Menu.Open(
        'job_default',
        GetCurrentResourceName(),
        'sells',
        {
            title = _U('sells'),
            align = 'top-left',
            elements = elements,
            primaryColor = Jobs.GetPrimaryColor(),
            secondaryColor = Jobs.GetSecondaryColor(),
            image = Jobs.GetCurrentHeaderImage()
        },
        function(data, menu)
            local selectedType = string.lower((data.current or {}).value or 'unknown')

            Jobs.TriggerMenu('sells_categories', selectedType)
        end,
        function(data, menu)
            menu.close()
        end)
end)

Jobs.RegisterMenu('sells_categories', function(categoryType)
    categoryType = string.lower(categoryType or 'unknown')

    if (not Jobs.HasAnyPermission({ 'sells.sell.cars', 'sells.sell.aircrafts', 'sells.sell.weapons', 'sells.sell.items' })) then
        return
    end

    local elements = {}

    Jobs.TriggerServerCallback('esx_customjobs:getSellCategories', function(categories)
        for category, categoryValue in pairs(categories or {}) do
            table.insert(elements, { label = _U('category', (categoryValue.label or 'Unknown'), (categoryValue.count or 0)), value = category })
        end

        table.insert(elements, { label = _U('back'), value = '', disabled = true })
        table.insert(elements, { label = _U('back'), value = 'back' })

        Jobs.ESX.UI.Menu.Open(
            'job_default',
            GetCurrentResourceName(),
            'sells_categories',
            {
                title = _U('sells'),
                align = 'top-left',
                elements = elements,
                primaryColor = Jobs.GetPrimaryColor(),
                secondaryColor = Jobs.GetSecondaryColor(),
                image = Jobs.GetCurrentHeaderImage()
            },
            function(data, menu)
                if (data.current.value == 'back') then
                    Jobs.TriggerMenu('sells')
                    return
                end

                local selectedCategory = string.lower((data.current or {}).value or 'unknown')

                Jobs.TriggerMenu('sells_objects', categoryType, selectedCategory)
            end,
            function(data, menu)
                Jobs.TriggerMenu('sells')
            end)
    end, categoryType)
end)

Jobs.RegisterMenu('sells_objects', function(categoryType, category)
    categoryType = string.lower(categoryType or 'unknown')
    category = string.lower(category or 'unknown')

    if (not Jobs.HasAnyPermission({ 'sells.sell.cars', 'sells.sell.aircrafts', 'sells.sell.weapons', 'sells.sell.items' })) then
        return
    end

    local elements = {}

    Jobs.TriggerServerCallback('esx_customjobs:getCategoryObjects', function(items)
        for _, item in pairs(items or {}) do
            table.insert(elements, { label = _U('item', (item.label or 'Unknown'), Jobs.Formats.NumberToCurrancy(item.sellPrice or 0)), value = (item.code or 'unknown') })
        end

        table.insert(elements, { label = _U('back'), value = '', disabled = true })
        table.insert(elements, { label = _U('back'), value = 'back' })

        Jobs.ESX.UI.Menu.Open(
            'job_default',
            GetCurrentResourceName(),
            'sells_objects',
            {
                title = _U('sells'),
                align = 'top-left',
                elements = elements,
                primaryColor = Jobs.GetPrimaryColor(),
                secondaryColor = Jobs.GetSecondaryColor(),
                image = Jobs.GetCurrentHeaderImage()
            },
            function(data, menu)
                if (data.current.value == 'back') then
                    Jobs.TriggerMenu('sells_categories', categoryType)
                    return
                end

                local vehicleName = string.lower((data.current or {}).value or 'unknown')

                if (vehicleName ~= nil and vehicleName ~= '' and string.lower(vehicleName) ~= 'unknown' and string.lower(vehicleName) ~= 'none') then
                    local position = Jobs.GetCurrentData().spawn or {}
                    local vehicleHash = (type(vehicleName) == 'number' and vehicleName or GetHashKey(vehicleName))

                    if (position ~= nil and position ~= {} and IsModelInCdimage(vehicleHash)) then
                        local veh, distance = Jobs.ESX.Game.GetClosestVehicle(position)
                        local vehicleLoaded = Jobs.WaitForVehicleIsLoaded(vehicleHash)

                        while not vehicleLoaded do
                            Citizen.Wait(0)
                        end

                        if (Jobs.CurrentSellingVehicle ~= nil) then
                            if (DoesEntityExist(Jobs.CurrentSellingVehicle)) then
                                Jobs.ESX.Game.DeleteVehicle(Jobs.CurrentSellingVehicle)
                            end
                        end

                        if (DoesEntityExist(Jobs.CurrentSellingVehicle) or (DoesEntityExist(veh) and distance < 1.0)) then
                            Jobs.ESX.ShowNotification(_U('error_spawn_blocked'))
                            return
                        end

                        Jobs.ESX.Game.SpawnVehicle(vehicleHash, position, position.h or 75.0, function(vehicle)
                            Jobs.CurrentSellingVehicle = vehicle

                            local sellingInfo = {
                                category = 'sports',
                                code = vehicleName,
                                vehicle = vehicle,
                                position = position,
                                hash = vehicleHash,
                                currentPostion = nil,
                                props = Jobs.ESX.Game.GetVehicleProperties(vehicle)
                            }

                            SetVehicleNumberPlateText(vehicle, 'NONE')
                            SetVehicleOnGroundProperly(vehicle)
                            FreezeEntityPosition(vehicle, true)
                            SetVehicleDoorsLocked(vehicle, 2)

                            Jobs.ESX.ShowNotification(_U('sell_car_spawned'))

                            Jobs.TriggerServerEvent('esx_customjobs:setCurrentVehicleSell', sellingInfo)

                            menu.close()
                        end)
                    end
                end
            end,
            function(data, menu)
                Jobs.TriggerMenu('sells_categories', categoryType)
            end)
    end, categoryType, category)
end)
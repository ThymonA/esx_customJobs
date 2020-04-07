Jobs.RegisterMenu('safe_weapons', function()
    local elements = {}

    if (Jobs.HasPermission('safe.weapon.add')) then
        table.insert(elements, { label = _U('safe_weapon_add'), value = 'weapon_add' })
    end

    if (Jobs.HasPermission('safe.weapon.remove')) then
        table.insert(elements, { label = _U('safe_weapon_remove'), value = 'weapon_remove' })
    end

    if (Jobs.HasPermission('safe.weapon.buy') and (Jobs.GetCurrentJobValue().hasBuyableWeapon or false)) then
        table.insert(elements, { label = _U('safe_weapon_buy'), value = 'weapon_buy' })
    end

    Jobs.ESX.UI.Menu.Open(
        'job_default',
        GetCurrentResourceName(),
        'safe_weapons',
        {
            title = _U('safe_weapons'),
            align = 'top-left',
            elements = elements,
            primaryColor = Jobs.GetPrimaryColor(),
            secondaryColor = Jobs.GetSecondaryColor(),
            image = Jobs.GetCurrentHeaderImage()
        },
        function(data, menu)
            if (data.current.value == 'weapon_add' and (Jobs.HasPermission('safe.weapon.add'))) then
                Jobs.TriggerMenu('safe_weapons_add')
            elseif (data.current.value == 'weapon_remove' and Jobs.HasPermission('safe.weapon.remove')) then
                Jobs.TriggerMenu('safe_weapons_remove')
            elseif (data.current.value == 'weapon_buy' and Jobs.HasPermission('safe.weapon.buy') and (Jobs.GetCurrentJobValue().hasBuyableWeapon or false)) then
                Jobs.TriggerMenu('safe_weapons_buy')
            end
        end,
        function(data, menu)
            menu.close()
        end)
end)

Jobs.RegisterMenu('safe_weapons_add', function()
    if (not Jobs.HasPermission('safe.weapon.add')) then
        return
    end

    Jobs.TriggerServerCallback('esx_jobs:getPlayerWeapons', function(inventory)
        local elements = {}

        if (#(inventory.weapons or {}) > 0) then
            table.insert(elements, { label = _U('weapons'), value = '', disabled = true })

            for _, weapon in pairs(inventory.weapons or {}) do
                table.insert(elements, { label = _U('weapon', weapon.label, weapon.ammo), value = weapon.name })
            end
        end

        table.insert(elements, { label = _U('back'), value = '', disabled = true })
        table.insert(elements, { label = _U('back'), value = 'back' })

        Jobs.ESX.UI.Menu.Open(
            'job_default',
            GetCurrentResourceName(),
            'safe_weapons_add',
            {
                title = _U('safe_weapon_add'),
                align = 'top-left',
                elements = elements,
                primaryColor = Jobs.GetPrimaryColor(),
                secondaryColor = Jobs.GetSecondaryColor(),
                image = Jobs.GetCurrentHeaderImage()
            },
            function(data, menu)
                if (Jobs.HasPermission('safe.weapon.add')) then
                    if (string.lower(data.current.value) == 'back') then
                        Jobs.TriggerMenu('safe_weapons')
                    else
                        Jobs.TriggerServerCallback('esx_jobs:storeWeapon', function(result)
                            if ((result.done or false)) then
                                Jobs.ESX.ShowNotification(_U('safe_weapon_added'))
                            else
                                Jobs.ESX.ShowNotification(_U(result.message or 'unknown'))
                            end

                            Jobs.TriggerMenu('safe_weapons_add')
                        end, data.current.value)
                    end
                end
            end,
            function(data, menu)
                Jobs.TriggerMenu('safe_weapons')
            end)
    end)
end)

Jobs.RegisterMenu('safe_weapons_remove', function()
    if (not Jobs.HasPermission('safe.weapon.remove')) then
        return
    end

    Jobs.TriggerServerCallback('esx_jobs:getJobWeapons', function(inventory)
        local elements = {}

        if (#(inventory.weapons or {}) > 0) then
            table.insert(elements, { label = _U('weapons'), value = '', disabled = true })

            for _, weapon in pairs(inventory.weapons or {}) do
                table.insert(elements, { label = _U('item', weapon.label, weapon.count), value = weapon.name })
            end
        end

        table.insert(elements, { label = _U('back'), value = '', disabled = true })
        table.insert(elements, { label = _U('back'), value = 'back' })

        Jobs.ESX.UI.Menu.Open(
            'job_default',
            GetCurrentResourceName(),
            'safe_weapons_remove',
            {
                title = _U('safe_weapon_remove'),
                align = 'top-left',
                elements = elements,
                primaryColor = Jobs.GetPrimaryColor(),
                secondaryColor = Jobs.GetSecondaryColor(),
                image = Jobs.GetCurrentHeaderImage()
            },
            function(data, menu)
                if (Jobs.HasPermission('safe.weapon.remove')) then
                    if (string.lower(data.current.value) == 'back') then
                        Jobs.TriggerMenu('safe_weapons')
                    else
                        Jobs.TriggerServerCallback('esx_jobs:getWeapon', function(result)
                            if ((result.done or false)) then
                                Jobs.ESX.ShowNotification(_U('safe_weapon_removed'))
                            else
                                Jobs.ESX.ShowNotification(_U(result.message or 'unknown'))
                            end

                            Jobs.TriggerMenu('safe_weapons_remove')
                        end, data.current.value)
                    end
                end
            end,
            function(data, menu)
                Jobs.TriggerMenu('safe_weapons')
            end)
    end)
end)

Jobs.RegisterMenu('safe_weapons_buy', function()
    if (not Jobs.HasPermission('safe.weapon.buy') or not (Jobs.GetCurrentJobValue().hasBuyableItem or false)) then
        return
    end

    Jobs.TriggerServerCallback('esx_jobs:getBuyableWeapons', function(items)
        local elements = {}

        if (#(items.weapons or {}) > 0) then
            table.insert(elements, { label = _U('weapons'), value = '', disabled = true })

            for _, weapon in pairs(items.weapons or {}) do
                table.insert(elements, { label = _U('item', weapon.count .. '<small>x</small> ' .. weapon.label, Jobs.Formats.NumberToCurrancy(weapon.price)), value = weapon.name })
            end
        end

        table.insert(elements, { label = _U('back'), value = '', disabled = true })
        table.insert(elements, { label = _U('back'), value = 'back' })

        Jobs.ESX.UI.Menu.Open(
            'job_default',
            GetCurrentResourceName(),
            'safe_weapons_buy',
            {
                title = _U('safe_weapon_buy'),
                align = 'top-left',
                elements = elements,
                primaryColor = Jobs.GetPrimaryColor(),
                secondaryColor = Jobs.GetSecondaryColor(),
                image = Jobs.GetCurrentHeaderImage()
            },
            function(data, menu)
                if (Jobs.HasPermission('safe.weapon.buy') and (Jobs.GetCurrentJobValue().hasBuyableItem or false)) then
                    if (string.lower(data.current.value) == 'back') then
                        Jobs.TriggerMenu('safe_weapons')
                    else
                        Jobs.TriggerMenu('safe_weapons_buy_count', data.current.value)
                    end
                end
            end,
            function(data, menu)
                Jobs.TriggerMenu('safe_weapons')
            end)
    end)
end)

Jobs.RegisterMenu('safe_weapons_buy_count', function(weapon)
    if (not Jobs.HasPermission('safe.weapon.buy')) then
        return
    end

    Jobs.ESX.UI.Menu.Open(
        'job_dialog',
        GetCurrentResourceName(),
        'safe_weapons_buy_count',
        {
            title = _U('safe_weapon_buy_count'),
            submit = _U('buy'),
            primaryColor = Jobs.GetPrimaryColor(),
            secondaryColor = Jobs.GetSecondaryColor(),
            image = Jobs.GetCurrentHeaderImage()
        },
        function(data, menu)
            Jobs.TriggerServerCallback('esx_jobs:buyWeapon', function(result)
                if ((result.done or false)) then
                    Jobs.ESX.ShowNotification(_U('safe_weapon_buyed'))
                else
                    Jobs.ESX.ShowNotification(_U(result.message or 'unknown'))
                end

                Jobs.TriggerMenu('safe_weapons_buy')
            end, (weapon or 'unknown'), (data.value or 0))
        end,
        function(data, menu)
            Jobs.TriggerMenu('safe_weapons_buy')
        end)
end)
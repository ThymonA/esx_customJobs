Jobs.RegisterMenu('safe_weapons', function(isPrimaryJob)
    local elements = {}

    if (Jobs.HasPermission('safe.weapon.add', isPrimaryJob)) then
        table.insert(elements, { label = _U('safe_weapon_add'), value = 'weapon_add' })
    end

    if (Jobs.HasPermission('safe.weapon.remove', isPrimaryJob)) then
        table.insert(elements, { label = _U('safe_weapon_remove'), value = 'weapon_remove' })
    end

    if (Jobs.HasPermission('safe.weapon.buy', isPrimaryJob) and (Jobs.GetCurrentJobValue(isPrimaryJob).hasBuyableWeapon or false)) then
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
            primaryColor = Jobs.GetPrimaryColor(isPrimaryJob),
            secondaryColor = Jobs.GetSecondaryColor(isPrimaryJob),
            image = Jobs.GetCurrentHeaderImage(isPrimaryJob)
        },
        function(data, menu)
            if (data.current.value == 'weapon_add' and (Jobs.HasPermission('safe.weapon.add', isPrimaryJob))) then
                Jobs.TriggerMenu('safe_weapons_add', isPrimaryJob)
            elseif (data.current.value == 'weapon_remove' and Jobs.HasPermission('safe.weapon.remove', isPrimaryJob)) then
                Jobs.TriggerMenu('safe_weapons_remove', isPrimaryJob)
            elseif (data.current.value == 'weapon_buy' and Jobs.HasPermission('safe.weapon.buy', isPrimaryJob) and (Jobs.GetCurrentJobValue(isPrimaryJob).hasBuyableWeapon or false)) then
                Jobs.TriggerMenu('safe_weapons_buy', isPrimaryJob)
            end
        end,
        function(data, menu)
            menu.close()
        end)
end)

Jobs.RegisterMenu('safe_weapons_add', function(isPrimaryJob)
    if (not Jobs.HasPermission('safe.weapon.add', isPrimaryJob)) then
        return
    end

    Jobs.TriggerServerCallback('mlx_jobs:getPlayerWeapons', isPrimaryJob, function(inventory)
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
                primaryColor = Jobs.GetPrimaryColor(isPrimaryJob),
                secondaryColor = Jobs.GetSecondaryColor(isPrimaryJob),
                image = Jobs.GetCurrentHeaderImage(isPrimaryJob)
            },
            function(data, menu)
                if (Jobs.HasPermission('safe.weapon.add', isPrimaryJob)) then
                    if (string.lower(data.current.value) == 'back') then
                        menu.close()
                        Jobs.TriggerMenu('safe_weapons', isPrimaryJob)
                    else
                        Jobs.TriggerServerCallback('mlx_jobs:storeWeapon', isPrimaryJob, function(result)
                            if ((result.done or false)) then
                                Jobs.ESX.ShowNotification(_U('safe_weapon_added'))
                            else
                                Jobs.ESX.ShowNotification(_U(result.message or 'unknown'))
                            end

                            menu.close()
                            Jobs.TriggerMenu('safe_weapons_add', isPrimaryJob)
                        end, data.current.value)
                    end
                end
            end,
            function(data, menu)
                menu.close()
                Jobs.TriggerMenu('safe_weapons', isPrimaryJob)
            end)
    end)
end)

Jobs.RegisterMenu('safe_weapons_remove', function(isPrimaryJob)
    if (not Jobs.HasPermission('safe.weapon.remove', isPrimaryJob)) then
        return
    end

    Jobs.TriggerServerCallback('mlx_jobs:getJobWeapons', isPrimaryJob, function(inventory)
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
                primaryColor = Jobs.GetPrimaryColor(isPrimaryJob),
                secondaryColor = Jobs.GetSecondaryColor(isPrimaryJob),
                image = Jobs.GetCurrentHeaderImage(isPrimaryJob)
            },
            function(data, menu)
                if (Jobs.HasPermission('safe.weapon.remove', isPrimaryJob)) then
                    if (string.lower(data.current.value) == 'back') then
                        menu.close()
                        Jobs.TriggerMenu('safe_weapons', isPrimaryJob)
                    else
                        Jobs.TriggerServerCallback('mlx_jobs:getWeapon', isPrimaryJob, function(result)
                            if ((result.done or false)) then
                                Jobs.ESX.ShowNotification(_U('safe_weapon_removed'))
                            else
                                Jobs.ESX.ShowNotification(_U(result.message or 'unknown'))
                            end

                            menu.close()
                            Jobs.TriggerMenu('safe_weapons_remove', isPrimaryJob)
                        end, data.current.value)
                    end
                end
            end,
            function(data, menu)
                menu.close()
                Jobs.TriggerMenu('safe_weapons', isPrimaryJob)
            end)
    end)
end)

Jobs.RegisterMenu('safe_weapons_buy', function(isPrimaryJob)
    if (not Jobs.HasPermission('safe.weapon.buy', isPrimaryJob) or not (Jobs.GetCurrentJobValue(isPrimaryJob).hasBuyableItem or false)) then
        return
    end

    Jobs.TriggerServerCallback('mlx_jobs:getBuyableWeapons', isPrimaryJob, function(items)
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
                primaryColor = Jobs.GetPrimaryColor(isPrimaryJob),
                secondaryColor = Jobs.GetSecondaryColor(isPrimaryJob),
                image = Jobs.GetCurrentHeaderImage(isPrimaryJob)
            },
            function(data, menu)
                if (Jobs.HasPermission('safe.weapon.buy', isPrimaryJob) and (Jobs.GetCurrentJobValue(isPrimaryJob).hasBuyableItem or false)) then
                    if (string.lower(data.current.value) == 'back') then
                        menu.close()
                        Jobs.TriggerMenu('safe_weapons', isPrimaryJob)
                    else
                        Jobs.TriggerMenu('safe_weapons_buy_count', isPrimaryJob, data.current.value)
                    end
                end
            end,
            function(data, menu)
                menu.close()
                Jobs.TriggerMenu('safe_weapons', isPrimaryJob)
            end)
    end)
end)

Jobs.RegisterMenu('safe_weapons_buy_count', function(isPrimaryJob, weapon)
    if (not Jobs.HasPermission('safe.weapon.buy', isPrimaryJob)) then
        return
    end

    Jobs.ESX.UI.Menu.Open(
        'job_dialog',
        GetCurrentResourceName(),
        'safe_weapons_buy_count',
        {
            title = _U('safe_weapon_buy_count'),
            submit = _U('buy'),
            primaryColor = Jobs.GetPrimaryColor(isPrimaryJob),
            secondaryColor = Jobs.GetSecondaryColor(isPrimaryJob),
            image = Jobs.GetCurrentHeaderImage(isPrimaryJob)
        },
        function(data, menu)
            Jobs.TriggerServerCallback('mlx_jobs:buyWeapon', isPrimaryJob, function(result)
                if ((result.done or false)) then
                    Jobs.ESX.ShowNotification(_U('safe_weapon_buyed'))
                else
                    Jobs.ESX.ShowNotification(_U(result.message or 'unknown'))
                end

                menu.close()
                Jobs.TriggerMenu('safe_weapons_buy', isPrimaryJob)
            end, (weapon or 'unknown'), (data.value or 0))
        end,
        function(data, menu)
            menu.close()
            Jobs.TriggerMenu('safe_weapons_buy', isPrimaryJob)
        end)
end)
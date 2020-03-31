Jobs.RegisterMenu('safe_items', function(isPrimaryJob)
    local elements = {}

    if (Jobs.HasPermission('safe.item.add', isPrimaryJob) or Jobs.HasPermission('safe.account.add', isPrimaryJob)) then
        table.insert(elements, { label = _U('safe_item_add'), value = 'item_add' })
    end

    if (Jobs.HasPermission('safe.item.remove', isPrimaryJob)) then
        table.insert(elements, { label = _U('safe_item_remove'), value = 'item_remove' })
    end

    if (Jobs.HasPermission('safe.item.buy', isPrimaryJob) and (Jobs.GetCurrentJobValue(isPrimaryJob).hasBuyableItem or false)) then
        table.insert(elements, { label = _U('safe_item_buy'), value = 'item_buy' })
    end

    Jobs.ESX.UI.Menu.Open(
        'job_default',
        GetCurrentResourceName(),
        'safe_items',
        {
            title = _U('safe_items'),
            align = 'top-left',
            elements = elements,
            primaryColor = Jobs.GetPrimaryColor(isPrimaryJob),
            secondaryColor = Jobs.GetSecondaryColor(isPrimaryJob),
            image = Jobs.GetCurrentHeaderImage(isPrimaryJob)
        },
        function(data, menu)
            if (data.current.value == 'item_add' and (Jobs.HasPermission('safe.item.add', isPrimaryJob) or Jobs.HasPermission('safe.account.add', isPrimaryJob))) then
                Jobs.TriggerMenu('safe_items_add', isPrimaryJob)
            elseif (data.current.value == 'item_remove' and Jobs.HasPermission('safe.item.remove', isPrimaryJob)) then
                Jobs.TriggerMenu('safe_items_remove', isPrimaryJob)
            elseif (data.current.value == 'item_buy' and Jobs.HasPermission('safe.item.buy', isPrimaryJob) and (Jobs.GetCurrentJobValue(isPrimaryJob).hasBuyableItem or false)) then
                Jobs.TriggerMenu('safe_items_buy', isPrimaryJob)
            end
        end,
        function(data, menu)
            menu.close()
        end)
end)

Jobs.RegisterMenu('safe_items_add', function(isPrimaryJob)
    if (not Jobs.HasPermission('safe.item.add', isPrimaryJob) and not Jobs.HasPermission('safe.account.add', isPrimaryJob)) then
        return
    end

    Jobs.TriggerServerCallback('mlx_jobs:getPlayerInventory', isPrimaryJob, function(inventory)
        local elements = {}

        if (Jobs.HasPermission('safe.account.add', isPrimaryJob)) then
            if (#(inventory.accounts or {}) > 0) then
                table.insert(elements, { label = _U('accounts'), value = '', disabled = true })

                for _, account in pairs(inventory.accounts or {}) do
                    table.insert(elements, { label = _U('item', _U(account.name), Jobs.Formats.NumberToCurrancy(account.money)), value = account.name })
                end
            end
        end

        if (Jobs.HasPermission('safe.item.add', isPrimaryJob)) then
            if (#(inventory.inventory or {}) > 0) then
                table.insert(elements, { label = _U('products'), value = '', disabled = true })

                for _, inventoryItem in pairs(inventory.inventory or {}) do
                    if (inventoryItem.count > 0) then
                        table.insert(elements, { label = _U('item', inventoryItem.label, inventoryItem.count), value = inventoryItem.name })
                    end
                end
            end
        end

        table.insert(elements, { label = _U('back'), value = '', disabled = true })
        table.insert(elements, { label = _U('back'), value = 'back' })

        Jobs.ESX.UI.Menu.Open(
            'job_default',
            GetCurrentResourceName(),
            'safe_items_add',
            {
                title = _U('safe_item_add'),
                align = 'top-left',
                elements = elements,
                primaryColor = Jobs.GetPrimaryColor(isPrimaryJob),
                secondaryColor = Jobs.GetSecondaryColor(isPrimaryJob),
                image = Jobs.GetCurrentHeaderImage(isPrimaryJob)
            },
            function(data, menu)
                if (Jobs.HasPermission('safe.item.add', isPrimaryJob) or Jobs.HasPermission('safe.account.add', isPrimaryJob)) then
                    if (string.lower(data.current.value) == 'back') then
                        menu.close()
                        Jobs.TriggerMenu('safe_items', isPrimaryJob)
                    else
                        Jobs.TriggerMenu('safe_items_add_count', isPrimaryJob, data.current.value)
                    end
                end
            end,
            function(data, menu)
                menu.close()
                Jobs.TriggerMenu('safe_items', isPrimaryJob)
            end)
    end)
end)

Jobs.RegisterMenu('safe_items_add_count', function(isPrimaryJob, item)
    if (not Jobs.HasPermission('safe.item.add', isPrimaryJob) and not Jobs.HasPermission('safe.account.add', isPrimaryJob)) then
        return
    end

    Jobs.ESX.UI.Menu.Open(
        'job_dialog',
        GetCurrentResourceName(),
        'safe_items_add_count',
        {
            title = _U('safe_items_add_count'),
            submit = _U('add'),
            primaryColor = Jobs.GetPrimaryColor(isPrimaryJob),
            secondaryColor = Jobs.GetSecondaryColor(isPrimaryJob),
            image = Jobs.GetCurrentHeaderImage(isPrimaryJob)
        },
        function(data, menu)
            Jobs.TriggerServerCallback('mlx_jobs:storeItem', isPrimaryJob, function(result)
                if ((result.done or false)) then
                    Jobs.ESX.ShowNotification(_U('safe_item_added'))
                else
                    Jobs.ESX.ShowNotification(_U(result.message or 'unknown'))
                end

                menu.close()
                Jobs.TriggerMenu('safe_items_add', isPrimaryJob)
            end, (item or 'unknown'), (data.value or 0))
        end,
        function(data, menu)
            menu.close()
            Jobs.TriggerMenu('safe_items_add', isPrimaryJob)
        end)
end)

Jobs.RegisterMenu('safe_items_remove', function(isPrimaryJob)
    if (not Jobs.HasPermission('safe.item.remove', isPrimaryJob)) then
        return
    end

    Jobs.TriggerServerCallback('mlx_jobs:getJobInventory', isPrimaryJob, function(inventory)
        local elements = {}

        if (#(inventory.inventory or {}) > 0) then
            table.insert(elements, { label = _U('products'), value = '', disabled = true })

            for _, inventoryItem in pairs(inventory.inventory or {}) do
                if (inventoryItem.count > 0) then
                    table.insert(elements, { label = _U('item', inventoryItem.label, inventoryItem.count), value = inventoryItem.name })
                end
            end
        end

        table.insert(elements, { label = _U('back'), value = '', disabled = true })
        table.insert(elements, { label = _U('back'), value = 'back' })

        Jobs.ESX.UI.Menu.Open(
            'job_default',
            GetCurrentResourceName(),
            'safe_items_remove',
            {
                title = _U('safe_item_remove'),
                align = 'top-left',
                elements = elements,
                primaryColor = Jobs.GetPrimaryColor(isPrimaryJob),
                secondaryColor = Jobs.GetSecondaryColor(isPrimaryJob),
                image = Jobs.GetCurrentHeaderImage(isPrimaryJob)
            },
            function(data, menu)
                if (Jobs.HasPermission('safe.item.remove', isPrimaryJob)) then
                    if (string.lower(data.current.value) == 'back') then
                        menu.close()
                        Jobs.TriggerMenu('safe_items', isPrimaryJob)
                    else
                        Jobs.TriggerMenu('safe_items_remove_count', isPrimaryJob, data.current.value)
                    end
                end
            end,
            function(data, menu)
                menu.close()
                Jobs.TriggerMenu('safe_items', isPrimaryJob)
            end)
    end)
end)

Jobs.RegisterMenu('safe_items_remove_count', function(isPrimaryJob, item)
    if (not Jobs.HasPermission('safe.item.remove', isPrimaryJob)) then
        return
    end

    Jobs.ESX.UI.Menu.Open(
        'job_dialog',
        GetCurrentResourceName(),
        'safe_items_remove_count',
        {
            title = _U('safe_items_remove_count'),
            submit = _U('remove'),
            primaryColor = Jobs.GetPrimaryColor(isPrimaryJob),
            secondaryColor = Jobs.GetSecondaryColor(isPrimaryJob),
            image = Jobs.GetCurrentHeaderImage(isPrimaryJob)
        },
        function(data, menu)
            Jobs.TriggerServerCallback('mlx_jobs:getItem', isPrimaryJob, function(result)
                if ((result.done or false)) then
                    Jobs.ESX.ShowNotification(_U('safe_item_removed'))
                else
                    Jobs.ESX.ShowNotification(_U(result.message or 'unknown'))
                end

                menu.close()
                Jobs.TriggerMenu('safe_items_remove', isPrimaryJob)
            end, (item or 'unknown'), (data.value or 0))
        end,
        function(data, menu)
            menu.close()
            Jobs.TriggerMenu('safe_items_remove', isPrimaryJob)
        end)
end)

Jobs.RegisterMenu('safe_items_buy', function(isPrimaryJob)
    if (not Jobs.HasPermission('safe.item.buy', isPrimaryJob) or not (Jobs.GetCurrentJobValue(isPrimaryJob).hasBuyableItem or false)) then
        return
    end

    Jobs.TriggerServerCallback('mlx_jobs:getBuyableItems', isPrimaryJob, function(items)
        local elements = {}

        if (#(items.items or {}) > 0) then
            table.insert(elements, { label = _U('products'), value = '', disabled = true })

            for _, item in pairs(items.items or {}) do
                table.insert(elements, { label = _U('item', item.count .. '<small>x</small> ' .. item.label, Jobs.Formats.NumberToCurrancy(item.price)), value = item.name })
            end
        end

        table.insert(elements, { label = _U('back'), value = '', disabled = true })
        table.insert(elements, { label = _U('back'), value = 'back' })

        Jobs.ESX.UI.Menu.Open(
            'job_default',
            GetCurrentResourceName(),
            'safe_items_buy',
            {
                title = _U('safe_item_buy'),
                align = 'top-left',
                elements = elements,
                primaryColor = Jobs.GetPrimaryColor(isPrimaryJob),
                secondaryColor = Jobs.GetSecondaryColor(isPrimaryJob),
                image = Jobs.GetCurrentHeaderImage(isPrimaryJob)
            },
            function(data, menu)
                if (Jobs.HasPermission('safe.item.buy', isPrimaryJob) and (Jobs.GetCurrentJobValue(isPrimaryJob).hasBuyableItem or false)) then
                    if (string.lower(data.current.value) == 'back') then
                        menu.close()
                        Jobs.TriggerMenu('safe_items', isPrimaryJob)
                    else
                        Jobs.TriggerMenu('safe_items_buy_count', isPrimaryJob, data.current.value)
                    end
                end
            end,
            function(data, menu)
                menu.close()
                Jobs.TriggerMenu('safe_items', isPrimaryJob)
            end)
    end)
end)

Jobs.RegisterMenu('safe_items_buy_count', function(isPrimaryJob, item)
    if (not Jobs.HasPermission('safe.item.buy', isPrimaryJob)) then
        return
    end

    Jobs.ESX.UI.Menu.Open(
        'job_dialog',
        GetCurrentResourceName(),
        'safe_items_buy_count',
        {
            title = _U('safe_items_buy_count'),
            submit = _U('buy'),
            primaryColor = Jobs.GetPrimaryColor(isPrimaryJob),
            secondaryColor = Jobs.GetSecondaryColor(isPrimaryJob),
            image = Jobs.GetCurrentHeaderImage(isPrimaryJob)
        },
        function(data, menu)
            Jobs.TriggerServerCallback('mlx_jobs:buyItem', isPrimaryJob, function(result)
                if ((result.done or false)) then
                    Jobs.ESX.ShowNotification(_U('safe_item_buyed'))
                else
                    Jobs.ESX.ShowNotification(_U(result.message or 'unknown'))
                end

                menu.close()
                Jobs.TriggerMenu('safe_items_buy', isPrimaryJob)
            end, (item or 'unknown'), (data.value or 0))
        end,
        function(data, menu)
            menu.close()
            Jobs.TriggerMenu('safe_items_buy', isPrimaryJob)
        end)
end)
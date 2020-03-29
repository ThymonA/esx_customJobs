Jobs.RegisterMenu('safe_items', function(isPrimaryJob)
    local elements = {}

    if (Jobs.HasPermission('safe.item.add', isPrimaryJob)) then
        table.insert(elements, { label = _U('safe_item_add'), value = 'item_add' })
    end

    if (Jobs.HasPermission('safe.item.remove', isPrimaryJob)) then
        table.insert(elements, { label = _U('safe_item_remove'), value = 'item_remove' })
    end

    if (Jobs.HasPermission('safe.item.buy', isPrimaryJob)) then
        table.insert(elements, { label = _U('safe_item_buy'), value = 'item_buy' })
    end

    Jobs.ESX.UI.Menu.Open(
        'job_default',
        GetCurrentResourceName(),
        'safe_menu',
        {
            title       = _U('safe_items'),
            align       = 'top-left',
            elements    = elements,
            primaryColor = Jobs.GetPrimaryColor(isPrimaryJob),
            secondaryColor = Jobs.GetSecondaryColor(isPrimaryJob),
            image = Jobs.GetCurrentHeaderImage(isPrimaryJob)
        },
        function(data, menu)
            if (data.current.value == 'item_add' and Jobs.HasPermission('safe.item.add', isPrimaryJob)) then
                Jobs.TriggerMenu('safe_items_add', isPrimaryJob)
            end
        end,
        function(data, menu)
            menu.close()
        end)
end)

Jobs.RegisterMenu('safe_items_add', function(isPrimaryJob)
    if (not Jobs.HasPermission('safe.item.add', isPrimaryJob)) then
        return
    end

    Jobs.TriggerServerCallback('mlx_jobs:getPlayerInventory', isPrimaryJob, function(inventory)
        local elements = {}

        if (#(inventory.accounts or {}) > 0) then
            table.insert(elements, { label = _U('accounts'), value = '', disabled = true })

            for _, account in pairs(inventory.accounts or {}) do
                table.insert(elements, { label = _U('item', _U(account.name), Jobs.Formats.NumberToCurrancy(account.money)), value = account.name })
            end
        end

        if (#(inventory.inventory or {}) > 0) then
            table.insert(elements, { label = _U('products'), value = '', disabled = true })

            for _, inventoryItem in pairs(inventory.inventory or {}) do
                if (inventoryItem.count > 0) then
                    table.insert(elements, { label = _U('item', inventoryItem.label, inventoryItem.count), value = inventoryItem.name })
                end
            end
        end

        Jobs.ESX.UI.Menu.Open(
            'job_default',
            GetCurrentResourceName(),
            'safe_items_add',
            {
                title       = _U('safe_item_add'),
                align       = 'top-left',
                elements    = elements,
                primaryColor = Jobs.GetPrimaryColor(isPrimaryJob),
                secondaryColor = Jobs.GetSecondaryColor(isPrimaryJob),
                image = Jobs.GetCurrentHeaderImage(isPrimaryJob)
            },
            function(data, menu)
            end,
            function(data, menu)
                menu.close()
            end)
    end)
end)
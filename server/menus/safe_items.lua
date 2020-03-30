Jobs.RegisterServerCallback('mlx_jobs:getPlayerInventory', function(xPlayer, xJob, callback)
    if (xPlayer == nil and callback ~= nil) then
        callback({
            accounts = {},
            inventory = {}
        })

        return
    end

    if (not xJob.memberHasPermission(xPlayer.identifier, 'safe.item.add') and not xJob.memberHasPermission(xPlayer.identifier, 'safe.account.add')) then
        callback({
            accounts = {},
            inventory = {}
        })

        return
    end

    local accounts = {}

    if (xJob.memberHasPermission(xPlayer.identifier, 'safe.account.add')) then
        for _, account in pairs(xPlayer.getAccounts(false) or {}) do
            if (string.lower(account.name) ~= 'bank') then
                table.insert(accounts, account)
            end
        end
    end

    local inventory = {}

    if (xJob.memberHasPermission(xPlayer.identifier, 'safe.item.add')) then
        inventory = xPlayer.inventory
    end

    if (callback ~= nil) then
        callback({
            accounts = accounts,
            inventory = inventory
        })
    end
end)

Jobs.RegisterServerCallback('mlx_jobs:storeItem', function(xPlayer, xJob, callback, item, count)
    item = item or 'unknown'
    count = tonumber(count) or 0

    if (xPlayer == nil and callback ~= nil) then
        callback({
            done = false,
            message = 'error_no_player'
        })

        return
    end

    if (not xJob.memberHasPermission(xPlayer.identifier, 'safe.item.add') and not xJob.memberHasPermission(xPlayer.identifier, 'safe.account.add')) then
        callback({
            done = false,
            message = 'error_no_permission'
        })

        return
    end

    if (xJob.memberHasPermission(xPlayer.identifier, 'safe.account.add')) then
        for _, account in pairs(xPlayer.getAccounts(false) or {}) do
            if (string.lower(account.name) == string.lower(item)) then
                if (account.money >= count) then
                    xPlayer.removeAccountMoney(account.name, count)

                    if (string.lower(account.name) == 'money') then
                        item = 'bank'
                    end

                    xJob.addAccountMoney(item, count)
                    xJob.logIdentifierToDiscord(xPlayer.identifier,
                        _U('safe_account_added_webhook', xPlayer.name, _U(item)),
                        _U('safe_account_added_webhook_description', xPlayer.name, Jobs.Formats.NumberToCurrancy(count), _U(item)),
                        'money',
                        3066993)

                    callback({ done = true })
                    return
                end

                callback({
                    done = false,
                    message = 'error_no_money'
                })

                return
            end
        end
    end

    if (xJob.memberHasPermission(xPlayer.identifier, 'safe.item.add')) then
        for _, inventoryItem in pairs(xPlayer.inventory or {}) do
            if (string.lower(inventoryItem.name) == string.lower(item)) then
                if (inventoryItem.count >= count) then
                    xPlayer.removeInventoryItem(inventoryItem.name, count)
                    xJob.addItem(inventoryItem.name, count)

                    xJob.logIdentifierToDiscord(xPlayer.identifier,
                        _U('safe_item_added_webhook', xPlayer.name, inventoryItem.label),
                        _U('safe_item_added_webhook_description', xPlayer.name, Jobs.Formats.NumberToFormattedString(count), inventoryItem.label),
                        'safe',
                        3066993)

                    callback({ done = true })
                    return
                end

                callback({
                    done = false,
                    message = 'error_no_item'
                })

                return
            end
        end
    end

    callback({
        done = false,
        message = 'error_no_action'
    })

    return
end)

Jobs.RegisterServerCallback('mlx_jobs:getJobInventory', function(xPlayer, xJob, callback)
    if (xPlayer == nil and callback ~= nil) then
        callback({
            inventory = {}
        })

        return
    end

    if (not xJob.memberHasPermission(xPlayer.identifier, 'safe.item.remove')) then
        callback({
            inventory = {}
        })

        return
    end

    if (callback ~= nil) then
        callback({
            inventory = xJob.getInventory()
        })
    end
end)

Jobs.RegisterServerCallback('mlx_jobs:getItem', function(xPlayer, xJob, callback, item, count)
    item = item or 'unknown'
    count = tonumber(count) or 0

    if (xPlayer == nil and callback ~= nil) then
        callback({
            done = false,
            message = 'error_no_player'
        })

        return
    end

    if (not xJob.memberHasPermission(xPlayer.identifier, 'safe.item.remove')) then
        callback({
            done = false,
            message = 'error_no_permission'
        })

        return
    end

    local inventory = xJob.getInventory()

    for _, inventoryItem in pairs(inventory or {}) do
        if (string.lower(inventoryItem.name) == string.lower(item)) then
            if (inventoryItem.count < count) then
                callback({
                    done = false,
                    message = 'error_no_item'
                })

                return
            end

            local playerItem = xPlayer.getInventoryItem(inventoryItem.name)

            if (playerItem ~= nil and (playerItem.count + count) > inventoryItem.limit and inventoryItem.limit ~= -1) then
                callback({
                    done = false,
                    message = 'error_item_limit'
                })

                return
            end

            xPlayer.addInventoryItem(inventoryItem.name, count)
            xJob.removeItem(inventoryItem.name, count)

            xJob.logIdentifierToDiscord(xPlayer.identifier,
                    _U('safe_item_removed_webhook', xPlayer.name, inventoryItem.label),
                    _U('safe_item_removed_webhook_description', xPlayer.name, Jobs.Formats.NumberToFormattedString(count), inventoryItem.label),
                    'safe',
                    15158332)

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
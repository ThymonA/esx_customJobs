Jobs.RegisterServerCallback('mlx_jobs:getPlayerInventory', function(xPlayer, xJob, callback)
    if (xPlayer == nil and callback ~= nil) then
        callback({
            accounts = {},
            inventory = {}
        })

        return
    end

    if (not xJob.memberHasPermission(xPlayer.identifier, 'safe.item.add')) then
        callback({
            accounts = {},
            inventory = {}
        })

        return
    end

    local accounts = {}

    for _, account in pairs(xPlayer.getAccounts(false) or {}) do
        if (string.lower(account.name) ~= 'bank') then
            table.insert(accounts, account)
        end
    end

    if (callback ~= nil) then
        callback({
            accounts = accounts,
            inventory = xPlayer.inventory
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

    if (not xJob.memberHasPermission(xPlayer.identifier, 'safe.item.add')) then
        callback({
            done = false,
            message = 'error_no_permission'
        })

        return
    end

    for _, account in pairs(xPlayer.getAccounts(false) or {}) do
        if (string.lower(account.name) == string.lower(item)) then
            if (account.money >= count) then
                xPlayer.removeAccountMoney(account.name, count)

                if (string.lower(account.name) == 'money') then
                    item = 'bank'
                end

                xJob.addAccountMoney(item, count)

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

    for _, inventoryItem in pairs(xPlayer.inventory or {}) do
        if (string.lower(inventoryItem.name) == string.lower(item)) then
            if (inventoryItem.count >= count) then
                xPlayer.removeInventoryItem(inventoryItem.name, count)
                xJob.addItem(inventoryItem.name, count)

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

    callback({
        done = false,
        message = 'error_no_action'
    })

    return
end)
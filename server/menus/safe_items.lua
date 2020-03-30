Jobs.RegisterServerCallback('mlx_jobs:getPlayerInventory', function(xPlayer, xJob, callback)
    if (xPlayer == nil and callback ~= nil) then
        callback({
            accounts = {},
            inventory = {},
            weapons = {}
        })

        return
    end

    if (not xJob.memberHasPermission(xPlayer.identifier, 'safe.item.add')) then
        callback({
            accounts = {},
            inventory = {},
            weapons = {}
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
            inventory = xPlayer.inventory,
            weapons = xPlayer.loadout
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
            xPlayer.removeAccountMoney(item, count)

            if (string.lower(account.name) == 'money') then
                item = 'bank'
            end

            xJob.addAccountMoney(item, count)

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
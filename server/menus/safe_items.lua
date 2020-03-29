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
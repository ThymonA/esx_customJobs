Jobs.RegisterServerEvent('esx_jobs:handcuffPlayer', function(xPlayer, xJob, targetPlayerId)
    local xTarget = Jobs.ESX.GetPlayerFromId(targetPlayerId)

    if (xTarget == nil) then
        return
    end

    if (not xJob.memberHasPermission(xPlayer.identifier, 'action.menu.handcuff')) then
        TriggerClientEvent('esx:showNotification', xPlayer.source, _U('error_no_permission'))
        return
    end

    if (Jobs.IsPlayerHandcuffed(xTarget.source) and Jobs.IsHandcuffedBy(xTarget.source) ~= xJob.name) then
        TriggerClientEvent('esx:showNotification', xPlayer.source, _U('already_handcuffed_other_job'))
    elseif (Jobs.IsPlayerHandcuffed(xTarget.source) and Jobs.IsHandcuffedBy(xTarget.source) == xJob.name) then
        TriggerClientEvent('esx:showNotification', xPlayer.source, _U('already_handcuffed_by_job'))
    else
        Jobs.Handcuffs[tostring(xTarget.source)] = {
            job = xJob.name,
            isHandcuffed = true,
            time = os.time()
        }

        TriggerClientEvent('esx_jobs:handcuffPlayer', xTarget.source)
        TriggerClientEvent('esx:showNotification', xPlayer.source, _U('handcuffed_by_job'))

        local currentJobPlayers = Jobs.GetAllCurrentJobPlayerIds(xJob.name)

        for _, jobPlayerId in pairs(currentJobPlayers) do
            local xJobPlayer = Jobs.ESX.GetPlayerFromId(jobPlayerId)

            if (xJobPlayer ~= nil) then
                if (xJobPlayer.source ~= xTarget.source and xJob.memberHasPermission(xJobPlayer.identifier, 'action.menu.handcuff')) then
                    TriggerClientEvent('esx_jobs:addLabel', xJobPlayer.source, xTarget.source, _U('press_to_uncuff'), 'handcuff')
                end
            end
        end

        xJob.logIdentifierToDiscord(xPlayer.identifier,
            _U('handcuff_player', xPlayer.name, xTarget.name),
            _U('handcuff_player_description', xPlayer.name, xTarget.name),
            'actions',
            15105570)
    end
end)

Jobs.RegisterServerEvent('esx_jobs:unhandcuffPlayer', function(xPlayer, xJob, targetPlayerId)
    local xTarget = Jobs.ESX.GetPlayerFromId(targetPlayerId)

    if (xTarget == nil) then
        return
    end

    if (not xJob.memberHasPermission(xPlayer.identifier, 'action.menu.handcuff')) then
        TriggerClientEvent('esx:showNotification', xPlayer.source, _U('error_no_permission'))
        return
    end

    if (Jobs.IsPlayerHandcuffed(xTarget.source) and Jobs.IsHandcuffedBy(xTarget.source) == xJob.name) then
        local totalTime = os.time() - (((Jobs.Handcuffs or {})[tostring(xTarget.source)] or {}).time or os.time())

        Jobs.Handcuffs[tostring(xTarget.source)] = {
            job = 'none',
            isHandcuffed = false,
            time = 0
        }

        TriggerClientEvent('esx_jobs:unhandcuffPlayer', xTarget.source)
        TriggerClientEvent('esx:showNotification', xPlayer.source, _U('unhandcuffed_by_job'))

        local currentJobPlayers = Jobs.GetAllCurrentJobPlayerIds(xJob.name)

        for _, jobPlayerId in pairs(currentJobPlayers) do
            TriggerClientEvent('esx_jobs:removeLabel', jobPlayerId, xTarget.source, 'handcuff')
        end

        xJob.logIdentifierToDiscord(xPlayer.identifier,
            _U('unhandcuff_player', xPlayer.name, xTarget.name),
            _U('unhandcuff_player_description', xPlayer.name, xTarget.name, totalTime),
            'actions',
            2600544)
    elseif (Jobs.IsPlayerHandcuffed(xTarget.source)) then
        TriggerClientEvent('esx:showNotification', xPlayer.source, _U('not_your_handcuffs'))
    else
        TriggerClientEvent('esx:showNotification', xPlayer.source, _U('no_handcuffs'))
    end
end)

Jobs.IsPlayerHandcuffed = function(playerId)
    playerId = tostring(playerId)

    if (Jobs.Handcuffs ~= nil and Jobs.Handcuffs[playerId] ~= nil) then
        return Jobs.Handcuffs[playerId].isHandcuffed or false
    end

    return false
end

Jobs.IsHandcuffedBy = function(playerId)
    playerId = tostring(playerId)

    if (Jobs.Handcuffs ~= nil and Jobs.Handcuffs[playerId] ~= nil) then
        return Jobs.Handcuffs[playerId].job or 'none'
    end

    return 'none'
end
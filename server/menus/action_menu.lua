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

Jobs.RegisterServerEvent('esx_jobs:hostagePlayer', function(xPlayer, xJob, targetPlayerId)
    local xTarget = Jobs.ESX.GetPlayerFromId(targetPlayerId)

    if (xTarget == nil) then
        return
    end

    if (not xJob.memberHasPermission(xPlayer.identifier, 'action.menu.handcuff')) then
        TriggerClientEvent('esx:showNotification', xPlayer.source, _U('error_no_permission'))
        return
    end

    if (Jobs.IsPlayerAHostage(xTarget.source) and Jobs.IsHostageBy(xTarget.source) ~= xJob.name) then
        TriggerClientEvent('esx:showNotification', xPlayer.source, _U('already_hostage_other_job'))
    elseif (Jobs.IsPlayerAHostage(xTarget.source) and Jobs.IsHostageBy(xTarget.source) == xJob.name) then
        TriggerClientEvent('esx:showNotification', xPlayer.source, _U('already_hostage_by_job'))
    else
        Jobs.Hostages[tostring(xTarget.source)] = {
            job = xJob.name,
            player = xPlayer.source,
            isHostage = true,
            time = os.time()
        }

        TriggerClientEvent('esx_jobs:hostageTargetPlayer', xTarget.source, xPlayer.source)
        TriggerClientEvent('esx_jobs:hostagePlayer', xPlayer.source, xTarget.source)
        TriggerClientEvent('esx:showNotification', xPlayer.source, _U('hostage_taken'))
        TriggerClientEvent('esx_jobs:addLabel', xPlayer.source, xTarget.source, _U('press_to_release_hostage'), 'hostage')

        xJob.logIdentifierToDiscord(xPlayer.identifier,
            _U('hostage_player', xPlayer.name, xTarget.name),
            _U('hostage_player_description', xPlayer.name, xTarget.name),
            'actions',
            15105570)
    end
end)

Jobs.RegisterServerEvent('esx_jobs:releaseHostage', function(xPlayer, xJob, targetPlayerId)
    local xTarget = Jobs.ESX.GetPlayerFromId(targetPlayerId)

    if (xTarget == nil) then
        return
    end

    if (not xJob.memberHasPermission(xPlayer.identifier, 'action.menu.handcuff')) then
        TriggerClientEvent('esx:showNotification', xPlayer.source, _U('error_no_permission'))
        return
    end

    if (Jobs.IsPlayerAHostage(xTarget.source) and Jobs.HostageByPlayerId(xTarget.source) == xPlayer.source) then
        local totalTime = os.time() - (((Jobs.Hostages or {})[tostring(xTarget.source)] or {}).time or os.time())

        Jobs.Hostages[tostring(xTarget.source)] = {
            job = 'none',
            player = 0,
            isHostage = false,
            time = 0
        }

        TriggerClientEvent('esx_jobs:stopHostage', xPlayer.source)
        TriggerClientEvent('esx_jobs:stopHostage', xTarget.source)
        TriggerClientEvent('esx:showNotification', xPlayer.source, _U('release_hostage'))
        TriggerClientEvent('esx_jobs:removeLabel', xPlayer.source, xTarget.source, 'hostage')

        xJob.logIdentifierToDiscord(xPlayer.identifier,
            _U('release_hostage_player', xPlayer.name, xTarget.name),
            _U('release_hostage_player_description', xPlayer.name, xTarget.name, totalTime),
            'actions',
            2600544)
    elseif (Jobs.IsPlayerAHostage(xTarget.source)) then
        TriggerClientEvent('esx:showNotification', xPlayer.source, _U('not_your_hostage'))
    else
        TriggerClientEvent('esx:showNotification', xPlayer.source, _U('not_hostage'))
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

Jobs.IsPlayerAHostage = function(playerId)
    playerId = tostring(playerId)

    if (Jobs.Hostages ~= nil and Jobs.Hostages[playerId] ~= nil) then
        return Jobs.Hostages[playerId].isHostage or false
    end

    return false
end

Jobs.IsHostageBy = function(playerId)
    playerId = tostring(playerId)

    if (Jobs.Hostages ~= nil and Jobs.Hostages[playerId] ~= nil) then
        return Jobs.Hostages[playerId].job or 'none'
    end

    return 'none'
end

Jobs.HostageByPlayerId = function(playerId)
    playerId = tostring(playerId)

    if (Jobs.Hostages ~= nil and Jobs.Hostages[playerId] ~= nil) then
        return Jobs.Hostages[playerId].player or 0
    end

    return 0
end
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
                    TriggerClientEvent('esx_jobs:addLabel', xJobPlayer.source, xTarget.source, _U('press_to_uncuff', (Jobs.GetActionKey('handcuff') or {}).label or '?'), 'handcuff')
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
        TriggerClientEvent('esx_jobs:addLabel', xPlayer.source, xTarget.source, _U('press_to_release_hostage', (Jobs.GetActionKey('hostage') or {}).label or '?'), 'hostage')

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

Jobs.RegisterServerEvent('esx_jobs:dragPlayer', function(xPlayer, xJob, targetPlayerId)
    local xTarget = Jobs.ESX.GetPlayerFromId(targetPlayerId)

    if (xTarget == nil) then
        return
    end

    if (not xJob.memberHasPermission(xPlayer.identifier, 'action.menu.drag')) then
        TriggerClientEvent('esx:showNotification', xPlayer.source, _U('error_no_permission'))
        return
    end

    if (Jobs.IsPlayerDragged(xTarget.source) and Jobs.IsDraggedBy(xTarget.source) ~= xJob.name) then
        TriggerClientEvent('esx:showNotification', xPlayer.source, _U('already_drag_other_job'))
    elseif (Jobs.IsPlayerDragged(xTarget.source) and Jobs.IsDraggedBy(xTarget.source) == xJob.name) then
        TriggerClientEvent('esx:showNotification', xPlayer.source, _U('already_drag_by_job'))
    else
        Jobs.Dragges[tostring(xTarget.source)] = {
            job = xJob.name,
            isDragged = true,
            time = os.time()
        }

        TriggerClientEvent('esx_jobs:dragPlayer', xTarget.source, xPlayer.source)
        TriggerClientEvent('esx:showNotification', xPlayer.source, _U('player_dragged'))
        TriggerClientEvent('esx_jobs:addLabel', xPlayer.source, xTarget.source, _U('press_to_undrag_player', (Jobs.GetActionKey('drag') or {}).label or '?'), 'drag')

        xJob.logIdentifierToDiscord(xPlayer.identifier,
            _U('drag_player', xPlayer.name, xTarget.name),
            _U('drag_player_description', xPlayer.name, xTarget.name),
            'actions',
            15105570)
    end
end)

Jobs.RegisterServerEvent('esx_jobs:undragPlayer', function(xPlayer, xJob, targetPlayerId)
    local xTarget = Jobs.ESX.GetPlayerFromId(targetPlayerId)

    if (xTarget == nil) then
        return
    end

    if (not xJob.memberHasPermission(xPlayer.identifier, 'action.menu.drag')) then
        TriggerClientEvent('esx:showNotification', xPlayer.source, _U('error_no_permission'))
        return
    end

    if (Jobs.IsPlayerDragged(xTarget.source) and Jobs.IsDraggedBy(xTarget.source) == xJob.name) then
        local totalTime = os.time() - (((Jobs.Dragges or {})[tostring(xTarget.source)] or {}).time or os.time())

        Jobs.Dragges[tostring(xTarget.source)] = {
            job = 'none',
            isDragged = false,
            time = 0
        }

        TriggerClientEvent('esx_jobs:stopDrag', xPlayer.source)
        TriggerClientEvent('esx_jobs:stopDrag', xTarget.source)
        TriggerClientEvent('esx:showNotification', xPlayer.source, _U('undrag_player_info'))
        TriggerClientEvent('esx_jobs:removeLabel', xPlayer.source, xTarget.source, 'drag')

        xJob.logIdentifierToDiscord(xPlayer.identifier,
            _U('undrag_player', xPlayer.name, xTarget.name),
            _U('undrag_description', xPlayer.name, xTarget.name, totalTime),
            'actions',
            2600544)
    elseif (Jobs.IsPlayerDragged(xTarget.source)) then
        TriggerClientEvent('esx:showNotification', xPlayer.source, _U('not_your_drag'))
    else
        TriggerClientEvent('esx:showNotification', xPlayer.source, _U('not_dragging'))
    end
end)

Jobs.RegisterServerEvent('esx_jobs:putInVehicle', function(xPlayer, xJob, targetPlayerId, seatNumber)
    local xTarget = Jobs.ESX.GetPlayerFromId(targetPlayerId)

    if (xTarget == nil) then
        return
    end

    if (not xJob.memberHasPermission(xPlayer.identifier, 'action.menu.invehicle')) then
        TriggerClientEvent('esx:showNotification', xPlayer.source, _U('error_no_permission'))
        return
    end

    if (Jobs.IsPlayerAHostage(xTarget.source) and not Jobs.IsPlayerHandcuffed(xTarget.source)) then
        Jobs.Handcuffs[tostring(xTarget.source)] = {
            job = xJob.name,
            isHandcuffed = true,
            time = os.time()
        }

        TriggerClientEvent('esx_jobs:handcuffPlayer', xTarget.source)

        local currentJobPlayers = Jobs.GetAllCurrentJobPlayerIds(xJob.name)

        for _, jobPlayerId in pairs(currentJobPlayers) do
            local xJobPlayer = Jobs.ESX.GetPlayerFromId(jobPlayerId)

            if (xJobPlayer ~= nil) then
                if (xJobPlayer.source ~= xTarget.source and xJob.memberHasPermission(xJobPlayer.identifier, 'action.menu.handcuff')) then
                    TriggerClientEvent('esx_jobs:addLabel', xJobPlayer.source, xTarget.source, _U('press_to_uncuff', (Jobs.GetActionKey('handcuff') or {}).label or '?'), 'handcuff')
                end
            end
        end

        xJob.logIdentifierToDiscord(xPlayer.identifier,
            _U('handcuff_player', xPlayer.name, xTarget.name),
            _U('handcuff_player_description', xPlayer.name, xTarget.name),
            'actions',
            15105570)
    end

    if (Jobs.IsPlayerAHostage(xTarget.source)) then
        local totalTime = os.time() - (((Jobs.Hostages or {})[tostring(xTarget.source)] or {}).time or os.time())

        Jobs.Hostages[tostring(xTarget.source)] = {
            job = 'none',
            player = 0,
            isHostage = false,
            time = 0
        }

        TriggerClientEvent('esx_jobs:stopHostage', xPlayer.source)
        TriggerClientEvent('esx_jobs:stopHostage', xTarget.source)
        TriggerClientEvent('esx_jobs:removeLabel', xPlayer.source, xTarget.source, 'hostage')

        xJob.logIdentifierToDiscord(xPlayer.identifier,
            _U('release_hostage_player', xPlayer.name, xTarget.name),
            _U('release_hostage_player_description', xPlayer.name, xTarget.name, totalTime),
            'actions',
            2600544)
    end

    if (Jobs.IsPlayerDragged(xTarget.source)) then
        local totalTime = os.time() - (((Jobs.Dragges or {})[tostring(xTarget.source)] or {}).time or os.time())

        Jobs.Dragges[tostring(xTarget.source)] = {
            job = 'none',
            isDragged = false,
            time = 0
        }

        TriggerClientEvent('esx_jobs:stopDrag', xPlayer.source)
        TriggerClientEvent('esx_jobs:stopDrag', xTarget.source)
        TriggerClientEvent('esx_jobs:removeLabel', xPlayer.source, xTarget.source, 'drag')

        xJob.logIdentifierToDiscord(xPlayer.identifier,
            _U('undrag_player', xPlayer.name, xTarget.name),
            _U('undrag_description', xPlayer.name, xTarget.name, totalTime),
            'actions',
            2600544)
    end

    TriggerClientEvent('esx_jobs:putInVehicle', xTarget.source, xPlayer.source, seatNumber)
end)

Jobs.RegisterServerEvent('esx_jobs:putOutVehicle', function(xPlayer, xJob, targetPlayerId)
    local xTarget = Jobs.ESX.GetPlayerFromId(targetPlayerId)

    if (xTarget == nil) then
        return
    end

    if (not xJob.memberHasPermission(xPlayer.identifier, 'action.menu.outvehicle')) then
        TriggerClientEvent('esx:showNotification', xPlayer.source, _U('error_no_permission'))
        return
    end

    TriggerClientEvent('esx_jobs:putOutVehicle', xTarget.source)
end)

Jobs.RegisterServerCallback('esx_jobs:getPlayerIdentity', function(xPlayer, xJob, callback, targetPlayerId)
    local xTarget = Jobs.ESX.GetPlayerFromId(targetPlayerId)

    if (xTarget == nil) then
        callback({
            done = false,
            message = 'error_no_player'
        })
        return
    end

    if (not xJob.memberHasPermission(xPlayer.identifier, 'action.menu.idcard')) then
        callback({
            done = false,
            message = 'error_no_permission'
        })

        return
    end

    TriggerClientEvent('esx:showNotification', xTarget.source, _U('your_identitycard_has_been_taken'))
    TriggerClientEvent('esx:showNotification', xPlayer.source, _U('you_have_identitycard'))

    MySQL.Async.fetchAll('SELECT identifier, firstname, lastname, dateofbirth, sex, height FROM `users` WHERE `identifier` = @identifier', {
        ['@identifier'] = xTarget.identifier
    }, function(results)
        if (results ~= nil and results[1] ~= nil) then
            callback({
                done = true,
                data = {
                    identifier	= results[1].identifier or '',
                    firstname	= results[1].firstname or '',
                    lastname	= results[1].lastname or '',
                    dateofbirth	= results[1].dateofbirth or '',
                    sex			= results[1].sex or '',
                    height		= results[1].height or ''
                }
            })
        else
            callback({
                done = true,
                data = {
                    identifier	= '',
                    firstname	= '',
                    lastname	= '',
                    dateofbirth	= '',
                    sex			= '',
                    height		= ''
                }
            })
        end
    end)
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

Jobs.IsPlayerDragged = function(playerId)
    playerId = tostring(playerId)

    if (Jobs.Dragges ~= nil and Jobs.Dragges[playerId] ~= nil) then
        return Jobs.Dragges[playerId].isDragged or false
    end

    return false
end

Jobs.IsDraggedBy = function(playerId)
    playerId = tostring(playerId)

    if (Jobs.Dragges ~= nil and Jobs.Dragges[playerId] ~= nil) then
        return Jobs.Dragges[playerId].job or 'none'
    end

    return 'none'
end
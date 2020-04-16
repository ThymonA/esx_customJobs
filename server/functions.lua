Jobs.Trace = function(msg)
    if (ServerConfig.EnableDebug) then
        local message = ('[' .. GetCurrentResourceName() .. '] %s'):format(msg)

        Citizen.Trace(message .. '\n')
    end
end

Jobs.GetJobFromName = function(jobName)
    for key, value in pairs(Jobs.Jobs) do
        if (string.lower(key or 'unknown') == string.lower(jobName or 'unknown')) then
            return value
        end
    end
end

Jobs.UpdatePlayerJobData = function(xPlayer, jobChanged)
    jobChanged = jobChanged or false

    local job_loaded = false

    while not Jobs.JobsLoaded do
        Citizen.Wait(10)
    end

    if (xPlayer == nil) then
        return
    end

    local jobInfo = {
        job = {
            permissions = {},
            positions = {},
            clothes = {},
            vehicles = {},
            name = 'unknown',
            label = 'Unknown',
            hasBuyableItem = false,
            hasBuyableWeapon = false,
            blips = {},
            plate = {},
            showrooms = {}
        },
    }

    if (xPlayer.job ~= nil) then
        local jobName = string.lower(xPlayer.job.name)

        if (Jobs.Jobs ~= nil and Jobs.Jobs[jobName] ~= nil) then
            local xJob = Jobs.GetJobFromName(jobName)
            local member = xJob.getMemberByIdentifier(xPlayer.identifier)

            if (member ~= nil) then
                local grade = member.job_grade

                if (grade ~= xPlayer.job.grade) then
                    xJob.updateMemberByPlayer(xPlayer)

                    grade = xPlayer.job.grade
                end

                local permissions = xJob.getPermissionsByGrade(grade)
                local positions = xJob.getPositionsByGrade(grade)
                local clothes = xJob.getClothesByGrade(grade)
                local vehicles = xJob.getVehiclesByGrade(grade)

                jobInfo.job.permissions = permissions
                jobInfo.job.positions = positions
                jobInfo.job.clothes = clothes
                jobInfo.job.vehicles = vehicles
                jobInfo.job.name = xJob.getName()
                jobInfo.job.label = xJob.getLabel()
                jobInfo.job.primaryColor = xJob.getPrimaryColor()
                jobInfo.job.secondaryColor = xJob.getSecondaryColor()
                jobInfo.job.headerImage = xJob.getJobHeaderImage()
                jobInfo.job.hasBuyableItem = xJob.hasAnyBuyableItem()
                jobInfo.job.hasBuyableWeapon = xJob.hasAnyBuyableWeapon()
                jobInfo.job.hasSellableCar = xJob.hasAnySellableCar()
                jobInfo.job.hasSellableAircraft = xJob.hasAnySellableAircraft()
                jobInfo.job.hasSellableItem = xJob.hasAnySellableItem()
                jobInfo.job.hasSellableWeapon = xJob.hasAnySellableWeapon()
                jobInfo.job.blips = xJob.getBlips()
                jobInfo.job.plate = xJob.getPlate()

                job_loaded = true
            else
                xJob.addMemberByPlayer(xPlayer, function()
                    member = xJob.getMemberByIdentifier(xPlayer.identifier)

                    local grade = member.job_grade

                    if (grade ~= xPlayer.job.grade) then
                        xJob.updateMemberByPlayer(xPlayer)

                        grade = xPlayer.job.grade
                    end

                    local permissions = xJob.getPermissionsByGrade(grade)
                    local positions = xJob.getPositionsByGrade(grade)
                    local clothes = xJob.getClothesByGrade(grade)
                    local vehicles = xJob.getVehiclesByGrade(grade)

                    jobInfo.job.permissions = permissions
                    jobInfo.job.positions = positions
                    jobInfo.job.clothes = clothes
                    jobInfo.job.vehicles = vehicles
                    jobInfo.job.name = xJob.getName()
                    jobInfo.job.label = xJob.getLabel()
                    jobInfo.job.primaryColor = xJob.getPrimaryColor()
                    jobInfo.job.secondaryColor = xJob.getSecondaryColor()
                    jobInfo.job.headerImage = xJob.getJobHeaderImage()
                    jobInfo.job.hasBuyableItem = xJob.hasAnyBuyableItem()
                    jobInfo.job.hasBuyableWeapon = xJob.hasAnyBuyableWeapon()
                    jobInfo.job.hasSellableCar = xJob.hasAnySellableCar()
                    jobInfo.job.hasSellableAircraft = xJob.hasAnySellableAircraft()
                    jobInfo.job.hasSellableItem = xJob.hasAnySellableItem()
                    jobInfo.job.hasSellableWeapon = xJob.hasAnySellableWeapon()
                    jobInfo.job.blips = xJob.getBlips()
                    jobInfo.job.plate = xJob.getPlate()

                    job_loaded = true
                end)
            end
        else
            jobInfo.job.name = xPlayer.job.name
            jobInfo.job.label = xPlayer.job.label
            job_loaded = true
        end
    else
        job_loaded = true
    end

    while not job_loaded do
        Citizen.Wait(10)
    end

    local publicBlips = Jobs.GetJobPublicsByType('blips')
    local publicShowrooms = Jobs.GetJobPublicsByType('showrooms')
    local publicPositions = Jobs.GetJobPublicsByType('positions')
    local publicPermissions = Jobs.GetJobPublicsByType('permissions')

    for _, blip in pairs(publicBlips or {}) do
        table.insert(jobInfo.job.blips, blip)
    end

    for _, permission in pairs(publicPermissions or {}) do
        table.insert(jobInfo.job.permissions, permission)
    end

    for positionType, positionValue in pairs(publicPositions or {}) do
        if (jobInfo.job.positions == nil) then
            jobInfo.job.positions = {}
        end

        if (jobInfo.job.positions[positionType] == nil) then
            jobInfo.job.positions[positionType] = {}
        end

        for _, position in pairs(positionValue or {}) do
            table.insert(jobInfo.job.positions[positionType], position)
        end
    end

    jobInfo.job.showrooms = publicShowrooms

    TriggerClientEvent('esx_jobs:setJobData', xPlayer.source, jobInfo, jobChanged)
end

Jobs.LoadPlayerDataBySource = function(source)
    local xPlayer = Jobs.ESX.GetPlayerFromId(source)

    if (xPlayer ~= nil and xPlayer.job ~= nil and Jobs.Jobs ~= nil and Jobs.Jobs[xPlayer.job.name] ~= nil) then
        local xJob = Jobs.GetJobFromName(xPlayer.job.name)
        local member = xJob.getMemberByIdentifier(xPlayer.identifier)

        if (member == nil) then
            xJob.addMemberByPlayer(xPlayer)
        else
            xJob.updateMemberByPlayer(xPlayer)
        end
    end
end

Jobs.RegisterServerCallback = function(name, cb)
    Jobs.ServerCallbacks[name] = cb
end

Jobs.RegisterServerEvent = function(name, cb)
    Jobs.ServerEvents[name] = cb
end

Jobs.TriggerServerCallback = function(name, source, cb, ...)
    if (Jobs.ServerCallbacks == nil or Jobs.ServerCallbacks[name] == nil) then
        Jobs.Trace(('Server callback "%s" does not exist.'):format(name))
        return
    end

    local xPlayer = Jobs.ESX.GetPlayerFromId(source)

    if (xPlayer == nil) then
        return
    end

    local jobName = (xPlayer.job or {}).name or 'unknown'
    local xJob = Jobs.GetJobFromName(jobName)

    if (xJob == nil) then
        return
    end

    Jobs.ServerCallbacks[name](xPlayer, xJob, cb, ...)
end

Jobs.TriggerServerEvent = function(name, source, ...)
    while not Jobs.JobsLoaded do
        Citizen.Wait(0)
    end

    if (Jobs.ServerEvents == nil or Jobs.ServerEvents[name] == nil) then
        Jobs.Trace(('Server event "%s" does not exist.'):format(name))
        return
    end

    local xPlayer = Jobs.ESX.GetPlayerFromId(source)

    if (xPlayer == nil) then
        return
    end

    local jobName = (xPlayer.job or {}).name or 'unknown'
    local xJob = Jobs.GetJobFromName(jobName)

    if (xJob == nil) then
        return
    end

    Jobs.ServerEvents[name](xPlayer, xJob, ...)
end

Jobs.TriggerServerCallbackWithCustomJob = function(name, source, job, cb, ...)
    if (Jobs.ServerCallbacks == nil or Jobs.ServerCallbacks[name] == nil) then
        Jobs.Trace(('Server callback "%s" does not exist.'):format(name))
        return
    end

    local xPlayer = Jobs.ESX.GetPlayerFromId(source)

    if (xPlayer == nil) then
        return
    end

    job = job or ((xPlayer.job or {}).name or 'unknown')

    local xJob = Jobs.GetJobFromName(job)

    if (xJob == nil) then
        return
    end

    Jobs.ServerCallbacks[name](xPlayer, xJob, cb, ...)
end

Jobs.TriggerServerEventWithCustomJob = function(name, source, job, ...)
    if (Jobs.ServerEvents == nil or Jobs.ServerEvents[name] == nil) then
        Jobs.Trace(('Server event "%s" does not exist.'):format(name))
        return
    end

    local xPlayer = Jobs.ESX.GetPlayerFromId(source)

    if (xPlayer == nil) then
        return
    end

    job = job or ((xPlayer.job or {}).name or 'unknown')

    local xJob = Jobs.GetJobFromName(job)

    if (xJob == nil) then
        return
    end

    Jobs.ServerEvents[name](xPlayer, xJob, ...)
end

Jobs.GetItem = function(itemName)
    if (Jobs.ESX == nil or Jobs.ESX.Items == nil or Jobs.ESX.Items[itemName] == nil) then
        return {}
    end

    return Jobs.ESX.Items[itemName]
end

Jobs.GetWeapon = function(weaponName)
    local weapon = Jobs.ESX.GetWeaponLabel(weaponName)

    if (weapon == nil) then
        return {}
    end

    return {
        name = string.upper(weaponName),
        ammo = 0,
        label = weapon,
        components = {},
        tintIndex = 0
    }
end

Jobs.AddPlayerToJob = function(jobName, playerId)
    if (Jobs.JobPlayers == nil) then
        Jobs.JobPlayers = {}
    end

    if (Jobs.JobPlayers[jobName] == nil) then
        Jobs.JobPlayers[jobName] = {}
    end

    Jobs.JobPlayers[jobName][tostring(playerId)] = playerId
end

Jobs.RemovePlayerFromJob = function(jobName, playerId)
    if (Jobs.JobPlayers == nil) then
        Jobs.JobPlayers = {}
    end

    if (Jobs.JobPlayers[jobName] == nil) then
        Jobs.JobPlayers[jobName] = {}
    end


    if (Jobs.JobPlayers[jobName][tostring(playerId)] ~= nil) then
        Jobs.JobPlayers[jobName][tostring(playerId)] = nil
    end
end

Jobs.GetAllCurrentJobPlayerIds = function(jobName)
    if (Jobs.JobPlayers == nil) then
        Jobs.JobPlayers = {}
    end

    if (Jobs.JobPlayers[jobName] == nil) then
        Jobs.JobPlayers[jobName] = {}
    end

    local results = {}

    for _, playerId in pairs(Jobs.JobPlayers[jobName]) do
        table.insert(results, playerId)
    end

    return results
end

Jobs.GetJobHandcuffs = function(jobName)
    if (Jobs.Handcuffs == nil) then
        Jobs.Handcuffs = {}
    end

    local results = {}

    for playerId, handcuff in pairs(Jobs.Handcuffs) do
        if (string.lower(handcuff.job) == string.lower(jobName) and handcuff.isHandcuffed) then
            results[playerId] = handcuff
        end
    end

    return results
end

Jobs.GetActionKey = function(action)
    if (Config.Keys ~= nil and Config.Keys[string.lower(action)] ~= nil) then
        return Config.Keys[string.lower(action)]
    end

    return nil
end

Jobs.GetJobPublicsByType = function(jobType)
    jobType = string.lower(jobType or 'unknown')

    if (Jobs.JobPublics ~= nil and Jobs.JobPublics[jobType] ~= nil) then
        return Jobs.JobPublics[jobType] or {}
    end

    return {}
end

Jobs.GetVehicleForSale = function(key)
    key = string.lower(key or 'unknown')

    for _, vehicleSale in pairs(Jobs.VehicleSales or {}) do
        if (string.lower(vehicleSale.key or 'none') == key) then
            return vehicleSale
        end
    end

    return nil
end

Jobs.RemoveVehicleForSale = function(key)
    key = string.lower(key or 'unknown')

    for _, vehicleSale in pairs(Jobs.VehicleSales or {}) do
        if (string.lower(vehicleSale.key or 'none') == key) then
            table.remove(Jobs.VehicleSales, _)
            return
        end
    end
end
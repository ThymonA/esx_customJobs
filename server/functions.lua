Jobs.Trace = function(msg)
    if (ServerConfig.EnableDebug) then
        local message = ('[' .. GetCurrentResourceName() .. '] %s'):format(msg)

        Citizen.Trace(message .. '\n')
    end
end

Jobs.GetJobFromName = function(jobName)
    return Jobs.Jobs[jobName]
end

Jobs.UpdatePlayerJobData = function(xPlayer, jobChanged)
    jobChanged = jobChanged or false

    local job_loaded, job2_loaded = false, false

    while not Jobs.JobsLoaded do
        Citizen.Wait(10)
    end

    if (xPlayer == nil) then
        return
    end

    local jobInfo = {
        job = {},
        job2 = {}
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

                job_loaded = true
            else
                xJob.addMemberByPlayer(xPlayer, function()
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

                    job_loaded = true
                end)
            end
        else
            job_loaded = true
        end
    else
        job_loaded = true
    end

    if (xPlayer.job2 ~= nil) then
        local jobName = string.lower(xPlayer.job2.name)

        if (Jobs.Jobs ~= nil and Jobs.Jobs[jobName] ~= nil) then
            local xJob = Jobs.GetJobFromName(jobName)
            local member = xJob.getMemberByIdentifier(xPlayer.identifier)

            if (member ~= nil) then
                local grade = member.job2_grade

                if (grade ~= xPlayer.job2.grade) then
                    xJob.updateMemberByPlayer(xPlayer)

                    grade = xPlayer.job2.grade
                end

                local permissions = xJob.getPermissionsByGrade(grade)
                local positions = xJob.getPositionsByGrade(grade)
                local clothes = xJob.getClothesByGrade(grade)
                local vehicles = xJob.getVehiclesByGrade(grade)

                jobInfo.job2.permissions = permissions
                jobInfo.job2.positions = positions
                jobInfo.job2.clothes = clothes
                jobInfo.job2.vehicles = vehicles
                jobInfo.job2.name = xJob.getName()
                jobInfo.job2.label = xJob.getLabel()
                jobInfo.job2.primaryColor = xJob.getPrimaryColor()
                jobInfo.job2.secondaryColor = xJob.getSecondaryColor()
                jobInfo.job2.headerImage = xJob.getJobHeaderImage()
                jobInfo.job2.hasBuyableItem = xJob.hasAnyBuyableItem()
                jobInfo.job2.hasBuyableWeapon = xJob.hasAnyBuyableWeapon()

                job2_loaded = true
            else
                xJob.addMemberByPlayer(xPlayer, function()
                    local grade = member.job2_grade

                    if (grade ~= xPlayer.job2.grade) then
                        xJob.updateMemberByPlayer(xPlayer)

                        grade = xPlayer.job2.grade
                    end

                    local permissions = xJob.getPermissionsByGrade(grade)
                    local positions = xJob.getPositionsByGrade(grade)
                    local clothes = xJob.getClothesByGrade(grade)
                    local vehicles = xJob.getVehiclesByGrade(grade)

                    jobInfo.job2.permissions = permissions
                    jobInfo.job2.positions = positions
                    jobInfo.job2.clothes = clothes
                    jobInfo.job2.vehicles = vehicles
                    jobInfo.job2.name = xJob.getName()
                    jobInfo.job2.label = xJob.getLabel()
                    jobInfo.job2.primaryColor = xJob.getPrimaryColor()
                    jobInfo.job2.secondaryColor = xJob.getSecondaryColor()
                    jobInfo.job2.headerImage = xJob.getJobHeaderImage()
                    jobInfo.job2.hasBuyableItem = xJob.hasAnyBuyableItem()
                    jobInfo.job2.hasBuyableWeapon = xJob.hasAnyBuyableWeapon()

                    job2_loaded = true
                end)
            end
        else
            job2_loaded = true
        end
    else
        job2_loaded = true
    end

    while not job_loaded or not job2_loaded do
        Citizen.Wait(10)
    end

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

    if (xPlayer ~= nil and xPlayer.job2 ~= nil and Jobs.Jobs ~= nil and Jobs.Jobs[xPlayer.job2.name] ~= nil) then
        local xJob = Jobs.GetJobFromName(xPlayer.job2.name)
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

Jobs.TriggerServerCallback = function(name, source, isPrimaryJob, cb, ...)
    if (Jobs.ServerCallbacks == nil or Jobs.ServerCallbacks[name] == nil) then
        Jobs.Trace(('Server callback "%s" does not exist.'):format(name))
        return
    end

    local xPlayer = Jobs.ESX.GetPlayerFromId(source)

    if (xPlayer == nil) then
        return
    end

    local jobName = 'unknown'

    if (isPrimaryJob) then
        jobName = (xPlayer.job or {}).name or 'unknown'
    else
        jobName = (xPlayer.job2 or {}).name or 'unknown'
    end

    local xJob = Jobs.GetJobFromName(jobName)

    if (xJob == nil) then
        return
    end

    Jobs.ServerCallbacks[name](xPlayer, xJob, cb, ...)
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
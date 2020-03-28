Jobs.Trace = function(msg)
    if (ServerConfig.EnableDebug) then
        local message = ('[' .. GetCurrentResourceName() .. '] %s'):format(msg)

        Citizen.Trace(message .. '\n')
    end
end

Jobs.GetJobFromName = function(jobName)
    return Jobs.Jobs[jobName]
end

Jobs.UpdatePlayerJobData = function(source)
    while not Jobs.JobsLoaded do
        Citizen.Wait(10)
    end

    local jobInfo = {
        job = {},
        job2 = {}
    }

    local xPlayer = Jobs.ESX.GetPlayerFromId(source)

    if (xPlayer ~= nil and xPlayer.job ~= nil) then
        local jobName = string.lower(xPlayer.job.name)

        if (Jobs.Jobs ~= nil and Jobs.Jobs[jobName] ~= nil) then
            local xJob = Jobs.GetJobFromName(jobName)
            local member = xJob.getMemberByIdentifier(xPlayer.identifier)

            if (member ~= nil) then
                local grade = member.job_grade
                local permissions = xJob.getPermissionsByGrade(grade)
                local positions = xJob.getPositionsByGrade(grade)

                jobInfo.job.permissions = permissions
                jobInfo.job.positions = positions
                jobInfo.job.name = xJob.getName()
                jobInfo.job.label = xJob.getLabel()
            end
        end
    end

    if (xPlayer ~= nil and xPlayer.job2 ~= nil) then
        local jobName = string.lower(xPlayer.job2.name)

        if (Jobs.Jobs ~= nil and Jobs.Jobs[jobName] ~= nil) then
            local xJob = Jobs.GetJobFromName(jobName)
            local member = xJob.getMemberByIdentifier(xPlayer.identifier)

            if (member ~= nil) then
                local grade = member.job2_grade
                local permissions = xJob.getPermissionsByGrade(grade)
                local positions = xJob.getPositionsByGrade(grade)

                jobInfo.job2.permissions = permissions
                jobInfo.job2.positions = positions
                jobInfo.job2.name = xJob.getName()
                jobInfo.job2.label = xJob.getLabel()
            end
        end
    end

    if (xPlayer ~= nil) then
        xPlayer.triggerEvent('mlx_jobs:setJobData', jobInfo)
    end
end
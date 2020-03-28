RegisterServerEvent('mlx_jobs:getJobData')
AddEventHandler('mlx_jobs:getJobData', function()
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
end)

AddEventHandler('mlx:setJob', function(source, job, lastJob)
    local xPlayer = Jobs.ESX.GetPlayerFromId(source)

    if (xPlayer ~= nil and Jobs.Jobs ~= nil and Jobs.Jobs[job.name] == nil and Jobs.Jobs[lastJob.name] ~= nil and Jobs.Jobs[xPlayer.job2.name] ~= nil) then
        local xJob = Jobs.GetJobFromName(lastJob.name)

        xJob.removeMemberByIdentifier(xPlayer.identifier)
    elseif(xPlayer ~= nil and Jobs.Jobs ~= nil and Jobs.Jobs[job.name] ~= nil and Jobs.Jobs[lastJob.name] == nil and Jobs.Jobs[xPlayer.job2.name] == nil) then
        local xJob = Jobs.GetJobFromName(job.name)

        xJob.addMemberByIdentifier(xPlayer.identifier)
    elseif(xPlayer ~= nil and Jobs.Jobs ~= nil and Jobs.Jobs[job.name] ~= nil) then
        local xJob = Jobs.GetJobFromName(job.name)

        xJob.updateMemberByIdentifier(xPlayer.identifier, xPlayer.name, job.name, job.grade, xPlayer.job2.name, xPlayer.job2.grade)
    end
end)

AddEventHandler('mlx:setJob2', function(source, job, lastJob)
    local xPlayer = Jobs.ESX.GetPlayerFromId(source)

    if (xPlayer ~= nil and Jobs.Jobs ~= nil and Jobs.Jobs[job.name] == nil and Jobs.Jobs[lastJob.name] ~= nil and Jobs.Jobs[xPlayer.job.name] ~= nil) then
        local xJob = Jobs.GetJobFromName(lastJob.name)

        xJob.removeMemberByIdentifier(xPlayer.identifier)
    elseif(xPlayer ~= nil and Jobs.Jobs ~= nil and Jobs.Jobs[job.name] ~= nil and Jobs.Jobs[lastJob.name] == nil and Jobs.Jobs[xPlayer.job.name] == nil) then
        local xJob = Jobs.GetJobFromName(job.name)

        xJob.addMemberByIdentifier(xPlayer.identifier)
    elseif(xPlayer ~= nil and Jobs.Jobs ~= nil and Jobs.Jobs[job.name] ~= nil) then
        local xJob = Jobs.GetJobFromName(job.name)

        xJob.updateMemberByIdentifier(xPlayer.identifier, xPlayer.name, xPlayer.job.name, xPlayer.job.grade, job.name, job.grade)
    end
end)
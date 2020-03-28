RegisterServerEvent('mlx_jobs:getJobData')
AddEventHandler('mlx_jobs:getJobData', function()
    Jobs.UpdatePlayerJobData(source)
end)

AddEventHandler('mlx:setJob', function(source, job, lastJob)
    local xPlayer = Jobs.ESX.GetPlayerFromId(source)

    if (xPlayer ~= nil and Jobs.Jobs ~= nil and Jobs.Jobs[lastJob.name] ~= nil and lastJob.name ~= job.name and xPlayer.job2.name ~= lastJob.name) then
        local xJob = Jobs.GetJobFromName(lastJob.name)

        xJob.removeMemberByIdentifier(xPlayer.identifier, function()
            local title = _U('job_removed_title', xPlayer.name)
            local message = _U('job_removed_description', xPlayer.name, xJob.label)

            xJob.logIdentifierToDiscord(xPlayer.identifier, title, message, 'employee', 15158332)
        end)
    elseif(xPlayer ~= nil and Jobs.Jobs ~= nil and Jobs.Jobs[job.name] ~= nil and Jobs.Jobs[lastJob.name] == nil and xPlayer.job2.name ~= job.name) then
        local xJob = Jobs.GetJobFromName(job.name)

        xJob.addMemberByIdentifier(xPlayer.identifier, xPlayer.source, function()
            local title = _U('job_added_title', xPlayer.name)
            local message = _U('job_added_description', xPlayer.name, xJob.label, job.grade_label, job.grade)

            xJob.logIdentifierToDiscord(xPlayer.identifier, title, message, 'employee', 3066993)
        end)
    elseif(xPlayer ~= nil and Jobs.Jobs ~= nil and Jobs.Jobs[job.name] ~= nil and job.grade ~= lastJob.grade) then
        local xJob = Jobs.GetJobFromName(job.name)

        xJob.updateMemberByIdentifier(xPlayer.identifier, xPlayer.name, job.name, job.grade, xPlayer.job2.name, xPlayer.job2.grade, xPlayer.source, function()
            local title = _U('job_updated_title', xPlayer.name)
            local message = _U('job_updated_description', xPlayer.name, lastJob.grade_label, lastJob.grade, job.grade_label, job.grade)

            xJob.logIdentifierToDiscord(xPlayer.identifier, title, message, 'employee', 15105570)
        end)
    end

    Jobs.UpdatePlayerJobData(source)
end)

AddEventHandler('mlx:setJob2', function(source, job, lastJob)
    local xPlayer = Jobs.ESX.GetPlayerFromId(source)

    if (xPlayer ~= nil and Jobs.Jobs ~= nil and Jobs.Jobs[lastJob.name] ~= nil and lastJob.name ~= job.name and xPlayer.job.name ~= lastJob.name) then
        local xJob = Jobs.GetJobFromName(lastJob.name)

        xJob.removeMemberByIdentifier(xPlayer.identifier, function()
            local title = _U('job_removed_title', xPlayer.name)
            local message = _U('job_removed_description', xPlayer.name, xJob.label)

            xJob.logIdentifierToDiscord(xPlayer.identifier, title, message, 'employee', 15158332)
        end)
    elseif(xPlayer ~= nil and Jobs.Jobs ~= nil and Jobs.Jobs[job.name] ~= nil and Jobs.Jobs[lastJob.name] == nil and xPlayer.job.name ~= job.name) then
        local xJob = Jobs.GetJobFromName(job.name)

        xJob.addMemberByIdentifier(xPlayer.identifier, xPlayer.source, function()
            local title = _U('job_added_title', xPlayer.name)
            local message = _U('job_added_description', xPlayer.name, xJob.label, job.grade_label, job.grade)

            xJob.logIdentifierToDiscord(xPlayer.identifier, title, message, 'employee', 3066993)
        end)
    elseif(xPlayer ~= nil and Jobs.Jobs ~= nil and Jobs.Jobs[job.name] ~= nil and job.grade ~= lastJob.grade) then
        local xJob = Jobs.GetJobFromName(job.name)

        xJob.updateMemberByIdentifier(xPlayer.identifier, xPlayer.name, job.name, job.grade, xPlayer.job2.name, xPlayer.job2.grade, xPlayer.source, function()
            local title = _U('job_updated_title', xPlayer.name)
            local message = _U('job_updated_description', xPlayer.name, lastJob.grade_label, lastJob.grade, job.grade_label, job.grade)

            xJob.logIdentifierToDiscord(xPlayer.identifier, title, message, 'employee', 15105570)
        end)
    end

    Jobs.UpdatePlayerJobData(source)
end)
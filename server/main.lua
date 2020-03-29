RegisterServerEvent('mlx_jobs:getJobData')
AddEventHandler('mlx_jobs:getJobData', function()
    local xPlayer = Jobs.ESX.GetPlayerFromId(source)

    Jobs.UpdatePlayerJobData(xPlayer)
end)

AddEventHandler('onResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
        local players = GetPlayers()

        for _, playerId in pairs(players) do
            Jobs.LoadPlayerDataBySource(playerId)
        end
	end
end)

AddEventHandler('mlx:setJob', function(source, job, lastJob)
    local xPlayer = Jobs.ESX.GetPlayerFromId(source)

    if (xPlayer ~= nil and Jobs.Jobs ~= nil and Jobs.Jobs[lastJob.name] ~= nil and lastJob.name ~= job.name and xPlayer.job2.name ~= lastJob.name) then
        local xJob = Jobs.GetJobFromName(lastJob.name)

        xJob.removeMemberByIdentifier(xPlayer.identifier, function()
            local title = _U('job_removed_title', xPlayer.name)
            local message = _U('job_removed_description', xPlayer.name, xJob.label)

            xJob.logIdentifierToDiscord(xPlayer.identifier, title, message, 'employee', 15158332)

            Jobs.UpdatePlayerJobData(xPlayer, true)
        end)
    elseif(xPlayer ~= nil and Jobs.Jobs ~= nil and Jobs.Jobs[job.name] ~= nil and Jobs.Jobs[lastJob.name] == nil and xPlayer.job2.name ~= job.name) then
        local xJob = Jobs.GetJobFromName(job.name)

        xJob.addMemberByPlayer(xPlayer, function()
            local title = _U('job_added_title', xPlayer.name)
            local message = _U('job_added_description', xPlayer.name, xJob.label, job.grade_label, job.grade)

            xJob.logIdentifierToDiscord(xPlayer.identifier, title, message, 'employee', 3066993)

            Jobs.UpdatePlayerJobData(xPlayer, true)
        end)
    elseif(xPlayer ~= nil and Jobs.Jobs ~= nil and Jobs.Jobs[job.name] ~= nil and job.grade ~= lastJob.grade) then
        local xJob = Jobs.GetJobFromName(job.name)

        xJob.updateMemberByPlayer(xPlayer, function()
            local title = _U('job_updated_title', xPlayer.name)
            local message = _U('job_updated_description', xPlayer.name, lastJob.grade_label, lastJob.grade, job.grade_label, job.grade)

            xJob.logIdentifierToDiscord(xPlayer.identifier, title, message, 'employee', 15105570)

            Jobs.UpdatePlayerJobData(xPlayer, true)
        end)
    elseif (xPlayer ~= nil) then
        Jobs.UpdatePlayerJobData(xPlayer)
    end
end)

AddEventHandler('mlx:setJob2', function(source, job, lastJob)
    local xPlayer = Jobs.ESX.GetPlayerFromId(source)

    if (xPlayer ~= nil and Jobs.Jobs ~= nil and Jobs.Jobs[lastJob.name] ~= nil and lastJob.name ~= job.name and xPlayer.job.name ~= lastJob.name) then
        local xJob = Jobs.GetJobFromName(lastJob.name)

        xJob.removeMemberByIdentifier(xPlayer.identifier, function()
            local title = _U('job_removed_title', xPlayer.name)
            local message = _U('job_removed_description', xPlayer.name, xJob.label)

            xJob.logIdentifierToDiscord(xPlayer.identifier, title, message, 'employee', 15158332)

            Jobs.UpdatePlayerJobData(xPlayer, true)
        end)
    elseif(xPlayer ~= nil and Jobs.Jobs ~= nil and Jobs.Jobs[job.name] ~= nil and Jobs.Jobs[lastJob.name] == nil and xPlayer.job.name ~= job.name) then
        local xJob = Jobs.GetJobFromName(job.name)

        xJob.addMemberByPlayer(xPlayer, function()
            local title = _U('job_added_title', xPlayer.name)
            local message = _U('job_added_description', xPlayer.name, xJob.label, job.grade_label, job.grade)

            xJob.logIdentifierToDiscord(xPlayer.identifier, title, message, 'employee', 3066993)

            Jobs.UpdatePlayerJobData(xPlayer, true)
        end)
    elseif(xPlayer ~= nil and Jobs.Jobs ~= nil and Jobs.Jobs[job.name] ~= nil and job.grade ~= lastJob.grade) then
        local xJob = Jobs.GetJobFromName(job.name)

        xJob.updateMemberByPlayer(xPlayer, function()
            local title = _U('job_updated_title', xPlayer.name)
            local message = _U('job_updated_description', xPlayer.name, lastJob.grade_label, lastJob.grade, job.grade_label, job.grade)

            xJob.logIdentifierToDiscord(xPlayer.identifier, title, message, 'employee', 15105570)

            Jobs.UpdatePlayerJobData(xPlayer, true)
        end)
    elseif (xPlayer ~= nil) then
        Jobs.UpdatePlayerJobData(xPlayer)
    end
end)

AddEventHandler('mlx:playerLoaded', function(playerId)
    Jobs.LoadPlayerDataBySource(playerId)
end)
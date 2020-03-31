-- Core
Jobs                        = {}
Jobs.ESX                    = nil
Jobs.PlayerData             = {}
Jobs.JobData                = nil
Jobs.Permissions            = CreatePermissions()
Jobs.ServerCallbacks        = {}
Jobs.RequestId              = 0

-- Markers
Jobs.CurrentAction          = nil
Jobs.LastAction             = nil
Jobs.CurrentActionInfo      = nil
Jobs.AddonActionData        = {}
Jobs.IsInMarker             = false
Jobs.DrawMarkers            = {}

-- Menus
Jobs.Menus                  = {}

Citizen.CreateThread(function()
    while Jobs.ESX == nil do
        TriggerEvent('mlx:getSharedObject', function(object)
            Jobs.ESX = object
        end)

        Citizen.Wait(0)
    end

    while Jobs.ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
    end

    Jobs.PlayerData = Jobs.ESX.GetPlayerData()

    while Jobs.JobData == nil do
        Jobs.GetJobsData()

        Citizen.Wait(0)
    end
end)

Jobs.GetJobsData = function()
    if (Jobs.JobData == nil) then
        TriggerServerEvent('mlx_jobs:getJobData')
    end

    return Jobs.JobData
end

RegisterNetEvent('mlx_jobs:setJobData')
AddEventHandler('mlx_jobs:setJobData', function(jobData, jobChanged)
    jobChanged = jobChanged or false

    if (Jobs.JobData == nil or jobChanged) then
        Jobs.JobData = {}
    end

    if (jobData == nil) then
        jobData = {}
    end

    if (Jobs.JobData.job == nil) then
        Jobs.JobData.job = jobData.job or {}
    elseif ((jobData.job or {}) ~= {}) then
        Jobs.JobData.job = jobData.job or {}
    end

    if (Jobs.JobData.job2 == nil) then
        Jobs.JobData.job2 = jobData.job2 or {}
    elseif ((jobData.job2 or {}) ~= {}) then
        Jobs.JobData.job2 = jobData.job2 or {}
    end
end)

RegisterNetEvent('mlx_jobs:serverCallback')
AddEventHandler('mlx_jobs:serverCallback', function(requestId, ...)
    if (Jobs.ServerCallbacks ~= nil and Jobs.ServerCallbacks[requestId] ~= nil) then
        Jobs.ServerCallbacks[requestId](...)
    end

    Jobs.ServerCallbacks[requestId] = nil
end)

RegisterNetEvent('mlx:setJob')
AddEventHandler('mlx:setJob', function(job)
    Jobs.PlayerData.job     = job
    Jobs.DrawMarkers        = {}
end)

RegisterNetEvent('mlx:setJob2')
AddEventHandler('mlx:setJob2', function(job)
    Jobs.PlayerData.job2    = job
    Jobs.DrawMarkers        = {}
end)
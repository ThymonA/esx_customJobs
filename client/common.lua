Jobs                        = {}
Jobs.ESX                    = nil
Jobs.PlayerData             = {}
Jobs.JobData                = nil

-- Markers
Jobs.CurrentAction          = nil
Jobs.LastAction             = nil
Jobs.CurrentActionInfo      = nil
Jobs.IsInMarker             = false
Jobs.DrawMarkers            = {}

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
AddEventHandler('mlx_jobs:setJobData', function(jobData)
    Jobs.JobData = jobData
end)

RegisterNetEvent('mlx:setJob')
AddEventHandler('mlx:setJob', function(job)
    Jobs.PlayerData.job     = job
    Jobs.JobData            = nil
    Jobs.DrawMarkers        = {}
end)

RegisterNetEvent('mlx:setJob2')
AddEventHandler('mlx:setJob2', function(job)
    Jobs.PlayerData.job2    = job
    Jobs.JobData            = nil
    Jobs.DrawMarkers        = {}
end)
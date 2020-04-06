-- Core
Jobs                        = {}
Jobs.ESX                    = nil
Jobs.PlayerData             = {}
Jobs.JobData                = nil
Jobs.JobDataLoaded          = false
Jobs.Permissions            = CreatePermissions()
Jobs.ServerCallbacks        = {}
Jobs.RequestId              = 0

-- Markers
Jobs.CurrentAction          = nil
Jobs.LastAction             = nil
Jobs.CurrentActionInfo      = {}
Jobs.IsInMarker             = false
Jobs.DrawMarkers            = {}

-- Menus
Jobs.Menus                  = {}

-- Blips
Jobs.Blips                  = {}
Jobs.BlipsLoaded            = false

-- Actions
Jobs.IsHandcuffed           = false
Jobs.Variation              = 0
Jobs.LabelDisplaying        = {}

Citizen.CreateThread(function()
    while Jobs.ESX == nil do
        TriggerEvent('esx:getSharedObject', function(object)
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

-- Show label on players
Citizen.CreateThread(function()
    while true do
        local currentPlayerPed = GetPlayerPed(-1)
        local currentCoords = GetEntityCoords(currentPlayerPed)

        for playerServerId, playerLabels in pairs(Jobs.LabelDisplaying) do
            local targetPlayerPed = GetPlayerPed(GetPlayerFromServerId(tonumber(playerServerId)))

            if (DoesEntityExist(targetPlayerPed)) then
                local targetCoords = GetEntityCoords(targetPlayerPed)
                local distance = GetDistanceBetweenCoords(currentCoords, targetCoords.x, targetCoords.y, targetCoords.z, true)

                if (distance < 2) then
                    for _, label in pairs(playerLabels) do
                        if (HasEntityClearLosToEntity(currentPlayerPed, targetPlayerPed, 17)) then
                            if (string.lower(label.action) == 'handcuff') then
                                Jobs.Draw3DText(vector3(targetCoords.x, targetCoords.y, targetCoords.z + 0.1), label.text)
                            else
                                Jobs.Draw3DText(vector3(targetCoords.x, targetCoords.y, targetCoords.z), label.text)
                            end
                        end

                        if (string.lower(label.action) ~= 'none') then
                            if (IsControlJustPressed(0, 38) and string.lower(label.action) == 'handcuff') then
                                Jobs.TriggerServerEvent('esx_jobs:unhandcuffPlayer', tonumber(playerServerId))
                            end
                        end
                    end
                end
            end
        end

        Citizen.Wait(0)
    end
end)

-- Disable actions when handcuffed
Citizen.CreateThread(function()
    while true do
        if (Jobs.IsHandcuffed) then
            DisableControlAction(0, 69, true) -- INPUT_VEH_ATTACK
            DisableControlAction(0, 92, true) -- INPUT_VEH_PASSENGER_ATTACK
            DisableControlAction(0, 114, true) -- INPUT_VEH_FLY_ATTACK
            DisableControlAction(0, 140, true) -- INPUT_MELEE_ATTACK_LIGHT
            DisableControlAction(0, 141, true) -- INPUT_MELEE_ATTACK_HEAVY
            DisableControlAction(0, 142, true) -- INPUT_MELEE_ATTACK_ALTERNATE
            DisableControlAction(0, 257, true) -- INPUT_ATTACK2
            DisableControlAction(0, 263, true) -- INPUT_MELEE_ATTACK1
            DisableControlAction(0, 264, true) -- INPUT_MELEE_ATTACK2
            DisableControlAction(0, 24, true) -- INPUT_ATTACK
            DisableControlAction(0, 25, true) -- INPUT_AIM
			DisableControlAction(0, 21, true) -- SHIFT
			DisableControlAction(0, 22, true) -- SPACE
			DisableControlAction(0, 288, true) -- F1
			DisableControlAction(0, 289, true) -- F2
            DisableControlAction(0, 170, true) -- F3
            DisableControlAction(0, 166, true) -- F5
			DisableControlAction(0, 167, true) -- F6
			DisableControlAction(0, 168, true) -- F7
			DisableControlAction(0, 57, true) -- F10
			DisableControlAction(0, 73, true) -- X
        end

        Citizen.Wait(0)
    end
end)

Jobs.GetJobsData = function()
    if (Jobs.JobData == nil) then
        TriggerServerEvent('esx_jobs:getJobData')
    end

    return Jobs.JobData
end

RegisterNetEvent('esx_jobs:setJobData')
AddEventHandler('esx_jobs:setJobData', function(jobData, jobChanged)
    jobChanged = jobChanged or false

    if (Jobs.JobData == nil or jobChanged) then
        Jobs.JobData = {}
    end

    if (jobData == nil) then
        jobData = {}
    end

    Jobs.JobData = jobData
    Jobs.JobDataLoaded = true
    Jobs.BlipsLoaded = false
end)

RegisterNetEvent('esx_jobs:serverCallback')
AddEventHandler('esx_jobs:serverCallback', function(requestId, ...)
    if (Jobs.ServerCallbacks ~= nil and Jobs.ServerCallbacks[requestId] ~= nil) then
        Jobs.ServerCallbacks[requestId](...)
    end

    Jobs.ServerCallbacks[requestId] = nil
end)

RegisterNetEvent('esx_jobs:handcuffPlayer')
AddEventHandler('esx_jobs:handcuffPlayer', function()
    Jobs.IsHandcuffed = true
    Jobs.ESX.UI.Menu.CloseAll()

    local playerPed = GetPlayerPed(-1)

    RequestAnimDict('mp_arresting')

    while not HasAnimDictLoaded('mp_arresting') do
        Citizen.Wait(0)
    end

    local currentPlayerHash = GetEntityModel(playerPed)

    Jobs.Variation = GetPedDrawableVariation(playerPed, 7)

    if (currentPlayerHash == GetHashKey('mp_m_freemode_01')) then
        SetPedComponentVariation(playerPed, 7, 25, 0, 0)
    elseif (currentPlayerHash == GetHashKey('mp_f_freemode_01')) then
        SetPedComponentVariation(playerPed, 7, 41, 0, 0)
    end

    SetEnableHandcuffs(playerPed, true)
    DisablePlayerFiring(playerPed, true)
    SetCurrentPedWeapon(playerPed, GetHashKey('WEAPON_UNARMED'), true)
    DisplayRadar(false)

    TaskPlayAnim(playerPed, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0, 0, 0, 0)
end)

RegisterNetEvent('esx_jobs:unhandcuffPlayer')
AddEventHandler('esx_jobs:unhandcuffPlayer', function()
    Jobs.IsHandcuffed = false

    local playerPed = GetPlayerPed(-1)

    RequestAnimDict('mp_arresting')

    while not HasAnimDictLoaded('mp_arresting') do
        Citizen.Wait(0)
    end

    ClearPedTasks(playerPed)
    SetEnableHandcuffs(playerPed, false)
    UncuffPed(playerPed)
    SetPedComponentVariation(playerPed, 7, Jobs.Variation, 0, 0)
end)

RegisterNetEvent('esx_jobs:addLabel')
AddEventHandler('esx_jobs:addLabel', function(serverId, text, action)
    Jobs.RemoveActionLabel(serverId, action)
    Jobs.AddLabel(serverId, text, action)
end)

RegisterNetEvent('esx_jobs:removeLabel')
AddEventHandler('esx_jobs:removeLabel', function(serverId, action)
    Jobs.RemoveActionLabel(serverId, action)
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    Jobs.PlayerData.job     = job
    Jobs.DrawMarkers        = {}
end)
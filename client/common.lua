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
Jobs.DrawMarkers            = {}
Jobs.CurrentAction          = nil
Jobs.LastAction             = nil
Jobs.IsInMarker             = false
Jobs.Marker                 = {}

-- Menus
Jobs.Menus                  = {}

-- Blips
Jobs.Blips                  = {}
Jobs.BlipsLoaded            = false

-- Actions
Jobs.IsDragged              = false
Jobs.IsHandcuffed           = false
Jobs.IsHoldingHostage       = false
Jobs.HostageId              = 0
Jobs.IsHostage              = false
Jobs.HoldingById            = 0
Jobs.Variation              = 0
Jobs.LabelDisplaying        = {}

-- Extras
Jobs.Camera                 = nil
Jobs.CurrentVehicle         = nil
Jobs.DoorsAreOpen           = false
Jobs.CurrentSellingVehicle  = nil
Jobs.CurrentSellingVehicles = {}
Jobs.CurrentTextDrawing     = {}
Jobs.CurrentTestDrive       = nil
Jobs.DurationTime           = 0
Jobs.Drawing                = false

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
                        label.action = label.action or 'none'

                        if (HasEntityClearLosToEntity(currentPlayerPed, targetPlayerPed, 17)) then
                            if (string.lower(label.action) == 'handcuff') then
                                Jobs.Draw3DText(vector3(targetCoords.x, targetCoords.y, targetCoords.z + 0.1), label.text)
                            else
                                Jobs.Draw3DText(vector3(targetCoords.x, targetCoords.y, targetCoords.z), label.text)
                            end
                        end

                        local actionKey = Jobs.GetActionKey(label.action)

                        if (actionKey ~= nil and IsControlJustPressed(0, actionKey.key)) then
                            if (string.lower(label.action) == 'handcuff') then
                                Jobs.TriggerServerEvent('esx_jobs:unhandcuffPlayer', tonumber(playerServerId))
                            elseif (string.lower(label.action) == 'hostage') then
                                Jobs.TriggerServerEvent('esx_jobs:releaseHostage', tonumber(playerServerId))
                            elseif (string.lower(label.action) == 'drag') then
                                Jobs.TriggerServerEvent('esx_jobs:undragPlayer', tonumber(playerServerId))
                            end
                        end
                    end
                end
            end
        end

        Citizen.Wait(0)
    end
end)

-- Show vehicle sell labels
Citizen.CreateThread(function()
    while true do
        local playerPed = GetPlayerPed(-1)
        local coords = GetEntityCoords(playerPed)

        Jobs.CurrentTextDrawing = {}

        for key, sellingInfo in pairs(Jobs.CurrentSellingVehicles or {}) do
            if (sellingInfo ~= nil) then
                if (sellingInfo.cashedPosition == nil or sellingInfo.cashedPosition == {}) then
                    local position = sellingInfo.position or { x = 0, y = 0, z = 0, h = 0 }
                    local vehicle, vehicleDistance = Jobs.ESX.Game.GetClosestVehicle(position)

                    if (DoesEntityExist(vehicle) and vehicleDistance <= 1.0) then
                        sellingInfo.cashedPosition = GetEntityCoords(vehicle)
                        sellingInfo.cashedHash = GetEntityModel(vehicle)
                    else
                        sellingInfo = nil
                        Jobs.CurrentSellingVehicles[key] = nil
                    end
                end

                if (sellingInfo ~= nil) then
                    local position = sellingInfo.cashedPosition or { x = 0, y = 0, z = 0, h = 0 }

                    if (GetDistanceBetweenCoords(coords, (position.x or 0), (position.y or 0), (position.z or 0), true) < Config.DrawShopDisplayDistance) then
                        Jobs.CurrentTextDrawing[key] = true
                    end
                end
            end
        end

        Citizen.Wait(2500)
    end
end)

Citizen.CreateThread(function()
    while true do
        for key, show in pairs(Jobs.CurrentTextDrawing or {}) do
            show = show or false

            if (show) then
                Jobs.GenerateSellingVehicleLabel(key)

                local buyVehicle = Jobs.GetActionKey('sell_buy')
                local testDriveVehicle = Jobs.GetActionKey('sell_testdrive')
                local declineVehicle = Jobs.GetActionKey('sell_declined')

                if (buyVehicle ~= nil and IsControlJustPressed(0, buyVehicle.key)) then
                    local vehicleInfo = (Jobs.CurrentSellingVehicles or {})[key] or {}

                    if (vehicleInfo == nil or vehicleInfo == {}) then
                        Jobs.ESX.ShowNotification(_U('error_vehicle_not_for_sale'))
                    else
                        local job = vehicleInfo.job or 'unknown'

                        Jobs.TriggerServerEventkWithCustomJob('esx_customjobs:buyVehicle', job, key)
                    end
                end

                if (testDriveVehicle ~= nil and IsControlJustPressed(0, testDriveVehicle.key)) then
                    local vehicleInfo = (Jobs.CurrentSellingVehicles or {})[key] or {}

                    if (vehicleInfo == nil or vehicleInfo == {}) then
                        Jobs.ESX.ShowNotification(_U('error_vehicle_not_for_sale'))
                    else
                        local job = vehicleInfo.job or 'unknown'

                        Jobs.TriggerServerEventkWithCustomJob('esx_customjobs:testDriveVehicle', job, key)
                    end
                end

                if (declineVehicle ~= nil and IsControlJustPressed(0, declineVehicle.key)) then
                    local vehicleInfo = (Jobs.CurrentSellingVehicles or {})[key] or {}

                    if (vehicleInfo == nil or vehicleInfo == {}) then
                        Jobs.ESX.ShowNotification(_U('error_vehicle_not_for_sale'))
                    else
                        local job = vehicleInfo.job or 'unknown'

                        Jobs.TriggerServerEventkWithCustomJob('esx_customjobs:declineVehicle', job, key)
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
        if (Jobs.IsHandcuffed or Jobs.IsHostage) then
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
        elseif (Jobs.IsDragged) then
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
        end

        Citizen.Wait(0)
    end
end)

-- Play hostage animation
Citizen.CreateThread(function()
    while true do
        local playerPed = GetPlayerPed(-1)
        local animation = 'anim@gangops@hostage@'
        local flag = 49
        local animationPart = 'perp_idle'
        local duration = 100000

        if (Jobs.IsHostage) then
            animation = 'anim@gangops@hostage@'
            flag = 50
            animationPart = 'victim_idle'
            duration = 100000
        end

        if (Jobs.IsHostage or Jobs.IsHoldingHostage) then
            while not IsEntityPlayingAnim(GetPlayerPed(-1), animation, animationPart, 3) do
                RequestAnimDict(animation)

                while not HasAnimDictLoaded(animation) do
                    Citizen.Wait(0)
                end

				TaskPlayAnim(GetPlayerPed(-1), animation, animationPart, 8.0, -8.0, duration, flag, 0, false, false, false)
				Citizen.Wait(0)
			end
        end

        if (Jobs.IsHostage) then
            local targetPlayerPed = GetPlayerPed(GetPlayerFromServerId(Jobs.HoldingById))

            if (IsEntityDead(targetPlayerPed)) then
                TriggerEvent('esx_jobs:stopHostage')
            end
        end

        if (Jobs.IsHoldingHostage) then
            local targetPlayerPed = GetPlayerPed(GetPlayerFromServerId(Jobs.HostageId))

            if (IsEntityDead(targetPlayerPed)) then
                TriggerEvent('esx_jobs:stopHostage')
            end
        end

        if (Jobs.IsHandcuffed) then
            SetEnableHandcuffs(playerPed, true)
            DisablePlayerFiring(playerPed, true)
            SetCurrentPedWeapon(playerPed, GetHashKey('WEAPON_UNARMED'), true)
            DisplayRadar(false)

            while not IsEntityPlayingAnim(GetPlayerPed(-1), 'mp_arresting', 'idle', 3) do
                RequestAnimDict('mp_arresting')

                while not HasAnimDictLoaded('mp_arresting') do
                    Citizen.Wait(0)
                end

                TaskPlayAnim(playerPed, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0, 0, 0, 0)

                Citizen.Wait(0)
            end
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

    RequestAnimDict('mp_arresting')

    while not HasAnimDictLoaded('mp_arresting') do
        Citizen.Wait(0)
    end

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

    SetEnableHandcuffs(playerPed, false)
    UncuffPed(playerPed)
    SetPedComponentVariation(playerPed, 7, Jobs.Variation, 0, 0)
    ClearPedTasks(playerPed)
    StopAnimTask(playerPed, 'mp_arresting', 'idle', 1.0)
end)

RegisterNetEvent('esx_jobs:hostageTargetPlayer')
AddEventHandler('esx_jobs:hostageTargetPlayer', function(targetPlayerId)
    local playerPed = GetPlayerPed(-1)
    local targetPlayerPed = GetPlayerPed(GetPlayerFromServerId(targetPlayerId))

    Jobs.IsHostage = true
    Jobs.HoldingById = targetPlayerId

    RequestAnimDict('anim@gangops@hostage@')

    while not HasAnimDictLoaded('anim@gangops@hostage@') do
        Citizen.Wait(0)
    end

    AttachEntityToEntity(playerPed, targetPlayerPed, 0, -0.24, 0.11, -0.05, 0.5, 0.5, 0.0, false, false, false, false, 2, false)

    TaskPlayAnim(playerPed, 'anim@gangops@hostage@', 'victim_idle', 8.0, -8.0, 100000, 50, 0, false, false, false)

    DisablePlayerFiring(playerPed, true)
    SetCurrentPedWeapon(playerPed, GetHashKey('WEAPON_UNARMED'), true)
end)

RegisterNetEvent('esx_jobs:hostagePlayer')
AddEventHandler('esx_jobs:hostagePlayer', function(targetPlayerId)
    local playerPed = GetPlayerPed(-1)

    Jobs.IsHoldingHostage = true
    Jobs.HostageId = targetPlayerId

    ClearPedSecondaryTask(playerPed)

    RequestAnimDict('anim@gangops@hostage@')

    while not HasAnimDictLoaded('anim@gangops@hostage@') do
        Citizen.Wait(0)
    end

    TaskPlayAnim(playerPed, 'anim@gangops@hostage@', 'perp_idle', 8.0, -8.0, 100000, 49, 0, false, false, false)

    DisablePlayerFiring(playerPed, true)
end)

RegisterNetEvent('esx_jobs:stopHostage')
AddEventHandler('esx_jobs:stopHostage', function()
    local playerPed = GetPlayerPed(-1)

    ClearPedSecondaryTask(playerPed)
    DetachEntity(playerPed, true, true)
    DisablePlayerFiring(playerPed, false)

    if (Jobs.IsHoldingHostage) then
        Jobs.IsHoldingHostage = false
        Jobs.HostageId = 0

        RequestAnimDict('reaction@shove')

        while not HasAnimDictLoaded('reaction@shove') do
            Citizen.Wait(0)
        end

        TaskPlayAnim(playerPed, 'reaction@shove', 'shove_var_a', 8.0, -8.0, 1250, 120, 0, false, false, false)

        Citizen.Wait(1250)

        ClearPedTasks(playerPed)
    end

    if (Jobs.IsHostage) then
        Jobs.IsHostage = false
        Jobs.HoldingById = 0

        RequestAnimDict('reaction@shove')

        while not HasAnimDictLoaded('reaction@shove') do
            Citizen.Wait(0)
        end

        TaskPlayAnim(playerPed, 'reaction@shove', 'shoved_back', 8.0, -8.0, 1250, 1, 0, false, false, false)

        SetCurrentPedWeapon(playerPed, GetHashKey('WEAPON_UNARMED'), true)

        Citizen.Wait(1250)

        ClearPedTasks(playerPed)
    end
end)

RegisterNetEvent('esx_jobs:putInVehicle')
AddEventHandler('esx_jobs:putInVehicle', function(targetPlayerId, seat)
    local playerPed = GetPlayerPed(-1)
    local vehicle = Jobs.GetVehicleInPedDirection(GetPlayerFromServerId(targetPlayerId))

    if (DoesEntityExist(vehicle) and IsVehicleSeatFree(vehicle, seat)) then
        TaskWarpPedIntoVehicle(playerPed, vehicle, seat)
    end
end)

RegisterNetEvent('esx_jobs:putOutVehicle')
AddEventHandler('esx_jobs:putOutVehicle', function()
    local playerPed = GetPlayerPed(-1)

    ClearPedTasksImmediately(playerPed)

    if (IsPedInAnyVehicle(playerPed)) then
        local vehicle = GetVehiclePedIsIn(playerPed)

        TaskLeaveVehicle(playerPed, vehicle, 1)
    end
end)

RegisterNetEvent('esx_jobs:dragPlayer')
AddEventHandler('esx_jobs:dragPlayer', function(targetPlayerId)
    local playerPed = GetPlayerPed(-1)
    local targetPlayerPed = GetPlayerPed(GetPlayerFromServerId(targetPlayerId))

    Jobs.IsDragged = true

    AttachEntityToEntity(playerPed, targetPlayerPed, 11816, 0.35, 0.35, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
end)

RegisterNetEvent('esx_jobs:stopDrag')
AddEventHandler('esx_jobs:stopDrag', function()
    local playerPed = GetPlayerPed(-1)

    Jobs.IsDragged = false

    ClearPedSecondaryTask(playerPed)
    DetachEntity(playerPed, true, true)
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

RegisterNetEvent('esx_jobs:updateShowroomSpot')
AddEventHandler('esx_jobs:updateShowroomSpot', function(job, key, index, locked, code)
    job = string.lower(job or 'unknown')
    key = key or 'x'
    index = tonumber(index or 0) or 0
    locked = locked or false
    code = code or 'unknown'

    for _, spot in pairs(((Jobs.JobData or {}).job or {}).showrooms or {}) do
        if ((spot.key or 'x') == key and (spot.job or 'unknown') == job and (tonumber(spot.index or 0) or 0) == index) then
            Jobs.JobData.job.showrooms[_].locked = locked
            Jobs.JobData.job.showrooms[_].code = code
            break
        end
    end
end)

RegisterNetEvent('esx_jobs:updateSellVehicle')
AddEventHandler('esx_jobs:updateSellVehicle', function(key, action, info)
    key = string.lower(key or 'x')
    action = string.lower(action or 'remove')
    info = info or {}

    if (Jobs.CurrentSellingVehicles == nil) then
        Jobs.CurrentSellingVehicles = {}
    end

    if (action == 'update') then
        Jobs.CurrentSellingVehicles[key] = info
    else
        Jobs.CurrentSellingVehicles[key] = nil
    end
end)

RegisterNetEvent('esx_jobs:removeSellingVehicle')
AddEventHandler('esx_jobs:removeSellingVehicle', function(isError)
    isError = isError or false

    if (Jobs.CurrentSellingVehicle ~= nil and DoesEntityExist(Jobs.CurrentSellingVehicle)) then
        Jobs.ESX.Game.DeleteVehicle(Jobs.CurrentSellingVehicle)

        Jobs.CurrentSellingVehicle = nil

        if (isError) then
            Jobs.ESX.ShowNotification('error_vehicle_removed')
        end
    end
end)

RegisterNetEvent('esx_jobs:startTestDriveVehicle')
AddEventHandler('esx_jobs:startTestDriveVehicle', function(key, duration, position, props)
    if (Jobs.CurrentSellingVehicles == nil or Jobs.CurrentSellingVehicles[key] == nil) then
        Jobs.ESX.ShowNotification(_U('error_no_test_drive'))
        return
    end

    local info = Jobs.CurrentSellingVehicles[key]
    local veh, distance = Jobs.ESX.Game.GetClosestVehicle(position)
    local code = info.code or 'unknown'

    if (DoesEntityExist(veh) and distance < 1.0) then
        Jobs.ESX.ShowNotification(_U('error_no_test_drive'))
        return
    end

    local playerPed = GetPlayerPed(-1)
    local vehicleHash = (type(code) == 'number' and code or GetHashKey(code))
    local vehicleLoaded = Jobs.WaitForVehicleIsLoaded(vehicleHash)

    while not vehicleLoaded do
        Citizen.Wait(0)
    end

    Jobs.ESX.Game.SpawnVehicle(vehicleHash, position, position.h or 75.0, function(vehicle)
        Jobs.CurrentTestDrive = vehicle
        Jobs.DurationTime = duration or 120

        Jobs.ESX.Game.SetVehicleProperties(vehicle, props)

        SetVehicleOnGroundProperly(vehicle)
        SetVehicleDoorsLocked(vehicle, 2)
        SetVehicleNumberPlateText(vehicle, 'TESTDRIV')

        TaskWarpPedIntoVehicle(playerPed, vehicle, -1)

        Citizen.CreateThread(function()
            while true do
                Citizen.Wait(1000)

                if (Jobs.CurrentTestDrive ~= nil and DoesEntityExist(Jobs.CurrentTestDrive)) then
                    Jobs.DurationTime = Jobs.DurationTime - 1

                    if (Jobs.DurationTime <= 0) then
                        Jobs.ESX.Game.DeleteVehicle(Jobs.CurrentTestDrive)
                        Jobs.ESX.ShowNotification(_U('vehicle_test_drive_over'))

                        return
                    end
                else
                    Jobs.CurrentTestDrive = nil
                    Jobs.DurationTime = 0

                    return
                end
            end
        end)

        Citizen.CreateThread(function()
            while Jobs.DurationTime > 0 do
                Jobs.DrawOnScreenText(_U('time_left', Jobs.DurationTime), 185, 185, 185, 255)

                Citizen.Wait(0)
            end
        end)
    end)
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    Jobs.PlayerData.job     = job
    Jobs.DrawMarkers        = {}
end)

AddEventHandler("playerSpawned", function()
    TriggerEvent('esx_jobs:stopHostage')
    TriggerEvent('esx_jobs:unhandcuffPlayer')
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() == resourceName) then
        if (Jobs.CurrentSellingVehicle ~= nil and DoesEntityExist(Jobs.CurrentSellingVehicle)) then
            Jobs.ESX.Game.DeleteVehicle(Jobs.CurrentSellingVehicle)
        end

        if (Jobs.CurrentTestDrive ~= nil and DoesEntityExist(Jobs.CurrentTestDrive)) then
            Jobs.ESX.Game.DeleteVehicle(Jobs.CurrentTestDrive)
        end
    end
end)
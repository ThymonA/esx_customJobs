-- Draw blips
Citizen.CreateThread(function()
    while true do
        while not Jobs.JobDataLoaded do
            Citizen.Wait(10)
        end

        if (not Jobs.BlipsLoaded) then
            for _, blip in pairs(Jobs.Blips or {}) do
                RemoveBlip(blip.data)
            end

            local jobData = Jobs.JobData or {}
            local jobInfo = jobData.job or {}

            for _, blip in pairs(jobInfo.blips or {}) do
                local position = blip.position or {}
                local data = AddBlipForCoord(position.x or 0, position.y or 0, position.z or 0)

                SetBlipSprite(data, blip.sprite or 1)
                SetBlipDisplay(data, blip.display or 4)
                SetBlipScale(data, blip.scale or 1.0)
                SetBlipColour(data, blip.colour or 1)
                SetBlipAsShortRange(data, blip.asShortRange or true)
                BeginTextCommandSetBlipName('STRING')
                AddTextComponentString(blip.title)
                EndTextCommandSetBlipName(data)

                blip.data = data

                table.insert(Jobs.Blips, blip)
            end

            Jobs.BlipsLoaded = true
        end

        Citizen.Wait(0)
    end
end)

-- Store marker information
Citizen.CreateThread(function()
    while true do
        local jobData = Jobs.JobData or {}
        local playerPed = GetPlayerPed(-1)
        local coords = GetEntityCoords(playerPed)
        local jobInfo = jobData.job or {}

        Jobs.DrawMarkers = {}

        for markerType, markers in pairs(jobInfo.positions or {}) do
            if (Jobs.DrawMarkers[markerType] == nil) then
                Jobs.DrawMarkers[markerType] = {}
            end

            for _, marker in pairs(markers or {}) do
                if (marker ~= nil and marker.position ~= nil and GetDistanceBetweenCoords(coords, marker.position.x, marker.position.y, marker.position.z, true) < Config.DrawDistance) then
                    table.insert(Jobs.DrawMarkers[markerType], {
                        label = marker.name or 'Unknown',
                        position = marker.position or { x = 0, y = 0, z = 0 },
                        type = marker.type or 'unknown',
                        info = {
                            x = marker.size.x or 1.5,
                            y = marker.size.y or 1.5,
                            z = marker.size.z or 0.5,
                            r = marker.color.r or 255,
                            g = marker.color.g or 0,
                            b = marker.color.b or 0,
                            type = marker.marker or 25
                        },
                        public = marker.public or false,
                        name = marker.name or 'Unknown',
                        action = marker.type or 'unknown',
                        actionInfo = true,
                        addonData = marker.addonData or {},
                        index = marker.index or -1,
                        key = marker.key or 'x',
                        job = marker.job or 'unknown',
                        jobLabel = marker.jobLabel or 'Unknown',
                        primaryColor = marker.primaryColor or { r = 255, g = 0, b = 0 },
                        secondaryColor = marker.secondaryColor or { r = 0, g = 0, b = 0 },
                        headerImage = marker.headerImage or 'menu_default.jpg'
                    })
                end
            end
        end

        Citizen.Wait(2500) -- Every 2.5 sec
    end
end)

-- Draw markers
Citizen.CreateThread(function()
    while true do
        for markerType, markers in pairs(Jobs.DrawMarkers) do
            markers = markers or {}

            for _, marker in pairs(markers) do
                DrawMarker(marker.info.type, marker.position.x, marker.position.y, marker.position.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, marker.info.x, marker.info.y, marker.info.z, marker.info.r, marker.info.g, marker.info.b, 100, false, true, 2, false, false, false, false)
            end
        end

        Citizen.Wait(0)
    end
end)

-- Enter markers
Citizen.CreateThread(function()
    while true do
        Jobs.IsInMarker = false

        local playerPed = GetPlayerPed(-1)
        local coords = GetEntityCoords(playerPed)

        for markerType, markers in pairs(Jobs.DrawMarkers) do
            markers = markers or {}

            for _, marker in pairs(markers) do
                if (GetDistanceBetweenCoords(coords, marker.position.x, marker.position.y, marker.position.z, true) < marker.info.x) then
                    Jobs.IsInMarker = true
                    Jobs.CurrentAction = marker.action
                    Jobs.Marker = marker or {}
                end
            end
        end

        Citizen.Wait(0)
    end
end)

-- Trigger marker events
Citizen.CreateThread(function()
    while true do
        if (Jobs.IsInMarker and Jobs.LastAction == nil) then
            Jobs.HasEnteredMarker()
        elseif (not Jobs.IsInMarker and Jobs.LastAction ~= nil) then
            Jobs.HasExitedMarker()
        end

        Citizen.Wait(0)
    end
end)

-- Open menu when in marker
Citizen.CreateThread(function()
    while true do
        if (Jobs.CurrentAction ~= nil and Jobs.IsInMarker) then
            if (IsControlJustPressed(0, 38)) then
                Jobs.LastAction     = Jobs.CurrentAction .. ''
                Jobs.CurrentAction  = nil

                if (Jobs.DoesMenuExists(Jobs.LastAction)) then
                    Jobs.TriggerMenu(Jobs.LastAction)
                end

                Jobs.CurrentAction  = nil
            end
        end

        Citizen.Wait(0)
    end
end)

-- Open action menu when key pressed
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        -- F6 Menu
        if (IsControlJustReleased(0, 167) and Jobs.HasPermission('action.menu.allow')) then
            Jobs.TriggerMenu('action_menu')
        end
    end
end)

-- Spawn showroom vehicles
Citizen.CreateThread(function()
    while true do
        while not Jobs.JobDataLoaded do
            Citizen.Wait(10)
        end

        local playerPed = GetPlayerPed(-1)
        local coords = GetEntityCoords(playerPed)

        for _, spot in pairs(((Jobs.JobData or {}).job or {}).showrooms or {}) do
            local position = spot.position or nil

            if (position ~= nil and position ~= {} and GetDistanceBetweenCoords(coords, position.x, position.y, position.z, true) < Config.DrawDistance) then
                local spotType = string.lower(spot.type or 'unknown')

                if (spotType == 'car') then
                    if (spot.code ~= nil and spot.code ~= '' and string.lower(spot.code) ~= 'unknown' and string.lower(spot.code) ~= 'none') then
                        local vehicleHash = (type(spot.code) == 'number' and spot.code or GetHashKey(spot.code))

                        if (spot.vehicle == nil and IsModelInCdimage(vehicleHash)) then
                            local veh, distance = Jobs.ESX.Game.GetClosestVehicle(position)

                            if (DoesEntityExist(veh) and distance < 1.0) then
                                local currentVehicleModel = GetEntityModel(veh)

                                if (GetDisplayNameFromVehicleModel(currentVehicleModel) ~= GetDisplayNameFromVehicleModel(vehicleHash)) then
                                    Jobs.ESX.Game.DeleteVehicle(veh)

                                    local vehicleLoaded = Jobs.WaitForVehicleIsLoaded(vehicleHash)

                                    while not vehicleLoaded do
                                        Citizen.Wait(0)
                                    end

                                    Jobs.ESX.Game.SpawnLocalVehicle(vehicleHash, position, position.h or 75.0, function(vehicle)
                                        local props = spot.props or {}

                                        props.windowTint = props.modWindows or -1

                                        Jobs.ESX.Game.SetVehicleProperties(vehicle, props)

                                        SetEntityAsMissionEntity(vehicle, true, true)
                                        SetVehicleOnGroundProperly(vehicle)
                                        FreezeEntityPosition(vehicle, true)
                                        SetEntityInvincible(vehicle, true)
                                        SetVehicleDoorsLocked(vehicle, 2)

                                        spot.vehicle = vehicle
                                    end)
                                else
                                    spot.vehicle = veh
                                end
                            elseif (not DoesEntityExist(veh) or (DoesEntityExist(veh) and distance > 1.0)) then
                                local vehicleLoaded = Jobs.WaitForVehicleIsLoaded(vehicleHash)

                                while not vehicleLoaded do
                                    Citizen.Wait(0)
                                end

                                Jobs.ESX.Game.SpawnLocalVehicle(vehicleHash, position, position.h or 75.0, function(vehicle)
                                    local props = spot.props or {}

                                    props.windowTint = props.modWindows or -1

                                    Jobs.ESX.Game.SetVehicleProperties(vehicle, props)

                                    SetEntityAsMissionEntity(vehicle, true, true)
                                    SetVehicleOnGroundProperly(vehicle)
                                    FreezeEntityPosition(vehicle, true)
                                    SetEntityInvincible(vehicle, true)
                                    SetVehicleDoorsLocked(vehicle, 2)

                                    spot.vehicle = vehicle
                                end)
                            end
                        else
                            if (not DoesEntityExist(spot.vehicle)) then
                                spot.vehicle = nil
                            else
                                local currentVehicleModel = GetEntityModel(spot.vehicle)

                                if (GetDisplayNameFromVehicleModel(currentVehicleModel) ~= GetDisplayNameFromVehicleModel(vehicleHash)) then
                                    spot.vehicle = nil
                                end
                            end
                        end
                    elseif (spot.vehicle ~= nil) then
                        if (not DoesEntityExist(spot.vehicle)) then
                            spot.vehicle = nil
                        else
                            Jobs.ESX.Game.DeleteVehicle(spot.vehicle)
                            spot.vehicle = nil
                        end
                    end
                end
            end
        end

        Citizen.Wait(Config.IntervalShowroomMustCheck)
    end
end)

-- Trigger when player enters marker
Jobs.HasEnteredMarker = function()
    local jobName = Jobs.JobData.job.label or 'Unknown'

    if ((Jobs.Marker or {}).public or false) then
        jobName = (Jobs.Marker or {}).jobLabel or 'Unknown'
    end

    Jobs.ESX.ShowHelpNotification(_U('open_' .. Jobs.GetCurrentAction(), jobName))
end

-- Trigger when player left marker
Jobs.HasExitedMarker = function()
    Jobs.ESX.UI.Menu.CloseAll()
    Jobs.CurrentAction = nil
    Jobs.LastAction = nil
    Jobs.Marker = {}

    if (Jobs.Camera ~= nil) then
        DestroyCam(Jobs.Camera)
        Jobs.Camera = nil
        RenderScriptCams(0, 1, 750, 1, 0)
    end
end

Jobs.GetCurrentAction = function()
    return Jobs.CurrentAction or Jobs.LastAction or ''
end
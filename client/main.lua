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
                        action = marker.type or 'unknown',
                        actionInfo = true,
                        addonData = marker.addonData or {}
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
                    Jobs.CurrentActionInfo = marker.addonData
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

-- Trigger when player enters marker
Jobs.HasEnteredMarker = function()
    local jobName = Jobs.JobData.job.label or 'Unknown'

    Jobs.ESX.ShowHelpNotification(_U('open_' .. Jobs.GetCurrentAction(), jobName))
end

-- Trigger when player left marker
Jobs.HasExitedMarker = function()
    Jobs.ESX.UI.Menu.CloseAll()
    Jobs.CurrentAction = nil
    Jobs.LastAction = nil
    Jobs.CurrentActionInfo = {}
end

Jobs.GetCurrentAction = function()
    return Jobs.CurrentAction or Jobs.LastAction or ''
end
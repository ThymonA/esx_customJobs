-- Store marker information
Citizen.CreateThread(function()
    while true do
        local jobData = Jobs.JobData or {}
        local playerPed = GetPlayerPed(-1)
        local coords = GetEntityCoords(playerPed)
        local jobInfo = jobData.job or {}
        local job2Info = jobData.job2 or {}

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

        for markerType, markers in pairs(job2Info.positions or {}) do
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
                        actionInfo = false,
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
                    Jobs.CurrentActionInfo = marker.actionInfo
                    Jobs.AddonActionData = marker.addonData
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
                    Jobs.TriggerMenu(Jobs.LastAction, Jobs.CurrentActionInfo)
                end

                Jobs.CurrentAction  = nil
            end
        end

        Citizen.Wait(0)
    end
end)

-- Trigger when player enters marker
Jobs.HasEnteredMarker = function()
    local isPrimaryJob = Jobs.CurrentActionInfo

    if (isPrimaryJob == nil) then
        isPrimaryJob = true
    end

    local jobName = 'Unknown'

    if (isPrimaryJob and Jobs.JobData ~= nil and Jobs.JobData.job ~= nil) then
        jobName = Jobs.JobData.job.label or 'Unknown'
    elseif (Jobs.JobData ~= nil and Jobs.JobData.job2 ~= nil) then
        jobName = Jobs.JobData.job2.label or 'Unknown'
    end

    Jobs.ESX.ShowHelpNotification(_U('open_' .. Jobs.GetCurrentAction(), jobName))
end

-- Trigger when player left marker
Jobs.HasExitedMarker = function()
    Jobs.ESX.UI.Menu.CloseAll()
    Jobs.CurrentAction = nil
    Jobs.LastAction = nil
    Jobs.CurrentActionInfo = nil
    Jobs.AddonActionData = {}
end

Jobs.GetCurrentAction = function()
    return Jobs.CurrentAction or Jobs.LastAction or ''
end
-- Store marker information
Citizen.CreateThread(function()
    while true do
        local playerPed = GetPlayerPed(-1)
        local coords = GetEntityCoords(playerPed)

        while Jobs.JobData == nil do
            Citizen.Wait(10)
        end

        local jobInfo = Jobs.JobData.job or {}
        local job2Info = Jobs.JobData.job2 or {}

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
                        actionInfo = jobInfo.label or 'unknown'
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
                        actionInfo = job2Info.label or 'unknown'
                    })
                end
            end
        end

        Citizen.Wait(5000) -- Every 5 sec
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

-- Trigger when player enters marker
Jobs.HasEnteredMarker = function()
    Jobs.ESX.ShowHelpNotification(_U('open_' .. Jobs.GetCurrentAction(), Jobs.CurrentActionInfo or 'Unknown'))
end

-- Trigger when player left marker
Jobs.HasExitedMarker = function()
end

Jobs.GetCurrentAction = function()
    return Jobs.CurrentAction or Jobs.LastAction or ''
end
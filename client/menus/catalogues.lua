Jobs.RegisterMenu('catalogues', function()
    if (not Jobs.HasPermission('catalogues.use')) then
        return
    end

    local job = Jobs.JobData.job.name or 'unknown'
    local marker = Jobs.GetCurrentMarker()

    if (marker.public or false) then
        job = marker.job or job
    end

    Jobs.TriggerServerCallbackWithCustomJob('esx_jobs:getJobCatalogues', job, function(catalogues)
        Jobs.RenderCamera(true)

        local elements = {}

        for _, catalogueItem in pairs(catalogues or {}) do
            table.insert(elements, { label = catalogueItem.label or 'Unknown', value = catalogueItem.code or 'unknown' })
        end

        table.insert(elements, { label = _U('close'), value = '', disabled = true })
        table.insert(elements, { label = _U('close'), value = 'close' })

        if (#elements > 0) then
            local entityModel = elements[1].value or 'unknown'

            Jobs.RenderVehicleSpot(entityModel)
        end

        Jobs.ESX.UI.Menu.Open(
            'job_default',
            GetCurrentResourceName(),
            'catalogues',
            {
                title = _U('catalogues'),
                align = 'top-left',
                elements = elements,
                primaryColor = Jobs.GetPrimaryColor(),
                secondaryColor = Jobs.GetSecondaryColor(),
                image = Jobs.GetCurrentHeaderImage()
            },
            function(data, menu)
                if (data.current.value == 'close') then
                    Jobs.DeleteObject()
                    Jobs.RenderCamera(false)
                    menu.close()
                    return
                end
            end,
            function(data, menu)
                Jobs.DeleteObject()
                Jobs.RenderCamera(false)
                menu.close()
            end,
            function(data, menu)
                local entityModel = data.current.value or 'unknown'

                Jobs.RenderVehicleSpot(entityModel)
            end)
    end, (Jobs.GetCurrentMarkerIndex() or -1))
end)

Jobs.RenderCamera = function(toggle)
    local camera = (Jobs.GetCurrentData() or {}).camera or nil

    print(json.encode(camera))

    if (camera == nil) then
        return
    end

    if (not toggle) then
        if (Jobs.Camera ~= nil) then
            DestroyCam(Jobs.Camera)
            Jobs.Camera = nil
        end

        Jobs.DeleteObject()

        RenderScriptCams(0, 1, 750, 1, 0)

        return
    end

    if (Jobs.Camera ~= nil) then
        DestroyCam(Jobs.Camera)
        Jobs.Camera = nil
    end

    Jobs.Camera = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)

    SetCamCoord(Jobs.Camera, camera.x, camera.y, camera.z)
    SetCamRot(Jobs.Camera, camera.rotationX, camera.rotationY, camera.rotationZ)
    SetCamActive(Jobs.Camera, true)

    RenderScriptCams(1, 1, 750, 1, 1)

    Citizen.Wait(500)
end

Jobs.RenderVehicleSpot = function(model)
    local position = Jobs.GetPosition()

    if (model ~= nil and model ~= '' and string.lower(model) ~= 'unknown' and string.lower(model) ~= 'none') then
        local vehicleHash = (type(model) == 'number' and model or GetHashKey(model))

        if (IsModelInCdimage(vehicleHash)) then
            local veh, distance = Jobs.ESX.Game.GetClosestVehicle(position)

            if (DoesEntityExist(veh) and distance < 1.0) then
                local currentVehicleModel = GetEntityModel(veh)

                if (currentVehicleModel ~= vehicleHash) then
                    Jobs.ESX.Game.DeleteVehicle(veh)

                    Jobs.ESX.Game.SpawnLocalVehicle(vehicleHash, position, position.h or 75.0, function(vehicle)
                        FreezeEntityPosition(vehicle, true)
                    end)
                end
            elseif (DoesEntityExist(veh) and distance > 1.0) then
                Jobs.ESX.Game.SpawnLocalVehicle(vehicleHash, position, position.h or 75.0, function(vehicle)
                    FreezeEntityPosition(vehicle, true)
                end)
            elseif (not DoesEntityExist(veh)) then
                Jobs.ESX.Game.SpawnLocalVehicle(vehicleHash, position, position.h or 75.0, function(vehicle)
                    FreezeEntityPosition(vehicle, true)
                end)
            end
        else
            local veh, distance = Jobs.ESX.Game.GetClosestVehicle(position)

            if (DoesEntityExist(veh) and distance < 1.0) then
                Jobs.ESX.Game.DeleteVehicle(veh)
            end
        end
    else
        local veh, distance = Jobs.ESX.Game.GetClosestVehicle(position)

        if (DoesEntityExist(veh) and distance < 1.0) then
            Jobs.ESX.Game.DeleteVehicle(veh)
        end
    end
end

Jobs.DeleteObject = function()
    local markerType = (Jobs.GetCurrentData() or {}).type or 'unknown'

    if (markerType == 'car') then
        local position = Jobs.GetPosition()
        local veh, distance = Jobs.ESX.Game.GetClosestVehicle(position)

        if (DoesEntityExist(veh) and distance < 1.0) then
            Jobs.ESX.Game.DeleteVehicle(veh)
        end
    end
end

Jobs.GetPosition = function()
    return (Jobs.GetCurrentData() or {}).spawn or { x = 0, y = 0, z = 0, h = 0 }
end
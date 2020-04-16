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

        Citizen.CreateThread(function()
            local form = Jobs.SetupScaleform("instructional_buttons")

            while Jobs.Camera ~= nil do
                DrawScaleformMovieFullscreen(form, 255, 255, 255, 255, 0)

                Citizen.Wait(0)
            end
        end)

        Citizen.CreateThread(function()
            local playerPed = GetPlayerPed(-1)

            while Jobs.Camera ~= nil do
                FreezeEntityPosition(playerPed, true)

                while IsControlPressed(0, 189) do
                    Jobs.RotateEntity(5, false)
                    Citizen.Wait(25)
                end

                while IsControlPressed(0, 190) do
                    Jobs.RotateEntity(5, true)
                    Citizen.Wait(25)
                end

                Citizen.Wait(0)
            end

            FreezeEntityPosition(playerPed, false)
        end)

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

                SetVehicleDoorCanBreak(Jobs.CurrentVehicle, 0, false)
                SetVehicleDoorCanBreak(Jobs.CurrentVehicle, 1, false)
                SetVehicleDoorCanBreak(Jobs.CurrentVehicle, 2, false)
                SetVehicleDoorCanBreak(Jobs.CurrentVehicle, 3, false)
                SetVehicleDoorCanBreak(Jobs.CurrentVehicle, 4, false)
                SetVehicleDoorCanBreak(Jobs.CurrentVehicle, 5, false)
                SetVehicleDoorCanBreak(Jobs.CurrentVehicle, 6, false)

                if (Jobs.CurrentVehicle ~= nil and DoesEntityExist(Jobs.CurrentVehicle) and not Jobs.DoorsAreOpen) then
                    SetVehicleDoorOpen(Jobs.CurrentVehicle, 0, false)
                    SetVehicleDoorOpen(Jobs.CurrentVehicle, 1, false)
                    SetVehicleDoorOpen(Jobs.CurrentVehicle, 2, false)
                    SetVehicleDoorOpen(Jobs.CurrentVehicle, 3, false)
                    SetVehicleDoorOpen(Jobs.CurrentVehicle, 4, false)
                    SetVehicleDoorOpen(Jobs.CurrentVehicle, 5, false)
                    SetVehicleDoorOpen(Jobs.CurrentVehicle, 6, false)

                    Jobs.DoorsAreOpen = true
                elseif (Jobs.CurrentVehicle ~= nil and DoesEntityExist(Jobs.CurrentVehicle) and Jobs.DoorsAreOpen) then
                    SetVehicleDoorShut(Jobs.CurrentVehicle, 0, true)
                    SetVehicleDoorShut(Jobs.CurrentVehicle, 1, true)
                    SetVehicleDoorShut(Jobs.CurrentVehicle, 2, true)
                    SetVehicleDoorShut(Jobs.CurrentVehicle, 3, true)
                    SetVehicleDoorShut(Jobs.CurrentVehicle, 4, true)
                    SetVehicleDoorShut(Jobs.CurrentVehicle, 5, true)
                    SetVehicleDoorShut(Jobs.CurrentVehicle, 6, true)

                    Jobs.DoorsAreOpen = false
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
            if (DoesEntityExist(Jobs.CurrentVehicle)) then
                local currentVehicleModel = GetEntityModel(Jobs.CurrentVehicle)

                if (currentVehicleModel ~= vehicleHash) then
                    Jobs.DeleteObject()
                    Jobs.ESX.Game.SpawnLocalVehicle(vehicleHash, position, position.h or 75.0, function(vehicle)
                        local props = (Jobs.GetCurrentData() or {}).vehicleprops or {}

                        props.windowTint = props.modWindows or -1

                        Jobs.ESX.Game.SetVehicleProperties(vehicle, props)

                        Jobs.CurrentVehicle = vehicle
                        Jobs.DoorsAreOpen = false

                        SetEntityAsMissionEntity(vehicle, true, true)
                        SetVehicleOnGroundProperly(vehicle)
                        FreezeEntityPosition(vehicle, true)
                        SetEntityInvincible(vehicle, true)
                        SetVehicleDoorsLocked(vehicle, 2)
                    end)
                end
            elseif (not DoesEntityExist(Jobs.CurrentVehicle)) then
                Jobs.DeleteObject()
                Jobs.ESX.Game.SpawnLocalVehicle(vehicleHash, position, position.h or 75.0, function(vehicle)
                    local props = (Jobs.GetCurrentData() or {}).vehicleprops or {}

                    props.windowTint = props.modWindows or -1

                    Jobs.ESX.Game.SetVehicleProperties(vehicle, props)

                    Jobs.CurrentVehicle = vehicle
                    Jobs.DoorsAreOpen = false

                    SetEntityAsMissionEntity(vehicle, true, true)
                    SetVehicleOnGroundProperly(vehicle)
                    FreezeEntityPosition(vehicle, true)
                    SetEntityInvincible(vehicle, true)
                    SetVehicleDoorsLocked(vehicle, 2)
                end)
            end
        else
            Jobs.DeleteObject()
        end
    else
        Jobs.DeleteObject()
    end
end

Jobs.DeleteObject = function()
    local markerType = (Jobs.GetCurrentData() or {}).type or 'unknown'

    if (markerType == 'car') then
        if (DoesEntityExist(Jobs.CurrentVehicle)) then
            Jobs.ESX.Game.DeleteVehicle(Jobs.CurrentVehicle)
        end

        local position = Jobs.GetPosition()
        local veh, distance = Jobs.ESX.Game.GetClosestVehicle(position)

        if (DoesEntityExist(veh) and distance < 1.0) then
            Jobs.ESX.Game.DeleteVehicle(veh)
        end
    end
end

Jobs.RotateEntity = function(direction, added)
    direction = direction or 0
    added = added or false

    if (Jobs.CurrentVehicle ~= nil and DoesEntityExist(Jobs.CurrentVehicle)) then
        local entityHeading = GetEntityHeading(Jobs.CurrentVehicle)

        if (added) then
            entityHeading = (entityHeading + direction) % 360
        else
            entityHeading = (entityHeading - direction) % 360
        end

        SetEntityHeading(Jobs.CurrentVehicle, entityHeading)
    end
end

Jobs.SetupScaleform = function(scaleform)
    local scaleform = RequestScaleformMovie(scaleform)

    while not HasScaleformMovieLoaded(scaleform) do
        Citizen.Wait(0)
    end

    PushScaleformMovieFunction(scaleform, "CLEAR_ALL")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_CLEAR_SPACE")
    PushScaleformMovieFunctionParameterInt(200)
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(0)
    Jobs.GetButton (GetControlInstructionalButton(2, 194, true))
    Jobs.DrawButtonNotification(_U('backspace_close'))
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(1)
    Jobs.GetButton (GetControlInstructionalButton(2, 191, true))
    Jobs.DrawButtonNotification(_U('inspect_object'))
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(2)
    Jobs.GetButton (GetControlInstructionalButton(2, 190, true))
    Jobs.DrawButtonNotification(_U('rotate_object_right'))
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(3)
    Jobs.GetButton (GetControlInstructionalButton(2, 189, true))
    Jobs.DrawButtonNotification(_U('rotate_object_left'))
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_BACKGROUND_COLOUR")
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(80)
    PopScaleformMovieFunctionVoid()

    return scaleform
end
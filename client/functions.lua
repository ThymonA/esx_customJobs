Jobs.RegisterMenu = function(menuType, func)
    if (Jobs.Menus == nil) then
        Jobs.Menus = {}
    end

    Jobs.Menus[menuType] = func
end

Jobs.DoesMenuExists = function(menyType)
    return Jobs.Menus ~= nil and Jobs.Menus[menyType] ~= nil
end

Jobs.TriggerMenu = function(menuType, ...)
    if (Jobs.DoesMenuExists(menuType)) then
        Jobs.ESX.UI.Menu.CloseAll()
        Jobs.Menus[menuType](...)
    end
end

Jobs.GetPrimaryColor = function(opacity)
    opacity = opacity or 1.0

    local primaryColor = ((Jobs.JobData or {}).job or {}).primaryColor or { r = 255, g = 0, b = 0 }

    if ((Jobs.Marker or {}).public or false) then
        primaryColor = (Jobs.Marker or {}).primaryColor or primaryColor
    end

    return 'rgba(' .. primaryColor.r .. ',' .. primaryColor.g .. ',' .. primaryColor.b .. ',' .. tostring(opacity) .. ')'
end

Jobs.GetSecondaryColor = function(opacity)
    opacity = opacity or 1.0

    local secondaryColor = ((Jobs.JobData or {}).job or {}).secondaryColor or { r = 0, g = 0, b = 0 }

    if ((Jobs.Marker or {}).public or false) then
        secondaryColor = (Jobs.Marker or {}).secondaryColor or secondaryColor
    end

    return 'rgba(' .. secondaryColor.r .. ',' .. secondaryColor.g .. ',' .. secondaryColor.b .. ',' .. tostring(opacity) .. ')'
end

Jobs.GetCurrentHeaderImage = function()
    local headerImage = ((Jobs.JobData or {}).job or {}).headerImage or 'menu_default.jpg'

    if ((Jobs.Marker or {}).public or false) then
        headerImage = (Jobs.Marker or {}).headerImage or headerImage
    end

    return headerImage
end

Jobs.HasPermission = function(permission)
    return Jobs.Permissions.hasAnyPermission(((Jobs.JobData or {}).job or {}).permissions or {}, permission)
end

Jobs.HasAnyPermission = function(permissions)
    if (string.lower(type(permissions)) ~= 'table') then
        return Jobs.Permissions.hasAnyPermission(((Jobs.JobData or {}).job or {}).permissions or {}, permissions)
    end

    for _, permission in pairs(permissions) do
        if (Jobs.Permissions.hasAnyPermission(((Jobs.JobData or {}).job or {}).permissions or {}, permission)) then
            return true
        end
    end

    return false
end

Jobs.GetCurrentJobValue = function()
    return (Jobs.JobData or {}).job or {}
end

Jobs.GetCurrentData = function()
    return (Jobs.Marker or {}).addonData or {}
end

Jobs.GetCurrentMarkerIndex = function()
    return (Jobs.Marker or {}).index or -1
end

Jobs.GetCurrentMarker = function()
    return Jobs.Marker or {}
end

Jobs.TriggerServerCallback = function(name, cb, ...)
    Jobs.ServerCallbacks[Jobs.RequestId] = cb

    TriggerServerEvent('esx_jobs:triggerServerCallback', name, Jobs.RequestId, ...)

    if (Jobs.RequestId < 65535) then
        Jobs.RequestId = Jobs.RequestId + 1
    else
        Jobs.RequestId = 0
    end
end

Jobs.TriggerServerEvent = function(name, ...)
    TriggerServerEvent('esx_jobs:triggerServerEvent', name, ...)
end

Jobs.TriggerServerCallbackWithCustomJob = function(name, job, cb, ...)
    Jobs.ServerCallbacks[Jobs.RequestId] = cb

    TriggerServerEvent('esx_jobs:triggerServerCallbackWithCustomJob', name, job, Jobs.RequestId, ...)

    if (Jobs.RequestId < 65535) then
        Jobs.RequestId = Jobs.RequestId + 1
    else
        Jobs.RequestId = 0
    end
end

Jobs.TriggerServerEventkWithCustomJob = function(name, job, ...)
    TriggerServerEvent('esx_jobs:triggerServerEventWithCustomJob', name, job, ...)
end

Jobs.AddLabel = function(serverId, text, action)
    action = action or 'none'

    if (Jobs.LabelDisplaying[tostring(serverId)] == nil) then
        Jobs.LabelDisplaying[tostring(serverId)] = {}
    end

    table.insert(Jobs.LabelDisplaying[tostring(serverId)], {
        text = text,
        action = action
    })
end

Jobs.RemoveActionLabel = function(serverId, action)
    action = action or 'none'

    if (action == 'none') then
        Jobs.LabelDisplaying[tostring(serverId)] = {}
    else
        if (Jobs.LabelDisplaying[tostring(serverId)] == nil) then
            Jobs.LabelDisplaying[tostring(serverId)] = {}
        end

        for _, label in pairs(Jobs.LabelDisplaying[tostring(serverId)]) do
            local currentAction = label.action or 'none'

            if (string.lower(currentAction) == string.lower(action)) then
                table.remove(Jobs.LabelDisplaying[tostring(serverId)], _)
            end
        end
    end
end

Jobs.GetVehicleInPedDirection = function(playerPedId)
    local playerPed    = GetPlayerPed(playerPedId)
	local playerCoords = GetEntityCoords(playerPed)
	local inDirection  = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 5.0, 0.0)
	local rayHandle    = StartShapeTestRay(playerCoords, inDirection, 10, playerPed, 0)
	local numRayHandle, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(rayHandle)

	if hit == 1 and GetEntityType(entityHit) == 2 then
		return entityHit
	end

	return nil
end

Jobs.GetActionKey = function(action)
    if (Config.Keys ~= nil and Config.Keys[string.lower(action)] ~= nil) then
        return Config.Keys[string.lower(action)]
    end

    return nil
end

Jobs.Draw3DText = function(coords, text)
    local camCoords = GetGameplayCamCoord()
    local dist = #(coords - camCoords)
    local scale = 200 / (GetGameplayCamFov() * dist)

    -- Format the text
    SetTextColour(230, 230, 230, 255 )
    SetTextScale(0.0, 0.25 * scale)
    SetTextDropshadow(0, 0, 0, 0, 55)
    SetTextDropShadow()
    SetTextCentre(true)

    -- Diplay the text
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    SetDrawOrigin(coords, 0)
    EndTextCommandDisplayText(0.0, 0.0)
    ClearDrawOrigin()
end

Jobs.DrawButtonNotification = function(msg)
    BeginTextCommandScaleformString("STRING")
    AddTextComponentScaleform(msg)
    EndTextCommandScaleformString()
end

Jobs.GetButton = function(button)
    N_0xe83a3e3557a56640(button)
end

Jobs.GetPosition = function()
    return (Jobs.GetCurrentData() or {}).spawn or { x = 0, y = 0, z = 0, h = 0 }
end

Jobs.DrawText3D = function(position, text, extraHeight)
    extraHeight = tonumber(tostring(extraHeight or 0))

    if (not Jobs.Drawing) then
        Jobs.Drawing = true

        local onScreen, x, y = GetScreenCoordFromWorldCoord((position.x or 0), (position.y or 0), (position.z or 0) + extraHeight)
        local playerX, playerY, playerZ = table.unpack(GetGameplayCamCoord())
        local distance = GetDistanceBetweenCoords(playerX, playerY, playerZ, (position.x or 0), (position.y or 0), (position.z or 0) + extraHeight, 1)
        local scale = ((1 / distance) * 2) * (1 / GetGameplayCamFov()) * 100

        if (onScreen) then
            SetTextColour(255, 255, 255, 215)
            SetTextScale(0.0 * scale, 0.35 * scale)
            SetTextFont(0)
            SetTextProportional(1)
            SetTextCentre(true)

            BeginTextCommandWidth("STRING")
            AddTextComponentString(text)

            local height = GetTextScaleHeight(0.50 * scale, 4)
            local width = EndTextCommandGetWidth(0)

            SetTextEntry("STRING")
            AddTextComponentString(text)
            EndTextCommandDisplayText(x, y)

            DrawRect(x, y + scale / 90, width, height, 0, 0, 0, 100)
        end

        Jobs.Drawing = false
    end
end

Jobs.DrawOnScreenText = function(text, red, green, blue, alpha)
    SetTextFont(4)
	SetTextProportional(1)
	SetTextScale(0.64, 0.64)
	SetTextColour(red, green, blue, alpha)
	SetTextDropShadow(0, 0, 0, 0, 255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextEntry("STRING")
	AddTextComponentString(text)
    DrawText(0.155, 0.935)
end

Jobs.WaitForVehicleIsLoaded = function(vehicleHash)
	vehicleHash = (type(vehicleHash) == 'number' and vehicleHash or GetHashKey(vehicleHash))

	if not HasModelLoaded(vehicleHash) then
		RequestModel(vehicleHash)

		while not HasModelLoaded(vehicleHash) do
			Citizen.Wait(0)
		end

        return true
    else
        return true
	end
end

Jobs.GenerateSellingVehicleLabel = function(key)
    local sellingInfo = (Jobs.CurrentSellingVehicles or {})[key] or nil

    if (sellingInfo == nil) then
        return
    end

    local position = sellingInfo.cashedPosition or { x = 0, y = 0, z = 0, h = 0 }
    local vehicle = GetDisplayNameFromVehicleModel(sellingInfo.cashedHash or 0)
    local price = Jobs.Formats.NumberToCurrancy(sellingInfo.price or 0)

    Jobs.DrawText3D(position, _U('sell_veh_line1', vehicle, price), 1.00)
    Jobs.DrawText3D(position, _U('sell_veh_line2', Config.Keys['sell_buy'].label), 0.875)
    Jobs.DrawText3D(position, _U('sell_veh_line3', Config.Keys['sell_testdrive'].label), 0.75)
    Jobs.DrawText3D(position, _U('sell_veh_line4', Config.Keys['sell_declined'].label), 0.625)
end
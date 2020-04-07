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

    return 'rgba(' .. primaryColor.r .. ',' .. primaryColor.g .. ',' .. primaryColor.b .. ',' .. tostring(opacity) .. ')'
end

Jobs.GetSecondaryColor = function(opacity)
    opacity = opacity or 1.0

    local secondaryColor = ((Jobs.JobData or {}).job or {}).secondaryColor or { r = 0, g = 0, b = 0 }

    return 'rgba(' .. secondaryColor.r .. ',' .. secondaryColor.g .. ',' .. secondaryColor.b .. ',' .. tostring(opacity) .. ')'
end

Jobs.GetCurrentHeaderImage = function()
    return ((Jobs.JobData or {}).job or {}).headerImage or 'menu_default.jpg'
end

Jobs.HasPermission = function(permission)
    return Jobs.Permissions.hasAnyPermission(((Jobs.JobData or {}).job or {}).permissions or {}, permission)
end

Jobs.GetCurrentJobValue = function()
    return (Jobs.JobData or {}).job or {}
end

Jobs.GetCurrentData = function()
    return Jobs.CurrentActionInfo or {}
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
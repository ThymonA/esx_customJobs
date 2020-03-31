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
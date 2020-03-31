Jobs.RegisterMenu = function(menuType, func)
    if (Jobs.Menus == nil) then
        Jobs.Menus = {}
    end

    Jobs.Menus[menuType] = func
end

Jobs.DoesMenuExists = function(menyType)
    return Jobs.Menus ~= nil and Jobs.Menus[menyType] ~= nil
end

Jobs.TriggerMenu = function(menuType, isPrimaryJob, ...)
    if (isPrimaryJob == nil) then
        isPrimaryJob = true
    end

    if (Jobs.DoesMenuExists(menuType)) then
        Jobs.ESX.UI.Menu.CloseAll()
        Jobs.Menus[menuType](isPrimaryJob, ...)
    end
end

Jobs.GetPrimaryColor = function(isPrimaryJob, opacity)
    if (isPrimaryJob == nil) then
        isPrimaryJob = true
    end

    opacity = opacity or 1.0

    if (isPrimaryJob) then
        local primaryColor = ((Jobs.JobData or {}).job or {}).primaryColor or { r = 255, g = 0, b = 0 }

        return 'rgba(' .. primaryColor.r .. ',' .. primaryColor.g .. ',' .. primaryColor.b .. ',' .. tostring(opacity) .. ')'
    end

    local primaryColor = ((Jobs.JobData or {}).job2 or {}).primaryColor or { r = 255, g = 0, b = 0 }

    return 'rgba(' .. primaryColor.r .. ',' .. primaryColor.g .. ',' .. primaryColor.b .. ',' .. tostring(opacity) .. ')'
end

Jobs.GetSecondaryColor = function(isPrimaryJob, opacity)
    if (isPrimaryJob == nil) then
        isPrimaryJob = true
    end

    opacity = opacity or 1.0

    if (isPrimaryJob) then
        local secondaryColor = ((Jobs.JobData or {}).job or {}).secondaryColor or { r = 0, g = 0, b = 0 }

        return 'rgba(' .. secondaryColor.r .. ',' .. secondaryColor.g .. ',' .. secondaryColor.b .. ',' .. tostring(opacity) .. ')'
    end

    local secondaryColor = ((Jobs.JobData or {}).job2 or {}).secondaryColor or { r = 0, g = 0, b = 0 }

    return 'rgba(' .. secondaryColor.r .. ',' .. secondaryColor.g .. ',' .. secondaryColor.b .. ',' .. tostring(opacity) .. ')'
end

Jobs.GetCurrentHeaderImage = function(isPrimaryJob)
    if (isPrimaryJob == nil) then
        isPrimaryJob = true
    end

    if (isPrimaryJob) then
        return ((Jobs.JobData or {}).job or {}).headerImage or 'menu_default.jpg'
    end

    return ((Jobs.JobData or {}).job2 or {}).headerImage or 'menu_default.jpg'
end

Jobs.HasPermission = function(permission, isPrimaryJob)
    if (isPrimaryJob == nil) then
        isPrimaryJob = true
    end

    if (isPrimaryJob) then
        return Jobs.Permissions.hasAnyPermission(((Jobs.JobData or {}).job or {}).permissions or {}, permission)
    end

    return Jobs.Permissions.hasAnyPermission(((Jobs.JobData or {}).job2 or {}).permissions or {}, permission)
end

Jobs.GetCurrentJobValue = function(isPrimaryJob)
    if (isPrimaryJob == nil) then
        isPrimaryJob = true
    end

    if (isPrimaryJob) then
        return (Jobs.JobData or {}).job or {}
    end

    return (Jobs.JobData or {}).job2 or {}
end

Jobs.GetCurrentAddonData = function()
    return Jobs.AddonActionData or {}
end

Jobs.TriggerServerCallback = function(name, isPrimaryJob, cb, ...)
    if (isPrimaryJob == nil) then
        isPrimaryJob = true
    end

    Jobs.ServerCallbacks[Jobs.RequestId] = cb

    TriggerServerEvent('esx_jobs:triggerServerCallback', name, Jobs.RequestId, isPrimaryJob, ...)

    if (Jobs.RequestId < 65535) then
        Jobs.RequestId = Jobs.RequestId + 1
    else
        Jobs.RequestId = 0
    end
end
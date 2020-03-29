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
    if (Jobs.DoesMenuExists(menuType)) then
        Jobs.Menus[menuType](isPrimaryJob, ...)
    end
end

Jobs.GetPrimaryColor = function(isPrimaryJob, opacity)
    isPrimaryJob = isPrimaryJob or true
    opacity = opacity or 1.0

    if (isPrimaryJob) then
        local primaryColor = ((Jobs.JobData or {}).job or {}).primaryColor or { r = 255, g = 0, b = 0 }

        return 'rgba(' .. primaryColor.r .. ',' .. primaryColor.g .. ',' .. primaryColor.b .. ',' .. tostring(opacity) .. ')'
    end

    local primaryColor = ((Jobs.JobData or {}).job2 or {}).primaryColor or { r = 255, g = 0, b = 0 }

    return 'rgba(' .. primaryColor.r .. ',' .. primaryColor.g .. ',' .. primaryColor.b .. ',' .. tostring(opacity) .. ')'
end

Jobs.GetSecondaryColor = function(isPrimaryJob, opacity)
    isPrimaryJob = isPrimaryJob or true
    opacity = opacity or 1.0

    if (isPrimaryJob) then
        local secondaryColor = ((Jobs.JobData or {}).job or {}).secondaryColor or { r = 0, g = 0, b = 0 }

        return 'rgba(' .. secondaryColor.r .. ',' .. secondaryColor.g .. ',' .. secondaryColor.b .. ',' .. tostring(opacity) .. ')'
    end

    local secondaryColor = ((Jobs.JobData or {}).job2 or {}).secondaryColor or { r = 0, g = 0, b = 0 }

    return 'rgba(' .. secondaryColor.r .. ',' .. secondaryColor.g .. ',' .. secondaryColor.b .. ',' .. tostring(opacity) .. ')'
end

Jobs.GetCurrentHeaderImage = function(isPrimaryJob)
    isPrimaryJob = isPrimaryJob or true

    if (isPrimaryJob) then
        return ((Jobs.JobData or {}).job or {}).headerImage or 'menu_default.jpg'
    end

    return ((Jobs.JobData or {}).job2 or {}).headerImage or 'menu_default.jpg'
end
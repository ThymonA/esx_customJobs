Jobs.RegisterServerCallback('esx_jobs:getShowroomSpots', function(xPlayer, xJob, callback, index)
    if (not xJob.memberHasPermission(xPlayer.identifier, 'showroom.add') and not xJob.memberHasPermission(xPlayer.identifier, 'showroom.remove')) then
        TriggerClientEvent('esx:showNotification', xPlayer.source, _U('error_no_permission'))
        return
    end

    index = tonumber(index or -1)

    local spots = xJob.getShowroomSpots(index)

    callback(spots)
end)

Jobs.RegisterServerCallback('esx_jobs:getSpotObjects', function(xPlayer, xJob, callback, showroomIndex, spotIndex)
    if (not xJob.memberHasPermission(xPlayer.identifier, 'showroom.add')) then
        TriggerClientEvent('esx:showNotification', xPlayer.source, _U('error_no_permission'))
        return
    end

    showroomIndex = tonumber(showroomIndex or -1)
    spotIndex = tonumber(spotIndex or -1)

    local spotType = xJob.getShowroomSpotType(showroomIndex, spotIndex) or 'unknown'
    local items = xJob.getSellableItemsByType(spotType)

    callback(items)
end)

Jobs.RegisterServerEvent('esx_jobs:addOrUpdateSpotObject', function(xPlayer, xJob, showroomIndex, spotIndex, code)
    if (not xJob.memberHasPermission(xPlayer.identifier, 'showroom.add')) then
        TriggerClientEvent('esx:showNotification', xPlayer.source, _U('error_no_permission'))
        return
    end

    showroomIndex = tonumber(showroomIndex or -1)
    spotIndex = tonumber(spotIndex or -1)
    code = code or 'unknown'

    local spotType = xJob.getShowroomSpotType(showroomIndex, spotIndex) or 'unknown'
    local items = xJob.getSellableItemsByType(spotType)

    for _, item in pairs(items) do
        if (string.lower(item.code) == string.lower(code)) then
            local showroom = xJob.getShowroom(showroomIndex)

            if (showroom ~= nil) then
                showroom.updateSpotObject(spotIndex, item.code)

                TriggerClientEvent('esx:showNotification', xPlayer.source, _U('showroom_spot_updated', showroom.getName(), item.label))
            end

            break
        end
    end
end)
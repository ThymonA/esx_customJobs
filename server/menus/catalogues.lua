Jobs.RegisterServerCallback('esx_jobs:getJobCatalogues', function(xPlayer, xJob, callback, markerIndex)
    if (not xJob.memberHasPermission(xPlayer.identifier, 'catalogues.use')) then
        TriggerClientEvent('esx:showNotification', xPlayer.source, _U('error_no_permission'))
        return
    end

    local marker = xJob.getPositionsByIndex(markerIndex or 0)

    if (marker == nil) then
        callback({})
        return
    end

    if (string.lower(marker.type or 'unknown') == 'catalogues') then
        local markerType = (marker.addonData or {}).type or 'unknown'
        local items = xJob.getSellableItemsByType(markerType) or {}

        callback(items)
    else
        callback({})
    end
end)
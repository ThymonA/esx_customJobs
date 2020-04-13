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
        local elements = {}

        for _, catalogueItem in pairs(catalogues or {}) do
            table.insert(elements, { label = catalogueItem.label or 'Unknown', value = catalogueItem.code or 'unknown' })
        end

        table.insert(elements, { label = _U('close'), value = '', disabled = true })
        table.insert(elements, { label = _U('close'), value = 'close' })

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
                if (data.current.value == 'back') then
                    Jobs.TriggerMenu('showroom')
                end

                local index = tonumber(data.current.value or 0)

                if ((index or 0) > 0) then
                    Jobs.TriggerMenu('showroom_add_object', index)
                end
            end,
            function(data, menu)
                Jobs.TriggerMenu('showroom')
            end)
    end, (Jobs.GetCurrentMarkerIndex() or -1))
end)
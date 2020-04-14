Jobs.RegisterMenu('showroom', function()
    if (not Jobs.HasAnyPermission({ 'showroom.add', 'showroom.remove' })) then
        return
    end

    local elements = {}

    if (Jobs.HasPermission('showroom.add')) then
        table.insert(elements, { label = _U('showroom_add'), value = 'showroom_add' })
    end

    if (Jobs.HasPermission('showroom.remove')) then
        table.insert(elements, { label = _U('showroom_remove'), value = 'showroom_remove' })
    end

    Jobs.ESX.UI.Menu.Open(
        'job_default',
        GetCurrentResourceName(),
        'showroom',
        {
            title = _U('showroom'),
            align = 'top-left',
            elements = elements,
            primaryColor = Jobs.GetPrimaryColor(),
            secondaryColor = Jobs.GetSecondaryColor(),
            image = Jobs.GetCurrentHeaderImage()
        },
        function(data, menu)
            if (data.current.value == 'showroom_add' and Jobs.HasPermission('showroom.add')) then
                Jobs.TriggerMenu('showroom_add')
            elseif (data.current.value == 'showroom_remove' and Jobs.HasPermission('showroom.remove')) then
                Jobs.TriggerMenu('showroom_remove')
            end
        end,
        function(data, menu)
            menu.close()
        end)
end)

Jobs.RegisterMenu('showroom_add', function()
    if (not Jobs.HasPermission('showroom.add')) then
        return
    end

    Jobs.TriggerServerCallback('esx_jobs:getShowroomSpots', function(spots)
        local elements = {}

        for _, spot in pairs(spots) do
            table.insert(elements, { label = spot.label or 'Unknown', value = spot.index, disabled = (spot.locked or false) })
        end

        table.insert(elements, { label = _U('back'), value = '', disabled = true })
        table.insert(elements, { label = _U('back'), value = 'back' })

        Jobs.ESX.UI.Menu.Open(
            'job_default',
            GetCurrentResourceName(),
            'showroom_add',
            {
                title = _U('showroom_add'),
                align = 'top-left',
                elements = elements,
                primaryColor = Jobs.GetPrimaryColor(),
                secondaryColor = Jobs.GetSecondaryColor(),
                image = Jobs.GetCurrentHeaderImage()
            },
            function(data, menu)
                if (data.current.value == 'back') then
                    Jobs.TriggerMenu('showroom')
                    return
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

Jobs.RegisterMenu('showroom_add_object', function(spotIndex)
    if (not Jobs.HasPermission('showroom.add')) then
        return
    end

    Jobs.TriggerServerCallback('esx_jobs:getSpotObjects', function(objects)
        local elements = {}

        for _, object in pairs(objects) do
            table.insert(elements, { label = object.label or 'Unknown', value = object.code })
        end

        table.insert(elements, { label = _U('back'), value = '', disabled = true })
        table.insert(elements, { label = _U('back'), value = 'back' })

        Jobs.ESX.UI.Menu.Open(
            'job_default',
            GetCurrentResourceName(),
            'showroom_add_object',
            {
                title = _U('showroom_add_object'),
                align = 'top-left',
                elements = elements,
                primaryColor = Jobs.GetPrimaryColor(),
                secondaryColor = Jobs.GetSecondaryColor(),
                image = Jobs.GetCurrentHeaderImage()
            },
            function(data, menu)
                if (data.current.value == 'back') then
                    Jobs.TriggerMenu('showroom_add')
                end

                Jobs.TriggerServerEvent('esx_jobs:addOrUpdateSpotObject', (Jobs.GetCurrentMarkerIndex() or -1), spotIndex, data.current.value)

                Jobs.TriggerMenu('showroom_add')
            end,
            function(data, menu)
                Jobs.TriggerMenu('showroom_add')
            end)
    end, (Jobs.GetCurrentMarkerIndex() or -1), spotIndex)
end)

Jobs.RegisterMenu('showroom_remove', function()
    if (not Jobs.HasPermission('showroom.remove')) then
        return
    end

    Jobs.TriggerServerCallback('esx_jobs:getShowroomSpots', function(spots)
        local elements = {}

        for _, spot in pairs(spots) do
            table.insert(elements, { label = spot.label or 'Unknown', value = spot.index, disabled = not (spot.locked or false) })
        end

        table.insert(elements, { label = _U('back'), value = '', disabled = true })
        table.insert(elements, { label = _U('back'), value = 'back' })

        Jobs.ESX.UI.Menu.Open(
            'job_default',
            GetCurrentResourceName(),
            'showroom_remove',
            {
                title = _U('showroom_remove'),
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
                    Jobs.TriggerServerEvent('esx_jobs:removeSpotObject', (Jobs.GetCurrentMarkerIndex() or -1), index)

                    Jobs.TriggerMenu('showroom')
                end
            end,
            function(data, menu)
                Jobs.TriggerMenu('showroom')
            end)
    end, (Jobs.GetCurrentMarkerIndex() or -1))
end)
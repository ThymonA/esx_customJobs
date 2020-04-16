Jobs.RegisterMenu('vehicles', function()
    if (not Jobs.HasPermission('vehicle.spawn')) then
        return
    end

    local elements = {}

    table.insert(elements, { label = _U('vehicles'), value = '', disabled = true })

    for _, vehicle in pairs(Jobs.GetCurrentJobValue().vehicles or {}) do
        table.insert(elements, { label = vehicle.name, value = vehicle.model, index = _ })
    end

    table.insert(elements, { label = _U('close'), value = '', disabled = true })
    table.insert(elements, { label = _U('close'), value = 'close' })

    Jobs.ESX.UI.Menu.Open(
        'job_default',
        GetCurrentResourceName(),
        'vehicles',
        {
            title = _U('vehicles'),
            align = 'top-left',
            elements = elements,
            primaryColor = Jobs.GetPrimaryColor(),
            secondaryColor = Jobs.GetSecondaryColor(),
            image = Jobs.GetCurrentHeaderImage()
        },
        function(data, menu)
            if (string.lower(data.current.value) == 'close') then
                menu.close()
                return
            end

            local model = (type(data.current.value) == 'number' and data.current.value or GetHashKey(data.current.value))

            if IsModelInCdimage(model) then
                local spawnPosition = Jobs.GetCurrentData().spawn or {}

                if (spawnPosition ~= {}) then
                    Jobs.ESX.Game.SpawnVehicle(model, spawnPosition, spawnPosition.h, function(vehicle)
                        menu.close()

                        TaskWarpPedIntoVehicle(GetPlayerPed(-1), vehicle, -1)
                        SetVehRadioStation(vehicle, "OFF")

                        local props = Jobs.GetCurrentJobValue().vehicles[data.current.index].props or {}

                        props.windowTint = props.modWindows or -1

                        Jobs.ESX.Game.SetVehicleProperties(vehicle, props)

                        local prefix = (Jobs.GetCurrentJobValue().plate or {}).prefix or ''
                        local length = (Jobs.GetCurrentJobValue().plate or {}).length or 6
                        local spaceBetween = (Jobs.GetCurrentJobValue().plate or {}).spaceBetween or false

                        SetVehicleNumberPlateText(vehicle, Jobs.GenerateLicense(prefix, length, spaceBetween))
                    end)
                end
            else
                Jobs.ESX.ShowNotification(_U('error_invalid_model'))
            end
        end,
        function(data, menu)
            menu.close()
        end)
end)
Jobs.RegisterMenu('action_menu', function()
    if (not Jobs.HasPermission('action.menu.allow')) then
        return
    end

    local elements = {}

    if (Jobs.HasPermission('action.menu.handcuff')) then
        table.insert(elements, { label = _U('handcuff'), value = 'handcuff' })
    end

    if (Jobs.HasPermission('action.menu.drag')) then
        table.insert(elements, { label = _U('drag'), value = 'drag' })
    end

    if (Jobs.HasPermission('action.menu.hostage')) then
        table.insert(elements, { label = _U('hostage'), value = 'hostage' })
    end

    if (Jobs.HasPermission('action.menu.invehicle')) then
        table.insert(elements, { label = _U('in_vehicle'), value = 'in_vehicle' })
    end

    if (Jobs.HasPermission('action.menu.outvehicle')) then
        table.insert(elements, { label = _U('out_vehicle'), value = 'out_vehicle' })
    end

    if (Jobs.HasPermission('action.menu.idcard')) then
        table.insert(elements, { label = _U('id_card'), value = 'id_card' })
    end

    if (Jobs.HasPermission('action.menu.search')) then
        table.insert(elements, { label = _U('search_player'), value = 'search_player' })
    end

    if (Jobs.HasPermission('action.menu.hijackvehicle')) then
        table.insert(elements, { label = _U('hijack_vehicle'), value = 'hijack_vehicle' })
    end

    Jobs.ESX.UI.Menu.Open(
        'job_default',
        GetCurrentResourceName(),
        'action_menu',
        {
            title = _U('action_menu'),
            align = 'top-left',
            elements = elements,
            primaryColor = Jobs.GetPrimaryColor(),
            secondaryColor = Jobs.GetSecondaryColor(),
            image = Jobs.GetCurrentHeaderImage()
        },
        function(data, menu)
            if (data.current.value == 'handcuff' and Jobs.HasPermission('action.menu.handcuff')) then
                Jobs.HandcuffPlayer()
            end

            if (data.current.value == 'hostage' and Jobs.HasPermission('action.menu.hostage')) then
                Jobs.HostagePlayer()
            end

            if (data.current.value == 'drag' and Jobs.HasPermission('action.menu.drag')) then
                Jobs.DragPlayer()
            end

            if (data.current.value == 'in_vehicle' and Jobs.HasPermission('action.menu.invehicle')) then
                Jobs.TriggerMenu('action_menu_in_vehicle')
            end

            if (data.current.value == 'out_vehicle' and Jobs.HasPermission('action.menu.outvehicle')) then
                Jobs.TriggerMenu('action_menu_out_vehicle')
            end
        end,
        function(data, menu)
            menu.close()
        end)
end)

Jobs.RegisterMenu('action_menu_in_vehicle', function()
    if (not Jobs.HasPermission('action.menu.invehicle')) then
        return
    end

    local playerPed = GetPlayerPed(-1)
    local targetPlayer, targetDistance = Jobs.ESX.Game.GetClosestPlayer()

    if (targetPlayer == -1 or targetDistance > 2) then
        Jobs.ESX.ShowNotification(_U('no_player_close'))
        Jobs.TriggerMenu('action_menu')
        return
    end

    local vehicle, elements = nil, {}

    if (IsPedInAnyVehicle(playerPed, true)) then
        vehicle = GetVehiclePedIsIn(playerPed, false)
    else
        vehicle = Jobs.ESX.Game.GetVehicleInDirection()
    end

    if (DoesEntityExist(vehicle)) then
        local maxSeats = GetVehicleMaxNumberOfPassengers(vehicle)

        for i = 0, maxSeats, 1 do
            if (maxSeats == i and not IsVehicleSeatFree(vehicle, -1)) then
                table.insert(elements, { label = _U('seat_head'), value = -1, disabled = true })
            elseif (maxSeats == i and IsVehicleSeatFree(vehicle,  -1)) then
                table.insert(elements, { label = _U('seat_head'), value = -1})
            elseif IsVehicleSeatFree(vehicle,  i) then
                table.insert( elements, { label = _U('seat', (i + 1)), value = i })
            else
                table.insert( elements, { label = _U('seat', (i + 1)), value = i, disabled = true })
            end
        end

        table.insert(elements, { label = _U('back'), value = '', disabled = true })
        table.insert(elements, { label = _U('back'), value = 'back' })

        Jobs.ESX.UI.Menu.Open(
            'job_default',
            GetCurrentResourceName(),
            'action_menu_in_vehicle',
            {
                title = _U('action_menu_in_vehicle'),
                align = 'top-left',
                elements = elements,
                primaryColor = Jobs.GetPrimaryColor(),
                secondaryColor = Jobs.GetSecondaryColor(),
                image = Jobs.GetCurrentHeaderImage()
            },
            function(data, menu)
                if (data.current.value == nil or
                    data.current.value == '' or
                    string.lower(data.current.value) == 'back') then
                    Jobs.TriggerMenu('action_menu')
                else
                    Jobs.TriggerServerEvent('esx_jobs:putInVehicle', GetPlayerServerId(targetPlayer), data.current.value)
                    Jobs.TriggerMenu('action_menu')
                end
            end,
            function(data, menu)
                Jobs.TriggerMenu('action_menu')
            end)
    else
        Jobs.ESX.ShowNotification(_U('no_vehicle'))
        Jobs.TriggerMenu('action_menu')
        return
    end
end)

Jobs.RegisterMenu('action_menu_out_vehicle', function()
    if (not Jobs.HasPermission('action.menu.outvehicle')) then
        return
    end

    local playerPed = GetPlayerPed(-1)
    local targetPlayer, targetDistance = Jobs.ESX.Game.GetClosestPlayer()

    if (targetPlayer == -1 or targetDistance > 2) then
        Jobs.ESX.ShowNotification(_U('no_player_close'))
        Jobs.TriggerMenu('action_menu')
        return
    end

    local vehicle, elements = nil, {}

    if (IsPedInAnyVehicle(playerPed, true)) then
        vehicle = GetVehiclePedIsIn(playerPed, false)
    else
        vehicle = Jobs.ESX.Game.GetVehicleInDirection()
    end

    if (DoesEntityExist(vehicle)) then
        local maxSeats = GetVehicleMaxNumberOfPassengers(vehicle)

        for i = 0, maxSeats, 1 do
            if (maxSeats == i and not IsVehicleSeatFree(vehicle,  -1)) then
                local targetPlayerPed = GetPedInVehicleSeat(vehicle, -1)
                local playerId = NetworkGetPlayerIndexFromPed(targetPlayerPed)
                local player = GetPlayerServerId(playerId)

                if (targetPlayerPed ~= playerPed) then
                    table.insert( elements, { label = _U('seat_head'), value = player })
                else
                    table.insert( elements, { label = _U('seat_head'), value = -1, disabled = true  })
                end
              elseif (maxSeats == i and IsVehicleSeatFree(vehicle,  -1)) then
                table.insert( elements, { label = _U('seat_head'), value = -1, disabled = true  })
              elseif IsVehicleSeatFree(vehicle,  i) then
                table.insert( elements, { label = _U('seat', (i + 1)), value = i, disabled = true })
              else
                local targetPlayerPed = GetPedInVehicleSeat(vehicle, i)
                local playerId = NetworkGetPlayerIndexFromPed(targetPlayerPed)
                local player = GetPlayerServerId(playerId)

                if (targetPlayerPed ~= playerPed) then
                    table.insert( elements, { label = _U('seat', (i + 1)), value = player })
                else
                    table.insert( elements, { label = _U('seat', (i + 1)), value = i, disabled = true })
                end
              end
        end

        table.insert(elements, { label = _U('back'), value = '', disabled = true })
        table.insert(elements, { label = _U('back'), value = 'back' })

        Jobs.ESX.UI.Menu.Open(
            'job_default',
            GetCurrentResourceName(),
            'action_menu_out_vehicle',
            {
                title = _U('action_menu_out_vehicle'),
                align = 'top-left',
                elements = elements,
                primaryColor = Jobs.GetPrimaryColor(),
                secondaryColor = Jobs.GetSecondaryColor(),
                image = Jobs.GetCurrentHeaderImage()
            },
            function(data, menu)
                if (data.current.value == nil or
                    data.current.value == '' or
                    string.lower(data.current.value) == 'back') then
                    Jobs.TriggerMenu('action_menu')
                else
                    Jobs.TriggerServerEvent('esx_jobs:putOutVehicle', data.current.value)
                    Jobs.TriggerMenu('action_menu')
                end
            end,
            function(data, menu)
                Jobs.TriggerMenu('action_menu')
            end)
    else
        Jobs.ESX.ShowNotification(_U('no_vehicle'))
        Jobs.TriggerMenu('action_menu')
        return
    end
end)

Jobs.HandcuffPlayer = function()
    if (not Jobs.HasPermission('action.menu.handcuff')) then
        return
    end

    local targetPlayer, targetDistance = Jobs.ESX.Game.GetClosestPlayer()

    if (targetPlayer == -1 or targetDistance > 2) then
        Jobs.ESX.ShowNotification(_U('no_player_close'))
        return
    end

    Jobs.TriggerServerEvent('esx_jobs:handcuffPlayer', GetPlayerServerId(targetPlayer))
end

Jobs.HostagePlayer = function()
    if (not Jobs.HasPermission('action.menu.hostage')) then
        return
    end

    local playerPed = GetPlayerPed(-1)
    local targetPlayer, targetDistance = Jobs.ESX.Game.GetClosestPlayer()

    if (targetPlayer == -1 or targetDistance > 2) then
        Jobs.ESX.ShowNotification(_U('no_player_close'))
        return
    end

    for _, blacklistedWeapon in pairs(Config.BlacklsitedHostageWeapons) do
        if (GetSelectedPedWeapon(playerPed) == GetHashKey(blacklistedWeapon)) then
            Jobs.ESX.ShowNotification(_U('hostage_weapon_not_allowed'))
            return
        end
    end

    Jobs.TriggerServerEvent('esx_jobs:hostagePlayer', GetPlayerServerId(targetPlayer))
end

Jobs.DragPlayer = function()
    if (not Jobs.HasPermission('action.menu.drag')) then
        return
    end

    local targetPlayer, targetDistance = Jobs.ESX.Game.GetClosestPlayer()

    if (targetPlayer == -1 or targetDistance > 2) then
        Jobs.ESX.ShowNotification(_U('no_player_close'))
        return
    end

    Jobs.TriggerServerEvent('esx_jobs:dragPlayer', GetPlayerServerId(targetPlayer))
end
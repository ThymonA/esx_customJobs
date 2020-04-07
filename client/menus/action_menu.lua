Jobs.RegisterMenu('action_menu', function()
    if (not Jobs.HasPermission('action.menu.allow')) then
        return
    end

    local elements = {}

    if (Jobs.HasAnyPermission({ 'action.menu.handcuff', 'action.menu.drag', 'action.menu.hostage', 'action.menu.idcard', 'action.menu.search' })) then
        table.insert(elements, { label = _U('action_on_player'), value = '', disabled = true })
    end

    if (Jobs.HasPermission('action.menu.handcuff')) then
        table.insert(elements, { label = _U('handcuff'), value = 'handcuff' })
    end

    if (Jobs.HasPermission('action.menu.hostage')) then
        table.insert(elements, { label = _U('hostage'), value = 'hostage' })
    end

    if (Jobs.HasPermission('action.menu.drag')) then
        table.insert(elements, { label = _U('drag'), value = 'drag' })
    end

    if (Jobs.HasPermission('action.menu.idcard')) then
        table.insert(elements, { label = _U('id_card'), value = 'id_card' })
    end

    if (Jobs.HasPermission('action.menu.search')) then
        table.insert(elements, { label = _U('search_player'), value = 'search_player' })
    end

    if (Jobs.HasAnyPermission({ 'action.menu.invehicle', 'action.menu.outvehicle', 'action.menu.hijackvehicle' })) then
        table.insert(elements, { label = _U('vehicle_actions'), value = '', disabled = true })
    end

    if (Jobs.HasPermission('action.menu.invehicle')) then
        table.insert(elements, { label = _U('in_vehicle'), value = 'in_vehicle' })
    end

    if (Jobs.HasPermission('action.menu.outvehicle')) then
        table.insert(elements, { label = _U('out_vehicle'), value = 'out_vehicle' })
    end

    if (Jobs.HasPermission('action.menu.hijackvehicle')) then
        table.insert(elements, { label = _U('hijack_vehicle'), value = 'hijack_vehicle' })
    end

    table.insert(elements, { label = _U('close'), value = 'close', disabled = true })
    table.insert(elements, { label = _U('close'), value = 'close' })

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
            if (data.current.value == 'close') then
                menu.close()
                return
            end

            if (data.current.value == 'handcuff' and Jobs.HasPermission('action.menu.handcuff')) then
                Jobs.HandcuffPlayer()
                return
            end

            if (data.current.value == 'hostage' and Jobs.HasPermission('action.menu.hostage')) then
                Jobs.HostagePlayer()
                return
            end

            if (data.current.value == 'drag' and Jobs.HasPermission('action.menu.drag')) then
                Jobs.DragPlayer()
                return
            end

            if (data.current.value == 'in_vehicle' and Jobs.HasPermission('action.menu.invehicle')) then
                Jobs.TriggerMenu('action_menu_in_vehicle')
                return
            end

            if (data.current.value == 'out_vehicle' and Jobs.HasPermission('action.menu.outvehicle')) then
                Jobs.TriggerMenu('action_menu_out_vehicle')
                return
            end

            if (data.current.value == 'id_card' and Jobs.HasPermission('action.menu.idcard')) then
                Jobs.TriggerMenu('action_menu_idcard')
                return
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

Jobs.RegisterMenu('action_menu_idcard', function()
    if (not Jobs.HasPermission('action.menu.idcard')) then
        return
    end

    local targetPlayer, targetDistance = Jobs.ESX.Game.GetClosestPlayer()

    if (targetPlayer == -1 or targetDistance > 2) then
        Jobs.ESX.ShowNotification(_U('no_player_close'))
        Jobs.TriggerMenu('action_menu')
        return
    end

    Jobs.TriggerServerCallback('esx_jobs:getPlayerIdentity', function(identity)
        if ((identity.done or false)) then
            local gender = _U('male')

            if (string.lower(identity.data.sex) == 'f') then
                gender = _U('female')
            end

            local elements = {
                { label = _U('identity'), value = '', disabled = true },
                { label = _U('firstname', identity.data.firstname), value = '', disabled = true },
                { label = _U('lastname', identity.data.lastname), value = '', disabled = true },
                { label = _U('sex', gender), value = '', disabled = true },
                { label = _U('dateofbirth', identity.data.dateofbirth), value = '', disabled = true },
                { label = _U('length', identity.data.height), value = '', disabled = true },
                { label = _U('back'), value = '', disabled = true },
                { label = _U('back'), value = 'back' }
            }

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
                function (data, menu)
                    if (data.current.value == 'back') then
                        Jobs.TriggerMenu('action_menu')
                    end
                end,
                function (data, menu)
                    Jobs.TriggerMenu('action_menu')
                end)
        else
            Jobs.ESX.ShowNotification(_U(identity.message))
        end
    end, GetPlayerServerId(targetPlayer))
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
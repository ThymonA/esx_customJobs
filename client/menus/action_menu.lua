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
        end,
        function(data, menu)
            menu.close()
        end)
end)

Jobs.HandcuffPlayer = function()
    local targetPlayer, targetDistance = Jobs.ESX.Game.GetClosestPlayer()

    if (targetPlayer == -1 or targetDistance > 5) then
        Jobs.ESX.ShowNotification(_U('no_player_close'))
        return
    end

    Jobs.TriggerServerEvent('esx_jobs:handcuffPlayer', GetPlayerServerId(targetPlayer))
end
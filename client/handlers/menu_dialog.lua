Jobs.MenuDialog             = {}
Jobs.MenuDialog.Timeouts    = {}
Jobs.MenuDialog.OpenMenus   = {}

Citizen.CreateThread(function()
    while Jobs.ESX == nil do
        Citizen.Wait(0)
    end

    local GUI           = { Time = 0 }
    local MenuType      = 'job_dialog'

    Jobs.ESX.UI.Menu.RegisterType(MenuType, Jobs.MenuDialog.OpenMenu, Jobs.MenuDialog.CloseMenu)

    RegisterNUICallback('job_dialog_submit', function(data, cb)
        local menu = Jobs.ESX.UI.Menu.GetOpened(MenuType, data._namespace, data._name)
        local post = true

        if data.value ~= nil then
			if tonumber(data.value) ~= nil then

				data.value = Jobs.Formats.Round(tonumber(data.value))

				if tonumber(data.value) < 0 then
					post = false
				end
			end

			if post then
				menu.submit(data, menu)
			else
				Jobs.ESX.ShowNotification(_U('negative'))
			end
		end

		cb('OK')
    end)

    RegisterNUICallback('job_dialog_cancel', function(data, cb)
		local menu = Jobs.ESX.UI.Menu.GetOpened(MenuType, data._namespace, data._name)

		if menu.cancel ~= nil then
			menu.cancel(data, menu)
		end

		cb('OK')
    end)

    RegisterNUICallback('job_dialog_change', function(data, cb)
		local menu = Jobs.ESX.UI.Menu.GetOpened(MenuType, data._namespace, data._name)

		if menu.change ~= nil then
			menu.change(data, menu)
		end

		cb('OK')
    end)

    Citizen.CreateThread(function()
        while true do
			Citizen.Wait(10)

            local OpenedMenuCount = 0

			for _, openedMenu in pairs(Jobs.MenuDialog.OpenMenus) do
                if (openedMenu == true) then
                    OpenedMenuCount = OpenedMenuCount + 1
                end
            end

			if OpenedMenuCount > 0 then
				DisableControlAction(0, 1, true) -- LookLeftRight
				DisableControlAction(0, 2, true) -- LookUpDown
				DisableControlAction(0, 142, true) -- MeleeAttackAlternate
				DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
				DisableControlAction(0, 12, true) -- WeaponWheelUpDown
				DisableControlAction(0, 14, true) -- WeaponWheelNext
				DisableControlAction(0, 15, true) -- WeaponWheelPrev
				DisableControlAction(0, 16, true) -- SelectNextWeapon
				DisableControlAction(0, 17, true) -- SelectPrevWeapon
			end
		end
    end)
end)

Jobs.MenuDialog.OpenMenu = function(namespace, name, data)
    for i = 1, #Jobs.MenuDialog.Timeouts, 1 do
        Jobs.ESX.ClearTimeout(Jobs.MenuDialog.Timeouts[i])
    end

    Jobs.MenuDialog.OpenMenus[namespace .. '_' .. name] = true

    SendNUIMessage({
        action = 'openMenuDialog',
        namespace = namespace,
        name = name,
        data = data
    })

    local timeoutId = Jobs.ESX.SetTimeout(200, function()
        SetNuiFocus(true, true)
    end)

    table.insert(Jobs.MenuDialog.Timeouts, timeoutId)
end

Jobs.MenuDialog.CloseMenu = function(namespace, name)
    Jobs.MenuDialog.OpenMenus[namespace .. '_' .. name] = nil

    local OpenedMenuCount = 0

    SendNUIMessage({
        action = 'closeMenuDialog',
        namespace = namespace,
        name = name,
        data = {}
    })

    for _, openedMenu in pairs(Jobs.MenuDialog.OpenMenus) do
        if (openedMenu == true) then
            OpenedMenuCount = OpenedMenuCount + 1
        end
    end

    if (OpenedMenuCount == 0) then
        SetNuiFocus(false)
    end
end
Jobs.MenuDefault = {}

Citizen.CreateThread(function()
    while Jobs.ESX == nil do
        Citizen.Wait(0)
    end

    local GUI       = { Time = 0 }
    local MenuType  = 'job_default'

    Jobs.ESX.UI.Menu.RegisterType(MenuType, Jobs.MenuDefault.OpenMenu, Jobs.MenuDefault.CloseMenu)

    RegisterNUICallback('job_default_submit', function(data, cb)
		local menu = Jobs.ESX.UI.Menu.GetOpened(MenuType, data._namespace, data._name)

        if menu.submit ~= nil then
			menu.submit(data, menu)
        end

        cb('OK')
    end)

    RegisterNUICallback('job_default_cancel', function(data, cb)
		local menu = Jobs.ESX.UI.Menu.GetOpened(MenuType, data._namespace, data._name)

		if menu.cancel ~= nil then
			menu.cancel(data, menu)
		end

		cb('OK')
    end)

    RegisterNUICallback('job_default_change', function(data, cb)
		local menu = Jobs.ESX.UI.Menu.GetOpened(MenuType, data._namespace, data._name)

		for i=1, #data.elements, 1 do
			menu.setElement(i, 'value', data.elements[i].value)

			if data.elements[i].selected then
				menu.setElement(i, 'selected', true)
			else
				menu.setElement(i, 'selected', false)
			end

		end

		if menu.change ~= nil then
			menu.change(data, menu)
		end

		cb('OK')
    end)

    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)

            if IsControlPressed(0, 18) and GetLastInputMethod(2) and (GetGameTimer() - GUI.Time) > 150 then
				SendNUIMessage({
					action  = 'controlPressedDefault',
					control = 'ENTER'
				})

				GUI.Time = GetGameTimer()
			end

			if IsControlPressed(0, 177) and GetLastInputMethod(2) and (GetGameTimer() - GUI.Time) > 150 then
				SendNUIMessage({
					action  = 'controlPressedDefault',
					control = 'BACKSPACE'
				})

				GUI.Time = GetGameTimer()
			end

			if IsControlPressed(0, 27) and GetLastInputMethod(2) and (GetGameTimer() - GUI.Time) > 200 then
				SendNUIMessage({
					action  = 'controlPressedDefault',
					control = 'TOP'
				})

				GUI.Time = GetGameTimer()
			end

			if IsControlPressed(0, 173) and GetLastInputMethod(2) and (GetGameTimer() - GUI.Time) > 200 then
				SendNUIMessage({
					action  = 'controlPressedDefault',
					control = 'DOWN'
				})

				GUI.Time = GetGameTimer()
			end

			if IsControlPressed(0, 174) and GetLastInputMethod(2) and (GetGameTimer() - GUI.Time) > 150 then
				SendNUIMessage({
					action  = 'controlPressedDefault',
					control = 'LEFT'
				})

				GUI.Time = GetGameTimer()
			end

			if IsControlPressed(0, 175) and GetLastInputMethod(2) and (GetGameTimer() - GUI.Time) > 150 then
				SendNUIMessage({
					action  = 'controlPressedDefault',
					control = 'RIGHT'
				})

				GUI.Time = GetGameTimer()
			end
        end
    end)
end)

Jobs.MenuDefault.OpenMenu = function(namespace, name, data)
    SendNUIMessage({
        action = 'openMenuDefault',
        namespace = namespace,
        name = name,
        data = data
    })
end

Jobs.MenuDefault.CloseMenu = function(namespace, name)
    SendNUIMessage({
        action = 'closeMenuDefault',
        namespace = namespace,
        name = name,
        data = {}
    })
end
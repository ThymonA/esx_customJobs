Jobs.RegisterMenu('parkings', function()
    if (not Jobs.HasPermission('vehicle.park')) then
        return
    end

    local playerPed = GetPlayerPed(-1)

    if IsPedInAnyVehicle(playerPed,  false) then
        local vehicle = GetVehiclePedIsIn(playerPed, false)

        if (GetPedInVehicleSeat(vehicle, -1) ~= playerPed) then
            Jobs.ESX.ShowNotification(_U('error_must_driver'))
            return
        end

        Jobs.ESX.Game.DeleteVehicle(vehicle)

        Jobs.ESX.ShowNotification(_U('vehicle_parked'))
    else
        Jobs.ESX.ShowNotification(_U('error_no_vehicle'))
    end
end)
Jobs.RegisterServerCallback('esx_jobs:getPlayerGender', function(xPlayer, xJob, callback)
    MySQL.Async.fetchAll('SELECT `skin` FROM `users` WHERE `identifier` = @identifier', {
        ['@identifier'] = xPlayer.identifier
    }, function(userResult)
        if (userResult ~= nil and userResult[1] ~= nil) then
            local skin = json.decode(userResult[1].skin or '{}')
            local gender = 'male'

            if (tonumber(skin.sex or '0') == 1) then
                gender = 'female'
            end

            callback(gender)
        end
    end)
end)
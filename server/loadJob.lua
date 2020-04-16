Jobs.LoadJob = function(rawData)
    local jobName = rawData.JobName or nil

    if (jobName == nil) then
        return
    end

    local jobTasks = {}
    local jobData = {
        label = rawData.JobName or '',
        name = rawData.Job or '',
        members = {},
        permissions = {},
        publicPermissions = {},
        webhooks = {},
        grades = {},
        positions = {},
        accounts = {},
        items = {},
        weapons = {},
        buyableItems = {},
        sellableItems = {},
        clothes = {},
        vehicles = {},
        testDrives = {},
        plate = {},
        blips = {},
        showrooms = {},
        menu = rawData.Menu or {},
        permissionSystem = CreatePermissions()
    }

    while (jobData.permissionSystem == nil) do
        Citizen.Wait(10)
    end

    for _, allowedPermission in pairs(rawData.Allowed or {}) do
        if (allowedPermission ~= nil) then
            allowedPermission = tostring(allowedPermission)

            if (jobData.permissionSystem.isPermissionGroup(allowedPermission)) then
                local permissionGroup = jobData.permissionSystem.getPermissionGroup(allowedPermission)

                for __, subPermission in pairs(permissionGroup.permissions or {}) do
                    table.insert(jobData.permissions, subPermission)
                end
            else
                table.insert(jobData.permissions, allowedPermission)
            end
        end
    end

    if (Jobs.JobPublics == nil) then
        Jobs.JobPublics = {}
    end

    if (Jobs.JobPublics['permissions'] == nil) then
        Jobs.JobPublics['permissions'] = {}
    end

    for _, allowedPermission in pairs(rawData.PublicAllowed or {}) do
        if (allowedPermission ~= nil) then
            allowedPermission = tostring(allowedPermission)

            if (jobData.permissionSystem.isPermissionGroup(allowedPermission)) then
                local permissionGroup = jobData.permissionSystem.getPermissionGroup(allowedPermission)

                for __, subPermission in pairs(permissionGroup.permissions or {}) do
                    table.insert(jobData.permissions, subPermission)
                    table.insert(jobData.publicPermissions, subPermission)
                    table.insert(Jobs.JobPublics['permissions'], subPermission)
                end
            else
                table.insert(jobData.permissions, allowedPermission)
                table.insert(jobData.publicPermissions, allowedPermission)
                table.insert(Jobs.JobPublics['permissions'], allowedPermission)
            end
        end
    end

    for _, position in pairs(rawData.Positions or {}) do
        local positionType = string.lower(position.Type or 'unknown')

        if (jobData.positions ~= nil and jobData.positions[positionType] == nil) then
            jobData.positions[positionType] = {}
        end

        local addonData = {}

        for key, value in pairs(position.AddonData or {}) do
            if (string.lower(type(key)) == 'number') then
                addonData[key] = value
            else
                addonData[string.lower(tostring(key))] = value
            end
        end

        table.insert(jobData.positions[positionType], {
            type = positionType,
            name = position.Name or 'Unknown',
            denied = position.Denied or {},
            public = position.Public or false,
            position = position.Position or { x = 0, y = 0, z = 0 },
            color = position.Color or { r = 255, g = 0, b = 0 },
            size = position.Size or { x = 1.5, y = 1.5, z = 0.5 },
            marker = position.Marker or 25,
            addonData = addonData or {},
            index = _,
            key = position.Key or 'x',
            job = jobData.name,
            jobLabel = jobData.label,
            primaryColor = (jobData.menu or {}).PrimaryColor or { r = 255, g = 0, b = 0 },
            secondaryColor = (jobData.menu or {}).SecondaryColor or { r = 0, g = 0, b = 0 },
            headerImage = (jobData.menu or {}).HeaderImage or 'menu_default.jpg'
        })

        if (positionType == 'showroom') then
            if (jobData.showrooms == nil) then
                jobData.showrooms = {}
            end

            local showroomSpots = {}
            local showroomProps = (position.AddonData or {}).VehicleProps or {}

            for __, spot in pairs((position.AddonData or {}).Spots or {}) do
                local spotLabel = spot.Label or 'Unknown'
                local spotPosition = spot.Position or {}
                local spotType = spot.Type or 'unknown'
                local spotIndex = __

                table.insert(showroomSpots, {
                    label = spotLabel,
                    position = spotPosition,
                    type = spotType,
                    index = spotIndex,
                    props = showroomProps
                })
            end

            local showroom = CreateShowroom(_, (position.Key or 'x'), (position.Name or 'Unknown'), jobData.name, showroomSpots, showroomProps)
            local spots = showroom.getSpots() or {}

            if (Jobs.JobPublics == nil) then
                Jobs.JobPublics = {}
            end

            if (Jobs.JobPublics['showrooms'] == nil) then
                Jobs.JobPublics['showrooms'] = {}
            end

            table.insert(jobData.showrooms, showroom)

            for _, showroomSpot in pairs(spots) do
                table.insert(Jobs.JobPublics['showrooms'], showroomSpot)
            end
        end

        if (position.Public or false) then
            if (Jobs.JobPublics == nil) then
                Jobs.JobPublics = {}
            end

            if (Jobs.JobPublics['positions'] == nil) then
                Jobs.JobPublics['positions'] = {}
            end

            if (Jobs.JobPublics['positions'][positionType] == nil) then
                Jobs.JobPublics['positions'][positionType] = {}
            end

            table.insert(Jobs.JobPublics['positions'][positionType], {
                type = positionType,
                name = position.Name or 'Unknown',
                denied = position.Denied or {},
                public = position.Public or false,
                position = position.Position or { x = 0, y = 0, z = 0 },
                color = position.Color or { r = 255, g = 0, b = 0 },
                size = position.Size or { x = 1.5, y = 1.5, z = 0.5 },
                marker = position.Marker or 25,
                addonData = addonData or {},
                index = _,
                key = position.Key or 'x',
                job = jobData.name,
                jobLabel = jobData.label,
                primaryColor = (jobData.menu or {}).PrimaryColor or { r = 255, g = 0, b = 0 },
                secondaryColor = (jobData.menu or {}).SecondaryColor or { r = 0, g = 0, b = 0 },
                headerImage = (jobData.menu or {}).HeaderImage or 'menu_default.jpg'
            })
        end
    end

    jobData.clothes['male'] = {}
    jobData.clothes['female'] = {}

    for _, clothes in pairs(rawData.Clothes or {}) do
        if (clothes ~= nil) then
            local isMale = string.lower(clothes.Gender or 'M') == 'm'

            if (isMale) then
                table.insert(jobData.clothes['male'], {
                    name = clothes.Name or 'Unknown',
                    allowed = clothes.Allowed or {},
                    skin = clothes.Skin or {},
                    gender = 'm'
                })
            else
                table.insert(jobData.clothes['female'], {
                    name = clothes.Name or 'Unknown',
                    allowed = clothes.Allowed or {},
                    skin = clothes.Skin or {},
                    gender = 'f'
                })
            end
        end
    end

    rawData.Vehicles = rawData.Vehicles or {}

    for _, vehicle in pairs(rawData.Vehicles.Vehicles or {}) do
        local vehicleProps = rawData.Vehicles.VehicleProps or {}

        local customTuning = vehicle.CustomTuning or {}
            local newVehicleProps = {}

            for prop, value in pairs(vehicleProps) do
                newVehicleProps[prop] = value
            end

            for prop, value in pairs(customTuning) do
                newVehicleProps[prop] = value
            end

            table.insert(jobData.vehicles, {
                name = vehicle.Name or 'Unknown',
                model = vehicle.Model or 'unknown',
                props = newVehicleProps or {},
                allowed = vehicle.Allowed or {}
            })
    end

    jobData.plate.prefix = (rawData.Vehicles.LicensePlate or {}).Prefix or ''
    jobData.plate.length = (rawData.Vehicles.LicensePlate or {}).Length or 6
    jobData.plate.spaceBetween = (rawData.Vehicles.LicensePlate or {}).SpaceBetween or false

    MySQL.Async.fetchAll('SELECT * FROM `jobs` WHERE `name` = @job', {
        ['@job'] = string.lower(jobData.name)
    }, function(results)
        if (results == nil or #results <= 0) then
            MySQL.Async.execute('INSERT INTO `jobs` (`name`, `label`) VALUES (@job, @name)', {
                ['@job'] = string.lower(jobData.name),
                ['@name'] = jobData.label
            }, function(updated)
                Jobs.Information('Job ' .. jobData.label .. ' added to the system')
            end)
        else
            MySQL.Async.execute('UPDATE `jobs` SET `label` = @name WHERE `name` = @job', {
                ['@job'] = string.lower(jobData.name),
                ['@name'] = jobData.label
            }, function(updated)
                Jobs.Information('Job ' .. jobData.label .. ' is now up to date')
            end)
        end
    end)

    MySQL.Async.fetchAll('SELECT * FROM `job_grades` WHERE `job_name` = @job', {
        ['@job'] = string.lower(jobData.name)
    }, function(results)
        local addedJobGrades = {}
        local updatedJobGrades = {}
        local deletedJobGrades = {}

        if (results == nil or #results <= 0) then
            results = {}
        end

        for _, jobGrade in pairs(rawData.Grades or {}) do
            local jobGradeFound = false

            for __, dbGrade in pairs(results) do
                if ((dbGrade.grade or 0) == (jobGrade.Grade or 0)) then
                    jobGradeFound = true
                    break
                end
            end

            if (jobGradeFound) then
                updatedJobGrades[tostring(jobGrade.Grade or 0)] = jobGrade
            else
                addedJobGrades[tostring(jobGrade.Grade or 0)] = jobGrade
            end

            jobData.grades[tostring(jobGrade.Grade or 0)] = {
                grade = jobGrade.Grade or 0,
                name = jobGrade.Name or 'unknown',
                label = jobGrade.Label or 'Unknown',
                salary = jobGrade.Salary or 0,
                permissions = {},
                positions = {},
                clothes = {},
                vehicles = {}
            }

            for _, jobPermission in pairs(jobData.permissions or {}) do
                table.insert(jobData.grades[tostring(jobGrade.Grade or 0)].permissions, jobPermission)
            end

            for _, gradeDeniedPermission in pairs(jobGrade.Denied or {}) do
                if (jobData.permissionSystem.isPermissionGroup(gradeDeniedPermission)) then
                    local permissionGroup = jobData.permissionSystem.getPermissionGroup(gradeDeniedPermission)

                    for __, deniedExtendedPermission in pairs(permissionGroup.permissions or {}) do
                        Jobs.RemoveFromTable(jobData.grades[tostring(jobGrade.Grade or 0)].permissions, deniedExtendedPermission)
                    end
                elseif (gradeDeniedPermission ~= nil) then
                    Jobs.RemoveFromTable(jobData.grades[tostring(jobGrade.Grade or 0)].permissions, gradeDeniedPermission)
                end
            end

            for positionType, positionTypeValue in pairs(jobData.positions or {}) do
                for _, positionValue in pairs (positionTypeValue or {}) do
                    local deniedGrades = positionValue.denied or {}
                    local gradeDenied = false

                    for _, deniedGrade in pairs(deniedGrades) do
                        if (deniedGrade ~= nil and string.lower(tostring(deniedGrade)) == string.lower(jobData.grades[tostring(jobGrade.Grade or 0)].name)) then
                            gradeDenied = true
                        end

                        if (deniedGrade ~= nil and string.lower(tostring(deniedGrade)) == tostring(jobGrade.Grade or 0)) then
                            gradeDenied = true
                        end
                    end

                    local gradeHasAccess = jobData.permissionSystem.isAnyPermissionAllowedToUseType(
                        jobData.grades[tostring(jobGrade.Grade or 0)].permissions,
                        positionValue.type or 'unknown'
                    )

                    if (not gradeDenied and gradeHasAccess) then
                        if (jobData.grades[tostring(jobGrade.Grade or 0)].positions[positionType] == nil) then
                            jobData.grades[tostring(jobGrade.Grade or 0)].positions[positionType] = {}
                        end

                        table.insert(jobData.grades[tostring(jobGrade.Grade or 0)].positions[positionType], positionValue)
                    end
                end
            end

            jobData.grades[tostring(jobGrade.Grade or 0)].clothes['male'] = {}
            jobData.grades[tostring(jobGrade.Grade or 0)].clothes['female'] = {}

            for _, clothes in pairs ((jobData.clothes or {}).male or {}) do
                local allowedGrades = clothes.allowed or {}
                local gradeAllowed = false

                for _, allowedGrade in pairs(allowedGrades) do
                    if (allowedGrade ~= nil and string.lower(tostring(allowedGrade)) == string.lower(jobData.grades[tostring(jobGrade.Grade or 0)].name)) then
                        gradeAllowed = true
                    end

                    if (allowedGrade ~= nil and string.lower(tostring(allowedGrade)) == tostring(jobGrade.Grade or 0)) then
                        gradeAllowed = true
                    end
                end

                if (gradeAllowed or #allowedGrades <= 0) then
                    table.insert(jobData.grades[tostring(jobGrade.Grade or 0)].clothes['male'], clothes)
                end
            end

            for _, clothes in pairs ((jobData.clothes or {}).female or {}) do
                local allowedGrades = clothes.allowed or {}
                local gradeAllowed = false

                for _, allowedGrade in pairs(allowedGrades) do
                    if (allowedGrade ~= nil and string.lower(tostring(allowedGrade)) == string.lower(jobData.grades[tostring(jobGrade.Grade or 0)].name)) then
                        gradeAllowed = true
                    end

                    if (allowedGrade ~= nil and string.lower(tostring(allowedGrade)) == tostring(jobGrade.Grade or 0)) then
                        gradeAllowed = true
                    end
                end

                if (gradeAllowed or #allowedGrades <= 0) then
                    table.insert(jobData.grades[tostring(jobGrade.Grade or 0)].clothes['female'], clothes)
                end
            end

            for _, vehicle in pairs (jobData.vehicles or {}) do
                local allowedGrades = vehicle.allowed or {}
                local gradeAllowed = false

                for _, allowedGrade in pairs(allowedGrades) do
                    if (allowedGrade ~= nil and string.lower(tostring(allowedGrade)) == string.lower(jobData.grades[tostring(jobGrade.Grade or 0)].name)) then
                        gradeAllowed = true
                    end

                    if (allowedGrade ~= nil and string.lower(tostring(allowedGrade)) == tostring(jobGrade.Grade or 0)) then
                        gradeAllowed = true
                    end
                end

                if (gradeAllowed or #allowedGrades <= 0) then
                    table.insert(jobData.grades[tostring(jobGrade.Grade or 0)].vehicles, vehicle)
                end
            end
        end

        for __, dbGrade in pairs(results) do
            if (addedJobGrades[tostring(dbGrade.grade or 0)] == nil and updatedJobGrades[tostring(dbGrade.grade or 0)] == nil) then
                deletedJobGrades[tostring(dbGrade.grade or 0)] = dbGrade
            end
        end

        local updateGradeTasks = {}

        for addedJobGrade, addedJobGradeValue in pairs(addedJobGrades or {}) do
            table.insert(updateGradeTasks, function(cb)
                MySQL.Async.execute('INSERT INTO `job_grades` (`job_name`, `grade`, `name`, `label`, `salary`, `skin_male`, `skin_female`) VALUES (@job, @grade, @name, @label, @salary, \'{}\', \'{}\')', {
                    ['@job'] = string.lower(jobData.name),
                    ['@grade'] = tonumber(addedJobGrade),
                    ['@name'] = addedJobGradeValue.Name or 'unknown',
                    ['@label'] = addedJobGradeValue.Label or 'Unknown',
                    ['@salary'] = addedJobGradeValue.Salary or 0
                }, function(result)
                    Jobs.Information('Job ' .. jobData.label .. ' grade ' .. addedJobGrade .. ' added to the system')
                    cb()
                end)
            end)
        end

        for updatedJobGrade, updatedJobGradeValue in pairs(updatedJobGrades or {}) do
            table.insert(updateGradeTasks, function(cb)
                MySQL.Async.execute('UPDATE `job_grades` SET `name` = @name, `label` = @label, `salary` = @salary, `skin_male` = \'{}\', `skin_female` = \'{}\' WHERE `job_name` = @job AND `grade` = @grade', {
                    ['@job'] = string.lower(jobData.name),
                    ['@grade'] = tonumber(updatedJobGrade),
                    ['@name'] = updatedJobGradeValue.Name or 'unknown',
                    ['@label'] = updatedJobGradeValue.Label or 'Unknown',
                    ['@salary'] = updatedJobGradeValue.Salary or 0
                }, function(result)
                    cb()
                end)
            end)
        end

        for deletedJobGrade, _ in pairs(deletedJobGrades or {}) do
            table.insert(updateGradeTasks, function(cb)
                MySQL.Async.execute('DELETE FROM `job_grades` WHERE `job_name` = @job AND `grade` = @grade', {
                    ['@job'] = string.lower(jobData.name),
                    ['@grade'] = tonumber(deletedJobGrade)
                }, function(result)
                    Jobs.Information('Job ' .. jobData.label .. ' grade ' .. deletedJobGrade .. ' deleted from the system')
                    cb()
                end)
            end)
        end

        Async.parallel(updateGradeTasks, function(results)
            local newJobGrades = {}

            for newJobGradeKey, newJobGradeValue in pairs(jobData.grades or {}) do
                newJobGrades[newJobGradeKey] = {
                    job_name = jobData.name,
                    grade = newJobGradeValue.grade,
                    name = newJobGradeValue.name,
                    label = newJobGradeValue.label,
                    salary = newJobGradeValue.salary,
                    skin_male = '{}',
                    skin_female = '{}'
                }
            end

            TriggerEvent('esx:updateJob', {
                name = jobData.name,
                label = jobData.label
            }, newJobGrades)

            Jobs.Information('Job grades for ' .. jobData.label .. ' is now up to date')
        end)
    end)

    table.insert(jobTasks, function(cb)
        MySQL.Async.fetchAll('SELECT * FROM `users` WHERE LOWER(`job`) = @job', {
            ['@job'] = string.lower(jobData.name)
        }, function(results)
            if (results ~= nil and #results > 0) then
                for _, user in pairs(results) do
                    local memberData = {
                        identifier = user.identifier or 'none',
                        name = user.name or '',
                        job = user.job or 'Kansloos',
                        job_grade = user.job_grade or 0,
                        source = nil,
                    }

                    jobData.members[memberData.identifier] = memberData
                end
            end

            cb()
        end)
    end)

    table.insert(jobTasks, function(cb)
        for webhookType, webhooks in pairs(rawData.Wehbooks or {}) do
            if (webhookType ~= nil and webhooks ~= nil and string.lower(type(webhooks)) == 'table') then
                jobData.webhooks[string.lower(webhookType)] = webhooks
            end
        end

        cb()
    end)

    table.insert(jobTasks, function(cb)
        MySQL.Async.fetchAll('SELECT * FROM `job_account` WHERE LOWER(`job`) = @job',{
            ['@job'] = string.lower(jobData.name)
        }, function(results)
            local foundedAccounts = {}

            if (results ~= nil and #results > 0) then
                for _, account in pairs(results) do
                    foundedAccounts[string.lower(account.account)] = true

                    local _account = CreateJobAccount(account.account, account.money, _U(account.account), jobData.name, jobData.label)

                    while _account == nil do
                        Citizen.Wait(0)
                    end

                    jobData.accounts[string.lower(account.account)] = _account
                end
            end

            for _, requiredAccount in pairs(ServerConfig.RequiredAccounts) do
                if (foundedAccounts ~= nil and foundedAccounts[requiredAccount] == nil) then
                    local _account = CreateJobAccount(requiredAccount, 0, _U(requiredAccount), jobData.name, jobData.label)

                    while _account == nil do
                        Citizen.Wait(0)
                    end

                    jobData.accounts[string.lower(requiredAccount)] = _account

                    _account.save()
                end
            end

            cb()
        end)
    end)

    table.insert(jobTasks, function(cb)
        MySQL.Async.fetchAll('SELECT * FROM `job_safe` WHERE LOWER(`job`) = @job',{
            ['@job'] = string.lower(jobData.name)
        }, function(results)
            if (results ~= nil and #results > 0) then
                for _, item in pairs(results) do
                    local label = Jobs.ESX.GetItemLabel(item.item or 'unknown') or item.label or item.name or 'unknown'
                    local _item = CreateJobItem(item.item, item.count, label, jobData.name, jobData.label)

                    while _item == nil do
                        Citizen.Wait(0)
                    end

                    jobData.items[string.lower(item.item)] = _item
                end
            end

            cb()
        end)
    end)

    table.insert(jobTasks, function(cb)
        MySQL.Async.fetchAll('SELECT * FROM `job_weapon` WHERE LOWER(`job`) = @job',{
            ['@job'] = string.lower(jobData.name)
        }, function(results)
            if (results ~= nil and #results > 0) then
                for _, weapon in pairs(results) do
                    local _weapon = CreateJobWeapon(string.upper(weapon.weapon), weapon.count, _U(string.lower(weapon.weapon)), jobData.name, jobData.label)

                    while _weapon == nil do
                        Citizen.Wait(0)
                    end

                    jobData.weapons[string.lower(weapon.weapon)] = _weapon
                end
            end

            cb()
        end)
    end)

    table.insert(jobTasks, function(cb)
        jobData.buyableItems['items'] = {}
        jobData.buyableItems['weapons'] = {}

        for _, buyableItem in pairs(rawData.BuyableItems or {}) do
            if (buyableItem ~= nil) then
                local buyableItemType = buyableItem.Type or 'unknown'

                if (string.lower(buyableItemType) == 'item') then
                    table.insert(jobData.buyableItems['items'], {
                        item = buyableItem.Item or 'unknown',
                        price = buyableItem.Price or 0
                    })
                elseif (string.lower(buyableItemType) == 'weapon') then
                    table.insert(jobData.buyableItems['weapons'], {
                        weapon = buyableItem.Weapon or 'unknown',
                        price = buyableItem.Price or 0
                    })
                end
            end
        end

        cb()
    end)

    table.insert(jobTasks, function(cb)
        jobData.sellableItems = {}
        jobData.sellableItems['none'] = {
            label = _U('none'),
            items = {}
        }

        for _, category in pairs((rawData.SellableItems or {}).Categories or {}) do
            local name = string.lower(category.name or 'unknown')

            jobData.sellableItems[name] = {
                label = category.label or 'Unknown',
                items = {}
            }
        end

        for _, vehicle in pairs((rawData.SellableItems or {}).Vehicles or {}) do
            local brand = vehicle.brand or 'Unknown'
            local name = vehicle.name or 'Unknown'
            local code = vehicle.code or 'unknown'
            local buyPrice = vehicle.buyPrice or 0
            local sellPrice = vehicle.sellPrice or 0
            local category = string.lower(vehicle.category or 'none')
            local discountAllowed = vehicle.discountAllowed or false
            local discountCodes = vehicle.discountCodes or {}

            if (jobData.sellableItems == nil or jobData.sellableItems[category] == nil) then
                category = 'none'
            end

            local sellableItem = CreateSellableItem(code, name, 'car', {
                brand = brand,
                name = name,
                code = code,
                buyPrice = buyPrice,
                sellPrice = sellPrice,
                category = category,
                discountAllowed = discountAllowed,
                discountCodes = discountCodes
            })

            table.insert(jobData.sellableItems[category].items, sellableItem)
        end

        for _, aircraft in pairs((rawData.SellableItems or {}).Aircrafts or {}) do
            local brand = aircraft.brand or 'Unknown'
            local name = aircraft.name or 'Unknown'
            local code = aircraft.code or 'unknown'
            local buyPrice = aircraft.buyPrice or 0
            local sellPrice = aircraft.sellPrice or 0
            local category = string.lower(aircraft.category or 'none')
            local discountAllowed = aircraft.discountAllowed or false
            local discountCodes = aircraft.discountCodes or {}

            if (jobData.sellableItems == nil or jobData.sellableItems[category] == nil) then
                category = 'none'
            end

            local sellableItem = CreateSellableItem(code, name, 'aircraft', {
                brand = brand,
                name = name,
                code = code,
                buyPrice = buyPrice,
                sellPrice = sellPrice,
                category = category,
                discountAllowed = discountAllowed,
                discountCodes = discountCodes
            })

            table.insert(jobData.sellableItems[category].items, sellableItem)
        end

        cb()
    end)

    table.insert(jobTasks, function(cb)
        for _, blip in pairs(rawData.Blips or {}) do
            table.insert(jobData.blips, {
                title = blip.Title or 'Unknown',
                visibleForEveryone = blip.VisibleForEveryone or false,
                position = blip.Position or { x = 0, y = 0, z = 0 },
                sprite = blip.Sprite or 1.0,
                display = blip.Display or 4,
                scale = blip.Scale or 1.0,
                colour = blip.Colour or 1
            })

            if (blip.VisibleForEveryone or false) then
                if (Jobs.JobPublics == nil) then
                    Jobs.JobPublics = {}
                end

                if (Jobs.JobPublics['blips'] == nil) then
                    Jobs.JobPublics['blips'] = {}
                end

                table.insert(Jobs.JobPublics['blips'], {
                    title = blip.Title or 'Unknown',
                    visibleForEveryone = blip.VisibleForEveryone or false,
                    position = blip.Position or { x = 0, y = 0, z = 0 },
                    sprite = blip.Sprite or 1.0,
                    display = blip.Display or 4,
                    scale = blip.Scale or 1.0,
                    colour = blip.Colour or 1,
                    job = jobData.name,
                    jobLabel = jobData.label
                })
            end
        end

        cb()
    end)

    table.insert(jobTasks, function(cb)
        for _, testDrive in pairs(rawData.TestDrives or {}) do
            local driveType = string.lower(testDrive.Type or 'unknown')

            if (jobData.testDrives == nil) then
                jobData.testDrives = {}
            end

            if (jobData.testDrives[driveType] == nil) then
                jobData.testDrives[driveType] = {
                    position = testDrive.Position or { x = 0, y = 0, z = 0 },
                    type = driveType,
                    duration = testDrive.Duration or 60000,
                    price = testDrive.Price or 0,
                    payForDamage = testDrive.PayForDamage or false
                }
            end
        end

        cb()
    end)

    local jobInfoAdded = false

    Async.parallel(jobTasks, function(results)
        jobInfoAdded = true
    end)

    while not jobInfoAdded do
        Citizen.Wait(10)
    end

    local jobValue = CreateJob(jobData, Jobs.Version or '0.0.0')

    while jobValue == nil do
        Citizen.Wait(10)
    end

    return jobValue
end
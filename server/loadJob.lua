Jobs.LoadJob = function(rawData)
    local jobName = rawData.JobName or nil

    if (jobName == nil) then
        return
    end

    local jobTasks = {}
    local jobData = {
        label = rawData.JobName or '',
        name = rawData.Job or '',
        whitelisted = rawData.Whitelisted or true,
        members = {},
        permissions = {},
        webhooks = {},
        grades = {},
        positions = {},
        accounts = {},
        items = {},
        weapons = {},
        buyableItems = {},
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

    for _, position in pairs(rawData.Positions or {}) do
        local positionType = string.lower(position.Type or 'unknown')

        if (jobData.positions ~= nil and jobData.positions[positionType] == nil) then
            jobData.positions[positionType] = {}
        end

        table.insert(jobData.positions[positionType], {
            type = positionType,
            name = position.Name or 'Unknown',
            denied = position.Denied or {},
            public = position.Public or false,
            position = position.Position or { x = 0, y = 0, z = 0 },
            color = position.Color or { r = 255, g = 0, b = 0 },
            size = position.Size or { x = 1.5, y = 1.5, z = 0.5 },
            marker = position.Marker or 25
        })
    end

    MySQL.Async.fetchAll('SELECT * FROM `jobs` WHERE `name` = @job', {
        ['@job'] = string.lower(jobData.name)
    }, function(results)
        if (results == nil or #results <= 0) then
            MySQL.Async.execute('INSERT INTO `jobs` (`name`, `label`, `whitelisted`) VALUES (@job, @name, @whitelisted)', {
                ['@job'] = string.lower(jobData.name),
                ['@name'] = jobData.label,
                ['@whitelisted'] = jobData.whitelisted
            }, function(updated)
                Jobs.Information('Job ' .. jobData.label .. ' added to the system')
            end)
        else
            MySQL.Async.execute('UPDATE `jobs` SET `label` = @name, `whitelisted` = @whitelisted WHERE `name` = @job', {
                ['@job'] = string.lower(jobData.name),
                ['@name'] = jobData.label,
                ['@whitelisted'] = jobData.whitelisted
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
                positions = {}
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

            TriggerEvent('mlx:updateJob', {
                name = jobData.name,
                label = jobData.label,
                whitelisted = jobData.whitelisted
            }, newJobGrades)

            Jobs.Information('Job grades for ' .. jobData.label .. ' is now up to date')
        end)
    end)

    table.insert(jobTasks, function(cb)
        MySQL.Async.fetchAll('SELECT * FROM `users` WHERE LOWER(`job`) = @job OR LOWER(`job2`) = @job', {
            ['@job'] = string.lower(jobData.name)
        }, function(results)
            if (results ~= nil and #results > 0) then
                for _, user in pairs(results) do
                    local memberData = {
                        identifier = user.identifier or 'none',
                        name = user.name or '',
                        job = user.job or 'Kansloos',
                        job_grade = user.job_grade or 0,
                        job2 = user.job2 or 'Leeg',
                        job2_grade = user.job2_grade or 0,
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

    local jobInfoAdded = false

    Async.parallel(jobTasks, function(results)
        jobInfoAdded = true
    end)

    while not jobInfoAdded do
        Citizen.Wait(10)
    end

    return CreateJob(jobData.name, jobData.label, jobData.whitelisted, jobData.members, jobData.permissions, jobData.webhooks, jobData.grades, jobData.positions, jobData.accounts, jobData.items, jobData.weapons, jobData.buyableItems, jobData.menu, jobData.permissionSystem, Jobs.Version or '0.0.0')
end
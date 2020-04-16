function CreateJob(jobData, version)
    local self = {}

    self.name = jobData.name or 'unknown'
    self.label = jobData.label or 'Unknown'
    self.members = jobData.members or {}
    self.menu = jobData.menu or {}
    self.permissions = jobData.permissions or {}
    self.publicPermissions = jobData.publicPermissions or {}
    self.permissionSystem = jobData.permissionSystem or CreatePermissions()
    self.webhooks = jobData.webhooks or {}
    self.grades = jobData.grades or {}
    self.positions = jobData.positions or {}
    self.accounts = jobData.accounts or {}
    self.items = jobData.items or {}
    self.weapons = jobData.weapons or {}
    self.buyableItems = jobData.buyableItems or {}
    self.sellableItems = jobData.sellableItems or {}
    self.clothes = jobData.clothes or {}
    self.vehicles = jobData.vehicles or {}
    self.testDrives = jobData.testDrives or {}
    self.showrooms = jobData.showrooms or {}
    self.blips = jobData.blips or {}
    self.plate = jobData.plate or {}
    self.version = version or '0.0.1'

    self.getName = function()
        return self.name or 'unknown'
    end

    self.getLabel = function()
        return self.label or 'Unknown'
    end

    self.getMembers = function()
        return self.members or {}
    end

    self.addMemberByIdentifier = function(identifier, source, cb)
        if (self.members ~= nil and self.members[identifier] == nil) then
            MySQL.Async.fetchAll('SELECT * FROM `users` WHERE LOWER(`job`) = @job AND `identifier` = @identifier', {
                ['@job'] = string.lower(self.name),
                ['@identifier'] = identifier
            }, function(results)
                if (results ~= nil and results[1] ~= nil) then
                    self.members[identifier] = {
                        identifier = results[1].identifier or 'none',
                        name = results[1].name or '',
                        job = results[1].job or 'Kansloos',
                        job_grade = results[1].job_grade or 0,
                        source = source or nil,
                    }

                    if (cb ~= nil) then
                        cb()
                    end
                end
            end)
        end
    end

    self.addMemberByPlayer = function(xPlayer, cb)
        if (self.members ~= nil and self.members[xPlayer.identifier] == nil) then
            self.members[xPlayer.identifier] = {
                identifier = xPlayer.identifier or 'none',
                name = xPlayer.name or '',
                job = xPlayer.job.name or 'Kansloos',
                job_grade = xPlayer.job.grade or 0,
                source = xPlayer.source or nil,
            }

            if (cb ~= nil) then
                cb()
            end
        end
    end

    self.updateMemberByIdentifier = function(identifier, name, job, job_grade, source, cb)
        if (self.members ~= nil and self.members[identifier] ~= nil) then
            self.members[identifier].name = name or self.members[identifier].name
            self.members[identifier].job = job or self.members[identifier].job
            self.members[identifier].job_grade = job_grade or self.members[identifier].job_grade
            self.members[identifier].source = source or nil

            if (cb ~= nil) then
                cb()
            end
        end
    end

    self.updateMemberByPlayer = function(xPlayer, cb)
        if (self.members ~= nil and self.members[xPlayer.identifier] ~= nil) then
            self.members[xPlayer.identifier].name = xPlayer.name or ''
            self.members[xPlayer.identifier].job = xPlayer.job.name or 'Kansloos'
            self.members[xPlayer.identifier].job_grade = xPlayer.job.grade or 0
            self.members[xPlayer.identifier].source = xPlayer.source or nil

            if (cb ~= nil) then
                cb()
            end
        end
    end

    self.getMemberByIdentifier = function(identifier)
        if (self.members ~= nil and self.members[identifier] ~= nil) then
            return self.members[identifier]
        end
    end

    self.removeMemberByIdentifier = function(identifier, cb)
        if (self.members ~= nil and self.members[identifier] ~= nil) then
            self.members[identifier] = nil

            if (cb ~= nil) then
                cb()
            end
        end
    end

    self.memberHasPermission = function(identifier, permission)
        local member = self.getMemberByIdentifier(identifier)

        if (member ~= nil) then
            local grade = 0

            if (string.lower(member.job) == self.name) then
                grade = member.job_grade
            end

            local gradeInfo = self.getGradeByGrade(grade)

            if (gradeInfo ~= nil) then
                return self.permissionSystem.tableContainsItem(permission, gradeInfo.permissions or {}, true)
            end
        else
            return self.permissionSystem.tableContainsItem(permission, self.publicPermissions or {}, true)
        end

        return false
    end

    self.memberHasType = function(identifier, permissionType)
        local member = self.getMemberByIdentifier(identifier)

        if (member ~= nil) then
            local grade = 0

            if (string.lower(member.job) == self.name) then
                grade = member.job_grade
            end

            return self.gradeHasType(grade, permissionType)
        else
            return self.permissionSystem.isAnyPermissionAllowedToUseType(self.publicPermissions or {}, permissionType)
        end

        return false
    end

    self.getWebhooks = function()
        return self.webhooks or {}
    end

    self.getWebhooksByType = function(webhookType)
        if (self.webhooks ~= nil and self.webhooks[webhookType] ~= nil) then
            return self.webhooks[webhookType] or {}
        end
    end

    self.getGrades = function()
        return self.grades or {}
    end

    self.getGradeByGrade = function(grade)
        if (self.grades ~= nil and self.grades[tostring(grade)] ~= nil) then
            return self.grades[tostring(grade)]
        end
    end

    self.gradeHasType = function(grade, permissionType)
        local gradeInfo = self.getGradeByGrade(grade)

        if (gradeInfo ~= nil) then
            return self.permissionSystem.isAnyPermissionAllowedToUseType(gradeInfo.permissions or {}, permissionType)
        else
            return self.permissionSystem.isAnyPermissionAllowedToUseType(self.publicPermissions or {}, permissionType)
        end

        return false
    end

    self.getPermissionsByGrade = function(grade)
        local gradeData = self.getGradeByGrade(grade)

        if (gradeData) then
            return gradeData.permissions or {}
        else
            return self.publicPermissions or {}
        end
    end

    self.getPositionsByGrade = function(grade)
        local gradeData = self.getGradeByGrade(grade)

        if (gradeData) then
            return gradeData.positions or {}
        end
    end

    self.getPositionsByIndex = function(index)
        index = tonumber(index or 0) or 0

        for _, positionValues in pairs(self.positions or {}) do
            for __, position in pairs(positionValues or {}) do
                if ((position.index or 0) == index) then
                    return position
                end
            end
        end

        return nil
    end

    self.getClothesByGrade = function(grade)
        local gradeData = self.getGradeByGrade(grade)

        if (gradeData) then
            return gradeData.clothes or {}
        end
    end

    self.getVehiclesByGrade = function(grade)
        local gradeData = self.getGradeByGrade(grade)

        if (gradeData) then
            return gradeData.vehicles or {}
        end
    end

    self.getPlate = function()
        return self.plate or {}
    end

    self.getBlips = function()
        return self.blips or {}
    end

    self.getAccounts = function()
        return self.accounts or {}
    end

    self.getAccount = function(accountName)
        accountName = string.lower(accountName or 'unknown')

        if (self.accounts ~= nil and self.accounts[accountName] ~= nil) then
            return self.accounts[accountName]
        end
    end

    self.addAccountMoney = function(accountName, money)
        accountName = string.lower(accountName or 'unknown')
        money = self.round(money or 0)

        local account = self.getAccount(accountName)

        if (account ~= nil) then
            account.addMoney(money)
            self.logToDiscord(_U('job_money_added', self.label), _U('job_money_added_description',
                Jobs.Formats.NumberToCurrancy(money), accountName, _U(accountName)), accountName .. ' | ' .. self.getCurrentTimeString(),
                'moneytransactions',
                3066993)
        else
            self.accounts[accountName] = CreateJobAccount(accountName, 0, _U(accountName), self.name, self.label)
            self.addAccountMoney(accountName, money)
        end
    end

    self.removeAccountMoney = function(accountName, money)
        accountName = string.lower(accountName or 'unknown')
        money = self.round(money or 0)

        local account = self.getAccount(accountName)

        if (account ~= nil) then
            account.removeMoney(money)
            self.logToDiscord(_U('job_money_removed', self.label), _U('job_money_removed_description',
                Jobs.Formats.NumberToCurrancy(money), accountName, _U(accountName)), accountName .. ' | ' .. self.getCurrentTimeString(),
                'moneytransactions',
                15158332)
        else
            self.accounts[accountName] = CreateJobAccount(accountName, 0, _U(accountName), self.name, self.label)
            self.removeAccountMoney(accountName, money)
        end
    end

    self.setAccountMoney = function(accountName, money)
        accountName = string.lower(accountName or 'unknown')
        money = self.round(money or 0)

        local account = self.getAccount(accountName)

        if (account ~= nil) then
            account.setMoney(money)
            self.logToDiscord(_U('job_money_set', self.label), _U('job_money_set_description',
                Jobs.Formats.NumberToCurrancy(money), accountName, _U(accountName)), accountName .. ' | ' .. self.getCurrentTimeString(),
                'moneytransactions',
                15105570)
        else
            self.accounts[accountName] = CreateJobAccount(accountName, 0, _U(accountName), self.name, self.label)
            self.setAccountMoney(accountName, money)
        end
    end

    self.getItems = function()
        return self.items or {}
    end

    self.getInventory = function()
        local inventory = {}

        for _, item in pairs(self.items) do
            local xItem = Jobs.GetItem(item.name)

            table.insert(inventory, {
                name = item.name,
                count = item.count,
                label = item.label,
                weight = xItem.weight or 1,
                limit = xItem.limit or 50,
                rare = xItem.rare or 0,
                canRemove = xItem.canRemove or true
            })
        end

        return inventory
    end

    self.getItem = function(itemName)
        itemName = string.lower(itemName or 'unknown')

        if (self.items ~= nil and self.items[itemName] ~= nil) then
            return self.items[itemName]
        end
    end

    self.addItem = function(itemName, count)
        itemName = string.lower(itemName or 'unknown')
        count = self.round(count or 0)

        local item = self.getItem(itemName)

        if (item ~= nil) then
            item.addItem(count)
            self.logToDiscord(_U('job_item_added', self.label), _U('job_item_added_description',
                Jobs.Formats.NumberToFormattedString(count), itemName, item.label), itemName .. ' | ' .. self.getCurrentTimeString(),
                'itemtransactions',
                3066993)
        else
            local itemLabel = Jobs.ESX.GetItemLabel(itemName or 'unknown') or itemName or 'unknown'

            self.items[itemName] = CreateJobItem(itemName, 0, itemLabel, self.name, self.label)
            self.addItem(itemName, count)
        end
    end

    self.removeItem = function(itemName, count)
        itemName = string.lower(itemName or 'unknown')
        count = self.round(count or 0)

        local item = self.getItem(itemName)

        if (item ~= nil) then
            item.removeItem(count)
            self.logToDiscord(_U('job_item_removed', self.label), _U('job_item_removed_description',
                Jobs.Formats.NumberToFormattedString(count), itemName, item.label), itemName .. ' | ' .. self.getCurrentTimeString(),
                'itemtransactions',
                15158332)
        else
            local itemLabel = Jobs.ESX.GetItemLabel(itemName or 'unknown') or itemName or 'unknown'

            self.items[itemName] = CreateJobItem(itemName, 0, itemLabel, self.name, self.label)
            self.removeItem(itemName, count)
        end
    end

    self.setItem = function(itemName, count)
        itemName = string.lower(itemName or 'unknown')
        count = self.round(count or 0)

        local item = self.getItem(itemName)

        if (item ~= nil) then
            item.setItem(count)
            self.logToDiscord(_U('job_item_set', self.label), _U('job_item_set_description',
                Jobs.Formats.NumberToFormattedString(count), itemName, item.label), itemName .. ' | ' .. self.getCurrentTimeString(),
                'itemtransactions',
                15105570)
        else
            local itemLabel = Jobs.ESX.GetItemLabel(itemName or 'unknown') or itemName or 'unknown'

            self.items[itemName] = CreateJobItem(itemName, 0, itemLabel, self.name, self.label)
            self.setItem(itemName, count)
        end
    end

    self.getWeapons = function()
        return self.weapons or {}
    end

    self.getWeapon = function(weaponName)
        weaponName = string.lower(weaponName or 'unknown')

        if (self.weapons ~= nil and self.weapons[weaponName] ~= nil) then
            return self.weapons[weaponName]
        end
    end

    self.addWeapon = function(weaponName, count)
        weaponName = string.lower(weaponName or 'unknown')
        count = self.round(count or 0)

        local weapon = self.getWeapon(weaponName)

        if (weapon ~= nil) then
            weapon.addWeapon(count)
            self.logToDiscord(_U('job_weapon_added', self.label), _U('job_weapon_added_description',
                Jobs.Formats.NumberToFormattedString(count), string.upper(weaponName), _U(weaponName)), weaponName .. ' | ' .. self.getCurrentTimeString(),
                'weapontransactions',
                3066993)
        else
            self.weapons[weaponName] = CreateJobWeapon(weaponName, 0, _U(weaponName), self.name, self.label)
            self.addWeapon(weaponName, count)
        end
    end

    self.removeWeapon = function(weaponName, count)
        weaponName = string.lower(weaponName or 'unknown')
        count = self.round(count or 0)

        local weapon = self.getWeapon(weaponName)

        if (weapon ~= nil) then
            weapon.removeWeapon(count)
            self.logToDiscord(_U('job_weapon_removed', self.label), _U('job_weapon_removed_description',
                Jobs.Formats.NumberToFormattedString(count), string.upper(weaponName), weapon.label), weaponName .. ' | ' .. self.getCurrentTimeString(),
                'weapontransactions',
                15158332)
        else
            self.weapons[weaponName] = CreateJobWeapon(weaponName, 0, _U(weaponName), self.name, self.label)
            self.removeWeapon(weaponName, count)
        end
    end

    self.setWeapon = function(weaponName, count)
        weaponName = string.lower(weaponName or 'unknown')
        count = self.round(count or 0)

        local weapon = self.getWeapon(weaponName)

        if (weapon ~= nil) then
            weapon.setWeapon(count)
            self.logToDiscord(_U('job_weapon_set', self.label), _U('job_weapon_set_description',
                Jobs.Formats.NumberToFormattedString(count), string.upper(weaponName), _U(weaponName)), weaponName .. ' | ' .. self.getCurrentTimeString(),
                'weapontransactions',
                15105570)
        else
            self.weapons[weaponName] = CreateJobWeapon(weaponName, 0, _U(weaponName), self.name, self.label)
            self.setWeapon(weaponName, count)
        end
    end

    self.getBuyableItems = function()
        return self.buyableItems or {}
    end

    self.getBuyableItemsByType = function(itemType)
        return self.buyableItems[itemType] or {}
    end

    self.hasAnyBuyableItem = function()
        return #self.getBuyableItemsByType('items') > 0
    end

    self.hasAnyBuyableWeapon = function()
        return #self.getBuyableItemsByType('weapons') > 0
    end

    self.getSellableCategories = function(minified)
        minified = minified or false

        if (minified) then
            local results = {}

            for category, categoryValue in pairs(self.sellableItems or {}) do
                results[category] = categoryValue.label or 'Unknown'
            end

            return results or {}
        end

        return self.sellableItems or {}
    end

    self.hasAnySellableWeapon = function()
        return #self.getSellableItemsByType('weapon') > 0
    end

    self.hasAnySellableItem = function()
        return #self.getSellableItemsByType('item') > 0
    end

    self.hasAnySellableCar = function()
        return #self.getSellableItemsByType('car') > 0
    end

    self.hasAnySellableAircraft = function()
        return #self.getSellableItemsByType('aircraft') > 0
    end

    self.getSellableItemsFromCategroy = function(category)
        category = string.lower(category or 'none')

        if (self.sellableItems ~= nil and self.sellableItems[category] ~= nil) then
            return self.sellableItems[category] or {}
        end

        return {}
    end

    self.getSellableItemsByType = function(itemType)
        itemType = string.lower(itemType or 'unknown')

        local results = {}

        for category, categoryValue in pairs(self.sellableItems) do
            for _, sellableItem in pairs(categoryValue.items or {}) do
                if (sellableItem.getType() == itemType) then
                    table.insert(results, {
                        name = sellableItem.getName(),
                        code = sellableItem.getSpawnCode(),
                        label = sellableItem.getLabel(),
                        type = sellableItem.getType(),
                        buyPrice = sellableItem.getBuyPrice(),
                        sellPrice = sellableItem.getSellPrice(),
                        brand = sellableItem.getBrand(),
                        category = sellableItem.getCategory()
                    })
                end
            end
        end

        return results
    end

    self.getSellableVehicle = function(code)
        code = string.lower(code or 'unknown')

        for category, categoryValue in pairs(self.sellableItems) do
            for _, sellableItem in pairs(categoryValue.items or {}) do
                if (string.lower(sellableItem.getType() or 'unknown') == 'car' and string.lower(sellableItem.getSpawnCode() or 'none') == code) then
                    return {
                        name = sellableItem.getName(),
                        code = sellableItem.getSpawnCode(),
                        label = sellableItem.getLabel(),
                        type = sellableItem.getType(),
                        buyPrice = sellableItem.getBuyPrice(),
                        sellPrice = sellableItem.getSellPrice(),
                        brand = sellableItem.getBrand(),
                        category = sellableItem.getCategory()
                    }
                end
            end
        end

        return nil
    end

    self.getShowroom = function(index)
        for _, showroom in pairs(self.showrooms or {}) do
            if (showroom.getIndex() == index) then
                return showroom or nil
            end
        end

        return nil
    end

    self.getShowroomSpots = function(index)
        for _, showroom in pairs(self.showrooms or {}) do
            if (showroom.getIndex() == index) then
                return showroom.getSpots() or {}
            end
        end

        return {}
    end

    self.getShowroomSpotType = function(showroomIndex, spotIndex)
        for _, showroom in pairs(self.showrooms or {}) do
            if (showroom.getIndex() == showroomIndex) then
                return showroom.getSpotType(spotIndex) or 'unknown'
            end
        end

        return 'unknown'
    end

    self.getTestDriveByType = function(driveType)
        driveType = string.lower(driveType or 'unknown')

        if (self.testDrives ~= nil and self.testDrives[driveType] ~= nil) then
            return self.testDrives[driveType] or {}
        end

        return nil
    end

    self.getBank = function()
        local account = self.getAccount('bank')

        if (account ~= nil) then
            return account
        end
    end

    self.getMenu = function()
        return self.menu or {}
    end

    self.getPrimaryColor = function()
        return self.getMenu().PrimaryColor or { r = 255, g = 0, b = 0 }
    end

    self.getSecondaryColor = function()
        return self.getMenu().SecondaryColor or { r = 0, g = 0, b = 0 }
    end

    self.getJobHeaderImage = function()
        return self.getMenu().HeaderImage or 'menu_default.jpg'
    end

    self.logToDiscord = function(title, message, footer, webhookType, color)
        local webhookValues = self.getWebhooksByType(webhookType)

        for _, webhookValue in pairs(webhookValues or {}) do
            color = color or 9807270

            local requestInfo = {
                ['color'] = color,
                ['type'] = 'rich',
                ['title'] = title,
                ['description'] = message,
                ['footer'] = {
                    ['text'] = footer
                }
            }

            PerformHttpRequest(webhookValue, function(error, text, headers) end, 'POST', json.encode({ username = self.label .. ' | Logs | ' .. self.version, embeds = { requestInfo } }), { ['Content-Type'] = 'application/json' })
        end
    end

    self.logIdentifierToDiscord = function(identifier, title, message, webhookType, color)
        local currentTime = self.getCurrentTimeString()

        self.logToDiscord(title, message, self.label .. ' | ' .. identifier .. ' | ' .. currentTime, webhookType, color)
    end

    self.logSourceToDiscord = function(source, title, message, webhookType, color)
        local identifier = self.getIdentifierBySource(source)

        self.logIdentifierToDiscord(identifier, title, message, webhookType, color)
    end

    self.getIdentifierBySource = function(source)
        if (source == nil) then
            return ''
        end

        local playerId = tonumber(source)

        if (playerId <= 0) then
            return ''
        end

        local identifiers, steamIdentifier = GetPlayerIdentifiers(source)

        for _, identifier in pairs(identifiers) do
            if (string.match(string.lower(identifier), 'steam:')) then
                steamIdentifier = identifier
            end
        end

        return steamIdentifier
    end

    self.getCurrentTimeString = function()
        local date_table = os.date("*t")
        local hour, minute, second = date_table.hour, date_table.min, date_table.sec
        local year, month, day = date_table.year, date_table.month, date_table.day

        if (string.lower(Config.Locale) == 'nl') then
            return string.format("%d-%d-%d %d:%d:%d", day, month, year, hour, minute, second)
        end

        return string.format("%d-%d-%d %d:%d:%d", year, month, day, hour, minute, second)
    end

    self.round = function(value, numDecimalPlaces)
        if numDecimalPlaces then
            local power = 10^numDecimalPlaces
            return math.floor((value * power) + 0.5) / (power)
        else
            return math.floor(value + 0.5)
        end
    end

    return self
end
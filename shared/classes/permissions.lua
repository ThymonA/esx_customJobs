function CreatePermissions()
    local self = {}

    self.permissionGroups = {}
    self.permissions = {}
    self.types = {}

    self.systemPermissions = {
        ['safe.item.*'] = {
            ['safe.item.add'] = { 'safe_items' },
            ['safe.item.remove'] = { 'safe_items' },
            ['safe.item.buy'] = { 'safe_items' },
        },
        ['safe.weapon.*'] = {
            ['safe.weapon.add'] = { 'safe_weapons' },
            ['safe.weapon.remove'] = { 'safe_weapons' },
            ['safe.weapon.buy'] = { 'safe_weapons' },
        },
        ['safe.account.*'] = {
            ['safe.account.add'] = { 'safe_items' },
            ['safe.account.remove'] = { 'safe_banking' },
        },
        ['wardrobe.*'] = {
            ['wardrobe.use'] = { 'wardrobe' }
        },
        ['vehicle.*'] = {
            ['vehicle.spawn'] = { 'vehicles' },
            ['vehicle.park'] = { 'parkings' }
        },
        ['action.menu.*'] = {
            ['action.menu.allow'] = { 'action_menu' },
            ['action.menu.handcuff'] = { 'action_menu' },
            ['action.menu.drag'] = { 'action_menu' },
            ['action.menu.hostage'] = { 'action_menu' },
            ['action.menu.invehicle'] = { 'action_menu' },
            ['action.menu.outvehicle'] = { 'action_menu' },
            ['action.menu.idcard'] = { 'action_menu' },
            ['action.menu.search'] = { 'action_menu' },
            ['action.menu.steal'] = { 'action_menu' },
            ['action.menu.hijackvehicle'] = { 'action_menu' },
        },
        ['showroom.*'] = {
            ['showroom.add'] = { 'showroom' },
            ['showroom.remove'] = { 'showroom' }
        },
        ['sells.*'] = {
            ['sells.sell.cars'] = { 'sells' },
            ['sells.sell.aircrafts'] = { 'sells' },
            ['sells.sell.weapons'] = { 'sells' },
            ['sells.sell.items'] = { 'sels' }
        },
        ['catalogues.*'] = {
            ['catalogues.use'] = { 'catalogues' }
        }
    }

    self.initialize = function()
        for permissionGroup, permissionGroupValue in pairs(self.systemPermissions) do
            local permissions = {}
            local types = {}

            for permission, permissionTypes in pairs(permissionGroupValue) do
                if (not self.tableContainsItem(permission, permissions, true)) then
                    table.insert(permissions, permission)
                end

                for _, permissionType in pairs(permissionTypes) do
                    if (not self.tableContainsItem(permissionType, types, true)) then
                        table.insert(types, permissionType)
                    end

                    if (self.types ~= nil and self.types[permissionType] == nil) then
                        self.types[permissionType] = {
                            permissions = { permission }
                        }
                    else
                        table.insert(self.types[permissionType], permission)
                    end
                end

                if (self.permissions ~= nil and self.permissions[permission] == nil) then
                    self.permissions[permission] = {
                        allowedTypes = types
                    }
                end
            end

            if (self.permissionGroups ~= nil and self.permissionGroups[permissionGroup] == nil) then
                self.permissionGroups[permissionGroup] = {
                    group = permissionGroup,
                    permissions = permissions,
                    allowedTypes = types
                }
            end
        end
    end

    self.getAllPermissionGroups = function()
        return self.permissionGroups or {}
    end

    self.getPermissionGroup = function(permissionGroup)
        if (self.permissionGroups ~= nil and self.permissionGroups[permissionGroup] ~= nil) then
            return self.permissionGroups[permissionGroup] or {}
        end
    end

    self.getAllPermissions = function()
        return self.permissions or {}
    end

    self.getPermission = function(permission)
        if (self.permissions ~= nil and self.permissions[permission] ~= nil) then
            return self.permissions[permission] or {}
        end
    end

    self.isPermissionGroup = function(permission)
        return self.permissionGroups[permission] ~= nil
    end

    self.isPermissionAllowedToUseType = function(permission, permissionType)
        if (self.isPermissionGroup(permission)) then
            local group = self.getPermissionGroup(permission)
            local allowedTypes = group.allowedTypes or {}

            return self.tableContainsItem(permissionType, allowedTypes, true)
        end

        local perm = self.getPermission(permission)
        local allowedTypes = perm.allowedTypes or {}

        return self.tableContainsItem(permissionType, allowedTypes, true)
    end

    self.hasAnyPermission = function(permissions, permission)
        permissions = permissions or {}

        for _, _permission in pairs(permissions) do
            if (self.isPermissionGroup(_permission)) then
                local group = self.getPermissionGroup(_permission)

                for __, __permission in pairs(group.permissions or {}) do
                    if (string.lower(__permission) == string.lower(permission)) then
                        return true
                    end
                end
            else
                if (string.lower(_permission) == string.lower(permission)) then
                    return true
                end
            end
        end

        return false
    end

    self.isAnyPermissionAllowedToUseType = function(permissions, permissionType)
        for _, permission in pairs(permissions) do
            if (self.isPermissionAllowedToUseType(permission, permissionType)) then
                return true
            end
        end

        return false
    end

    self.doesPermissionExists = function(permission)
        return self.permissions[permission] ~= nil
    end

    self.tableContainsItem = function(item, table, ignoreCase)
        table = table or {}
        ignoreCase = ignoreCase or false

        if (string.lower(type(table)) ~= 'table' or #table <= 0) then
            return false
        end

        if (ignoreCase) then
            ignoreCase = true
        else
            ignoreCase = false
        end

        for _, tableItem in pairs(table) do
            if (ignoreCase and string.lower(tostring(item)) == string.lower(tostring(tableItem))) then
                return true
            elseif (tostring(item) == tostring(tableItem)) then
                return true
            end
        end

        return false
    end

    self.initialize()

    return self
end
function CreateJob(name, label, whitelisted, members, permissions, webhooks, grades, positions, permissionSystem)
    local self = {}

    self.name = name
    self.label = label
    self.whitelisted = whitelisted
    self.members = members
    self.permissions = permissions
    self.webhooks = webhooks
    self.grades = grades
    self.positions = positions
    self.permissionSystem = permissionSystem

    self.getName = function()
        return self.name or 'unknown'
    end

    self.getLabel = function()
        return self.label or 'Unknown'
    end

    self.isWhitelisted = function()
        return self.whitelisted or true
    end

    self.getMembers = function()
        return self.members or {}
    end

    self.addMemberByIdentifier = function(identifier)
        if (self.members ~= nil and self.members[identifier] == nil) then
            MySQL.Async.fetchAll('SELECT * FROM `users` WHERE LOWER(`job`) = @job OR LOWER(`job2`) = @job AND `identifier` = @identifier', {
                ['@job'] = string.lower(self.name),
                ['@identifier'] = identifier
            }, function(results)
                if (results ~= nil and results[1] ~= nil) then
                    self.members[identifier] = {
                        identifier = results[1].identifier or 'none',
                        name = results[1].name or '',
                        job = results[1].job or 'Kansloos',
                        job_grade = results[1].job_grade or 0,
                        job2 = results[1].job2 or 'Leeg',
                        job2_grade = results[1].job2_grade or 0,
                        firstname = results[1].firstname or 'Unknown',
                        lastname = results[1].lastname or 'Unknown',
                        dateOfBirth = results[1].dateofbirth or '01-01-0001',
                        sex = results[1].sex or 'm',
                        height = results[1].height or 0,
                        phoneNumber = results[1].phone_number or 0,
                        source = nil,
                    }
                end
            end)
        end
    end

    self.updateMemberByIdentifier = function(identifier, name, job, job_grade, job2, job2_grade)
        if (self.members ~= nil and self.members[identifier] ~= nil) then
            self.members[identifier].name = name or self.members[identifier].name
            self.members[identifier].job = job or self.members[identifier].job
            self.members[identifier].job_grade = job_grade or self.members[identifier].job_grade
            self.members[identifier].job2 = job2 or self.members[identifier].job2
            self.members[identifier].job2_grade = job2_grade or self.members[identifier].job2_grade
        end
    end

    self.getMemberByIdentifier = function(identifier)
        if (self.members ~= nil and self.members[identifier] ~= nil) then
            return self.members[identifier]
        end
    end

    self.removeMemberByIdentifier = function(identifier)
        if (self.members ~= nil and self.members[identifier] ~= nil) then
            self.members[identifier] = nil
        end
    end

    self.memberHasPermission = function(identifier, permission)
        local member = self.getMemberByIdentifier(identifier)

        if (member ~= nil) then
            local grade = 0

            if (string.lower(member.job) == self.name) then
                grade = member.job_grade
            end

            if (string.lower(member.job2) == self.name) then
                grade = member.job2_grade
            end

            local gradeInfo = self.getGradeByGrade(grade)

            if (gradeInfo ~= nil) then
                return self.permissionSystem.tableContainsItem(permission, gradeInfo.permissions or {}, true)
            end
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

            if (string.lower(member.job2) == self.name and member.job2_grade >= grade) then
                grade = member.job2_grade
            end

            return self.gradeHasType(grade, permissionType)
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
        end

        return false
    end

    self.getPermissionsByGrade = function(grade)
        local gradeData = self.getGradeByGrade(grade)

        if (gradeData) then
            return gradeData.permissions or {}
        end
    end

    self.getPositionsByGrade = function(grade)
        local gradeData = self.getGradeByGrade(grade)

        if (gradeData) then
            return gradeData.positions or {}
        end
    end

    return self
end
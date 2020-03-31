function CreateJobWeapon(name, count, label, jobName, jobLabel)
    local self = {}

    self.name = name
    self.count = count
    self.label = label
    self.jobName = jobName
    self.jobLabel = jobLabel

    self.getWeapons = function()
        return self.count or 0
    end

    self.addWeapon = function(count)
        count = self.round(count)

        if (count >= 0) then
            self.count = (self.count + count)
            self.triggerEvent('esx_jobs:setJobWeapon', self.jobName, self.name, self.count)
            self.triggerEvent('esx_jobs:addWeapon', self.jobName, self.name, count)
            self.save()
        end
    end

    self.removeWeapon = function(count)
        count = self.round(count)

        if (count >= 0) then
            self.count = (self.count - count)
            self.triggerEvent('esx_jobs:setJobWeapon', self.jobName, self.name, self.count)
            self.triggerEvent('esx_jobs:removeWeapon', self.jobName, self.name, count)
            self.save()
        end
    end

    self.setWeapon = function(count)
        count = self.round(count)

        if (count >= 0) then
            self.count = count
            self.triggerEvent('esx_jobs:setJobWeapon', self.jobName, self.name, self.count)
            self.triggerEvent('esx_jobs:setWeapon', self.jobName, self.name, count)
            self.save()
        end
    end

    self.save = function()
        MySQL.Async.execute('INSERT INTO `job_weapon` (`job`, `weapon`, `count`, `label`) VALUES (@job, @weapon, @count, @label) ON DUPLICATE KEY UPDATE `count` = @count, `label` = @label', {
            ['@count'] = self.round(self.count),
            ['@label'] = self.label,
            ['@job'] = self.jobName,
            ['@weapon'] = self.name
        })
    end

    self.triggerEvent = function(name, ...)
        TriggerEvent(name, ...)
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
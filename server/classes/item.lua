function CreateJobItem(name, count, label, jobName, jobLabel)
    local self = {}

    self.name = name
    self.count = count
    self.label = label
    self.jobName = jobName
    self.jobLabel = jobLabel

    self.getItems = function()
        return self.count or 0
    end

    self.addItem = function(count)
        count = self.round(count)

        if (count >= 0) then
            self.count = (self.count + count)
            self.triggerEvent('esx_jobs:setJobItem', self.jobName, self.name, self.count)
            self.triggerEvent('esx_jobs:addItem', self.jobName, self.name, count)
            self.save()
        end
    end

    self.removeItem = function(count)
        count = self.round(count)

        if (count >= 0) then
            self.count = (self.count - count)
            self.triggerEvent('esx_jobs:setJobItem', self.jobName, self.name, self.count)
            self.triggerEvent('esx_jobs:removeItem', self.jobName, self.name, count)
            self.save()
        end
    end

    self.setItem = function(count)
        count = self.round(count)

        if (count >= 0) then
            self.count = count
            self.triggerEvent('esx_jobs:setJobItem', self.jobName, self.name, self.count)
            self.triggerEvent('esx_jobs:setItem', self.jobName, self.name, count)
            self.save()
        end
    end

    self.save = function()
        MySQL.Async.execute('INSERT INTO `job_safe` (`job`, `item`, `count`, `label`) VALUES (@job, @item, @count, @label) ON DUPLICATE KEY UPDATE `count` = @count, `label` = @label', {
            ['@count'] = self.round(self.count),
            ['@label'] = self.label,
            ['@job'] = self.jobName,
            ['@item'] = self.name
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
function CreateJobAccount(name, money, label, jobName, jobLabel)
    local self = {}

    self.name = name
    self.money = money
    self.label = label
    self.jobName = jobName
    self.jobLabel = jobLabel

    self.getMoney = function()
        return self.money or 0
    end

    self.addMoney = function(money)
        money = self.round(money)

        if (money >= 0) then
            self.money = (self.money + money)
            self.triggerEvent('esx_jobs:setJobMoney', self.jobName, self.name, self.money)
            self.triggerEvent('esx_jobs:addMoney', self.jobName, self.name, money)
            self.save()
        end
    end

    self.removeMoney = function(money)
        money = self.round(money)

        if (money >= 0) then
            self.money = (self.money - money)
            self.triggerEvent('esx_jobs:setJobMoney', self.jobName, self.name, self.money)
            self.triggerEvent('esx_jobs:removeMoney', self.jobName, self.name, money)
            self.save()
        end
    end

    self.setMoney = function(money)
        money = self.round(money)

        if (money >= 0) then
            self.money = money
            self.triggerEvent('esx_jobs:setJobMoney', self.jobName, self.name, self.money)
            self.triggerEvent('esx_jobs:setMoney', self.jobName, self.name, money)
            self.save()
        end
    end

    self.save = function()
        MySQL.Async.execute('INSERT INTO `job_account` (`job`, `account`, `money`, `label`) VALUES (@job, @account, @money, @label) ON DUPLICATE KEY UPDATE `money` = @money, `label` = @label', {
            ['@money'] = self.round(self.money),
            ['@label'] = self.jobLabel .. ' ' .. self.label,
            ['@job'] = self.jobName,
            ['@account'] = self.name
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
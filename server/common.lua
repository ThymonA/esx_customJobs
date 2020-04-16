Jobs                            = {}
Jobs.Jobs                       = {}
Jobs.JobGradesAllowed           = {}
Jobs.Version                    = '0.0.0'
Jobs.ESX                        = nil
Jobs.ScriptLoaded               = false
Jobs.JobsLoaded                 = false
Jobs.ServerCallbacks            = {}
Jobs.ServerEvents               = {}
Jobs.Handcuffs                  = {}
Jobs.Hostages                   = {}
Jobs.Dragges                    = {}
Jobs.JobPlayers                 = {}
Jobs.JobPublics                 = {}
Jobs.VehicleSales               = {}
Jobs.BuyInProgress              = {}

TriggerEvent('esx:getSharedObject', function (object)
    Jobs.ESX = object
end)

Citizen.CreateThread(function()
    Citizen.Wait(0)

    while Jobs.ESX == nil do
        TriggerEvent('esx:getSharedObject', function (object)
            Jobs.ESX = object
        end)

        Citizen.Wait(0)
    end

    if (not Jobs.ScriptLoaded) then
        Jobs.InitializeScript()
    end
end)

Jobs.InitializeScript = function()
    if (Jobs.ScriptLoaded) then
        return
    end

    Jobs.LoadCurrentScriptVersion()
    Jobs.LoadAllJobs()
end

Jobs.LoadCurrentScriptVersion = function()
    local currentScriptVersion = Jobs.LoadResourceFile('version')

    if (not currentScriptVersion) then
        Jobs.Version = '0.0.0'
    else
        Jobs.Version = currentScriptVersion
    end
end

Jobs.LoadAllJobs = function()
    local jobsContent = Jobs.LoadResourceFile('data/jobs.json')

    if (not jobsContent) then
        return
    end

    local jobs = json.decode(jobsContent)

    if (not jobs) then
        return
    end

    local jobTasks = {}

    for _, job in pairs(jobs) do
        local currentJobContent = Jobs.LoadResourceFile('data/jobs/' .. string.lower(job) .. '.json')

        if (not currentJobContent) then
            Jobs.Warning('Job: ' .. job .. ' not found in path @' .. GetCurrentResourceName() .. '/data/jobs/' .. string.lower(job) .. '.json')
        else
            local currentJob = json.decode(currentJobContent)

            if (not currentJob) then
                Jobs.Warning('Job: ' .. job .. ' couldn\'t be loaded, please check if file \'@' .. GetCurrentResourceName() .. '/data/jobs/' .. string.lower(job) .. '.json\' is valid')
            else
                local jobName = currentJob.JobName or job or nil

                if (jobName ~= nil) then
                    table.insert(jobTasks, function(cb)
                        local data = Jobs.LoadJob(currentJob)

                        while data == nil do
                            Citizen.Wait(0)
                        end

                        Jobs.Jobs[data.getName()] = data

                        if (cb ~= nil) then
                            cb()
                        end
                    end)
                end
            end
        end
    end

    Async.parallel(jobTasks, function(results)
        Jobs.Information('All jobs has been loaded')

        Jobs.JobsLoaded = true
    end)
end

Jobs.LoadResourceFile = function(file)
    return LoadResourceFile(GetCurrentResourceName(), file)
end

Jobs.Information = function(message)
    Jobs.Trace('[INFO] ' .. message)
end

Jobs.Warning = function(message)
    Jobs.Trace('[WARNING] ' .. message)
end
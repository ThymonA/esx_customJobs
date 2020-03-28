Jobs.Trace = function(msg)
    if (ServerConfig.EnableDebug) then
        local message = ('[' .. GetCurrentResourceName() .. '] [DEBUG] %s'):format(msg)

        Citizen.Trace(message .. '\n')
    end
end

Jobs.GetJobFromName = function(jobName)
    return Jobs.Jobs[jobName]
end
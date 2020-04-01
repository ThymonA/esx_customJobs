Jobs.RemoveFromTable = function (items, str, ignoreCase)
    items = items or {}
    ignoreCase = ignoreCase or false

    if (string.lower(type(items)) ~= 'table' or #items <= 0) then
        return
    end

    if (ignoreCase) then
        ignoreCase = true
    else
        ignoreCase = false
    end

    for _, item in pairs(items) do
        if (ignoreCase and string.lower(tostring(item)) == string.lower(tostring(str))) then
            table.remove(items, _)
            return
        elseif (tostring(item) == tostring(str)) then
            table.remove(items, _)
            return
        end
    end
end

Jobs.RandomString = function(length)
    local result = ''

    for i = 1, length do
        Citizen.Wait(0)
        local addNumber = math.random(0, 1) == 1

        if (addNumber) then
            result = result .. Jobs.GetRandomNumber(1)
        else
            result = result .. Jobs.GetRandomLetter(1)
        end
    end

	return result
end

Jobs.GetRandomNumber = function(length)
    Citizen.Wait(0)
    if length > 0 then
		return Jobs.GetRandomNumber(length - 1) .. string.char(math.random(48, 57))
	else
		return ''
	end
end

Jobs.GetRandomLetter = function(length)
    Citizen.Wait(0)
	if length > 0 then
		return Jobs.GetRandomLetter(length - 1) .. string.char(math.random(97, 122))
	else
		return ''
	end
end
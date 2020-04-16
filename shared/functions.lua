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

Jobs.GenerateLicense = function(prefix, length, spaceBetween)
    prefix = prefix or ''
    length = length or 6
    spaceBetween = spaceBetween or false

    local firstLength = 0
    local secondLength = 0
    local plate = ''

    if (length > 8) then
        length = 8
    end

    if (spaceBetween) then
        firstLength = Jobs.Formats.Round(length / 2, 0)
        secondLength = length - firstLength

        if ((firstLength + secondLength) > 7 and spaceBetween) then
            firstLength = 4
            secondLength = 3
        elseif ((firstLength + secondLength) > 8 and not spaceBetween) then
            firstLength = 4
            secondLength = 4
        end
    else
        firstLength = length
    end

    if (string.len(prefix) > firstLength) then
        prefix = string.sub(prefix, 1, firstLength)
    end

    local firstLengthToGenerate = firstLength - string.len(prefix)

    if (firstLengthToGenerate <= 0) then
        plate = prefix
    else
        plate = prefix .. Jobs.RandomString(firstLengthToGenerate)
    end

    if (spaceBetween) then
        plate = plate .. ' '
    end

    if (secondLength > 0) then
        plate = plate .. Jobs.RandomString(secondLength)
    end

    return string.upper(plate)
end
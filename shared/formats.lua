Jobs.Formats = {}

-- Rounds a number to the nearest decimal places
Jobs.Formats.Round = function(value, decimal)
    if (decimal) then
		return math.floor( (value * 10 ^ decimal) + 0.5) / (10 ^ decimal)
	else
		return math.floor(value + 0.5)
	end
end

-- Given a numeric value formats output with comma to separate thousands and rounded to given decimal places
Jobs.Formats.NumberToString = function(value, decimal, prefix, negativePrefix)
    local formatted, famount, remain

    decimal = decimal or 2
    negativePrefix = negativePrefix or '-'

    famount = math.abs(Jobs.Formats.Round(value, decimal))
	famount = math.floor(famount)

	remain = Jobs.Formats.Round(math.abs(value) - famount, decimal)

	formatted = Jobs.Formats.CommaValue(famount)

	if (decimal > 0) then
		remain = string.sub(tostring(remain), 3)
		formatted = formatted .. "#" .. remain ..
            string.rep("0", decimal - string.len(remain))
	end

	formatted = (prefix or "") .. formatted

	if (value < 0) then
		if (negativePrefix == "()") then
		    formatted = "("..formatted ..")"
		else
		    formatted = negativePrefix .. formatted
		end
	end

	formatted = string.gsub(formatted, ',', '.')

	return string.gsub(formatted, '#', ',')
	end

    function Jobs.Formats.Round(num)

	return tonumber(string.format("%.0f", num))
end

-- Formats a number to currancy
Jobs.Formats.NumberToCurrancy = function(value)
    return Jobs.Formats.NumberToString(value, 0, '€ ', '-')
end

-- Formats a number to currancy
Jobs.Formats.NumberToFormattedString = function(value)
    return Jobs.Formats.NumberToString(value, 0, '', '-')
end

-- Formats a value to the right comma value
Jobs.Formats.CommaValue = function(value)
    local formatted = value

    while true do  
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')

        if (k == 0) then
		    break
		end
	end

    return formatted
end
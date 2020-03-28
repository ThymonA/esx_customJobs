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
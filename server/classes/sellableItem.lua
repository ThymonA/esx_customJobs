function CreateSellableItem(name, label, itemType, data)
    local self = {}

    self.name = name
    self.label = label
    self.type = itemType
    self.data = data

    self.getName = function()
        return self.name or 'unknown'
    end

    self.getLabel = function()
        return self.label or 'Unknown'
    end

    self.getType = function()
        return string.lower(self.type or 'unknown')
    end

    self.getBrand = function()
        return (self.data or {}).brand or 'Unknown'
    end

    self.getBuyPrice = function()
        return (self.data or {}).buyPrice or 0
    end

    self.getSellPrice = function()
        return (self.data or {}).sellPrice or 0
    end

    self.getSpawnCode = function()
        return (self.data or {}).code or 'unknown'
    end

    self.getCategory = function()
        return (self.data or {}).category or 'unknown'
    end

    return self
end
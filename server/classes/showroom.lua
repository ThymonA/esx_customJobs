function CreateShowroom(index, key, name, jobName, spots, props)
    local self = {}

    self.index = index or 0
    self.key = key or 'x'
    self.name = name or 'Unknown'
    self.jobName = jobName or 'Unknown'
    self.spots = spots or {}
    self.props = props or {}

    self.getIndex = function()
        return self.index or 0
    end

    self.getKey = function()
        return self.key or 'x'
    end

    self.getName = function()
        return self.name or 'Unknown'
    end

    self.getSpots = function()
        return self.spots or {}
    end

    self.getProps = function()
        return self.props or {}
    end

    self.spotExists = function(index)
        return self.spots ~= nil and self.spots[index] ~= nil
    end

    self.isSpotAvailable = function(index)
        if (self.spotExists(index)) then
            return not (self.spots[index].locked or false)
        end

        return false
    end

    self.getSpotName = function(index)
        if (self.spotExists(index)) then
            return self.spots[index].label or 'Unknown'
        end

        return 'Unknown'
    end

    self.getSpotObjectName = function(index)
        if (self.spotExists(index)) then
            local code = self.spots[index].code or 'unknown'

            if (string.lower(code) == 'unknown') then
                return nil
            end

            return code
        end

        return nil
    end

    self.getSpotType = function(index)
        if (self.spotExists(index)) then
            local spotType = self.spots[index].type or 'unknown'

            if (string.lower(spotType) == 'unknown') then
                return nil
            end

            return spotType
        end

        return nil
    end

    self.removeSpotObject = function(index)
        if (self.spotExists(index) and not self.isSpotAvailable(index)) then
            self.spots[index].code = 'unknown'
            self.spots[index].locked = false
            self.save()
        end
    end

    self.addSpotObject = function(index, code)
        if (self.spotExists(index) and self.isSpotAvailable(index)) then
            self.spots[index].code = code
            self.spots[index].locked = true
            self.save()
        end
    end

    self.updateSpotObject = function(index, code)
        if (self.spotExists(index) and not self.isSpotAvailable(index)) then
            self.spots[index].code = code
            self.save()
        else
            self.addSpotObject(index, code)
        end
    end

    self.getFilename = function()
        return string.lower(self.jobName) .. '_showroom_' .. string.lower(self.key) .. '.json'
    end

    self.save = function()
        local content = {
            key = self.key or 'x',
            name = self.name or 'Unknown',
            job = self.jobName or 'unknown',
            spots = {}
        }

        for _, spot in pairs(self.spots) do
            table.insert(content.spots, {
                label = spot.label or 'Unknown',
                position = spot.position or {},
                type = spot.type or 'unknown',
                index = spot.index or -1,
                locked = spot.locked or false,
                code = spot.code or 'unknown',
                job = self.jobName or 'unknown',
                key = self.key or 'x',
                showroomIndex = self.index or 0
            })
        end

        SaveResourceFile(GetCurrentResourceName(), 'data/showrooms/' .. self.getFilename(), json.encode(content or {}, { indent = true }))
    end

    self.initialize = function()
        local rawContent = LoadResourceFile(GetCurrentResourceName(), 'data/showrooms/' .. self.getFilename())

        for _, spot in pairs(self.spots) do
            spot.job = self.jobName or 'unknown'
            spot.key = self.key or 'x'
            spot.showroomIndex = self.index or 0
        end

        if (not rawContent) then
            self.save()
            return
        end

        local content = json.decode(rawContent)

        if (not content) then
            self.save()
            return
        end

        for _, rawSpot in pairs(content.spots or {}) do
            for _, spot in pairs(self.spots) do
                if ((rawSpot.position or {}) == (spot.position or {})) then
                    spot.locked = rawSpot.locked or false
                    spot.code = rawSpot.code or 'unknown'
                    break
                elseif((rawSpot.index or -1) == (spot.index or -1)) then
                    spot.locked = rawSpot.locked or false
                    spot.code = rawSpot.code or 'unknown'
                    break
                end
            end
        end

        self.save()
    end

    self.initialize()

    return self
end
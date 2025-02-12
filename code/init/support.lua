return function(map)
    --- adds support functions to map.
    -- add in a shortcut to get tile properties for the tile layers
	for _, layer in ipairs(map.layers) do
		if layer.type == "tilelayer" then
			layer.parent = map
			layer.getTileProperties = function(self, x, y)
				if  x < 0 or y < 0 or x > self.parent.width or y > self.parent.height then
					return {}
				end
				-- if  x < 0 or y < 0 then
				-- 	return {}
				-- end
				if self.data[y+1][x+1] then
					return self.data[y+1][x+1].properties
				else
					return {}
				end
			end
		end
	end


	-- rewriting this to fit our own means
	map.convertTileToPixel = function(self, x, y)
		return {
			x = x * self.tilewidth,
			y = y * self.tileheight
		}
	end

	-- same story here
	map.convertPixelToTile = function(self, x, y)
		return { 
			x = x / self.tilewidth,
			y = y / self.tileheight - self.tileheight
		}
	end

	---Looks through the objects and returns the first one with the given name
	---@param name string
	---@return table
	function map.getObjectByName(self, name)
		for k,v in ipairs(self.objects) do
			if v.name == name then
				return v
			end
		end
		return {}
	end

	function map.getObjectByID(self, id)
		for k,v in ipairs(self.objects) do
			if v.id == id then
				return v
			end
		end
	end


	map.objects = map.layers.objects.objects

	---Returns a table of objects that are at the given tile position.
	---@param self table
	---@param x integer tile X position
	---@param y integer tile Y position
	---@return table
	map.objectsAt = function(self, x, y)
		local objects = {}
		for k, object in ipairs(self.layers.objects.objects) do
			if object.tile.x == x and object.tile.y == y then
				table.insert(objects, object)
			end
		end
		return objects
	end

    map.reachableTiles = function(self, x, y, movementPoints, movementModel, positions)
        -- provide defaults
        positions = positions or {}
        movementModel = movementModel or 1
        local tileProperties = self.layers.terrain:getTileProperties(x, y)
        local isReachable = true

        -- make sure we are not already in the list, and don't do anything else if we are.
        for _, position in ipairs(positions) do
            if position[1] == x and position[2] == y then return positions end
        end
        -- go through tests to see if this is reachable first.
        -- -- -- is there an enemy blocking the way?
        -- local objects = self:objectsAt(x, y)
        -- for _, object in ipairs(objects) do
        -- 	if object.team == "enemy" then isReachable = false end
        -- end
        -- -- is there an object blocking the way?
        local objects = self:objectsAt(x, y)
        for _, object in ipairs(self:objectsAt(x,y)) do
            if object.team == "ally" or not object.visible then
                isReachable = true
            else
                isReachable = false
            end
        end
        -- -- do we have the energy to get there?
        if tileProperties.landEffect then
            local toll = tileProperties.landEffect /100 + 1 * movementModel
            movementPoints = movementPoints - toll
            if movementPoints <= 0 then isReachable = false end
        end
        -- -- is the position out of bounds?
        if x < 0 or y < 0 or x > self.width or y > self.height then isReachable = false end

        --if we passed all the checks, add to the positions list and check the adjacent tiles
        if isReachable then
            table.insert(positions, {x, y})
            self:reachableTiles(x+1, y, movementPoints, movementModel, positions)
            self:reachableTiles(x-1, y, movementPoints, movementModel, positions)
            self:reachableTiles(x, y+1, movementPoints, movementModel, positions)
            self:reachableTiles(x, y-1, movementPoints, movementModel, positions)
        end
        return positions
    end
end
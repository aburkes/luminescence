local sti = require "code/libs/Simple-Tiled-Implementation/sti"

---Loads the map and overloads it with objects and useful features.
---@param location string location of the map file in .lua format
---@diagnostic disable-next-line: undefined-doc-name
---@return Map
function Loadmap(location)
    local map = sti(location)

	-- get the objects from the object layer, replace the objects layer with a custom layer that has the objects and any extra setup we needed.
	local mapObjects = map.layers.objects.objects
	local objects = {}
	for k,v in ipairs(mapObjects) do
		table.insert(objects, v)
	end
	local layer = map:convertToCustomLayer("objects")
	layer.objects = objects
	for k,v in pairs(objects) do
		v.sprite = love.graphics.newImage(v.properties.image)
		v.y = v.y - map.tileheight -- because tiled uses bottom left, while love uses top left.
		-- give tile positions
		v.tile = {
			x = math.floor(v.x / map.tilewidth),
			y = math.floor((v.y - map.tileheight) / map.tileheight) + 1
		}
		
		-- we're just moving these around to make code a little less verbose later on.
		if v.type == "fighter" then
			v.stats = v.properties.stats
			v.team = v.properties.team
			-- give them maximums for hp and mp.
			v.stats.hpmax = v.stats.hp
			v.stats.mpmax = v.stats.mp
		end
		v.move = {
			parent = v,
			-- queue = {"left","right","down","up"},
			queue = {},
			lock = false,
			dest = {},
			-- speed = 200,
			speed = 500,
			update = function(self, dt)
				-- will be overwritten by subsequent functions.
			end,
			arbitrary = "teststring",
			
			--- Moves object one tile to the right
			---@param self table
			---@param dt number deltaTime - required
			right = function(self, dt)
				if self.lock then return end
				if self.parent.tile.x >= map.width +1 then return end
				self.lock = true
				self.parent.tile.x = self.parent.tile.x + 1
				self.dest = map:convertTileToPixel(self.parent.tile.x, self.parent.tile.y)
				-- overwrite the update function to make it move to the right position until done and stop.
				self.update = function (otherSelf, deltaTime)
					otherSelf.parent.x = otherSelf.parent.x + (otherSelf.speed * deltaTime)
					if otherSelf.parent.x >= otherSelf.dest.x then
						local realpos = map:convertTileToPixel(otherSelf.parent.tile.x, otherSelf.parent.tile.y)
						otherSelf.parent.x = realpos.x
						otherSelf.parent.y = realpos.y
						otherSelf.update = function() end
						otherSelf.lock = false
					end
					
				end
			end,

			--- Moves object one tile to the left
			---@param self table
			---@param dt number deltaTime - required
			left = function (self, dt)
				self.facing = "left"
				if self.lock then return end
				self.lock = true
				self.parent.tile.x = self.parent.tile.x - 1
				if self.parent.tile.x < 1 then self.parent.tile.x = 0 end
				self.dest = map:convertTileToPixel(self.parent.tile.x, self.parent.tile.y)
				-- overwrite the update function to make it move to the left position until done and stop.
				self.update = function (otherSelf, deltaTime)
					otherSelf.parent.x = otherSelf.parent.x - (otherSelf.speed * deltaTime)
					if otherSelf.parent.x <= otherSelf.dest.x then
						local realpos = map:convertTileToPixel(otherSelf.parent.tile.x, otherSelf.parent.tile.y)
						otherSelf.parent.x = realpos.x
						otherSelf.parent.y = realpos.y
						otherSelf.update = function() end
						otherSelf.lock = false
					end
					
				end
				
			end,

			--- Moves object one tile up
			--- @param self table
			--- @param dt number deltaTime - required
			up = function(self, dt)
				self.facing = "up"
				if self.lock then return end
				self.lock = true
				self.parent.tile.y = self.parent.tile.y - 1
				if self.parent.tile.y < 0 then self.parent.tile.y = 0 end
				self.dest = map:convertTileToPixel(self.parent.tile.x, self.parent.tile.y)
				-- overwrite the update function to make it move to the upper position until done and stop.
				self.update = function (otherSelf, deltaTime)
					otherSelf.parent.y = otherSelf.parent.y - (otherSelf.speed * deltaTime)
					if otherSelf.parent.y <= otherSelf.dest.y then
						local realpos = map:convertTileToPixel(otherSelf.parent.tile.x, otherSelf.parent.tile.y)
						otherSelf.parent.x = realpos.x
						otherSelf.parent.y = realpos.y
						otherSelf.update = function() end
						otherSelf.lock = false
					end
					
				end
			end,

			--- Moves object one tile down
			--- @param self table
			--- @param dt number deltaTime - required
			down = function (self, dt)
				self.facing = "down"
				if self.lock then return end
				if self.parent.tile.y >= map.height - 4 then return end
				self.lock = true
				self.parent.tile.y = self.parent.tile.y + 1
				self.dest = map:convertTileToPixel(self.parent.tile.x, self.parent.tile.y)
				-- overwrite the update function to make it move to the lower position until done and stop.
				self.update = function (otherSelf, deltaTime)
					otherSelf.parent.y = otherSelf.parent.y + (otherSelf.speed * deltaTime)
					if otherSelf.parent.y >= otherSelf.dest.y then
						local realpos = map:convertTileToPixel(otherSelf.parent.tile.x, otherSelf.parent.tile.y)
						otherSelf.parent.x = realpos.x
						otherSelf.parent.y = realpos.y
						otherSelf.update = function() end
						otherSelf.lock = false
					end
					
				end
				
			end,

			---Checks if a move is blocked by another object, and if not, executes the move.
			---@param self table object to be moved
			---@param direction string direction to move in
			blockable = function (self, direction)
				local blockers = {}

				local checkMovable = function(tileToCheck, action)
					blockers = map:objectsAt(tileToCheck.x, tileToCheck.y)
					if #blockers > 0 then
						local canMove = true
						for k,v in ipairs(blockers) do
							if v.visible then
								canMove = false
							end
						end
						if canMove then
							action()
						end
					else
						action()
					end
				end
				if direction == "left" then
					checkMovable({x = self.parent.tile.x - 1, y = self.parent.tile.y}, function() self:left() end)
				elseif direction == "right" then
					checkMovable({x = self.parent.tile.x + 1, y = self.parent.tile.y}, function() self:right() end)
				elseif direction == "up" then
					checkMovable({x = self.parent.tile.x, y = self.parent.tile.y - 1}, function() self:up() end)
				elseif direction == "down" then
					checkMovable({x = self.parent.tile.x, y = self.parent.tile.y + 1}, function() self:down() end)
				end
				self.parent.facing = direction
			end,

			---Executes a queue of moves. Note it does not check for blockers.
			---@param self table
			---@param dt number deltaTime - required
			executeQueue = function(self,dt)
				if type(self.queue) == "nil" then return end
				local nextMove = self.queue[1]
				if nextMove == "left" then
					self:left(dt)
					self.update = function(otherself, deltaTime)
						self.update = function (otherSelf, deltaTime)
							otherSelf.parent.x = otherSelf.parent.x - (otherSelf.speed * deltaTime)
							if otherSelf.parent.x <= otherSelf.dest.x then
								local realpos = map:convertTileToPixel(otherSelf.parent.tile.x, otherSelf.parent.tile.y)
								otherSelf.parent.x = realpos.x
								otherSelf.parent.y = realpos.y
								otherSelf.update = function() end
								otherSelf.lock = false
								table.remove(self.queue, 1)
								otherSelf.executeQueue(otherSelf, deltaTime)
							end
						end
					end
				elseif nextMove == "right" then
					self:right(dt)
					self.update = function(otherself, deltaTime)
						self.update = function (otherSelf, deltaTime)
							otherSelf.parent.x = otherSelf.parent.x + (otherSelf.speed * deltaTime)
							if otherSelf.parent.x >= otherSelf.dest.x then
								local realpos = map:convertTileToPixel(otherSelf.parent.tile.x, otherSelf.parent.tile.y)
								otherSelf.parent.x = realpos.x
								otherSelf.parent.y = realpos.y
								otherSelf.update = function() end
								otherSelf.lock = false
								table.remove(self.queue, 1)
								otherSelf.executeQueue(otherSelf, deltaTime)
							end
						end
					end
				elseif nextMove == "up" then
					self:up(dt)
					self.update = function(otherself, deltaTime)
						self.update = function (otherSelf, deltaTime)
							otherSelf.parent.y = otherSelf.parent.y - (otherSelf.speed * deltaTime)
							if otherSelf.parent.y <= otherSelf.dest.y then
								local realpos = map:convertTileToPixel(otherSelf.parent.tile.x, otherSelf.parent.tile.y)
								otherSelf.parent.x = realpos.x
								otherSelf.parent.y = realpos.y
								otherSelf.update = function() end
								otherSelf.lock = false
								table.remove(self.queue, 1)
								otherSelf.executeQueue(otherSelf, deltaTime)
							end
						end
					end
				elseif nextMove == "down" then
					self:down(dt)
					self.update = function(otherself, deltaTime)
						self.update = function (otherSelf, deltaTime)
							otherSelf.parent.y = otherSelf.parent.y + (otherSelf.speed * deltaTime)
							if otherSelf.parent.y >= otherSelf.dest.y then
								local realpos = map:convertTileToPixel(otherSelf.parent.tile.x, otherSelf.parent.tile.y)
								otherSelf.parent.x = realpos.x
								otherSelf.parent.y = realpos.y
								otherSelf.update = function() end
								otherSelf.lock = false
								table.remove(self.queue, 1)
								otherSelf.executeQueue(otherSelf, deltaTime)
							end
						end
					end
				end
			end
		}
		v.action = function(self)
			if self.facing == "right" then
				local subject = map:objectsAt(self.tile.x + 1, self.tile.y)
				for k,v in ipairs(subject) do
					if v.properties.message then
 						UI:add(UI.dialogBox.new(v.properties.message))
					end
					print(v.properties.message)
				end
			elseif self.facing == "left" then
				local subject = map:objectsAt(self.tile.x - 1, self.tile.y)
				for k,v in ipairs(subject) do
					if v.properties.message then
						UI:add(UI.dialogBox.new(v.properties.message))
				   end
			   end
			elseif self.facing == "up" then
				local subject = map:objectsAt(self.tile.x, self.tile.y - 1)
				for k,v in ipairs(subject) do
					if v.properties.message then
						UI:add(UI.dialogBox.new(v.properties.message))
				   end
			   end
			elseif self.facing == "down" then
				local subject = map:objectsAt(self.tile.x, self.tile.y + 1)
				for k,v in ipairs(subject) do
					if v.properties.message then
						UI:add(UI.dialogBox.new(v.properties.message))
				   end
			   end
			end
		end



	end

    layer.draw = function(self)
		for k,v in pairs(self.objects) do
			-- if performance is bad, consider checking if they are on screen before drawing.
			if v.visible then
				love.graphics.draw(v.sprite, v.x, v.y)
			end
			love.graphics.points(v.x, v.y)
		end
	end


	-- highlight layer for highlighting tiles
	local highlight = map:addCustomLayer("highlight", #map.layers + 1)
	highlight.graphic = love.graphics.newImage("res/sprite/whiteblock.png")
	highlight.highlighted = {{1,1}, {1,2}, {1,3}, {1,4}, {0,0}}
	highlight.opacity = 1
	highlight.opacitymax = 0.4
	highlight.opacitymin = 0.0
	highlight.speed = 2
	highlight.parent = map
	highlight.increment = function(self,dt)
		self.opacity = self.opacity + self.speed * dt
		if self.opacity >= self.opacitymax then
			self.opacity = self.opacitymax
			self.update = self.decrement
		end
	end
	highlight.decrement = function(self,dt)
		self.opacity = self.opacity - self.speed * dt
		if self.opacity <= self.opacitymin then
			self.opacity = self.opacitymin
			self.update = self.increment
		end
	end
	highlight.draw = function(self)
		-- love.graphics.setColor(255,255,255,self.opacity)
		love.graphics.setColor(self.opacity, self.opacity, self.opacity, self.opacity)
		for _,pair in ipairs(self.highlighted) do
			love.graphics.draw(self.graphic, pair[1] * self.parent.tilewidth, pair[2] * self.parent.tileheight)
		end
		love.graphics.setColor(255,255,255,255)
	end
	highlight.update = function(self,dt)
		self:decrement(dt)
	end



    -- set up the cursor with it's own layer
	local cursor = map:addCustomLayer("cursor", #map.layers + 1)
	

	cursor.tile = {
		-- note 1-indexed!
		x = 2,
		y = 1,
		offsetx = -2,
		offsety = -2,
	}
	cursor.position = {
		x = cursor.tile.x * map.tilewidth + cursor.tile.offsetx,
		y = cursor.tile.y * map.tileheight + cursor.tile.offsety
	}
	cursor.sprite = love.graphics.newImage("res/map/cursor.png")
	cursor.draw = function(self)
		love.graphics.draw(
			cursor.sprite,
			cursor.position.x,
			cursor.position.y
		)
	end
    
    cursor.movement = {
        destx = cursor.position.x,
        desty = cursor.position.y,
        speed = 250,
        direction = "",
        moving = false,
        timetowait = 1,
        timeelapsed = 0
    }

    cursor.update = function(self, dt)
        -- do nothing for now
        if cursor.movement.moving then
            cursor.movement.timeelapsed = cursor.movement.timeelapsed + dt
            if cursor.movement.timeelapsed >= cursor.movement.timetowait then
                cursor.movement.timeelapsed = 0
                cursor.movement.moving = false
            end
        end
    end
    -- Cursor movement routines. Make them better later; this is just functional.
    cursor.moveleft = function(self)
        if self.tile.x > 0 then
            self.tile.x = self.tile.x - 1
            self.position.x = self.tile.x * map.tilewidth + self.tile.offsetx
        end
    end
    cursor.moveright = function(self)
        if self.tile.x < map.width then
            self.tile.x = self.tile.x + 1
            self.position.x = self.tile.x * map.tilewidth + self.tile.offsetx
        end
    end
    cursor.moveup = function(self)
        if self.tile.y > 0 then
            self.tile.y = self.tile.y - 1
            self.position.y = self.tile.y * map.tileheight + self.tile.offsety
        end
    end
    cursor.movedown = function(self)
        if self.tile.y < map.height then
            self.tile.y = self.tile.y + 1
            self.position.y = self.tile.y * map.tileheight + self.tile.offsety
        end
    end

	-- rearranging the layers
	local cursorlayer, highlightlayer, objectlayer
	for k,v in ipairs(map.layers) do
		if v.name == "cursor" then
			cursorlayer = k
		elseif v.name == "highlight" then
			highlightlayer = k
		elseif v.name == "objects" then
			objectlayer = k
		end
	end
	table.remove(map.layers, cursorlayer)
	table.remove(map.layers, highlightlayer)
	table.remove(map.layers, objectlayer)
	table.insert(map.layers, highlight)
	table.insert(map.layers, layer)
	table.insert(map.layers, cursor)
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


	map.objects = objects

	---Returns a table of objects that are at the given tile position.
	---@param self table
	---@param x integer tile X position
	---@param y integer tile Y position
	---@return table
	map.objectsAt = function(self, x, y)
		local objects = {}
		for k, object in ipairs(self.objects) do
			if object.tile.x == x and object.tile.y == y then
				table.insert(objects, object)
			end
		end
		return objects
	end

-- map.reachableTiles = function(self, x, y, movementPoints, movementModel, positions)
-- 	-- provide defaults
-- 	positions = positions or {}
-- 	movementModel = movementModel or 1
-- 	local properties = self.layers.terrain:getTileProperties(x, y)

-- 	-- check if the tile is real before going forward
-- 	if properties.landEffect then
-- 		local toll = properties.landEffect /100 + 1 * movementModel
-- 		-- check if there are any objects here
-- 		local objects = self:objectsAt(x,y)
-- 		local isBlocked = false
-- 		-- do we have points to move here?
-- 		movementPoints = movementPoints - toll
-- 		if movementPoints > 0 then
-- 			--check if we are already in the list before we add it!
-- 			for _, position in ipairs(positions) do
-- 				if position[1] == x and position[2] == y then
-- 					-- just give up - you can't go any further!
-- 					return positions
-- 				end
-- 			end
-- 			table.insert(positions, {x, y})
-- 			self:reachableTiles(x+1, y, movementPoints, movementModel, positions)
-- 			self:reachableTiles(x-1, y, movementPoints, movementModel, positions)
-- 			self:reachableTiles(x, y+1, movementPoints, movementModel, positions)
-- 			self:reachableTiles(x, y-1, movementPoints, movementModel, positions)
-- 		end
-- 	end
-- 	return positions
-- end

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









    return map
end

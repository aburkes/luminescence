return function(map)
    -- get the objects from the object layer, replace the objects layer with a custom layer that has the objects and any extra setup we needed.
    local mapObjects = map.layers.objects.objects
    local objects = {}
    for k,v in ipairs(mapObjects) do
        table.insert(objects, v)
    end
    local objectsLayer = map:convertToCustomLayer("objects")
    objectsLayer.objects = objects
    
    -- initialize the objects to include the data we need
    for _, object in pairs(objects) do
        object.sprite = love.graphics.newImage(object.properties.image)
        object.y = object.y - map.tileheight -- because tiled uses bottom left, while love uses top left.
        -- give tile positions
        object.tile = {
            x = math.floor(object.x / map.tilewidth),
            y = math.floor((object.y - map.tileheight) / map.tileheight) + 1
        }
        -- we're just moving these around to make code a little less verbose later on.
        if object.type == "fighter" then
            object.stats = object.properties.stats
            object.team = object.properties.team
            -- give them maximums for hp and mp. For now they all get maximums.
            object.stats.hpmax = object.stats.hp
            object.stats.mpmax = object.stats.mp
        end
        object.move = {
            parent = object,
            queue = {},
            lock = false,
            dest = {},
            -- speed = 200,
            speed = 500,
            update = function(self, dt)
                -- will be overwritten by subsequent functions.
            end,

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
            ---@param queue table an optional table of directions to replace the object's queue to follow.
            ---@param dt number deltaTime - required
            executeQueue = function(self, dt, queue)
                if type(queue) == "table" then self.queue = queue end
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

        ---does the action according to the object's facing.
        object.action = function(self)
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

    objectsLayer.draw = function()
        for k,v in pairs(objects) do
			-- if performance is bad, consider checking if they are on screen before drawing.
			if v.visible then
				love.graphics.draw(v.sprite, v.x, v.y)
			end
			love.graphics.points(v.x, v.y)
		end
	end

end

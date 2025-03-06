return {
    populateObjects = function(self, map)
    -- get the objects from the object layer, replace the objects layer with a custom layer that has the objects and any extra setup we needed.
    local mapObjects = map.layers.objects.objects
    local objects = {}
    local positions = {}
    for k,v in ipairs(mapObjects) do
        if v.type == "spawnpoint" then
            --filter out any positions that are beyond the current active party size
            if v.properties.member <= #Party.active then
                table.insert(positions, v)
            end
        else
            table.insert(objects, v)
        end
    end
    local objectsLayer = map:convertToCustomLayer("objects")
    objectsLayer.objects = objects
    
    -- replace placeholders with characters from party
    for _, position in ipairs(positions) do
        local char = Party.active[position.properties.member]
        --give them full hp and mp
        char.stats.hp, char.stats.mp = char.stats.hpmax, char.stats.mpmax
        for k,v in pairs(char) do
            if not (k == "tile" or k == "x" or k == "y") then
                position[k] = v
            end
        end
    end
    -- add party to map
    for _,v in ipairs(positions) do table.insert(objects, v) end


    -- initialize the objects to include the data we need
    for _, object in pairs(objects) do
            self:objectInit(object, map)
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

end,
objectInit = function(self, object, map, image)

    -- object.sprite = love.graphics.newImage(assert(object.properties.image, "object named " .. object.name .." has no defined image!"))
    local image = assert(object.properties.image, "image not defined for object " .. object.name .. "!")
    object.sprite = love.graphics.newImage(image)
    object.y = object.y - map.tileheight -- because tiled uses bottom left, while love uses top left.
    -- give tile positions
    object.tile = {
        x = math.floor(object.x / map.tilewidth),
        y = math.floor((object.y - map.tileheight) / map.tileheight) + 1
    }
    -- snap to tile position
    object.y = object.tile.y * map.tileheight
    object.x = object.tile.x * map.tilewidth
    -- we're just moving these around to make code a little less verbose later on.
    if object.type == "fighter" then
        object.stats = object.properties.stats
        object.team = object.properties.team
        -- give them maximums for hp and mp. For now they all get maximums.
        object.stats.hpmax = object.stats.hp
        object.stats.mpmax = object.stats.mp
        object.class = object.properties.class
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
            -- local blockers = {}

            local checkMovable = function(tileToCheck, action)
                local blockers = map:objectsAt(tileToCheck.x, tileToCheck.y)
                local tile = map.layers.terrain:getTileProperties(tileToCheck.x, tileToCheck.y)
                if tile.land then
                    if not tile.land.walkable then
                        return
                    end
                end
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

        battleMove = function(self, direction)
            local x, y = self.parent.tile.x, self.parent.tile.y
            local function moveable(x,y)
                for _,v in ipairs(map.layers.highlight.highlighted) do
                    if v[1] == x and v[2] == y then
                        return true
                    end
                end
                return false
            end
            if direction == "left" and moveable(x-1, y) then
                self:left()
            elseif direction == "right" and moveable(x+1, y) then
                self:right()
            elseif direction == "up" and moveable(x, y-1) then
                self:up()
            elseif direction == "down" and moveable(x, y+1) then
                self:down()
            end
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

    ---does the action according to the object's facing. Very broken right now!
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

    ---Checks the map location and returns the cost to move to that location.
    ---@param self any
    ---@param location table The location to move to.
    object.moveCost = function(self, location)
        -- for a test we will just always return one. I guess we're flying.
        return 1
    end

    object.canMove = function(self, x, y)

        if x < 1 or y < 1 or x > map.width or y > map.height then return false end

        -- local objects = map:objectsAt(x, y)
        for _, thing in ipairs(map:objectsAt(x, y)) do
            if thing.properties.team and thing.visible then
                if not self.properties.team == thing.properties.team then return false end
            end
        end

        return true

    end

    ---Creates a table of valid moves for the combattant.
    ---@param self any
    ---@return table
    object.getMovements = function(self)
        -- local terrain = map.layers.terrain
        -- local position = {self.tile.x, self.tile.y}
        local speed = self.properties.stats.agility
        
        -- local stamina = speed --determines how much we can move.
        local searchQueue = {}
        table.insert(searchQueue, {x = self.tile.x, y = self.tile.y, stamina = speed})
        local reachable = {}
        local visited = {}
        visited[self.tile.x .. "," .. self.tile.y] = true

        local directions = {
            {x = 0, y = -1},
            {x = 1, y = 0},
            {x = 0, y = 1},
            {x = -1, y = 0}
        }
        while #searchQueue > 0 do
            local current = table.remove(searchQueue, 1)
            table.insert (reachable, {x = current.x, y = current.y})

            if current.stamina > 0 then
                for _, dir in ipairs(directions) do
                    local newX, newY = current.x + dir.x, current.y + dir.y
                    local key = newX .. "," .. newY


                    -- checks go here
                    if not visited[key] and self:canMove(newX, newY) then
                        visited[key] = true
                        table.insert(searchQueue, {x = newX, y = newY, stamina = current.stamina - self:moveCost(newX, newY)})
                    end
                end
            end
        end
        local highlightList = {}
        for _, v in ipairs(reachable) do
            table.insert(highlightList, {v.x, v.y})
        end

        return highlightList
    end

    object.userControl = function(self, type)
        if type == "battle" then
            Input.cursorControl:disable()
            -- Input:setKeyHandler(function(key)
            --     if key == Config.keys.down then
            --         self.move:battleMove("down")
            --     elseif  key == Config.keys.up then
            --         self.move:battleMove("up")
            --     elseif key == Config.keys.left then
            --         self.move:battleMove("left")
            --     elseif key == Config.keys.right then
            --         self.move:battleMove("right")
            --     end
            -- end)
            Input.realtimeControl:set(function(dt)
                if love.keyboard.isDown(Config.keys.down) then
                    self.move:battleMove("down")
                elseif love.keyboard.isDown(Config.keys.up) then
                    self.move:battleMove("up")
                elseif love.keyboard.isDown(Config.keys.left) then
                    self.move:battleMove("left")
                elseif love.keyboard.isDown(Config.keys.right) then
                    self.move:battleMove("right")
                end
                if Input.joystick then
                    local gd = function(button)
                        return Input.joystick:isGamepadDown(button)
                    end
                    if gd(Config.gamepad.up) then
                        self.move:battleMove("up")
                    elseif gd(Config.gamepad.down) then
                        self.move:battleMove("down")
                    elseif gd(Config.gamepad.left) then
                        self.move:battleMove("left")
                    elseif gd(Config.gamepad.right) then
                        self.move:battleMove("right")
                    end
                end
            end)

        end
        -- otherwise....

    end
        

    return object

end,
-- positionInit = function(self,object, map)

-- end

}

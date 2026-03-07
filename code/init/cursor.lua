return function(map)
    -- set up the cursor with it's own layer
    local cursor = map:addCustomLayer("cursor", #map.layers + 1)
        
    cursor.speed = 400

    cursor.tile = {
        -- note 1-indexed!
        x = 2,
        y = 2,
        offsetX = -2,
        offsetY = -2,
    }
    cursor.position = {
        x = cursor.tile.x * map.tilewidth + cursor.tile.offsetX,
        y = cursor.tile.y * map.tileheight + cursor.tile.offsetY
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
        destX = cursor.position.x,
        destY = cursor.position.y,
        speed = 250,
        direction = "",
        moving = false,
        timeToWait = 1,
        timeElapsed = 0
    }

    cursor.update = function(self, dt)
        -- -- do nothing for now
        -- if cursor.movement.moving then
        --     cursor.movement.timeElapsed = cursor.movement.timeElapsed + dt
        --     if cursor.movement.timeElapsed >= cursor.movement.timeToWait then
        --         cursor.movement.timeElapsed = 0
        --         cursor.movement.moving = false
        --     end
        -- end
    end
    -- Cursor movement routines. Make them better later; this is just functional.
    cursor.moveLeft = function(self)
        if not self.movement.moving then
            if self.tile.x > 0 then
                self.movement.moving = true
                self.tile.x = self.tile.x - 1
                self.movement.destX = self.tile.x * map.tilewidth + self.tile.offsetX
                -- self.position.x = self.tile.x * map.tilewidth + self.tile.offsetx
                self.update = function(self,dt)
                    if self.position.x > self.movement.destX then
                        self.position.x = self.position.x - (self.speed * dt)
                    else
                        self.position.x = self.movement.destX
                        self.update = function() end
                        self.movement.moving = false
                    end
                end
            end
        end
    end
    cursor.moveRight = function(self)
        if not self.movement.moving then
            if self.tile.x < map.width then
                self.movement.moving = true
                self.tile.x = self.tile.x + 1
                self.movement.destX = self.tile.x * map.tilewidth + self.tile.offsetX
                self.update = function(self,dt)
                    if self.position.x < self.movement.destX then
                        self.position.x = self.position.x + (self.speed * dt)
                    else
                        self.position.x = self.movement.destX
                        self.update = function() end
                        self.movement.moving = false
                    end
                end
            end
        end
        -- if self.tile.x < map.width then
        --     self.tile.x = self.tile.x + 1
        --     self.position.x = self.tile.x * map.tilewidth + self.tile.offsetx
        -- end
    end
    cursor.moveUp = function(self)
        if not self.movement.moving then
            if self.tile.y > 0 then
                self.movement.moving = true
                self.tile.y = self.tile.y - 1
                self.movement.destY = self.tile.y * map.tileheight + self.tile.offsetY
                self.update = function(self, dt)
                    if self.position.y > self.movement.destY then
                        self.position.y = self.position.y - (self.speed * dt)
                    else
                        self.position.y = self.movement.destY
                        self.update = function() end
                        self.movement.moving = false
                    end
                end
            end
        end
    end
    cursor.moveDown = function(self)
        if not self.movement.moving then
            if self.tile.y < map.height then
                self.movement.moving = true
                self.tile.y = self.tile.y + 1
                self.movement.destY = self.tile.y * map.tileheight + self.tile.offsetY
                self.update = function(self, dt)
                    if self.position.y < self.movement.destY then
                        self.position.y = self.position.y + (self.speed * dt)
                    else
                        self.position.y = self.movement.destY
                        self.update = function() end
                        self.movement.moving = false
                    end
                end
            end
        end
    end

    cursor.snapTo = function(self, x, y)
        self.tile.x = x
        self.tile.y = y
        self.position.x = x * map.tilewidth
        self.position.y = y * map.tileheight
    end

    --- It's probably better to use Input.cursorControl:moveTo()?
    cursor.moveTo = function(self, x, y)
        self.tile.x = x
        self.tile.y = y
        self.movement.destX = x * map.tilewidth
        self.movement.destY = y * map.tileheight
        self.update = function(self, dt)
            Input.cursorControl:disable()
            if self.position.x < self.movement.destX then
                self.position.x = self.position.x + (self.speed * dt)
                if self.position.x > self.movement.destX then self.position.x = self.movement.destX end
            elseif self.position.x > self.movement.destX then
                self.position.x = self.position.x - (self.speed * dt)
                if self.position.x < self.movement.destX then self.position.x = self.movement.destX end
            elseif self.position.y > self.movement.destY then
                self.position.y = self.position.y - (self.speed * dt)
                if self.position.y < self.movement.destY then self.position.y = self.movement.destY end
            elseif self.position.y < self.movement.destY then
                self.position.y = self.position.y + (self.speed * dt)
                if self.position.y > self.movement.destY then self.position.y = self.movement.destY end
            elseif self.position.x == self.movement.destX and self.position.y == self.movement.destY then
                self.update = function() end
                Input.cursorControl:enable()
            end
        end
    end

    cursor.activate = function(self)
        Input.cursorControl:enable()
    end

    ---gets the object at the cursor's current position and displays it's stats
    ---@param self unknown
    cursor.showUnitInfo = function(self)
        local objects = map:objectsAt(self.tile.x, self.tile.y)
        if( objects[1] ~= nil) then
            UI:add(UI.battleStats.new(objects[1]))
        end
    end


    return cursor
end
return function(map)
    -- set up the cursor with it's own layer
    local cursor = map:addCustomLayer("cursor", #map.layers + 1)
        
    cursor.speed = 400

    cursor.tile = {
        -- note 1-indexed!
        x = 2,
        y = 2,
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
        -- -- do nothing for now
        -- if cursor.movement.moving then
        --     cursor.movement.timeelapsed = cursor.movement.timeelapsed + dt
        --     if cursor.movement.timeelapsed >= cursor.movement.timetowait then
        --         cursor.movement.timeelapsed = 0
        --         cursor.movement.moving = false
        --     end
        -- end
    end
    -- Cursor movement routines. Make them better later; this is just functional.
    cursor.moveleft = function(self)
        if not self.movement.moving then
            if self.tile.x > 0 then
                self.movement.moving = true
                self.tile.x = self.tile.x - 1
                self.movement.destx = self.tile.x * map.tilewidth + self.tile.offsetx
                -- self.position.x = self.tile.x * map.tilewidth + self.tile.offsetx
                self.update = function(self,dt)
                    if self.position.x > self.movement.destx then
                        self.position.x = self.position.x - (self.speed * dt)
                    else
                        self.position.x = self.movement.destx
                        self.update = function() end
                        self.movement.moving = false
                    end
                end
            end
        end
    end
    cursor.moveright = function(self)
        if not self.movement.moving then
            if self.tile.x < map.width then
                self.movement.moving = true
                self.tile.x = self.tile.x + 1
                self.movement.destx = self.tile.x * map.tilewidth + self.tile.offsetx
                self.update = function(self,dt)
                    if self.position.x < self.movement.destx then
                        self.position.x = self.position.x + (self.speed * dt)
                    else
                        self.position.x = self.movement.destx
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
    cursor.moveup = function(self)
        if not self.movement.moving then
            if self.tile.y > 0 then
                self.movement.moving = true
                self.tile.y = self.tile.y - 1
                self.movement.desty = self.tile.y * map.tileheight + self.tile.offsety
                self.update = function(self, dt)
                    if self.position.y > self.movement.desty then
                        self.position.y = self.position.y - (self.speed * dt)
                    else
                        self.position.y = self.movement.desty
                        self.update = function() end
                        self.movement.moving = false
                    end
                end
            end
        end
        -- if self.tile.y > 0 then
        --     self.tile.y = self.tile.y - 1
        --     self.position.y = self.tile.y * map.tileheight + self.tile.offsety
        -- end
    end
    cursor.movedown = function(self)
        if not self.movement.moving then
            if self.tile.x < map.width then
                self.movement.moving = true
                self.tile.y = self.tile.y + 1
                self.movement.desty = self.tile.y * map.tileheight + self.tile.offsety
                self.update = function(self, dt)
                    if self.position.y < self.movement.desty then
                        self.position.y = self.position.y + (self.speed * dt)
                    else
                        self.position.y = self.movement.desty
                        self.update = function() end
                        self.movement.moving = false
                    end
                end
            end
        end
        -- if self.tile.y < map.height then
        --     self.tile.y = self.tile.y + 1
        --     self.position.y = self.tile.y * map.tileheight + self.tile.offsety
        -- end
    end

    cursor.snapTo = function(self, x, y)
        self.tile.x = x
        self.tile.y = y
        self.position.x = x * map.tilewidth
        self.position.y = x * map.tileheight
    end

    --- It's probably better to use Input.cursorControl:moveTo()?
    cursor.moveTo = function(self, x, y)
        self.tile.x = x
        self.tile.y = y
        self.movement.destx = x * map.tilewidth
        self.movement.desty = y * map.tileheight
        self.update = function(self, dt)
            Input.cursorControl:disable()
            if self.position.x < self.movement.destx then
                self.position.x = self.position.x + (self.speed * dt)
                if self.position.x > self.movement.destx then self.position.x = self.movement.destx end
            elseif self.position.x > self.movement.destx then
                self.position.x = self.position.x - (self.speed * dt)
                if self.position.x < self.movement.destx then self.position.x = self.movement.destx end
            elseif self.position.y > self.movement.desty then
                self.position.y = self.position.y - (self.speed * dt)
                if self.position.y < self.movement.desty then self.position.y = self.movement.desty end
            elseif self.position.y < self.movement.desty then
                self.position.y = self.position.y + (self.speed * dt)
                if self.position.y > self.movement.desty then self.position.y = self.movement.desty end
            elseif self.position.x == self.movement.destx and self.position.y == self.movement.desty then
                self.update = function() end
                Input.cursorControl:enable()
            end
        end
    end

    return cursor
end
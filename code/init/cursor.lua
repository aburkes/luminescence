return function(map)
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
    return cursor
end
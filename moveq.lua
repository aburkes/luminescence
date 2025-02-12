if type(Object) == "nil" then Object = require "code/libs/classic/classic" end

moveq = {
    moves = {},
    locks = {
        generic = false
    },
    settings = {
        speed = 10
    },
    ---Creates a new move object.
    ---@param object table object to manipulate
    ---@param destx any destination x, in pixels
    ---@param desty any destination y, in pixels
    ---@param update function will be called each love.update() call.
    ---@param completion function must test if the move is complete, returning a boolean
    ---@param thendo function will be called when the move is complete.
    newmove = function (object, destx, desty, update, completion, thendo)
        move = {
            object = object,
            destx = destx,
            desty = desty,
            speed = moveq.settings.speed,
            update = update,
            completion = completion,
            thendo = thendo
        }
        table.insert(moveq.moves, move)
        
    end,

    moveRight = function(object, thendo)
        -- moves an object right by one tile.
        -- pixels = moveq.map:tilesToPixels(object.tile.x, object.tile.y)
        if moveq.locks.generic then
            return
        end
        pixels = map:convertTileToPixel(object.tile.x, object.tile.y)
        moveq.newmove(object, pixels.x + map.tilewidth, pixels.y,
            function(self, dt) -- update function
                object.x = object.x + self.speed * dt
            end,
            function(self) -- completion function
                print("test")
                if object.x >= self.x then
                    return true
                else
                    return false
                end
            end,
            thendo
            )
            moveq.locks.generic = true
    end,
    update = function(dt)
        for i, move in ipairs(moveq.moves) do
            move.update(move, dt)
            if move.completion(move) then
                move.thendo(move)
                table.remove(moveq.moves, i)
            end
        end
    end




}
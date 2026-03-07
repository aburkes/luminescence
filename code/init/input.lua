---@class Handlers
---@field key fun(key: string)?         Called on keypressed events
---@field gamepad fun(joystick: love.Joystick, button: string)? Called on gamepadpressed events
---@field realtime fun(dt: number)?     Called every update frame

---@class Input
---@field stack Handlers[]              Stack of active handler sets
---@field joysticks love.Joystick[]     Connected joysticks
---@field joystick love.Joystick?       The primary active joystick
---@field handlers table<string, Handlers> Named handler presets
Input = {
    stack = {},
    joysticks = love.joystick.getJoysticks(),

    ---Push a handler set onto the input stack, making it the active handler.
    ---@param self Input
    ---@param handlers Handlers
    push = function(self, handlers)
        table.insert(self.stack, handlers)
    end,

    ---Pop the top handler set off the stack, restoring the previous one.
    ---@param self Input
    pop = function(self)
        table.remove(self.stack)
    end,

    ---Return the currently active handler set.
    ---@param self Input
    ---@return Handlers?
    top = function(self)
        return self.stack[#self.stack]
    end,

    ---Forward a key press to the active handler's key function.
    ---@param self Input
    ---@param key string The key identifier (e.g. "return", "space")
    keypressed = function(self, key)
        local t = self:top()
        if t and t.key then t.key(key) end
    end,

    ---Forward a gamepad button press to the active handler's gamepad function.
    ---@param self Input
    ---@param joystick love.Joystick The joystick that fired the event
    ---@param button string The button identifier
    gamepadpressed = function(self, joystick, button)
        local t = self:top()
        if t and t.gamepad then t.gamepad(joystick, button) end
    end,

    ---Call the active handler's realtime function once per frame.
    ---@param self Input
    ---@param dt number Seconds elapsed since the last frame
    update = function(self, dt)
        local t = self:top()
        if t and t.realtime then t.realtime(dt) end
    end,
}

Input.handlers = {
    default = {
        key = function(key)
            if key == Config.keys.confirm then map.objects[Index]:action()
            elseif key == "1" then Index = 1
            elseif key == "2" then Index = 2
            elseif key == "3" then Index = 3
            elseif key == "4" then Index = 4
            elseif key == "5" then Index = 5
            elseif key == "s" then Init.save.saveData(Party)
            elseif key == Config.keys.menu then
                UI:add(UI.quadMenu.new("res/sprite/actions.png", 72, 48, nil, nil, nil, nil))
            end
        end,
        gamepad = function(_joystick, button)
            if button == Config.gamepad.confirm then map.objects[Index]:action()
            elseif button == Config.gamepad.menu then
                UI:add(UI.quadMenu.new("res/sprite/actions.png", 72, 48, nil, nil, nil, nil))
            end
        end,
        realtime = function(_dt)
            local object = map.objects[Index]
            if love.keyboard.isDown(Config.keys.left) then object.move:blockable("left")
            elseif love.keyboard.isDown(Config.keys.right) then object.move:blockable("right")
            elseif love.keyboard.isDown(Config.keys.up) then object.move:blockable("up")
            elseif love.keyboard.isDown(Config.keys.down) then object.move:blockable("down")
            end
            if Input.joystick then
                local gd = function(b) return Input.joystick:isGamepadDown(b) end
                if gd(Config.gamepad.up) then object.move:blockable("up")
                elseif gd(Config.gamepad.down) then object.move:blockable("down")
                elseif gd(Config.gamepad.left) then object.move:blockable("left")
                elseif gd(Config.gamepad.right) then object.move:blockable("right")
                end
            end
        end
    },
    cursor = {
        key = function(key)
            if key == Config.keys.confirm then Cursor:showUnitInfo()
            elseif key == Config.keys.menu then
                UI:add(UI.quadMenu.new("res/sprite/actions.png", 72, 48, nil, nil, nil, nil))
            end
        end,
        gamepad = function(joystick, button) end,
        realtime = function(dt)
            if love.keyboard.isDown(Config.keys.left) then Cursor:moveLeft()
            elseif love.keyboard.isDown(Config.keys.right) then Cursor:moveRight()
            elseif love.keyboard.isDown(Config.keys.up) then Cursor:moveUp()
            elseif love.keyboard.isDown(Config.keys.down) then Cursor:moveDown()
            end
            if Input.joystick then
                local gd = function(b) return Input.joystick:isGamepadDown(b) end
                if gd(Config.gamepad.up) then Cursor:moveUp()
                elseif gd(Config.gamepad.down) then Cursor:moveDown()
                elseif gd(Config.gamepad.left) then Cursor:moveLeft()
                elseif gd(Config.gamepad.right) then Cursor:moveRight()
                end
            end
        end
    }
}

love.keypressed = function(key, scan, isRepeat)
    Input:keypressed(key)
end

love.gamepadpressed = function(joystick, button)
    Input:gamepadpressed(joystick, button)
end

if #Input.joysticks > 0 then
    Input.joystick = Input.joysticks[1]
end

love.joystickadded = function(joystick)
    Input.joystick = joystick
end

love.joystickremoved = function()
    Input.joysticks = love.joystick.getJoysticks()
    Input.joystick = Input.joysticks[1] or nil
end

Input = {

    keyHandler = function(key, scan, isRepeat) end,
    gamepadHandler = function(joystick, button) end,
    joysticks = love.joystick.getJoysticks(),

    --default keyboard handler function
    defaultKeys = function(key, scan, isRepeat)
        if key == Config.keys.confirm then map.objects[Index]:action()
		elseif key == "1" then Index = 1
		elseif key == "2" then Index = 2
		elseif key == "3" then Index = 3
		elseif key == "4" then Index = 4
        elseif key == "5" then Index = 5
        elseif key == "s" then Init.save.saveData(Party)
		elseif key == Config.keys.menu then UI:add(UI.quadMenu.new("res/sprite/actions.png", 72, 48, nil, nil, nil, nil))
		end
    end,
    
    ---Replaces the keyboard event handler with an arbitrary replacement
    ---Replacement arguement should have at least one arguement (for `key`) or it won't do anything.
    ---@param self any
    ---@param newHandler function your replacement keyboard handler function. Make sure it includes at least one arguement.
    setKeyHandler = function(self, newHandler)
        self.keyHandler = newHandler
    end,

    ---resets the keyboard controls to default.
    ---@return nil
    setDefaultKeys = function(self)
        self.keyHandler = self.defaultKeys
    end,

    --default gamepad handler function
    defaultGamepad = function(joystick, button)
        if button == Config.gamepad.confirm then
            map.objects[Index]:action()
        elseif button == Config.gamepad.menu then
            UI:add(UI.quadMenu.new("res/sprite/actions.png", 72, 48, "arbitrary", nil, nil, nil, nil))

        end
    end,
    ---Replaces the gamepad event handler with an arbitrary replacement.
    ---Repalcement arguements should have two arguements - `joystick` and `button`.
    ---@param newHandler function replacement handler function
    setGamepadHandler = function(self, newHandler)
        self.gamepadHandler = newHandler
    end,
    ---resets both keyboard and gamepad controls to defaults.
    ---@return nil
    release = function(self)
        self.keyHandler = self.defaultKeys
        self.gamepadHandler = self.defaultGamepad
    end,

    directControl = {
		enabled = false,
		enable = function(self)
			self.enabled = true
			Input:release()
		end,
		disable = function(self)
			self.enabled = false
		end,
        update = function(self)
            if self.enabled then
                local object = map.objects[Index]
                if love.keyboard.isDown(Config.keys.left) then
                    object.move:blockable("left")
                elseif love.keyboard.isDown(Config.keys.right) then
                    object.move:blockable("right")
                elseif love.keyboard.isDown(Config.keys.up) then
                    object.move:blockable("up")
                elseif love.keyboard.isDown(Config.keys.down) then
                    object.move:blockable("down")
                end
                if Input.joystick then
                    local gd = function(button)
                        return Input.joystick:isGamepadDown(button)
                    end
                    if gd(Config.gamepad.up) then
                        object.move:blockable("up")
                    elseif gd(Config.gamepad.down) then
                        object.move:blockable("down")
                    elseif gd(Config.gamepad.left) then
                        object.move:blockable("left")
                    elseif gd(Config.gamepad.right) then
                        object.move:blockable("right")
                    end
                end
            end
        end
	},
    cursorControl = {
        enabled = false,
        enable = function(self)
            self.enabled = true
            Input.directControl:disable()
        end,
        disable = function(self)
            self.enabled = false
        end,
        update = function(self)
            if self.enabled then
                if love.keyboard.isDown(Config.keys.left) then
                    Cursor:moveleft()
                elseif love.keyboard.isDown(Config.keys.right) then
                    Cursor:moveright()
                elseif love.keyboard.isDown(Config.keys.up) then
                    Cursor:moveup()
                elseif love.keyboard.isDown(Config.keys.down) then
                    Cursor:movedown()
                end
                if Input.joystick then
                    local gd = function(button)
                        return Input.joystick:isGamepadDown(button)
                    end
                    if gd(Config.gamepad.up) then
                        Cursor:moveup()
                    elseif gd(Config.gamepad.down) then
                        Cursor:movedown()
                    elseif gd(Config.gamepad.left) then
                        Cursor:moveleft()
                    elseif gd(Config.gamepad.right) then
                        Cursor:moveright()
                    end
                end
            end
        end,
        moveTo = function(self, x, y)
            Cursor:moveTo(x, y)
            -- I realized it made more sense to just make the cursor do it's thing than it did to reimpliment it, but here was the old code just in case.
        --     Cursor.tile.x = x
        --     Cursor.tile.y = y
        --     Cursor.movement.destx = x * map.tilewidth
        --     Cursor.movement.desty = y * map.tileheight
        --     Cursor.update = function(slef, dt)
        --         Input.cursorControl:disable()
        --         if Cursor.position.x < Cursor.movement.destx then
        --             Cursor.position.x = Cursor.position.x + (Cursor.speed * dt)
        --             if Cursor.position.x > Cursor.movement.destx then Cursor.position.x = Cursor.movement.destx end
        --         elseif Cursor.position.x > Cursor.movement.destx then
        --             Cursor.position.x = Cursor.position.x - (Cursor.speed * dt)
        --             if Cursor.position.x < Cursor.movement.destx then Cursor.position.x = Cursor.movement.destx end
        --         elseif Cursor.position.y > Cursor.movement.desty then
        --             Cursor.position.y = Cursor.position.y - (Cursor.speed * dt)
        --             if Cursor.position.y < Cursor.movement.desty then Cursor.position.y = Cursor.movement.desty end
        --         elseif Cursor.position.y < Cursor.movement.desty then
        --             Cursor.position.y = Cursor.position.y + (Cursor.speed * dt)
        --             if Cursor.position.y > Cursor.movement.desty then Cursor.position.y = Cursor.movement.desty end
        --         elseif Cursor.position.x == Cursor.movement.destx and Cursor.position.y == Cursor.movement.desty then
        --             slef.update = function() end
        --             Input.cursorControl:enable()
        --         end
        --     end
        end
    }
}


love.keypressed = function(key, scan, isRepeat)
    Input.keyHandler(key, scan, isRepeat)
end

love.gamepadpressed = function(joystick, button)
    Input.gamepadHandler(joystick, button)
end

if #Input.joysticks > 0 then 
    Input.joystick = Input.joysticks[1]
end

love.joystickadded = function(joystick)
    Input.joystick = joystick
end

love.joystickremoved = function()
    Input.joysticks = love.joystick.getJoysticks()
    if Input.joysticks then
        Input.joystick = Input.joysticks[1]
    else
        Input.joystick = nil
    end
end
return {
    new = function(image,itemwidth,itemheight, action1, action2, action3, action4, cancel)
        local screenOffset = 20 -- pixels from bottom of screen
        local screenWidth = love.graphics.getWidth()
        local screenHeight = love.graphics.getHeight()
        -- an alternative way to get the height offset...
        screenOffset = math.floor(screenHeight * 0.05)

    
        -- center point of menu
        local centerpoint = {
            x = screenWidth / 2,
            y = screenHeight - screenOffset - itemheight * 2
        }
        -- halfpoint for menu items
        local iconOffset = {
            x = itemwidth / 2,
            y = itemheight / 2
        }
        local menu = {
            {
                x = centerpoint.x - iconOffset.x,
                y = centerpoint.y - iconOffset.y,
                action = action1 or function() print("Action 1 activated!")  end
            },
            {
                x = centerpoint.x + itemwidth - iconOffset.x,
                y = centerpoint.y,
                action = action2 or function() print ("Action 2 activated!") end
            },
            {
                x = centerpoint.x - iconOffset.x,
                y = centerpoint.y + iconOffset.y,
                action = action3 or function() print("Action 3 Activated!") end
            },
            {
                x = centerpoint.x -itemwidth - iconOffset.x,
                y = centerpoint.y,
                action = action4 or function() print("Action 4 activated!") end
            },
            selected = 1,
            currentTime = 0,
            animationTime = 0.5,
            type = "quadMenu",
            oldInputHandler = love.keypressed
        }
        if type(action1) == "function" then menu[1].action = action1
        else menu[1].action = function() print("There were no actions specified for Action 1") end
        end
        if type(action2) == "function" then menu[2].action = action2
        else menu[2].action = function() print("There were no actions specified for Action 2") end
        end
        if type(action3) == "function" then menu[3].action = action3
        else menu[3].action = function() print("There were no actions specified for Action 3") end
        end
        if type(action4) == "function" then menu[4].action = action4
        else menu[4].action = function() print("There were no actions specified for Action 4") end
        end
        Input.lock = menu.lock

        local quads = Anim.loadMultistrip(image, itemwidth, itemheight)

        for key, frames in ipairs(menu) do
            -- menu[key].sprite = image
            menu[key].anim = quads[key]
            menu[key].currentFrame = 1

        end

        -- ---@diagnostic disable-next-line: duplicate-set-field
        -- love.keypressed = function(key)
        --     if key == Config.keys.up then menu:selectMenuItem(1)
        --     elseif key == Config.keys.right then menu:selectMenuItem(2)
        --     elseif key == Config.keys.down then menu:selectMenuItem(3)
        --     elseif key == Config.keys.left then menu:selectMenuItem(4)
        --     elseif key == Config.keys.cancel then menu:destroy()
        --     elseif key == Config.keys.confirm then
        --         menu[menu.selected].action()
        --         menu:destroy()
        --     elseif key == Config.keys.cancel then cancel()
        --     end
        -- end
        Input:setKeyHandler(
            function(key)
                if key == Config.keys.up then menu:selectMenuItem(1)
                elseif key == Config.keys.right then menu:selectMenuItem(2)
                elseif key == Config.keys.down then menu:selectMenuItem(3)
                elseif key == Config.keys.left then menu:selectMenuItem(4)
                elseif key == Config.keys.cancel then menu:destroy()
                elseif key == Config.keys.confirm then
                    menu[menu.selected].action()
                    menu:destroy()
                elseif key == Config.keys.cancel then cancel()
                end
            end
        )
        Input:setGamepadHandler(
            function(joystick, button)
                if button == Config.gamepad.up then menu:selectMenuItem(1)
                elseif button == Config.gamepad.right then menu:selectMenuItem(2)
                elseif button == Config.gamepad.down then menu:selectMenuItem(3)
                elseif button == Config.gamepad.left then menu:selectMenuItem(4)
                elseif button == Config.gamepad.cancel then menu:destroy()
                elseif button == Config.gamepad.confirm then
                    menu[menu.selected].action()
                    menu:destroy()
                end
            end
        )

        menu.draw = function(self, dt)
            for k, v in ipairs(self) do
                love.graphics.draw(v.anim.image, v.anim.frames[v.currentFrame], v.x, v.y)
            end
        end

        menu.update = function(self, dt)
            self.currentTime = self.currentTime + dt
            if self.currentTime > self.animationTime then
                self.currentTime = 0
                self[self.selected].currentFrame = self[self.selected].currentFrame + 1
                if self[self.selected].currentFrame > #self[self.selected].anim.frames then
                    self[self.selected].currentFrame = 1
                end
            end

        end
        menu.selectMenuItem = function(self, item)
            for k,v in ipairs(self) do
                v.currentFrame = 1
            end
            self[item].currentFrame = 2
            self.selected = item
            self.currentTime = 0
        end
        -- menu.destroy = function(self)
        --     for k in pairs(self) do
        --         self[k] = nil
        --     end
        --     self.update = function() end
        --     self.draw = function() end
        --     Input.lock = ""
        -- end
        menu.destroy = function(self)
            -- love.keypressed = self.oldInputHandler
            Input:release()
            UI:remove(self)
        end

        -- don't use this; if it's still in the UI carrier then it will prevent the UI updater from allowing free control.
        menu.disable = function(self)
            -- love.keypressed = self.oldInputHandler
            Input:release()
            if Config.menu.resets == true then
                self:selectMenuItem(1)
            end
        end

        menu.enable = function(self)
            if Config.menu.resets == true then
                self:selectMenuItem(1)
            end
        end



        return menu
    end
}
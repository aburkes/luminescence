---@class dialogBox
---@field new function
return {
    ---Creates a new dialogBox.
    ---@param text string text to be displayed
    ---@param thenDo function function to be called after completing the dialogBox.
    ---@return dialogBox
    new = function(text, thenDo)
        Input.directControl:disable()
        local object = {
            type = "dialogBox",
            status = "writing",
            screenHeight = love.graphics.getHeight(),
            font = UI.fonts.dialog,
            lineheight = 0,
            spacing = 20, -- distance from bottom/top of screen.
            window = {
                border = 10,
                inner = {},
                outer = {}
            },
            offset = 0,
            continueMarker = {
                currentTime = 0,
                duration = 0.25,
                display = true,
                active = true,
            },
            script = {
                character = 1,
                text = text,
                lines = {},
                currentTime = 0,
                nextTime = 0.02

            },



        }

        if type(object.script.text) == "table" then
            object.script.lines = object.script.text
            object.script.text = object.script.text[1]
        end
        if type(thenDo) == "function" then
            object.thenDo = thenDo
        else
            object.thenDo = function() end
        end
        -- use a dummy text to get the maximum height of the font
        local testTextHeight = love.graphics.newText(object.font, "QWERTYUIOPASDFGHJKLZXCVBNM?!qwertyuioopasdfghjklzxcvbnm\"'\\/")
        object.fontHeight = testTextHeight:getHeight()
        --default we get the height of three lines. Right now width is undefined. Current implemntation will have overflowing text cut off.
        object.window.inner.height = object.fontHeight * 3 + object.lineheight * 2
        object.window.inner.width = math.floor(love.graphics.getWidth() * 3 / 4) - object.window.border * 2
        object.window.outer.width = object.window.inner.width + object.window.border * 2
        object.window.outer.height = object.window.inner.height + object.window.border * 2
        object.window.outer.origin = {
            x = math.floor((love.graphics.getWidth() - object.window.outer.width) / 2),
            y = love.graphics.getHeight()  - object.window.outer.height - object.spacing
        }
        object.window.inner.origin = {
            x = object.window.outer.origin.x + object.window.border,
            y = object.window.outer.origin.y + object.window.border,
        }
        object.text = love.graphics.newText(UI.fonts.dialog, "") -- dumb way to prevent this from trying to get an uninitialized texture.

        -- set up input handling
        -- object.oldInputHandler = love.keypressed
        -- ---@diagnostic disable-next-line: duplicate-set-field
        -- love.keypressed = function(key)
        --     if key == Config.keys.confirm then
        --         if object.status == "printing" then
        --             object.script.character = #object.script.text
        --         elseif object.status == "waiting" then
        --             object:scrollToDeath()
        --         end
        --     end
        -- end
        object.oldInputHandler = love.keypressed
        ---@diagnostic disable-next-line: duplicate-set-field
        Input:setKeyHandler(
            function(key)
                if key == Config.keys.confirm then
                    if object.status == "printing" then
                        object.script.character = #object.script.text
                    elseif object.status == "waiting" then
                        object:scrollToDeath()
                    elseif object.status == "scrolling" then
                        object.offset = 999999 -- triggers the end of the scrolling animation
                    end
                end
            end
        )
        Input:setGamepadHandler(
            function(joystick, button)
                if button == Config.gamepad.confirm then
                    if object.status == "printing" then
                        object.script.character = #object.script.text
                    elseif object.status == "waiting" then
                        object:scrollToDeath()
                    end
                end
            end
        )


        object.draw = function(self)
            local oldColor = {} 
            oldColor.r, oldColor.g, oldColor.b, oldColor.a = love.graphics.getColor()
            love.graphics.setColor(0, 0, 1)
            love.graphics.polygon(
                "fill",
                self.window.outer.origin.x, self.window.outer.origin.y,
                self.window.outer.origin.x + self.window.outer.width, self.window.outer.origin.y,
                self.window.outer.origin.x + self.window.outer.width, self.window.outer.origin.y + self.window.outer.height,
                self.window.outer.origin.x, self.window.outer.origin.y + self.window.outer.height
            )

            love.graphics.setColor(1,1,1,1)
            -- only draw in the inner area
            love.graphics.setScissor(self.window.inner.origin.x, self.window.inner.origin.y, self.window.inner.width,self.window.inner.height)
            love.graphics.draw(self.text, self.window.inner.origin.x, self.window.inner.origin.y - self.offset)
            love.graphics.setScissor()
            love.graphics.points(self.window.inner.origin.x, self.window.inner.origin.y)

            love.graphics.setColor(oldColor.r, oldColor.g, oldColor.b, oldColor.a)

            if self.continueMarker.display then
                love.graphics.points(
                    self.window.inner.origin.x + self.window.inner.width,
                    self.window.inner.origin.y + self.window.inner.height
                )
            end
        end

        object.update = function(self, dt)
            -- -- animate the continueMarker
            local cm = self.continueMarker
            if self.status == "waiting" then
                cm.currentTime = cm.currentTime + dt
                if cm.currentTime > cm.duration then
                    cm.currentTime = 0
                    cm.display = not cm.display
                end
            else
                cm.display = false
            end
            -- -- Animate scrollToDeath
            if self.offset > 0 then
                self.status = "scrolling"
                if self.offset >= self.window.inner.height then
                    self.status = "waiting"
                    self:destroy()
                else
                    self.offset = self.offset + 400 * dt
                end
            end
            --animate the text.
            local script = self.script
            script.currentTime = script.currentTime + dt
            if script.currentTime >= script.nextTime then
                script.currentTime = 0
                if script.character < #script.text then
                    self.status = "printing"
                    script.character = script.character + 1
                else
                    self.status = "waiting"
                end
                self.text = love.graphics.newText(UI.fonts.dialog, string.sub(script.text, 1, script.character))
            end

        end
        object.destroy = function(self)
            Input:release()
            UI:remove(self)
            Input.lock = ""
            if #self.script.lines > 1 then
                table.remove(self.script.lines,1)
                UI:add(UI.dialogBox.new(self.script.lines, self.thenDo))
            else
                self.thenDo()
            end
        end
        object.scrollToDeath = function(self)
            self.offset = 1
        end
            




        return object
    end
}
---@class battleStats
return {
    new = function(unit, thenDo)

        print("battleStats.new has been called")

        local object = {
            font = UI.fonts.small,
            lineheight = 0,
            window = {
                border = 10,
                starts = {},
                textOrigin = {}
            },
            thenDo = thenDo
        }
        assert(unit.stats, "Unit given does not include stats.")
        local stats = unit.stats

        local screenWidth, screenHeight = love.graphics.getWidth(), love.graphics.getHeight()
        local info = unit.name .. "\n\n" .. unit.class .. "\n\n\nHP        " .. stats.hp .. "/" .. stats.hpmax .. "\n\nMP        " .. stats.mp .. "/" .. stats.mpmax .. "\n\nAttack    " .. stats.attack .. "\n\nDefense   " .. stats.defense .. "\n\nAgility   " .. stats.agility
        
        object.text = love.graphics.newText(object.font, info)
        local textWidth, textHeight = object.text:getWidth(), object.text:getHeight()
        object.window.textOrigin.x = screenWidth / 2 - textWidth / 2
        object.window.textOrigin.y = screenHeight / 2 - textHeight /2
        object.window.starts.x = object.window.textOrigin.x - object.window.border
        object.window.starts.y = object.window.textOrigin.y - object.window.border
        object.window.width = textWidth + object.window.border * 2
        object.window.height = textHeight + object.window.border * 2

        Input.cursorControl:disable()
        Input:setKeyHandler(function(key)
            if key == Config.keys.cancel then object:destroy() end
        end
        )


        object.draw = function(self)
            --something
            love.graphics.setColor(0,0,1)
            love.graphics.rectangle("fill", self.window.starts.x, self.window.starts.y, self.window.width, self.window.height)
            love.graphics.setColor(1,1,1)
            love.graphics.draw(self.text, self.window.textOrigin.x, self.window.textOrigin.y)
        end

        object.update = function(self, dt) end --doesn't actually need to update itself. Not yet, anyways.

        object.destroy = function(self)
            Input:release()
            UI:remove(self)
            if type(self.thenDo) == "function" then
                self.thenDo()
            else Input.cursorControl:enable()
            end
        end

        return object
    end


        -- -- use a dummy text to get the maximum height of the font
        -- local testTextHeight = love.graphics.newText(object.font, "QWERTYUIOPASDFGHJKLZXCVBNM?!qwertyuioopasdfghjklzxcvbnm\"'\\/")
        -- object.fontHeight = testTextHeight:getHeight()
        -- -- doing the same for font glyph width. This will only work for unispace fonts; you will have
        -- testTextHeight = love.graphics.newText(object.font, "X")
        -- object.window.inner.height = object.fontHeight * 8 + object.lineheight * 7


        --stats are hp mp speed and strength
        -- Unit Name
        -- Unit Class
        --
        -- HP        100/100
        -- MP        99/99
        -- Attack    99
        -- Defense   99
        -- Agility   99


}
require "Anim"
UI = {
    dialogBox = require("code/UI/dialogBox"),
    quadMenu = require("code/UI/quadMenu"),
    battleStats = require("code/UI/battleStats"),
    carrier = {}, -- holds UI elements
    ---Adds UI elements to the carrier.
    ---@param element table The UI element to add to the carrier
    ---@return nil
    add = function(self, element)
        table.insert(self.carrier,element)
        return element
    end,
    -- calls the update function in all elements in the carrier; only to be placed in the love.update callback.
    update = function(self, dt)
        for index, element in ipairs(self.carrier) do
            element:update(dt)
        end
        -- if #self.carrier == 0 and not Input.cursorControl.enabled then
        --     Input.directControl.enabled = true
        -- else
        --     Input.directControl.enabled = false
        -- end
    end,
    -- calls the draw function in all elements in the carrier; only to be placed in the love.draw callback.
    draw = function(self)
        for index, element in ipairs(self.carrier) do
            element:draw()
        end
    end,
    ---Removes an all of a given type of element from the carrier. Probably shouldn't be used....
    ---@param type string The type of item to remove. If "all" will remove all of them.
    removeType = function(self, type)
        if type == "all" then
            for item in ipairs(self.carrier) do
                self.carrier[item] = nil
            end
            self.carrier = {}
        else
            for index, element in ipairs(self.carrier) do
                if element.type == type then
                    table.remove(self.carrier, index)
                end
            end
        end
    end,
    remove = function(self, object)
        for item in ipairs(self.carrier) do
            if self.carrier[item] == object then table.remove(self.carrier, item) end
        end
    end,
    fonts = {}


}

for font, attributes in pairs(Config.fonts) do
    UI.fonts[font] = love.graphics.newFont(attributes.filename, attributes.size, attributes.hinting, attributes.dpiscale)
end


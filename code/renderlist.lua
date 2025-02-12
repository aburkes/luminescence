sti = require "code/libs/Simple-Tiled-Implementation/sti"
Object = require "code/libs/classic/classic"

RenderList = Object:extend()

function RenderList:new()
    self.list = {
        map = {},
        units = {},
        fx = {},
        ui = {},
        top = {}
    }
end

function RenderList:add(Renderable)
    self.list.add(Renderable)
end

function RenderList:update()
    for list in self.list do
        for item in list do
            item.update()
        end
    end
end

function RenderList:draw()
    for list in self.list do
        for item in list do
            item.draw()
        end
    end
end


Renderable = Object:extend()

function Renderable:new(Drawable, xPos, yPos)
    self.image = Drawable
    self.xPos = xPos
    self.yPos = yPos
end

function Renderable:update()
    -- do something: probably needs to be overwritten on a case-by-case basis?
end

function Renderable:draw()
    love.graphics.draw(self.image, self.xPos, self.yPos)
end
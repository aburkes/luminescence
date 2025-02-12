local font
local textObject
local scrollY = 0 -- Scrolling offset
local scrollSpeed = 1 -- Pixels per frame
local textHeight

function love.load()
    font = love.graphics.newFont(20) -- Set font size
    textObject = love.graphics.newText(font, "This is a scrolling text example.\nLine 2\nLine 3\nLine 4")
    textHeight = textObject:getHeight()
end

function love.update(dt)
    -- Scroll the text up
    scrollY = scrollY + scrollSpeed
    -- Stop scrolling when the text fully disappears
    if scrollY > textHeight then
        scrollY = -textHeight -- Restart scrolling (loop effect)
    end
end

function love.draw()
    local x, y = 100, 100 -- Starting position of the text
    local width, height = textObject:getWidth(), 80 -- Define visible area height

    -- Set a clipping rectangle
    love.graphics.setScissor(x, y, width, height)

    -- Draw the text with an upward offset
    love.graphics.draw(textObject, x, y - scrollY)

    -- Reset scissor to stop clipping
    love.graphics.setScissor()
end

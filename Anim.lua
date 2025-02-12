Anim = {
    ---loads a texture atlas file in strip format and returns frame data
    ---@param imagePath string path of file to load
    ---@param frameWidth integer width of frame within texture atlas
    ---@return table frames
    loadStrip = function(imagePath, frameWidth)
        local image = love.graphics.newImage(imagePath)
        local frames = {}
        local width = frameWidth
        local height = image:getHeight()
        local horizontalFrames = image:getWidth() / frameWidth
        for i = 0, horizontalFrames - 1 do
            local quad = love.graphics.newQuad(i * width, 0, width, height, image)
            table.insert(frames, quad)
        end
        return {image = image, frames = frames}
    end,

    loadMultistrip = function (imagePath, frameWidth, frameHeight)
        local image = love.graphics.newImage(imagePath)
        local frames = {}
        local frameQty = image:getWidth() / frameWidth
        local frameSets = image:getHeight() / frameHeight
        for set = 0, frameSets do
            local frameset = {}
            for frame = 0, frameQty - 1 do
                local quad = love.graphics.newQuad(frame * frameWidth, set * frameHeight, frameWidth, frameHeight, image)
                table.insert(frameset, quad)
            end
            table.insert(frames, {image = image, frames = frameset})
        end
        return frames
    end,

    ---loads a texture atlas file in x-y (matrix) format and returns frame data
    ---@param imagePath string path of file to load 
    ---@param frameWidth integer width of frame within texture atlas
    ---@param frameHeight integer height of frame within texture atlas
    ---@return table frames
    loadMatrix = function(imagePath, frameWidth, frameHeight)
        local image = love.graphics.newImage(imagePath)
        local frames = {}
        local width = frameWidth
        local height = frameHeight
        local horizontalFrames = image:getWidth() / frameWidth
        local verticalFrames = image:getHeight() / frameHeight

        for y = 0, verticalFrames - 1 do
            for x = 0, horizontalFrames - 1 do
                local quad = love.graphics.newQuad(x * width, y * height, width, height, image)
                table.insert(frames, quad)
            end
        end
        
        return {image = image, frames = frames}
    end,
    
    
    new = function(frameData, x, y, frameDuration)
        local animation = {
            image = frameData.image,
            frames = frameData.frames,
            frameDuration = frameDuration or 1,
            currentFrame = 1,
            currentTime = 0 --time passed since starting or last frame update
        }
        animation.update = function(self, dt)
            self.currentTime = self.currentTime + dt
            if self.currentTime >= self.frameDuration then
                self.currentTime = 0
                self.currentFrame = self.currentFrame + 1
                if self.currentFrame > #self.frames then
                    self.currentFrame = 1
                end
            end
        end
    
        animation.draw = function(self, x, y)
            love.graphics.draw(self.image, self.frames[self.currentFrame], x, y)
        end
        return animation
    end

}
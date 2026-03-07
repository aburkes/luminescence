---@class AnimFrameData
---@field image love.Image  The loaded texture
---@field frames love.Quad[] Array of quads sliced from the texture

---@class AnimStrip
---@field image love.Image
---@field frames love.Quad[]

---@class Animation
---@field image love.Image       Source texture
---@field frames love.Quad[]     Array of animation frame quads
---@field frameDuration number   Seconds each frame is displayed
---@field currentFrame integer   Index of the currently displayed frame
---@field currentTime number     Elapsed time since the last frame change
---@field update fun(self: Animation, dt: number) Advance animation by dt seconds
---@field draw fun(self: Animation, x: number, y: number) Draw the current frame at (x, y)

Anim = {
    ---Load a horizontal strip texture atlas and return frame data.
    ---All frames share the full image height; the atlas is divided into equal-width columns.
    ---@param imagePath string Path to the image file
    ---@param frameWidth integer Width in pixels of each frame
    ---@return AnimFrameData
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

    ---Load a multi-row strip texture atlas and return one AnimFrameData per row.
    ---Each row is treated as a separate animation strip.
    ---@param imagePath string Path to the image file
    ---@param frameWidth integer Width in pixels of each frame
    ---@param frameHeight integer Height in pixels of each row
    ---@return AnimFrameData[]
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

    ---Load a matrix (grid) texture atlas and return frame data.
    ---Frames are ordered left-to-right, top-to-bottom.
    ---@param imagePath string Path to the image file
    ---@param frameWidth integer Width in pixels of each frame
    ---@param frameHeight integer Height in pixels of each frame
    ---@return AnimFrameData
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
    
    
    ---Create a new looping animation from frame data.
    ---@param frameData AnimFrameData Frame data returned by a load function
    ---@param x number Initial x position (unused; pass to draw instead)
    ---@param y number Initial y position (unused; pass to draw instead)
    ---@param frameDuration number? Seconds per frame (default 1)
    ---@return Animation
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
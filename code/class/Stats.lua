-- Object = require "code/libs/classic/classic"

Stats = Object:extend()

function Stats:new(name, ...)
    self.name = name
    self.stats = ...
end

function Stats:__tostring() -- just because it seems useful for debugging
    return self.name
end

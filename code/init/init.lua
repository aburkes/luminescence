require "code/init/input"
local sti = require "code/libs/Simple-Tiled-Implementation/sti"

Init = {}

Init.objectsInit = require("code/init/object")
Init.addHighlightLayer = require("code/init/highlight")
Init.addCursorLayer = require("code/init/cursor")
Init.addSupportFunctions = require("code/init/support")

-- For some reason, the checker finds this twice... on the same line.
---@diagnostic disable-next-line: duplicate-set-field
Init.loadMap = function(filename)
    local map = sti(filename)
    Init.objectsInit(map)
    Init.addHighlightLayer(map)
    Init.addCursorLayer(map)
    Init.addSupportFunctions(map)


    -- rearranging the layers
	local cursorlayer, highlightlayer, objectlayer
	for k,v in ipairs(map.layers) do
		if v.name == "cursor" then
			cursorlayer = k
		elseif v.name == "highlight" then
			highlightlayer = k
		elseif v.name == "objects" then
			objectlayer = k
		end
	end
	table.remove(map.layers, cursorlayer)
	table.remove(map.layers, highlightlayer)
	table.remove(map.layers, objectlayer)
	table.insert(map.layers, map.layers.highlight)
	table.insert(map.layers, map.layers.objects)
	table.insert(map.layers, map.layers.cursor)



	
    return map
end


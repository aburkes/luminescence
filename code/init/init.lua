---@diagnostic disable: duplicate-set-field
require "code/init/input"
local sti = require "code/libs/Simple-Tiled-Implementation/sti"
-- local sti = require "sti"

DB = require("code/init/db")
print(DB.test)

Init = {}

Init.Objects = require("code/init/object")
Init.addHighlightLayer = require("code/init/highlight")
Init.addCursorLayer = require("code/init/cursor")
Init.addSupportFunctions = require("code/init/support")
Init.save = require("code/init/gamesave")

---loads a map for 'adventure mode'
---@param filename string map file to load, in lua format.
---@return map
Init.loadMap = function(filename)
	---@class map
	---@field layers table
	---@field objects table
    local map = {}
	
	map = sti(filename)
	Init.Objects:populateObjects(map)
    Init.addHighlightLayer(map)
    Init.addCursorLayer(map)
    Init.addSupportFunctions(map)
	
	Cursor = map.layers.cursor


	-- -- there is a strange bug of sorts in Tiled that gives bogus height and width numbers for infinate maps.
	-- -- As a dumb fix, we will manually check the length of the first row and column and take last non-nil
	-- -- as the edge of the map.
	-- --
	-- -- this can't *possibly* backfire.

	-- print("is this working?")
	-- local terrain = map.layers.terrain
	-- local max = 0
	-- for k,v in ipairs(terrain.data) do
	-- 	if not v ~= nil then max = k end
	-- end
	-- map.height = max
	-- for k,v in ipairs(terrain.data[1]) do
	-- 	if not v ~= nil then max = k end
	-- end
	-- map.width = max


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

Init.newGame = function()
	Party.active = {DB.characters.Alan}
end

---Loads a map initialized for a battle
---@param filename string location of map in lua format.
Init.loadBattleMap = function(filename)
    local map = sti(filename)
	Init.Objects:populateObjects(map)
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
end
if arg[#arg] == "vsc_debug" then require("lldebugger").start() end --VS Code's debugger
if type(Object) == "nil" then Object = require "code/libs/classic/classic" end


require "code/UI/ui"
require "code/init/init"
require "code/Party"
require "Anim"
require "Battle"


-- table used to trigger various debugging levels
DebuggingLevel = {
	FPS = true, --shows FPS counter
	plainTextSaves = true, -- note will completely ignore encoded saves if you do this.

}

function love.load()


	-- map = Init.loadMap("res/map/outside-test-map.lua")
	-- map = Init.loadMap("res/map/Battle Test 1/Battle Test 1.lua")
	Input.directControl:disable()

	local alan = Party:addMember(DB.characters.Alan)
	Party:addMember(DB.characters.Alan)
	Party:addMember(DB.characters.Sami)
	-- local Alan = Init.Objects:objectInit(alan,map)
	-- table.insert(map.objects, Alan)
	
	map = Init.loadMap("res/map/Battle Test 1/Battle Test 1.lua")


	-- local test = map:reachableTiles(3, 02, 5)
	-- map.layers.highlight.highlighted = test


	-- Input.directControl:enable()
	Input:release()
	Input.cursorControl:enable()

	-- map.objects[2].properties.message = {"message 1", "This is a slightly\nlonger message\ntaking three lines."}

end


Index = 1



function love.update(dt)
	for k,v in pairs(map.objects) do
		if v.move then v.move:update(dt) end
		-- v.move:update(dt)
	end
	Input.directControl:update()
	Input.cursorControl:update()
	map:update(dt)
	UI:update(dt)


	-- experimental "responsive" mode. Probably should just delete and do fixed dimensions.
	for n, a, b, c, d, e, f in love.event.poll() do
		if n == "resize" then
			print("resize detected!")
			print(love.graphics.getWidth())
			print(love.graphics.getWidth())
			map:resize()
		end	
	end
end

function love.draw()
	map:draw(-map.objects[Index].x + love.graphics.getWidth()/2, -map.objects[Index].y + love.graphics.getHeight()/2)
	UI:draw()




	if DebuggingLevel.FPS then
		love.graphics.print("FPS: "..tostring(love.timer.getFPS()), 10, 10)
	end

	if love.keyboard.isDown("end","\\") then
		print("entering debug mode")
		-- debug.debug()
	end



end

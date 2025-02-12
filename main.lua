if arg[#arg] == "vsc_debug" then require("lldebugger").start() end --VS Code's debugger
if type(Object) == "nil" then Object = require "code/libs/classic/classic" end


require "code/UI/ui"
require "code/init/init"
require "Anim"


-- Input = {
-- 	lock = "",
-- 	directControl = {
-- 		enabled = true,
-- 		enable = function(self)
-- 			self.enabled = true
-- 			love.keypressed = function(key)
-- 				if key == Config.keys.confirm then map.objects[Index]:action()
-- 				elseif key == "1" then Index = 1
-- 				elseif key == "2" then Index = 2
-- 				elseif key == "3" then Index = 3
-- 				elseif key == "4" then Index = 4
-- 				elseif key == "m" then UI:add(UI.quadMenu.new("res/sprite/actions.png", 72, 48))
-- 				end
-- 			end
-- 		end,
-- 		disable = function(self)
-- 			self.enabled = false
-- 		end
-- 	}

-- }






-- table used to trigger various debugging levels
DebuggingLevel = {
	FPS = true
}

function love.load()
	map = Init.loadMap("res/map/outside-test-map.lua")
	-- cursor = map.layers.cursor
	-- UI:add(UI.dialogBox.new("This is a test of the emergency broadcast system.\nand this is another.\nAnd a third!"))
	-- UI:add(UI.quadMenu.new("res/sprite/actions.png", 72, 48))
	-- UI:add(UI.dialogBox.new("second test!"))

	local test = map:reachableTiles(3, 02, 5)
	map.layers.highlight.highlighted = test


	
	Input:release()

	map.objects[2].properties.message = {"message 1", "This is a slightly\nlonger message\ntaking three lines."}

end


Index = 1



function love.update(dt)
	for k,v in pairs(map.objects) do
		v.move:update(dt)
	end
	Input.directControl:update()
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
	-- map:draw(-cursor.position.x + love.graphics.getWidth()/2, -cursor.position.y + love.graphics.getHeight()/2)
	map:draw(-map.objects[Index].x + love.graphics.getWidth()/2, -map.objects[Index].y + love.graphics.getHeight()/2)

	-- menu:draw()
	-- dialog:draw()
	UI:draw()




	if DebuggingLevel.FPS then
		love.graphics.print("FPS: "..tostring(love.timer.getFPS()), 10, 10)
	end

	if love.keyboard.isDown("end","\\") then
		print("entering debug mode")
		-- debug.debug()
	end



end

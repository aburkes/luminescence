return function(map)	

    -- highlight layer for highlighting tiles
	local highlight = map:addCustomLayer("highlight", #map.layers + 1)
	highlight.graphic = love.graphics.newImage("res/sprite/whiteblock.png")
	highlight.highlighted = {{1,1}, {1,2}, {1,3}, {1,4}, {0,0}}
	highlight.opacity = 1
	highlight.opacitymax = 0.4
	highlight.opacitymin = 0.0
	highlight.speed = 2
	highlight.parent = map
	highlight.increment = function(self,dt)
		self.opacity = self.opacity + self.speed * dt
		if self.opacity >= self.opacitymax then
			self.opacity = self.opacitymax
			self.update = self.decrement
		end
	end
	highlight.decrement = function(self,dt)
		self.opacity = self.opacity - self.speed * dt
		if self.opacity <= self.opacitymin then
			self.opacity = self.opacitymin
			self.update = self.increment
		end
	end
	highlight.draw = function(self)
		-- love.graphics.setColor(255,255,255,self.opacity)
		love.graphics.setColor(self.opacity, self.opacity, self.opacity, self.opacity)
		for _,pair in ipairs(self.highlighted) do
			love.graphics.draw(self.graphic, pair[1] * self.parent.tilewidth, pair[2] * self.parent.tileheight)
		end
		love.graphics.setColor(255,255,255,255)
	end
	highlight.update = function(self,dt)
		self:decrement(dt)
	end
end
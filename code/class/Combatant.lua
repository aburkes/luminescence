Object = require "code/libs/classic/classic"

Combatant = Object:extend()

function Combatant:new(name, stats)
	self.name = name or "DEFAULT"
	
	-- make sure stats is a table and fill missing details with defaults
	if type(stats) == "table" then
		self.stats = stats
	else
		self.stats = {}
	end
	self.stats.hp = self.stats.hp or {}
	self.stats.mp = self.stats.mp or {}
	self.stats.hp.max = self.stats.hp.max or 10
	self.stats.hp.current = self.stats.hp.max
	self.stats.mp.max = self.stats.mp.max or 0
	self.stats.mp.current = self.stats.mp.max
	self.stats.strength = self.stats.strength or 5
	self.stats.defense = self.stats.defense or 5
	self.stats.agility = self.stats.agility or 5
	self.stats.speed = self.stats.speed or 5
	
	-- initialize data with defaults

	self.graphics = "default"
	
	
end


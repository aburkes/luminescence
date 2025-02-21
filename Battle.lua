

Battle = {}

Battle.active = false

Battle.combattants = {}

Battle.initiate = function(self, combattants)
    self.combattants = combattants
    for _, unit in ipairs(combattants) do
        local props = unit.properties
        props.moveTimer = props.stats.agility
    end
end

Battle.nextTurn = function(self)
    local lowest = 9999999
    for _, unit in ipairs(self.combattants) do
        if unit.properties.moveTimer < lowest then lowest = unit.properties.moveTimer end
    end
    for _, unit in ipairs(self.combattants) do
        unit.properties.moveTimer = unit.properties.moveTimer - lowest
    end
    for which, unit in ipairs(self.combattants) do
        if unit.properties.moveTimer == 0 then 
            unit.properties.moveTimer = unit.properties.stats.agility -- must reset or will get to move infinitely!
            return self.combattants[which]
        end
    end
    assert(false, "Something is very wrong with Battle.nextTurn method") -- we should never see this.
end


--Does this need to be part of the Battle object? Would there be a better place to put this?
Battle.attack = function(self, attacker, defender)
    -- This is gonna be complex Hold on to your butts!

    -- but for now a basic implemntation. :P
    local damageDealt = attacker.stats.attack - defender.stats.defense
    if damageDealt > defender.stats.hp then damageDealt = defender.stats.hp end
    local message = {
        attacker.name .. " attacks " .. defender .. " for ",
        damageDealt .. " damage!"
    }
    if defender.stats.hp <= 0 then 
        table.insert(message, defender.name .. " falls!")
        Battle.queue:remove(defender)
    end
    

    UI:add(UI.dialogBox.new(message))

end



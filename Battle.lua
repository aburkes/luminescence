Battle = {}

Battle.queue = {
    lineup = {},
    insert = function(self, combattant)
        -- add a unit into the battle queue.
        -- to do this:
        -- -- use their agility score to assign a time value
        -- -- find where they would belong in the queue and then add them in in that position.
    end,
    remove = function(self, combattant)
        for unit, data in ipairs(self.lineup) do
            if data.id == combattant.id then
                table.remove (combattant)
            end
        end
    end,
    advance = function(self)
        local timeAdvance = self.lineup[1].time
        for k, unit in ipairs(self.lineup) do
            unit.time = unit.time - self.lineup[1].time
        end
        table.remove(self.lineup, 1)
    end,
}

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


--- Battle module. Manages combat state, turn order, and attack resolution.
--- Uses an agility-based tick-down initiative system: each unit's moveTimer starts
--- at their agility value and counts down each round; the first to reach zero acts next.

Battle = {}

--- Whether a battle is currently in progress.
Battle.active = false

--- Array of all map object tables participating in the current battle.
Battle.combattants = {}

--- State for the currently active turn.
--- `unit` is the acting unit; `startingPosition` records where they began.
Battle.turn = {
    unit = {},
    startingPosition = {}
}

--- Initialises a battle with a list of combatants.
--- Sets each unit's moveTimer to their agility stat, which seeds the initiative order.
--- @param self table The Battle object.
--- @param combattants table Array of map object tables, each requiring `properties.stats.agility`.
Battle.initiate = function(self, combattants)
    self.combattants = combattants
    for _, unit in ipairs(combattants) do
        local props = unit.properties
        props.moveTimer = props.stats.agility
    end
end

--- Advances to the next turn using the agility tick-down system.
--- Finds the lowest moveTimer across all combatants, subtracts it from everyone,
--- then returns the first unit whose timer has hit zero and resets that unit's timer.
--- Throws an assertion error if no unit reaches zero (should never happen).
--- @param self table The Battle object.
Battle.nextTurn = function(self)
    local lowest = 9999999
    -- makes lowest equal to the lowest moveTimer value
    for _, unit in ipairs(self.combattants) do
        if unit.properties.moveTimer < lowest then lowest = unit.properties.moveTimer end
    end
    --subtracts the lowest value from each unit's moveTimer
    for _, unit in ipairs(self.combattants) do
        unit.properties.moveTimer = unit.properties.moveTimer - lowest
    end
    --selects the first unit with a zero moveTimer value.
    for which, unit in ipairs(self.combattants) do
        if unit.properties.moveTimer == 0 then 
            unit.properties.moveTimer = unit.properties.stats.agility -- must reset or will get to move infinitely!
            return self.combattants[which]
        end
    end
    assert(false, "Something is very wrong with Battle.nextTurn method") -- we should never see this.
end

--- Begins a unit's turn. Currently just moves the cursor to (1,1).
--- @param self table The Battle object.
--- @param unit table The combatant whose turn is starting.
Battle.initiateTurn = function(self, unit)
    Cursor:moveTo(1,1)
end

--Does this need to be part of the Battle object? Would there be a better place to put this?
--- Resolves a basic attack and shows the result in a dialog box.
--- Damage = attacker.stats.attack - defender.stats.defense, capped at defender's remaining HP.
--- If the defender's HP reaches zero, they are removed from Battle.queue and a defeat message is shown.
--- @param self table The Battle object.
--- @param attacker table Combatant with `name` and `stats.attack` fields.
--- @param defender table Combatant with `name`, `stats.defense`, and `stats.hp` fields.
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



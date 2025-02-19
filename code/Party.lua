-- this file is supposed to describe the status of the party, including the last place saved at so that we can use it as a save 

Party = {
    active = {

    },
    activeMax = 10,
    reserve = {

    },
    flags = {
        -- story scripting flags go here
    },
    savedAt = {
        -- I'll figure this out soon enough...?
    },
    addMember = function(self, DB_character)

        local function deepCopy(original)
            local copy = {}
            for key, value in pairs(original) do
                if type(value) == "table" then
                    copy[key] = deepCopy(value)
                else
                    copy[key] = value
                end
            end
            return copy
        end

        local member = deepCopy(DB_character)
        member.properties = {
            stats = member.stats,
            facing = "down",
            image = member.image,
            team = "party",
        }
        member.visible = true
        -- just in case we have problems figuring out what to do with these
        member.x = 1
        member.y = 1

        if #self.active < self.activeMax then
            table.insert(self.active, member)
        else
            table.insert(self.reserve, member)
        end

        return member
    end


}

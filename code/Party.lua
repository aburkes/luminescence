-- this file is supposed to describe the status of the party, including the last place saved at so that we can use it as a save 

Party = {
    active = {

    },
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

        member.sprite = love.graphics.newImage(member.properties.image)
        

    end


}

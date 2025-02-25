
require("code/libs/TSerial")
if not TSerial then TSerial = require("code/libs/TSerial") end

return {
    saveData = function(party, filename)

        -- prep data for saving

        local getPartyMemberData = function(member)
            local out = {}
            out.class = member.class
            out.gain = member.gain
            out.image = member.image
            out.inventory = {}
            for k,v in ipairs(member.inventory) do
                -- will undoubetdly need to update this when item/inventory gets filled out.
                out.inventory[k] = v
            end
            out.name = member.name
            out.promotion = member.promotion
            out.stats = member.stats
            return out
        end
        local out = {}
        out.active = {}
        out.reserve = {}
        for _, member in ipairs(party.active) do
            table.insert(out.active, getPartyMemberData(member))
        end
        for _, member in ipairs(party.reserve) do
            table.insert(out.reserve, getPartyMemberData(member))
        end
        out.flags = party.flags
        out.savedAt = party.savedAt
        

        -- serialize and save data.

        local function drop(data)
            return type(data)
        end
        if DebuggingLevel.plainTextSaves then
            local serialized = TSerial.pack(out, nil, true)
            local success, message = love.filesystem.write("testsave.txt", serialized)
            if success then
                print("The game saved succesfully")
            else
                print(message)
            end
        else
            local serialized = TSerial.pack(out)
            -- encrypt before saving
            love.filesystem.write(filename, serialized)
        end
    end,
    loadData = function(filename)
        if filename == nil then filename = "testsave.txt" end
        local serialized = love.filesystem.read(filename)
        local savedata = TSerial.unpack(serialized)
        return savedata
    end
}
require("code/libs/TSerial")
return {
    saveData = function(party, filename)
        if DebuggingLevel.plainTextSaves then
            local serialized = TSerial.pack(party, nil, true)
            love.filesystem.write("testsave.txt", serialized)
        else
            local serialized = TSerial.pack(party)
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
local function loadDirectory(directory)
    local modules = {}
    local directoryItems = love.filesystem.getDirectoryItems(directory)
    for _, filename in ipairs(directoryItems) do
        local path = directory .. "/" .. filename
        if filename:match("%.lua$") then
            local moduleName = filename:sub(1, -5) -- remove the lua extention
            modules[moduleName] = require(directory .. "." .. moduleName)
        end
    end
    return modules
end


return {
    characters = loadDirectory("database/characters"),
    items = loadDirectory("database/items")
}
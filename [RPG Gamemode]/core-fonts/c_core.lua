--[[
    KOD    
--]]

local fonts = {}

function getFont(path, size)
    if not fileExists("files/font/"..path) then return end
    if not fonts[path] then
        fonts[path] = {}
    end
    if not fonts[path][size] then
        fonts[path][size] = dxCreateFont("files/font/"..path, size)
    end
    return (fonts[path][size] or false)
end
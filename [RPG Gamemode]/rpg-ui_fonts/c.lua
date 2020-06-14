local fonts = {}

function getFont(fontName, size)
    if not fileExists("files/font/"..fontName..".ttf") then return end
    if not fonts[fontName] then
        fonts[fontName] = {}
    end
    local size = size or 9
    if not fonts[fontName][size] then
        fonts[fontName][size] = dxCreateFont("files/font/"..fontName..".ttf", size)
    end
    return (fonts[fontName][size] or false)
end
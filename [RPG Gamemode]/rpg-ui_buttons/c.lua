local sx, sy = guiGetScreenSize() 
local zoom = sx < 1920 and math.min(2, 1920 / sx) or 1

local buttons = {}
local rendering = false

function createButton(id, x, y, w, h, text, fontSize, useBlur)
    if type(id) ~= "number" and type(id) ~= "string" then return end
    if type(x) ~= "number" then return end
    if type(y) ~= "number" then return end
    if type(w) ~= "number" then return end
    if type(h) ~= "number" then return end
    if type(text) ~= "string" then return end
    if findButtonByID(id) then return end
    local _useBlur = (useBlur or true)
    local _fontSize = (fontSize or 16)
    buttons[id] = {x, y, w, h, text, exports["rpg-ui_fonts"]:getFont("tw", _fontSize), _useBlur}
    if not rendering then
        rendering = true
        addEventHandler("onClientRender", getRootElement(), renderButtons)
    end
end

function removeButton(id)
    if not buttons[id] then return end
    buttons[id] = nil
    if #buttons <= 0 then
        rendering = false
        removeEventHandler("onClientRender", getRootElement(), renderButtons)
    end
end

function setButtonText(id, text)
    if not findButtonByID(id) then return false end
    local buttonData = buttons[id]
    buttonData[5] = text
    buttons[id] = buttonData
end

function setButtonFontSize(id, size)
    if not findButtonByID(id) then return false end
    local buttonData = buttons[id]
    buttonData[6] = exports["rpg-ui_fonts"]:getFont("tw", size)
    buttons[id] = buttonData
end

function setButtonUseBlur(id, bool)
    if not findButtonByID(id) then return false end
    local buttonData = buttons[id]
    buttonData[7] = bool
    buttons[id] = buttonData
end

function setButtonPosition(id, x, y, w, h)
    if not findButtonByID(id) then return false end
    local buttonData = buttons[id]
    buttonData[1] = x
    buttonData[2] = y
    buttonData[3] = w
    buttonData[4] = h
    buttons[id] = buttonData
end

function getButtonText(id, text)
    if not findButtonByID(id) then return false end
    return buttons[id][5]
end

function getButtonUseBlur(id, bool)
    if not findButtonByID(id) then return false end
    return buttons[id][7]
end

function getButtonPosition(id, x, y, w, h)
    if not findButtonByID(id) then return false end
    return buttons[id][1], buttons[id][2], buttons[id][3], buttons[id][4]
end

function findButtonByID(id)
    if buttons[id] then return true end
    return false
end

function click(x, y, w, h)
    if isMouseInPosition(x, y, w, h) and getKeyState("mouse1") and not clickblock then return true end
    return false
end

function renderButtons()
    for i, v in pairs(buttons) do
        local x, y, w, h, text, font, useBlur = unpack(v)
        local _r, _g, _b = 0, 0, 0
        if isMouseInPosition(x, y, w, h) then
            _a = 200
            if getKeyState("mouse1") then
                _r, _g, _b = 0, 144, 255
            end
            if click(x, y, w, h) then
                triggerEvent("rpg-ui_buttons:onButtonClick", getRootElement(), i, x, y, w, h, text, font, useBlur)
            end
        elseif not isMouseInPosition(x, y, w, h) then
            _a = 185
        end
        if useBlur then
            exports["rpg-ui_blur"]:dxDrawBluredRectangle(x, y, w, h, tocolor(255, 255, 255))
        end
        dxDrawRectangle(x, y, w, h, tocolor(_r, _g, _b, _a))
        dxDrawText(text, x, y, x+w, y+h, tocolor(225, 225, 225, 225), 1/zoom, font, "center", "center")
    end
    if getKeyState("mouse1") and not clickblock then
        clickblock = true
    elseif not getKeyState("mouse1") and clickblock then
        clickblock = false
    end
end

function isMouseInPosition(x, y, w, h)
    if not isCursorShowing() then return false end
    local cx, cy = getCursorPosition()
    local cx, cy = (cx*sx), (cy*sy)
    return ((cx >= x and cx <= x+w) and (cy >= y and cy <= y+h))
end
addEvent("rpg-ui_buttons:onButtonClick", true)
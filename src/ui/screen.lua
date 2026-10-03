-- База для экранов: кнопки, поля ввода, обработка нажатий (immediate-mode)
local Theme = require "ui.theme"
local utf8  = require "utf8"
local lg    = love.graphics

local Screen = {}
Screen.__index = Screen

function Screen.new()
    return setmetatable({ hits = {}, fields = {}, focus = nil }, Screen)
end

function Screen:update(dt) end
function Screen:draw(w, h) end

function Screen:begin() self.hits = {} end

function Screen:button(x, y, w, h, label, fn, opts)
    opts = opts or {}
    local r = opts.radius or 10
    lg.setColor(opts.fill or Theme.colors.primary)
    lg.rectangle("fill", x, y, w, h, r, r)
    local font = Theme.fonts.normal
    lg.setFont(font)
    lg.setColor(opts.color or Theme.colors.text)
    lg.printf(label, x, y + (h - font:getHeight()) / 2, w, "center")
    self.hits[#self.hits + 1] = { x = x, y = y, w = w, h = h, fn = fn }
end

function Screen:field(x, y, w, h, key, placeholder, secret)
    local C, font = Theme.colors, Theme.fonts.normal
    local value = self.fields[key] or ""
    local focused = self.focus == key
    lg.setColor(C.secondary)
    lg.rectangle("fill", x, y, w, h, 10, 10)
    if focused then
        lg.setColor(C.primary)
        lg.setLineWidth(2)
        lg.rectangle("line", x, y, w, h, 10, 10)
    end
    lg.setFont(font)
    local ty = y + (h - font:getHeight()) / 2
    if value == "" and not focused then
        lg.setColor(C.muted)
        lg.print(placeholder, x + 14, ty)
    else
        local shown = value
        if secret then shown = string.rep("•", utf8.len(value) or #value) end
        local maxw = w - 28
        while #shown > 0 and font:getWidth(shown) > maxw do
            shown = shown:sub(utf8.offset(shown, 2) or (#shown + 1))
        end
        lg.setColor(C.text)
        lg.print(shown, x + 14, ty)
        if focused and (love.timer.getTime() % 1) < 0.6 then
            local cx = x + 14 + font:getWidth(shown) + 1
            lg.rectangle("fill", cx, ty, 2, font:getHeight())
        end
    end
    self.hits[#self.hits + 1] = { x = x, y = y, w = w, h = h, fn = function()
        self.focus = key
        love.keyboard.setTextInput(true)
    end }
end

function Screen:header(w, title, back)
    lg.setColor(Theme.colors.panel)
    lg.rectangle("fill", 0, 0, w, 56)
    self:button(8, 10, 92, 36, "‹ Назад", back, { fill = Theme.colors.secondary })
    lg.setFont(Theme.fonts.title)
    lg.setColor(Theme.colors.text)
    lg.printf(title, 0, 12, w, "center")
end

function Screen:pressed(x, y)
    for i = #self.hits, 1, -1 do
        local h = self.hits[i]
        if x >= h.x and x <= h.x + h.w and y >= h.y and y <= h.y + h.h then
            h.fn()
            return true
        end
    end
    return false
end

function Screen:textinput(t)
    if not self.focus then return end
    local cur = self.fields[self.focus] or ""
    if (utf8.len(cur) or #cur) < (self.maxlen or 500) then
        self.fields[self.focus] = cur .. t
    end
end

function Screen:keypressed(key)
    if key == "return" or key == "kpenter" then
        if self.submit then self:submit() end
    elseif not self.focus then
        return
    elseif key == "backspace" then
        local v = self.fields[self.focus] or ""
        local o = utf8.offset(v, -1)
        if o then self.fields[self.focus] = v:sub(1, o - 1) end
    elseif key == "tab" and self.order then
        local order = self:order()
        for i, k in ipairs(order) do
            if k == self.focus then
                self.focus = order[i % #order + 1]
                break
            end
        end
    elseif key == "v" and love.keyboard.isDown("lctrl", "rctrl") then
        local clip = love.system.getClipboardText() or ""
        self:textinput((clip:gsub("[\r\n]+", " ")))
    end
end

return Screen

local App     = require "app"
local Theme   = require "ui.theme"
local Screen  = require "ui.screen"
local Message = require "chat.message"
local Bot     = require "chat.bot"
local Panel   = require "admin.panel"

local lg = love.graphics
local S = Screen.new()
local bots = { zylobot = Bot.zylo() }

local function trim(s) return (s:match("^%s*(.-)%s*$")) end

function S:enter()
    self.fields    = { msg = "" }
    self.focus     = "msg"
    self.scroll    = 0          -- на сколько прокручено вверх от конца
    self.maxscroll = 0
    self.active    = 1
    self.channels  = App.store.data.channels
    love.keyboard.setTextInput(true)
end

function S:submit()
    local text = trim(self.fields.msg or "")
    if text == "" then return end
    local store, user = App.store, App.user
    local ch = self.channels[self.active]
    ch:add(Message:new(store:nextid("msg"), user.username, text))
    local bot = ch.bot and bots[ch.bot]
    if bot then
        local reply = bot:on_message({ text = text, author = user.username }, { user = user })
        if reply then ch:add(Message:new(store:nextid("msg"), bot.name, reply)) end
    end
    store:save()
    self.fields.msg = ""
    self.scroll = 0
end

function S:drag(dy)  self.scroll = self.scroll + dy end
function S:wheel(dy) self.scroll = self.scroll + dy * 40 end

function S:draw(w, h)
    self:begin()
    local C, F = Theme.colors, Theme.fonts
    local user = App.user

    -- верхняя панель
    lg.setColor(C.panel)
    lg.rectangle("fill", 0, 0, w, 56)
    lg.setFont(F.title)
    lg.setColor(C.text)
    lg.print("ZYLO", 16, 12)
    local bx = w - 10
    local function topbtn(label, bw, fn)
        bx = bx - bw
        self:button(bx, 10, bw, 36, label, fn, { fill = C.secondary })
        bx = bx - 6
    end
    topbtn("Выход", 70, function() App.logout() end)
    if Panel.is_admin(user) then topbtn("Админ", 70, function() App.go("admin") end) end
    topbtn("VPN", 56, function() App.go("vpn") end)

    -- вкладки каналов
    local n = #self.channels
    local tw = w / n
    for i, c in ipairs(self.channels) do
        self:button((i - 1) * tw, 56, tw, 40, c.name,
            function() self.active = i; self.scroll = 0 end,
            { fill = (i == self.active) and C.primary or C.panel, radius = 0 })
    end

    -- на телефоне клавиатура перекрывает низ экрана, поэтому поле ввода сверху
    local os_name = love.system.getOS()
    local mobile = os_name == "Android" or os_name == "iOS"
    local inputH = 60
    local inputY = mobile and 96 or (h - inputH)
    local areaTop = mobile and (96 + inputH) or 96
    local areaBottom = mobile and h or (h - inputH)

    -- сообщения
    local ch = self.channels[self.active]
    local font, small = F.normal, F.small
    local lh = font:getHeight()
    local maxw = w * 0.74
    local items, total = {}, 0
    for _, m in ipairs(ch.msgs) do
        local tw2, lines = font:getWrap(m.text or "", maxw - 24)
        local bw = math.max(tw2, small:getWidth(m.author or "")) + 24
        local bh = #lines * lh + small:getHeight() + 18
        items[#items + 1] = { m = m, bw = bw, bh = bh }
        total = total + bh + 8
    end

    local viewH = areaBottom - areaTop
    self.maxscroll = math.max(0, total - viewH + 8)
    self.scroll = math.max(0, math.min(self.scroll, self.maxscroll))
    local y = (total + 8 > viewH) and (areaBottom - total - 4 + self.scroll) or (areaTop + 8)

    lg.setScissor(0, areaTop * Theme.scale, w * Theme.scale, viewH * Theme.scale)
    if #items == 0 then
        lg.setFont(small)
        lg.setColor(C.muted)
        lg.printf("Сообщений пока нет", 0, areaTop + 20, w, "center")
    end
    for _, it in ipairs(items) do
        if y + it.bh > areaTop and y < areaBottom then
            local mine = it.m.author == user.username
            local x = mine and (w - it.bw - 12) or 12
            lg.setColor(mine and C.bubble_me or C.bubble_other)
            lg.rectangle("fill", x, y, it.bw, it.bh, 12, 12)
            lg.setFont(small)
            lg.setColor(mine and C.text or C.primary)
            lg.print(it.m.author or "", x + 12, y + 6)
            lg.setFont(font)
            lg.setColor(C.text)
            lg.printf(it.m.text or "", x + 12, y + 8 + small:getHeight(), it.bw - 24, "left")
        end
        y = y + it.bh + 8
    end
    lg.setScissor()

    -- поле ввода
    lg.setColor(C.panel)
    lg.rectangle("fill", 0, inputY, w, inputH)
    self:field(10, inputY + 8, w - 90, 44, "msg", "Сообщение…")
    self:button(w - 74, inputY + 8, 64, 44, "Отпр.", function() self:submit() end)
end

return S

local App        = require "app"
local Theme      = require "ui.theme"
local Screen     = require "ui.screen"
local Panel      = require "admin.panel"
local Moderation = require "admin.moderation"

local lg = love.graphics
local S = Screen.new()

function S:enter()
    self.fields, self.focus, self.message = {}, nil, nil
    self.scroll, self.maxscroll = 0, 0
    if not Panel.is_admin(App.user) then App.go("chat") end
end

function S:back() App.go("chat") end
function S:drag(dy)  self.scroll = self.scroll - dy end
function S:wheel(dy) self.scroll = self.scroll - dy * 40 end

function S:draw(w, h)
    self:begin()
    local C, F = Theme.colors, Theme.fonts
    local users = Panel.list_users(App.store)
    local rowH, top = 60, 90

    self.maxscroll = math.max(0, #users * rowH - (h - top) + 40)
    self.scroll = math.max(0, math.min(self.scroll, self.maxscroll))

    lg.setScissor(0, 56 * Theme.scale, w * Theme.scale, (h - 56) * Theme.scale)
    local y = top - self.scroll
    for _, u in ipairs(users) do
        if y + rowH > 56 and y < h then
            lg.setColor(C.panel)
            lg.rectangle("fill", 12, y, w - 24, rowH - 8, 10, 10)
            lg.setFont(F.normal)
            lg.setColor(C.text)
            lg.print(u.username, 24, y + 8)
            lg.setFont(F.small)
            if u.is_admin then
                lg.setColor(C.primary); lg.print("админ", 24, y + 30)
            elseif u.banned then
                lg.setColor(C.accent); lg.print("заблокирован", 24, y + 30)
            end
            if not u.is_admin then
                local label = u.banned and "Разбанить" or "Заблокировать"
                self:button(w - 12 - 140, y + 6, 130, 36, label, function()
                    local ok, err
                    if u.banned then
                        ok, err = Moderation.unban(App.store, App.user, u.id)
                    else
                        ok, err = Moderation.ban(App.store, App.user, u.id)
                    end
                    self.message = (not ok) and err or nil
                end, { fill = u.banned and C.primary or C.accent })
            end
        end
        y = y + rowH
    end
    lg.setScissor()

    -- шапка поверх списка
    self:header(w, "Админ-панель", function() self:back() end)
    if self.message then
        lg.setFont(F.small)
        lg.setColor(C.accent)
        lg.printf(self.message, 12, 62, w - 24, "center")
    end
end

return S

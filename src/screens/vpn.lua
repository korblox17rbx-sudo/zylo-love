local App    = require "app"
local Theme  = require "ui.theme"
local Screen = require "ui.screen"
local vpn    = require "vpn.core"

local lg = love.graphics
local S = Screen.new()

function S:enter()
    self.fields, self.focus, self.message = {}, nil, nil
end

function S:back() App.go("chat") end

function S:draw(w, h)
    self:begin()
    local C, F = Theme.colors, Theme.fonts
    self:header(w, "VPN", function() self:back() end)

    lg.setFont(F.normal)
    lg.setColor(C.text)
    lg.printf(vpn.status(), 20, 76, w - 40, "left")

    local avail = vpn.available()
    local y = 116
    if not avail then
        lg.setFont(F.small)
        lg.setColor(C.muted)
        lg.printf("VPN работает только на Linux с WireGuard (wg-quick) и правами root. " ..
                  "На телефоне нужен системный VpnService — это пока не реализовано.",
                  20, y, w - 40, "left")
        y = y + 70
    end
    for _, r in ipairs(vpn.regions) do
        local active = vpn.active and vpn.active:find("zylo%-" .. r.code:lower() .. "%.conf")
        self:button(20, y, w - 40, 46, r.name .. " (" .. r.code .. ")", function()
            local ok, err = vpn.connect(r.code)
            self.message = (not ok) and err or nil
        end, { fill = active and C.primary or C.secondary })
        y = y + 54
    end
    self:button(20, y + 6, w - 40, 46, "Отключить", function()
        vpn.disconnect()
        self.message = nil
    end, { fill = C.panel, color = C.accent })

    if self.message then
        lg.setFont(F.small)
        lg.setColor(C.accent)
        lg.printf(self.message, 20, y + 64, w - 40, "left")
    end
end

return S

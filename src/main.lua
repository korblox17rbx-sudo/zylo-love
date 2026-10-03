local App   = require "app"
local Theme = require "ui.theme"
local Store = require "core.store"

local VW = 420      -- виртуальная ширина интерфейса
local scale = 0

local fs = {
    read  = function(name) return (love.filesystem.read(name)) end,
    write = function(name, data) return love.filesystem.write(name, data) end,
}

local function relayout()
    local s = math.max(0.5, love.graphics.getWidth() / VW)
    if math.abs(s - scale) > 0.02 then
        scale = s
        Theme.load(scale)
    end
end

function love.load()
    love.keyboard.setKeyRepeat(true)
    Theme.apply()
    relayout()
    App.store = Store.new(fs, "zylo.dat"):load()
    App.screens.splash = require "screens.splash"
    App.screens.auth   = require "screens.auth"
    App.screens.chat   = require "screens.chat"
    App.screens.vpn    = require "screens.vpn"
    App.screens.admin  = require "screens.admin"
    App.go("splash")
end

function love.resize() relayout() end

function love.update(dt)
    if App.current then App.current:update(dt) end
end

function love.draw()
    love.graphics.push()
    love.graphics.scale(scale, scale)
    App.current:draw(VW, love.graphics.getHeight() / scale)
    love.graphics.pop()
end

function love.mousepressed(x, y, button)
    if button == 1 then App.current:pressed(x / scale, y / scale) end
end

function love.mousemoved(_, _, _, dy)
    local c = App.current
    if c and c.drag and love.mouse.isDown(1) then c:drag(dy / scale) end
end

function love.wheelmoved(_, dy)
    local c = App.current
    if c and c.wheel then c:wheel(dy) end
end

function love.textinput(t)
    if App.current then App.current:textinput(t) end
end

function love.keypressed(key)
    local c = App.current
    if not c then return end
    if key == "escape" and c.back then c:back(); return end
    c:keypressed(key)
end

function love.quit()
    if App.store then App.store:save() end
end

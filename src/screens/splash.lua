local App    = require "app"
local Loader = require "ui.loader"
local Screen = require "ui.screen"

local S = Screen.new()

function S:enter() Loader.show() end
function S:update(dt)
    Loader.update(dt)
    if Loader.done() then App.resume() end
end
function S:draw(w, h) Loader.draw(w, h) end
function S:pressed() Loader.skip() end

return S

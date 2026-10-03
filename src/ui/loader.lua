-- Анимированная заставка: плавное появление, пауза, затухание
local lg = love.graphics

local Loader = {}

local FADE_IN, HOLD, FADE_OUT = 0.8, 1.0, 0.5
local TOTAL = FADE_IN + HOLD + FADE_OUT
local BG = {28 / 255, 32 / 255, 43 / 255}   -- цвет краёв картинки
local img, t = nil, 0

function Loader.show()
    t = 0
    img = img or lg.newImage("assets/splash.png")
    img:setFilter("linear", "linear")
end

function Loader.update(dt) t = t + dt end
function Loader.done() return t >= TOTAL end
function Loader.skip() t = TOTAL end

local function alpha()
    if t < FADE_IN then return t / FADE_IN end
    if t < FADE_IN + HOLD then return 1 end
    return math.max(0, 1 - (t - FADE_IN - HOLD) / FADE_OUT)
end

function Loader.draw(w, h)
    lg.setColor(BG)
    lg.rectangle("fill", 0, 0, w, h)
    local iw, ih = img:getDimensions()
    local s = w / iw
    lg.setColor(1, 1, 1, alpha())
    lg.draw(img, 0, (h - ih * s) / 2, 0, s, s)
    lg.setColor(1, 1, 1, 1)
end

return Loader

local Theme = {}

Theme.colors = {
    bg           = {0.07, 0.07, 0.08},
    panel        = {0.10, 0.11, 0.14},
    primary      = {0.05, 0.62, 0.72},
    accent       = {0.93, 0.26, 0.21},
    text         = {0.95, 0.95, 0.96},
    muted        = {0.55, 0.57, 0.62},
    secondary    = {0.18, 0.18, 0.20},
    bubble_me    = {0.05, 0.45, 0.55},
    bubble_other = {0.16, 0.17, 0.21},
}

Theme.fonts  = {}
Theme.scale  = 1
Theme.images = {}

-- шрифт DejaVu содержит кириллицу (встроенный шрифт LÖVE 11 — нет)
function Theme.load(scale)
    Theme.scale = scale
    local path = "assets/fonts/DejaVuSans.ttf"
    local dpi = scale * love.graphics.getDPIScale()
    local function f(size) return love.graphics.newFont(path, size, "normal", dpi) end
    Theme.fonts.small  = f(13)
    Theme.fonts.normal = f(16)
    Theme.fonts.title  = f(26)
end

function Theme.image(path)
    if not Theme.images[path] then
        local img = love.graphics.newImage(path)
        img:setFilter("linear", "linear")
        Theme.images[path] = img
    end
    return Theme.images[path]
end

function Theme.apply()
    love.graphics.setBackgroundColor(Theme.colors.bg)
end

return Theme

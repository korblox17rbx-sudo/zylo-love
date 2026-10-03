function love.conf(t)
    t.identity = "zylo"
    t.version  = "11.4"
    t.window.title     = "ZYLO"
    t.window.icon      = "assets/icon.png"
    t.window.width     = 420
    t.window.height    = 780
    t.window.resizable = true
    t.window.minwidth  = 320
    t.window.minheight = 480
    t.modules.joystick = false
    t.modules.physics  = false
    t.modules.video    = false
end

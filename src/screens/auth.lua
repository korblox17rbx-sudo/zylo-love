local App      = require "app"
local Theme    = require "ui.theme"
local Screen   = require "ui.screen"
local Login    = require "auth.login"
local Register = require "auth.register"

local lg = love.graphics
local S = Screen.new()

function S:enter()
    self.fields  = {}
    self.focus   = nil
    self.message = nil
    self.mode    = "login"
end

function S:order()
    if self.mode == "login" then return { "username", "password" } end
    return { "username", "password", "email", "phone" }
end

function S:submit()
    local f = self.fields
    local ok, res
    if self.mode == "login" then
        ok, res = Login.login(App.store, f.username, f.password)
    else
        ok, res = Register.register(App.store, {
            username = f.username, password = f.password,
            email = f.email, phone = f.phone,
        })
    end
    if ok then
        self.message = nil
        App.login(res)
    else
        self.message = res
    end
end

function S:draw(w, h)
    self:begin()
    local C, F = Theme.colors, Theme.fonts
    local img = Theme.image("assets/icon.png")
    local size = 120
    lg.setColor(1, 1, 1, 1)
    lg.draw(img, (w - size) / 2, 30, 0, size / img:getWidth(), size / img:getHeight())

    lg.setFont(F.normal)
    lg.setColor(C.muted)
    lg.printf(self.mode == "login" and "Вход в аккаунт" or "Регистрация", 0, 160, w, "center")

    local x, fw, y = 30, w - 60, 195
    self:field(x, y, fw, 48, "username", "Имя пользователя (латиница)"); y = y + 58
    self:field(x, y, fw, 48, "password", "Пароль (от 6 символов)", true); y = y + 58
    if self.mode == "register" then
        self:field(x, y, fw, 48, "email", "Почта (необязательно)"); y = y + 58
        self:field(x, y, fw, 48, "phone", "Телефон (необязательно)"); y = y + 58
    end

    if self.message then
        lg.setFont(F.small)
        lg.setColor(C.accent)
        lg.printf(self.message, x, y, fw, "center")
    end
    y = y + 36

    self:button(x, y, fw, 50,
        self.mode == "login" and "Войти" or "Создать аккаунт",
        function() self:submit() end)
    y = y + 62
    self:button(x, y, fw, 44,
        self.mode == "login" and "Нет аккаунта? Регистрация" or "Уже есть аккаунт? Войти",
        function()
            self.mode = self.mode == "login" and "register" or "login"
            self.message = nil
        end,
        { fill = C.panel, color = C.primary })

    if self.mode == "register" and #App.store.data.users == 0 then
        lg.setFont(F.small)
        lg.setColor(C.muted)
        lg.printf("Первый созданный аккаунт станет администратором.", x, y + 56, fw, "center")
    end
end

return S

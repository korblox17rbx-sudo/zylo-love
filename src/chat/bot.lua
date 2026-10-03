local Bot = {}
Bot.__index = Bot

function Bot:new(name, handler)
    return setmetatable({ name = name, handler = handler }, self)
end

function Bot:on_message(msg, ctx)
    if self.handler then return self.handler(msg, ctx or {}) end
end

-- Встроенный бот ZyloBot
function Bot.zylo()
    return Bot:new("ZyloBot", function(msg, ctx)
        local text = msg.text or ""
        local cmd, rest = text:match("^/(%w+)%s*(.*)$")
        if cmd == "start" or cmd == "help" then
            return "Команды: /help, /ping, /time, /me, /echo текст"
        elseif cmd == "ping" then
            return "pong"
        elseif cmd == "time" then
            return os.date("%Y-%m-%d %H:%M:%S")
        elseif cmd == "me" then
            return "Ты — " .. ((ctx.user and ctx.user.username) or "аноним")
        elseif cmd == "echo" then
            return rest ~= "" and rest or "Нечего повторять"
        end
        return "Не понял. Напиши /help"
    end)
end

return Bot

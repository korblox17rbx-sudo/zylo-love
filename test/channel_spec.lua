local Channel = require "chat.channel"
local Bot = require "chat.bot"

describe("channel", function()
    it("пересылает копию сообщения", function()
        local a, b = Channel:new(1, "A"), Channel:new(2, "B")
        a:add({ id = 1, author = "x", text = "hi" })
        assert.is_true(a:forward(1, b, 7))
        assert.equals(7, b.msgs[1].id)
        assert.equals("A", b.msgs[1].forwarded_from)
        assert.is_false(a:forward(99, b))
    end)

    it("ограничивает историю", function()
        local c = Channel:new(1, "A")
        for i = 1, Channel.MAX_MESSAGES + 10 do c:add({ id = i, text = "m" }) end
        assert.equals(Channel.MAX_MESSAGES, #c.msgs)
        assert.equals(11, c.msgs[1].id)
    end)
end)

describe("bot", function()
    local bot = Bot.zylo()
    it("отвечает на команды", function()
        assert.equals("pong", bot:on_message({ text = "/ping" }))
        assert.equals("abc", bot:on_message({ text = "/echo abc" }))
        assert.is_truthy(bot:on_message({ text = "/me" }, { user = { username = "bob" } }):find("bob"))
        assert.is_truthy(bot:on_message({ text = "что?" }):find("/help"))
    end)
end)

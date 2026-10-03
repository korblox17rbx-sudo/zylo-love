local Channel = {}
Channel.__index = Channel

Channel.MAX_MESSAGES = 500

function Channel:new(id, name, private, bot)
    return setmetatable({
        id      = id,
        name    = name,
        private = private or false,
        bot     = bot,
        msgs    = {}
    }, self)
end

function Channel.restore(data)
    data.msgs = data.msgs or {}
    return setmetatable(data, Channel)
end

function Channel:add(msg)
    self.msgs[#self.msgs + 1] = msg
    while #self.msgs > Channel.MAX_MESSAGES do table.remove(self.msgs, 1) end
    return msg
end

function Channel:find(msg_id)
    for _, m in ipairs(self.msgs) do
        if m.id == msg_id then return m end
    end
end

function Channel:forward(msg_id, target, new_id)
    local m = self:find(msg_id)
    if not m then return false end
    target:add({
        id             = new_id or m.id,
        author         = m.author,
        text           = m.text,
        timestamp      = m.timestamp,
        forwarded_from = self.name,
    })
    return true
end

return Channel

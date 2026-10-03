local Message = {}
Message.__index = Message

function Message:new(id, author, text, ts)
    return setmetatable({
        id        = id,
        author    = author,
        text      = text,
        timestamp = ts or os.time()
    }, self)
end

return Message

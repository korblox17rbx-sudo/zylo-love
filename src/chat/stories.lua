local Stories = {}
Stories.__index = Stories

function Stories:new() return setmetatable({items = {}}, self) end

function Stories:add(user_id, media_path, ttl)
    table.insert(self.items, {
        user_id = user_id,
        media   = media_path,
        expires = os.time() + (ttl or 86400)   -- 24 ч
    })
end

function Stories:clean()
    local now = os.time()
    for i = #self.items, 1, -1 do
        if self.items[i].expires < now then table.remove(self.items, i) end
    end
end

return Stories

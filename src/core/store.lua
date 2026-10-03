-- Локальное хранилище (пользователи, каналы, сообщения) в одном файле.
-- fs = { read = function(name) -> string|nil, write = function(name, data) -> bool }
local Channel = require "chat.channel"

local Store = {}
Store.__index = Store

local function serialize(v)
    local t = type(v)
    if t == "string" then
        return string.format("%q", v)
    elseif t == "number" or t == "boolean" then
        return tostring(v)
    elseif t == "table" then
        local parts = {}
        for k, val in pairs(v) do
            parts[#parts + 1] = "[" .. serialize(k) .. "]=" .. serialize(val)
        end
        return "{" .. table.concat(parts, ",") .. "}"
    end
    error("cannot serialize " .. t)
end

local function parse(src)
    local fn, err
    local setfenv_ = rawget(_G, "setfenv")
    if setfenv_ then
        fn, err = loadstring("return " .. src)
        if fn then setfenv_(fn, {}) end
    else
        fn, err = load("return " .. src, "store", "t", {})
    end
    if not fn then return nil, err end
    local ok, res = pcall(fn)
    if not ok then return nil, res end
    return res
end

function Store.new(fs, filename)
    return setmetatable({ fs = fs, filename = filename or "zylo.dat", data = nil }, Store)
end

function Store:load()
    local raw = self.fs.read(self.filename)
    local data
    if raw and raw ~= "" then
        data = parse(raw)
        if type(data) ~= "table" then
            self.fs.write(self.filename .. ".corrupt", raw)
            data = nil
        end
    end
    data = data or {}
    data.seq      = data.seq or {}
    data.users    = data.users or {}
    data.channels = data.channels or {}
    for i, c in ipairs(data.channels) do
        data.channels[i] = Channel.restore(c)
    end
    self.data = data
    if #data.channels == 0 then self:seed() end
    return self
end

function Store:seed()
    local function add(name, private, bot)
        table.insert(self.data.channels,
            Channel:new(self:nextid("channel"), name, private, bot))
    end
    add("Общий", false)
    add("Избранное", true)
    add("ZyloBot", true, "zylobot")
    self:save()
end

function Store:save()
    return self.fs.write(self.filename, serialize(self.data))
end

function Store:nextid(kind)
    local n = (self.data.seq[kind] or 0) + 1
    self.data.seq[kind] = n
    return n
end

function Store:find_user(username)
    local needle = tostring(username):lower()
    for _, u in ipairs(self.data.users) do
        if u.username:lower() == needle then return u end
    end
end

function Store:user_by_id(id)
    for _, u in ipairs(self.data.users) do
        if u.id == id then return u end
    end
end

function Store:add_user(rec)
    table.insert(self.data.users, rec)
    self:save()
    return rec
end

function Store:session_user()
    local id = self.data.session
    local u = id and self:user_by_id(id)
    if u and not u.banned then return u end
end

return Store

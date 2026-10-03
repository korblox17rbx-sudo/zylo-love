-- Пароли: соль + 20 000 итераций SHA-256 (love.data.hash).
-- bcrypt/argon2 в чистом LÖVE недоступны, это разумный минимум.
local Crypto = {}

Crypto.rounds  = 20000
Crypto.backend = nil   -- для тестов: function(str) -> hex

local function hex(s)
    return (s:gsub(".", function(c) return string.format("%02x", c:byte()) end))
end

function Crypto.sha256(s)
    if Crypto.backend then return Crypto.backend(s) end
    return hex(love.data.hash("sha256", s))
end

function Crypto.salt()
    local rnd = (love and love.math and love.math.random) or math.random
    local t = {}
    for i = 1, 16 do t[i] = string.format("%02x", rnd(0, 255)) end
    return table.concat(t)
end

function Crypto.hash_password(password, salt)
    local h = Crypto.sha256(salt .. password)
    for _ = 2, Crypto.rounds do
        h = Crypto.sha256(h .. salt .. password)
    end
    return h
end

function Crypto.verify(password, salt, expected)
    local got = Crypto.hash_password(password, salt)
    if #got ~= #expected then return false end
    local diff = 0
    for i = 1, #got do
        if got:byte(i) ~= expected:byte(i) then diff = diff + 1 end
    end
    return diff == 0
end

return Crypto

local Crypto = require "core.crypto"

local H = {}

function H.memfs()
    local files = {}
    return {
        files = files,
        read  = function(n) return files[n] end,
        write = function(n, d) files[n] = d; return true end,
    }
end

-- Лёгкая подмена SHA-256 для тестов (не криптографическая)
local function fake(s)
    local h1, h2 = 5381, 7
    for i = 1, #s do
        local b = s:byte(i)
        h1 = (h1 * 33 + b) % 4294967296
        h2 = (h2 * 131 + b) % 4294967291
    end
    return string.format("%08x%08x", h1, h2)
end

function H.fast_crypto()
    Crypto.backend = fake
    Crypto.rounds = 10
end

function H.new_store()
    H.fast_crypto()
    local Store = require "core.store"
    local fs = H.memfs()
    return Store.new(fs, "t.dat"):load(), fs
end

return H

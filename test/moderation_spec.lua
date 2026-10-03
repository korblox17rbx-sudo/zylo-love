local H = require "helpers"
local Register = require "auth.register"
local Moderation = require "admin.moderation"

describe("moderation", function()
    it("админ банит и разбанивает, обычный пользователь не может", function()
        local s = H.new_store()
        local _, admin = Register.register(s, { username = "admin1", password = "secret1" })
        local _, bob   = Register.register(s, { username = "bob", password = "secret2" })
        local _, eve   = Register.register(s, { username = "eve", password = "secret3" })

        assert.is_false((Moderation.ban(s, bob, eve.id)))
        assert.is_true((Moderation.ban(s, admin, bob.id)))
        assert.is_true(bob.banned)
        assert.is_true((Moderation.unban(s, admin, bob.id)))
        assert.is_false(bob.banned)
        assert.is_false((Moderation.ban(s, admin, admin.id)))
        assert.is_false((Moderation.ban(s, admin, 999)))
    end)
end)

local H = require "helpers"
local Register = require "auth.register"
local Login = require "auth.login"

describe("auth", function()
    local s
    before_each(function() s = H.new_store() end)

    it("регистрирует, первый пользователь — админ", function()
        local ok, u1 = Register.register(s, { username = "alice", password = "secret1" })
        assert.is_true(ok)
        assert.is_true(u1.is_admin)
        local ok2, u2 = Register.register(s, { username = "bob", password = "secret2" })
        assert.is_true(ok2)
        assert.is_false(u2.is_admin)
    end)

    it("пароль хранится с солью, не в открытом виде", function()
        local _, u = Register.register(s, { username = "alice", password = "secret1" })
        assert.is_not.equals("secret1", u.password_hash)
        assert.is_truthy(u.salt)
        local _, u2 = Register.register(s, { username = "bob", password = "secret1" })
        assert.is_not.equals(u.password_hash, u2.password_hash)
    end)

    it("отклоняет плохие данные и дубликаты", function()
        assert.is_false((Register.register(s, { username = "a", password = "secret1" })))
        assert.is_false((Register.register(s, { username = "bad name", password = "secret1" })))
        assert.is_false((Register.register(s, { username = "alice", password = "123" })))
        Register.register(s, { username = "alice", password = "secret1" })
        assert.is_false((Register.register(s, { username = "ALICE", password = "secret1" })))
    end)

    it("логин: верный, неверный, заблокированный", function()
        local _, u = Register.register(s, { username = "alice", password = "secret1" })
        assert.is_true((Login.login(s, "Alice", "secret1")))
        assert.is_false((Login.login(s, "alice", "wrong")))
        assert.is_false((Login.login(s, "nobody", "secret1")))
        u.banned = true
        local ok, err = Login.login(s, "alice", "secret1")
        assert.is_false(ok)
        assert.equals("Аккаунт заблокирован", err)
    end)
end)

local Crypto = require "core.crypto"

local M = {}

function M.login(store, username, password)
    local user = store:find_user(username or "")
    if not user or not Crypto.verify(password or "", user.salt, user.password_hash) then
        return false, "Неверное имя или пароль"
    end
    if user.banned then
        return false, "Аккаунт заблокирован"
    end
    return true, user
end

return M

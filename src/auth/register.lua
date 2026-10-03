local Crypto = require "core.crypto"

local M = {}

local function trim(s) return (tostring(s or ""):match("^%s*(.-)%s*$")) end

function M.register(store, info)
    local username = trim(info.username)
    local password = tostring(info.password or "")
    if #username < 3 or #username > 24 or not username:match("^[%w_]+$") then
        return false, "Имя: 3–24 символа, латиница, цифры и _"
    end
    if #password < 6 then
        return false, "Пароль должен быть не короче 6 символов"
    end
    if store:find_user(username) then
        return false, "Это имя уже занято"
    end
    local salt = Crypto.salt()
    local user = {
        id            = store:nextid("user"),
        username      = username,
        email         = trim(info.email),
        phone         = trim(info.phone),
        salt          = salt,
        password_hash = Crypto.hash_password(password, salt),
        is_admin      = #store.data.users == 0,  -- первый аккаунт = администратор
        banned        = false,
        created       = os.time(),
    }
    store:add_user(user)
    return true, user
end

return M

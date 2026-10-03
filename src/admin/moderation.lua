local Panel = require "admin.panel"

local Moderation = {}

local function set_ban(store, actor, target_id, value)
    if not Panel.is_admin(actor) then return false, "Недостаточно прав" end
    local target = store:user_by_id(target_id)
    if not target then return false, "Пользователь не найден" end
    if target.is_admin then return false, "Нельзя блокировать администратора" end
    target.banned = value
    store:save()
    return true
end

function Moderation.ban(store, actor, target_id)   return set_ban(store, actor, target_id, true)  end
function Moderation.unban(store, actor, target_id) return set_ban(store, actor, target_id, false) end

return Moderation

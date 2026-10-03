-- VPN через wg-quick. Работает только на Linux с WireGuard и root-правами.
-- Конфиги: /etc/wireguard/zylo-<код>.conf (создаёшь сам).
local Regions = require "vpn.regions"

local vpn = { regions = Regions, active = nil }

local function ok(res) return res == true or res == 0 end

-- заменяемые в тестах
function vpn.run(cmd) return ok(os.execute(cmd)) end
function vpn.platform()
    return (love and love.system and love.system.getOS()) or "unknown"
end

function vpn.find(code)
    code = type(code) == "string" and code:upper() or ""
    for _, r in ipairs(Regions) do
        if r.code == code then return r end
    end
end

-- путь строится только из белого списка регионов => инъекция невозможна
function vpn.config_path(code)
    local r = vpn.find(code)
    if not r then return nil end
    return string.format("/etc/wireguard/zylo-%s.conf", r.code:lower())
end

function vpn.available()
    return vpn.platform() == "Linux" and vpn.run("command -v wg-quick >/dev/null 2>&1")
end

function vpn.disconnect()
    if vpn.active then
        vpn.run(string.format("wg-quick down '%s' >/dev/null 2>&1", vpn.active))
        vpn.active = nil
    end
    return true
end

function vpn.connect(code)
    local path = vpn.config_path(code)
    if not path then return false, "Неизвестный регион" end
    if not vpn.available() then
        return false, "VPN доступен только на Linux с установленным wg-quick"
    end
    vpn.disconnect()
    if not vpn.run(string.format("wg-quick up '%s' >/dev/null 2>&1", path)) then
        return false, "Не удалось поднять " .. path .. " (нужны root и файл конфигурации)"
    end
    vpn.active = path
    return true
end

function vpn.status()
    if vpn.active then
        local r = vpn.active:match("zylo%-(%a+)%.conf")
        local reg = r and vpn.find(r)
        return "Подключено: " .. (reg and reg.name or vpn.active)
    end
    return "Отключено"
end

return vpn

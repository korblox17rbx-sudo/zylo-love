local vpn = require "vpn.core"

describe("vpn", function()
    local cmds
    before_each(function()
        cmds = {}
        vpn.active = nil
        vpn.platform = function() return "Linux" end
        vpn.run = function(cmd) cmds[#cmds + 1] = cmd; return true end
    end)

    it("не принимает неизвестный регион (защита от инъекции)", function()
        assert.is_nil(vpn.config_path("DE; rm -rf /"))
        local ok = vpn.connect("DE; rm -rf /")
        assert.is_false(ok)
        assert.equals(0, #cmds)
    end)

    it("подключается к известному региону", function()
        assert.is_true((vpn.connect("de")))
        assert.equals("/etc/wireguard/zylo-de.conf", vpn.active)
        assert.is_truthy(vpn.status():find("Германия"))
        vpn.disconnect()
        assert.equals("Отключено", vpn.status())
    end)

    it("недоступен вне Linux", function()
        vpn.platform = function() return "Android" end
        local ok = vpn.connect("DE")
        assert.is_false(ok)
    end)
end)

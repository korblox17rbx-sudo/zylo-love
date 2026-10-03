local H = require "helpers"
local Store = require "core.store"

describe("store", function()
    it("создаёт стандартные каналы", function()
        local s = H.new_store()
        assert.equals(3, #s.data.channels)
        assert.equals("zylobot", s.data.channels[3].bot)
    end)

    it("сохраняет и загружает данные (в т.ч. юникод и переводы строк)", function()
        local s, fs = H.new_store()
        s.data.channels[1]:add({ id = s:nextid("msg"), author = "a", text = "Привет\n\"мир\"" })
        s:save()
        local s2 = Store.new(fs, "t.dat"):load()
        assert.equals("Привет\n\"мир\"", s2.data.channels[1].msgs[1].text)
        assert.is_function(s2.data.channels[1].add)
    end)

    it("повреждённый файл не роняет загрузку", function()
        local fs = H.memfs()
        fs.files["t.dat"] = "{{{ not lua"
        local s = Store.new(fs, "t.dat"):load()
        assert.equals(3, #s.data.channels)
        assert.is_truthy(fs.files["t.dat.corrupt"])
    end)

    it("не выполняет произвольный код из файла", function()
        local fs = H.memfs()
        fs.files["t.dat"] = "os.exit(1)"
        local s = Store.new(fs, "t.dat"):load()
        assert.equals(3, #s.data.channels)
    end)
end)

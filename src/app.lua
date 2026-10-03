-- Общее состояние приложения и переключение экранов
local App = { screens = {}, current = nil, user = nil, store = nil }

function App.go(name, ...)
    local s = assert(App.screens[name], "unknown screen: " .. tostring(name))
    App.current = s
    if s.enter then s:enter(...) end
end

function App.resume()
    local u = App.store:session_user()
    if u then
        App.user = u
        App.go("chat")
    else
        App.go("auth")
    end
end

function App.login(user)
    App.user = user
    App.store.data.session = user.id
    App.store:save()
    App.go("chat")
end

function App.logout()
    App.user = nil
    App.store.data.session = nil
    App.store:save()
    App.go("auth")
end

return App

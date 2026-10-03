local Panel = {}

function Panel.is_admin(user)
    return user ~= nil and user.is_admin == true
end

function Panel.list_users(store)
    return store.data.users
end

return Panel

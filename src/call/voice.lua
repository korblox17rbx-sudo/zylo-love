-- ЗАГЛУШКА: настоящие звонки требуют сетевой части (WebRTC) и сервера.
local VoiceCall = { active = false, peer = nil }
VoiceCall.__index = VoiceCall

function VoiceCall:start(peer_id)
    self.active, self.peer = true, peer_id
    print("[Voice] Звонок →", peer_id)
end

function VoiceCall:stop()
    self.active, self.peer = false, nil
    print("[Voice] Звонок завершён")
end

return VoiceCall

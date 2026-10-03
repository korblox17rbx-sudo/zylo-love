-- ЗАГЛУШКА: настоящие звонки требуют сетевой части (WebRTC) и сервера.
local VideoCall = { active = false, peer = nil }
VideoCall.__index = VideoCall

function VideoCall:start(peer_id)
    self.active, self.peer = true, peer_id
    print("[Video] Звонок →", peer_id)
end

function VideoCall:stop()
    self.active, self.peer = false, nil
    print("[Video] Звонок завершён")
end

return VideoCall

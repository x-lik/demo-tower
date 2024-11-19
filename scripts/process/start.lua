local process = Process("start")

function process:onStart()
    
    -- 调试自动去除迷雾
    fog.enable(not LK_DEBUG)
    fog.maskEnable(not LK_DEBUG)
    
    Player(1):worth("=", { gold = 4 })
    self:next("test1")

end

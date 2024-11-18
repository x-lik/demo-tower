local process = Process("test1")

function process:onStart()
    
    sound.bgm("Sound\\Music\\mp3Music\\ArthasTheme.mp3")
    
    local bubble = self:bubble()
    
    --- 为玩家生成建造者
    local builderPoints = {
        { -512, 512, 0 },
        { 512, 512, 180 },
        { -512, -512, 0 },
        { 512, -512, 180 },
    }
    for i = 1, 4, 1 do
        local p = Player(i)
        if (p:isPlaying()) then
            local u = Unit(p, TPL_UNIT.Builder, builderPoints[i][1], builderPoints[i][2], builderPoints[i][3])
            superposition.plus(u, "invulnerable") -- 设置无敌
            bubble["builder" .. i] = u
        end
    end
    ---@param evtData eventOnKeyboardRelease
    keyboard.onRelease(keyboard.code["F1"], "builder", function(evtData)
        local idx = evtData.triggerPlayer:index()
        ---@type Unit
        local u = bubble["builder" .. idx]
        if u:isAlive() then
            camera.to(u:x(), u:y(), 0)
            evtData.triggerPlayer:select(u)
        end
    end)
    
    --- 敌人
    local enemyTeam = Team("敌方", 13, true, true)
    enemyTeam:members({ 9, 10, 11, 12 })
    local cur = 1 -- 当前波
    local wave = 100 -- 100波
    local period = 60 -- 初始周期
    local qty = 10 -- 每地点出怪数量
    -- 出怪地点
    local points = {
        {
            -- 左上
            start = { -2560, 2560, 270 },
            route = { { -2560, 1024 }, { -1280, 1024 }, { -1280, 2048 }, { 0, 2048 }, { 0, 0 } }
        },
        {
            -- 右上
            start = { 2560, 2560, 180 },
            route = { { 1024, 2560 }, { 1024, 1280 }, { 2048, 1280 }, { 2048, 0 }, { 0, 0 } }
        },
        {
            -- 左下
            start = { -2560, -2560, 0 },
            route = { { -1024, -2560 }, { -1024, -1280 }, { -2048, -1280 }, { -2048, 0 }, { 0, 0 } }
        },
        {
            -- 右下
            start = { 2560, -2560, 90 },
            route = { { 2560, -1024 }, { 1280, -1024 }, { 1280, -2048 }, { 0, -2048 }, { 0, 0 } }
        },
    }
    local baseHP = 20
    bubble["base0"] = Region("base0", "square", 0, 0, 120, 120)
    ---@param evtData eventOnRegionEnter
    bubble["base0"]:onEvent(eventKind.regionEnter, function(evtData)
        effector.point("MassTeleportTarget", evtData.triggerUnit:x(), evtData.triggerUnit:y(), nil, 0.5)
        class.destroy(evtData.triggerUnit)
        baseHP = baseHP - 1
        if (baseHP <= 0) then
            local tips = "被突破咯~"
            for i = 1, 4, 1 do
                Player(i):quit(tips)
            end
        end
    end)
    for pi, p in ipairs(points) do
        local route = p.route
        for i = 1, #route - 1, 1 do
            local k = "r" .. pi .. '-' .. i
            local rt = route[i]
            local next = route[i + 1]
            local r = Region(k, "square", rt[1], rt[2], 100, 100)
            r:setPeriod(0.3)
            ---@param evtData eventOnRegionEnter
            r:onEvent(eventKind.regionEnter, function(evtData)
                evtData.triggerUnit:orderMove(next[1], next[2])
            end)
            -- 调试模式搞点贴图方便看
            if (LK_DEBUG) then
                r:splat("PathTextures\\WayGate.tga", 150)
            end
            bubble[k] = r
        end
    end
    
    bubble.monTimer = time.setInterval(period, function(curTimer)
        cur = cur + 1
        if (cur >= wave) then
            class.destroy(curTimer)
            return
        end
        local i = 0
        bubble.monTimer2 = time.setInterval(1, function(curTimer2)
            i = i + 1
            if (i >= qty) then
                class.destroy(curTimer2)
                return
            end
            for pi, p in ipairs(points) do
                if (Player(pi):isPlaying()) then
                    local start = p.start
                    local route = p.route
                    local u = Unit(enemyTeam, TPL_UNIT.Empty, start[1], start[2], start[3])
                    u:orderRoute(false, route)
                end
            end
        end)
    end)
    
    -- 临时信息展示
    local ui = UIText("monTimer", UIGame)
        :relation(UI_ALIGN_TOP, UIGame, UI_ALIGN_TOP, 0, -0.07)
        :textAlign(TEXT_ALIGN_CENTER)
        :fontSize(12)
    bubble.uiTimer = time.setInterval(1, function()
        ui:text("第" .. cur .. "波：" .. math.floor(bubble.monTimer:remain()))
    end)
    
    -- 敌人奖励
    ---@param evtData eventOnUnitDead
    event.syncRegister(UnitClass, eventKind.unitDead, "enemyDrop", function(evtData)
        local tu = evtData.triggerUnit
        if (enemyTeam:is(tu)) then
            if (evtData.killerUnit) then
                evtData.killerUnit:owner():worth("+", { gold = 1 })  -- 未显示
            end
        end
    end)

end

function process:onOver()
    sound.bgmStop()
end

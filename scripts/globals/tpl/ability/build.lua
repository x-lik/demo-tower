---@param abData eventOnAbilityEffective
TPL_ABILITY.Build = AbilityTpl()
    :name("建造")
    :icon("ReplaceableTextures\\CommandButtons\\BTNHumanBuild.blp")
    :description("建造一个塔")
    :targetType(ability.targetType.build)
    :castWidthAdv(128, 0)
    :castHeightAdv(128, 0)
    :worthCostAdv({ gold = 1 }, nil)
    :modify("cursorPlanDistance", 64)
    :cursorCond(
    function(data)
        local terr = terrain.kind.lords_dirt -- =1281651316 在此游戏中的泥土地形
        if (false == terrain.isKind(data.x, data.y, terr)) then
            return -1
        end
        -- 5点辩证法，必须全部点与z近似高度
        local z = japi.Z(data.x, data.y)
        local ps = {
            { data.x - data.width / 2, data.y + data.height / 2 },
            { data.x + data.width / 2, data.y + data.height / 2 },
            { data.x - data.width / 2, data.y - data.height / 2 },
            { data.x + data.width / 2, data.y - data.height / 2 },
        }
        local status = 0
        for _, p in ipairs(ps) do
            local z2 = japi.Z(p[1], p[2])
            if (math.abs(z2 - z) > 16 or false == terrain.isKind(p[1], p[2], terr)) then
                status = -1
                break
            end
        end
        -- 已经有建筑挡住了
        if (0 == status and isGrid("towers")) then
            local ts = Grid("towers"):catch({
                limit = 1,
                square = data
            })
            if (#ts > 0) then
                status = -1
            end
        end
        return status
    end)
    :onEvent(eventKind.abilityEffective,
    function(abData)
        local x, y = abData.targetX, abData.targetY
        local p = abData.triggerUnit:owner()
        local u = Unit(p, TPL_UNIT.Tower1, x, y, 270)
        superposition.plus(u, "invulnerable") -- 设置无敌
        Grid("towers"):insert(u)
        async.call(p, function()
            sound.vcm("war3_BuildingPlacement")
        end)
        -- 非正经简单模拟一下建筑过程
        superposition.plus(u, "noAttack")
        u:animate("birth")
        time.setTimeout(1, function()
            u:animate("stand")
            superposition.minus(u, "noAttack")
        end)
    end)
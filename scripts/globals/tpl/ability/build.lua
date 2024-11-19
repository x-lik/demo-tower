ability.targetType.build = { value = "b", label = "建筑" }

---@param abData eventOnAbilityEffective
TPL_ABILITY.Build = AbilityTpl()
    :name("建造")
    :icon("ReplaceableTextures\\CommandButtons\\BTNHumanBuild.blp")
    :description("建造一个塔")
    :targetType(ability.targetType.build)
    :castWidthAdv(128, 0)
    :castHeightAdv(128, 0)
    :worthCostAdv({ gold = 1 }, nil)
    :cursorPlanDistance(64)
    :cursorBanCond(
    function(data)
        local terr = terrain.type.lords_dirt -- =1281651316 在此游戏中的泥土地形
        if (terr ~= terrain.getType(data.x, data.y)) then
            return true
        end
        -- 5点辩证法，必须全部点与z近似高度
        local z = japi.Z(data.x, data.y)
        local ps = {
            { data.x - data.width / 2, data.y + data.height / 2 },
            { data.x + data.width / 2, data.y + data.height / 2 },
            { data.x - data.width / 2, data.y - data.height / 2 },
            { data.x + data.width / 2, data.y - data.height / 2 },
        }
        local res = false
        for _, p in ipairs(ps) do
            local z2 = japi.Z(p[1], p[2])
            if (math.abs(z2 - z) > 16 or terr ~= terrain.getType(p[1], p[2])) then
                res = true
                break
            end
        end
        -- 已经有建筑挡住了
        if (false == res and isGrid("towers")) then
            local ts = Grid("towers"):catch({
                limit = 1,
                square = data
            })
            res = (#ts > 0)
        end
        return res
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
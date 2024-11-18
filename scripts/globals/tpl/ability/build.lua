---@param abData eventOnAbilityEffective
TPL_ABILITY.Build = AbilityTpl()
    :name("建造")
    :icon("ReplaceableTextures\\CommandButtons\\BTNHumanBuild.blp")
    :description("建造一个塔")
    :targetType(ability.targetType.pas)
    :onEvent(eventKind.abilityEffective,
    function(abData)
        local ak = abData.triggerAbility:id()
        event.syncUnregister(abData.triggerUnit, eventKind.classAfterChange .. "hpCur", ak)
        BuffClear(abData.triggerUnit, { key = "剑之勇气" .. ak })
    end)
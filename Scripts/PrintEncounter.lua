RegisterHook("/Game/jRPGTemplate/Blueprints/Components/AC_jRPG_BattleManager.AC_jRPG_BattleManager_C:StartBattle", function (self, ...)
    local battle_manager = self:get() ---@type UAC_jRPG_BattleManager_C

    local a = battle_manager.EncounterName:ToString()
    print("[COE33 Helper] - Encounter name : " .. a)
end)
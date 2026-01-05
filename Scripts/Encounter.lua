RegisterHook("/Game/jRPGTemplate/Blueprints/Components/AC_jRPG_BattleManager.AC_jRPG_BattleManager_C:StartBattle", function (self, ...)
    local battle_manager = self:get() ---@type UAC_jRPG_BattleManager_C


    local a = battle_manager.EncounterName:ToString()
    print("[COE33 Helper] - Encounter name : " .. a)

    b = battle_manager.CurrentBattleEncounterLevel
    print("[COE33 Helper] - Encounter level : "..b)

    
    --print("[COE33 Helper] - Enemies")
    --print(battle_manager.Enemies[1]:GetFullName())

   
    
    

end)

RegisterHook("/Game/jRPGTemplate/Blueprints/Components/AC_jRPG_BattleManager.AC_jRPG_BattleManager_C:LoadEncounterSettings", function (self, ...)
    local battle_manager = self:get() ---@type UAC_jRPG_BattleManager_C
    local party_level = 1

    --Settings
    local scale_to_party = true
    local scale_down_only = false
    local scale_up_only = true
    local change_to
    local factor = 1.1

    if scale_to_party then

        local char_data = FindAllOf("BP_CharacterData_C") ---@type UBP_CharacterData_C[]
        if char_data == nil then return 1 end

        local max = 1;
        for _, char in ipairs(char_data) do
            if char.IsExcluded then goto continue end

            local current_level = char.CurrentLevel
            if current_level > max then
                max = current_level
            end
            party_level = max
            ::continue::
        end

        change_to = math.ceil(party_level * factor)

        if scale_down_only then
            change_to = math.min(battle_manager.CurrentBattleEncounterLevel, change_to)
        
        elseif scale_up_only then
            change_to = math.max(battle_manager.CurrentBattleEncounterLevel, change_to)
        end


        battle_manager.CurrentBattleEncounterLevel = math.min(change_to, 300)
    end

    

end)



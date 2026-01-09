--Settings
local randomise_every_encounter = true

--vars
local enemy_dt
local enemies = {}





RegisterHook("/Game/jRPGTemplate/Blueprints/Components/AC_jRPG_BattleManager.AC_jRPG_BattleManager_C:StartBattle", function (self, ...)
    local battle_manager = self:get() ---@type UAC_jRPG_BattleManager_C


    local a = battle_manager.EncounterName:ToString()
    print("[COE33 Helper] - Encounter name : " .. a)

    b = battle_manager.CurrentBattleEncounterLevel
    print("[COE33 Helper] - Encounter level : "..b)

    
    print("[COE33 Helper] - Enemies")
    battle_manager.Enemies:ForEach(function (_,enemy)
        print(enemy:get():GetFullName())
        --print(enemy:get():IsValid())
    end)
    



    
    

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
        if change_to < 1 then change_to = 1
        elseif change_to > 300 then change_to = 300 end

        if scale_down_only then
            change_to = math.min(battle_manager.CurrentBattleEncounterLevel, change_to)        
        elseif scale_up_only then
            change_to = math.max(battle_manager.CurrentBattleEncounterLevel, change_to)
        end

    end

    

    

end)

RegisterHook("/Game/jRPGTemplate/Datatables/BP_FunctionLibrary_DT_Enemies_Accessor.BP_FunctionLibrary_DT_Enemies_Accessor_C:GetEncounterDataTableRow", function (self, RowName, _WorldContext, Found, EnemyData)

--print(row_name)
local new_enemy = "DS_Noire"

--local encounters = StaticFindObject("/Game/jRPGTemplate/Datatables/DT_jRPG_Encounters.DT_jRPG_Encounters")

--if enemies == nil then enemies = StaticFindObject("/Game/jRPGTemplate/Datatables/DT_jRPG_Enemies.DT_jRPG_Enemies") end
--print(enemies:IsValid())
--print(enemies:FindRow(RowName:get():ToString()).EnemyHardcodedName_4_0FAACC934CB2957BA37E888624E5835F:ToString())
--local new_enemy_row = enemies:FindRow(new_enemy) -- UScriptStruct

--enemies:AddRow(row_name,new_enemy_row)


if randomise_every_encounter then 
    enemy_dt:ForEachRow(function(enemy_name,enemy_data)
        local index = math.random(#enemies)
        local random_new_enemy = enemies[index][1]
        --print("COE33 Encounter - New Enemy: "..random_new_enemy)
        local new_enemy_row = enemy_dt:FindRow(random_new_enemy) -- UScriptStruct
        enemy_dt:AddRow(enemy_name,new_enemy_row)
    
    end)
end


end)




--randomise enemies

RegisterHook("/Game/Gameplay/Save/BP_SaveManager.BP_SaveManager_C:OnLoadOperationsDone", function ()


    enemy_dt = StaticFindObject("/Game/jRPGTemplate/Datatables/DT_jRPG_Enemies.DT_jRPG_Enemies")
    if not enemy_dt:IsValid() then return end
    
    enemy_dt:ForEachRow(function (name,value)
        table.insert(enemies,{name, value})
    end)
    
    print("Enemy Datatable get :3")
end)




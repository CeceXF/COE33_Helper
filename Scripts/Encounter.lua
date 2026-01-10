--Settings
local scale_to_party = true
local scale_down_only = false
local scale_up_only = true
local factor = 1.1

local randomise_enemies = true
local randomise_every_encounter = false --random enemies every encounter
local keep_bosses_in_boss_encounters = true
local include_cut_content = false
local randomise_swc_renoir = true -- so u dont need to potentially fight simon as 1hp level 1 gustave
local randomise_white_nevrons = false
local randomise_adds = false --affects summon petank, chromatic petank, renoir 1, danseuse, chromatic danseuse
local randomise_superbosses_except_duo = true
local randomise_duollistes = false -- buggy -  they dont die properly allegedly
local randomise_mimes = true
local randomise_petanks = true
local include_tutorials = false
local include_gimmick_fights = false
local randomise_merchants = false
--check how to change opera house curtain state



--vars
local JSON = require("json")
local change_to
local enemy_dt
local enemy_categories = JSON.read_file("ue4ss/Mods/COE33_Helper/Scripts/data/EnemyCategories.json")
local enemies = {}
local bosses = {}
local enemies_shuffled = false





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
    --local new_enemy = "DS_Noire"

    --local encounters = StaticFindObject("/Game/jRPGTemplate/Datatables/DT_jRPG_Encounters.DT_jRPG_Encounters")

    --if enemies == nil then enemies = StaticFindObject("/Game/jRPGTemplate/Datatables/DT_jRPG_Enemies.DT_jRPG_Enemies") end
    --print(enemies:IsValid())
    --print(enemies:FindRow(RowName:get():ToString()).EnemyHardcodedName_4_0FAACC934CB2957BA37E888624E5835F:ToString())
    --local new_enemy_row = enemies:FindRow(new_enemy) -- UScriptStruct

    --enemies:AddRow(row_name,new_enemy_row)
    if not randomise_enemies then return end



    if not enemies_shuffled then
        enemy_dt = StaticFindObject("/Game/jRPGTemplate/Datatables/DT_jRPG_Enemies.DT_jRPG_Enemies")
        if not enemy_dt:IsValid() then return end

        --[[
        local leave_swc_renoir = true -- so u dont need to potentially fight simon as 1hp level 1 gustave
        local keep_bosses_in_boss_encounters = true
        local randomise_adds = false --enemy summons 

        ]]

        if enemy_categories == nil then 
            print ("COE33 Helper - Failed to get enemy categories.")
            return
        end

        for i, enemy in ipairs(enemy_categories["regular enemies"]) do
            table.insert(enemies,{enemy,enemy_dt:FindRow(enemy)})
        end

        for i, boss in ipairs(enemy_categories["minibosses"]) do 
            table.insert(bosses, {boss,enemy_dt:FindRow(boss)})
        end

        for i, boss in ipairs(enemy_categories["chromatics"]) do 
            table.insert(bosses, {boss,enemy_dt:FindRow(boss)})
        end

        for i, boss in ipairs(enemy_categories["bosses"]) do 
            table.insert(bosses, {boss,enemy_dt:FindRow(boss)})
        end

        if include_cut_content then
            for i, enemy in ipairs(enemy_categories["cut regular enemies"]) do
                table.insert(enemies,{enemy,enemy_dt:FindRow(enemy)})
            end

            for i, boss in ipairs(enemy_categories["cut content bosses"]) do 
                table.insert(bosses, {boss,enemy_dt:FindRow(boss)})
            end
        end

        if randomise_white_nevrons then
            for i, enemy in ipairs(enemy_categories["white nevrons"]) do
                table.insert(enemies,{enemy,enemy_dt:FindRow(enemy)})
            end
        end

        if randomise_superbosses_except_duo then 
            for i, boss in ipairs(enemy_categories["superbosses"]) do 
                table.insert(bosses, {boss,enemy_dt:FindRow(boss)})
            end
        end

        if randomise_duollistes then
            for i, boss in ipairs(enemy_categories["duollistes"]) do 
                table.insert(bosses, {boss,enemy_dt:FindRow(boss)})
            end
        end

        if randomise_petanks then 
            for i, enemy in ipairs(enemy_categories["petanks"]) do
                table.insert(enemies,{enemy,enemy_dt:FindRow(enemy)})
            end
        end

        if randomise_mimes then 
            for i, enemy in ipairs(enemy_categories["mimes"]) do
                table.insert(enemies,{enemy,enemy_dt:FindRow(enemy)})
            end
        end

        if include_tutorials then 
            for i, boss in ipairs(enemy_categories["tutorials"]) do
                table.insert(bosses,{boss,enemy_dt:FindRow(boss)})
            end
        end

        if include_gimmick_fights then 
            for i, boss in ipairs(enemy_categories["gimmicks"]) do
                table.insert(bosses,{boss,enemy_dt:FindRow(boss)})
            end
            
        end

        if randomise_merchants then 
            for i, enemy in ipairs(enemy_categories["merchants"]) do
                table.insert(enemies,{enemy,enemy_dt:FindRow(enemy)})
            end
        end

        print("Enemy Datatable get :3")

        local adds_str = "|"
        
        for _,add in ipairs(enemy_categories["adds"]) do
            adds_str = adds_str..add.."|"
        end

        if not keep_bosses_in_boss_encounters then 
            for i=1,#bosses,1 do
                enemies[#enemies+1] = bosses[i]
            end
        end

        enemy_dt:ForEachRow(function(enemy_name,enemy_data)
            local index
            local random_new_enemy
            if keep_bosses_in_boss_encounters and enemy_data.IsBoss_46_F2839289483FE917FB914594C70C7CE4 then
                index = math.random(#bosses)
                random_new_enemy = bosses[index][1]
            else
                index = math.random(#enemies)
                random_new_enemy = enemies[index][1]
            end

            --print("COE33 Encounter - New Enemy: "..random_new_enemy)
            local new_enemy_row = enemy_dt:FindRow(random_new_enemy) -- UScriptStruct
            
            if enemy_name == "SC_MirrorRenoir_GustaveEnd" then
                if randomise_swc_renoir then
                    enemy_dt:AddRow(enemy_name,new_enemy_row)
                end
            
            elseif  randomise_adds or not string.find(enemy_name,adds_str) then
                enemy_dt:AddRow(enemy_name,new_enemy_row)            
            end
        end)

        if not randomise_every_encounter then 
            enemies_shuffled = true
        end

    end



end)





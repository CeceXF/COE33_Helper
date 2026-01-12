--Settings
local scale_to_party = true
local dynamic_scaling = true -- makes enemies easier if you kill them faster, makes enemies harder if you kill them slower
local scale_down_only = false
local scale_up_only = false
local factor = 1.1

local randomise_enemies = true
local randomise_every_encounter = false --random enemies every encounter
local keep_bosses_in_boss_encounters = true
local include_cut_content = false
local randomise_swc_renoir_encounter = true -- so u dont need to potentially fight simon as 1hp level 1 gustave
local include_a3_renoir = true --prevents access through opera house curtains, u need to patch ur save file to reopen them
local include_white_nevron_enemies = false
local randomise_white_nevron_encounters = false
local randomise_adds = false --affects summon petank, chromatic petank, renoir 1, danseuse, chromatic danseuse
local include_superbosses_except_duo = true
local randomise_superboss_encounters_except_duo = false
local include_duolliste = false -- buggy -  they dont die properly allegedly
local randomise_duolliste_encounter = false
local include_mime_enemies = false
local randomise_mime_encounters = true
local mimes_are_bosses = true -- forces a boss into mime encounters
local include_petank_enemies = true
local randomise_petank_encounters = true
local include_tutorial_enemies = false
local randomise_tutorial_encounters = true --doesnt do anything if you have tutorials turned off
local include_gimmick_enemies = false
local randomise_gimmick_encounters = false
local include_merchant_enemies = false
local randomise_merchant_encounters = false --you wont be able to unlock their inventory unless you actually defeat them when you find them elsewhere
--check how to change opera house curtain state



--vars
local JSON = require("json")
local change_to
local enemy_dt
local enemy_categories = JSON.read_file("ue4ss/Mods/COE33_Helper/Scripts/data/EnemyCategories.json")
local enemies = {}
local bosses = {}
local enemies_shuffled = false
local number_of_turns = 0
local rng_encounter_count = 0


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
RegisterHook("/Game/jRPGTemplate/Blueprints/Components/AC_jRPG_BattleManager.AC_jRPG_BattleManager_C:StartCharacterTurn", function (self, Character)
    local name = Character:get():GetFullName()
    --print(name)
    local chars = {"Verso","Noah","Monoco","Sciel","Lune","Maelle"}
    for i,character in ipairs(chars) do
        if string.find(name, "BP_"..character.."Battle") then
            number_of_turns = number_of_turns + 1
        end
    end
end)

RegisterHook("/Game/jRPGTemplate/Blueprints/Components/AC_jRPG_BattleManager.AC_jRPG_BattleManager_C:OnBattleEndVictory",function ()
    if dynamic_scaling then
        if number_of_turns <= 5 then
            factor = factor + 0.05
        elseif number_of_turns > 15 then
            factor = factor - 0.05
        end
    end
    --print(factor)
end)
hooks_registered = true

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
        battle_manager.CurrentBattleEncounterLevel = change_to

    end
end)



function PopulateEnemies()
    for i, enemy in ipairs(enemy_categories["regular enemies"]) do
        table.insert(enemies,{enemy,enemy_dt:FindRow(enemy)})
    end

    if include_cut_content then
        for i, enemy in ipairs(enemy_categories["cut regular enemies"]) do
            table.insert(enemies,{enemy,enemy_dt:FindRow(enemy)})
        end
    end

    if include_white_nevron_enemies then
        for i, enemy in ipairs(enemy_categories["white nevrons"]) do
            table.insert(enemies,{enemy,enemy_dt:FindRow(enemy)})
        end
    end

    if include_petank_enemies then 
        for i, enemy in ipairs(enemy_categories["petanks"]) do
            table.insert(enemies,{enemy,enemy_dt:FindRow(enemy)})
        end
    end

    if not mimes_are_bosses and include_mime_enemies then
        for i, enemy in ipairs(enemy_categories["mimes"]) do
            table.insert(enemies,{enemy,enemy_dt:FindRow(enemy)})
        end
    end

    if include_merchant_enemies then 
        for i, enemy in ipairs(enemy_categories["merchants"]) do
            table.insert(enemies,{enemy,enemy_dt:FindRow(enemy)})
        end
    end

end

function PopulateBosses ()
    for i, boss in ipairs(enemy_categories["minibosses"]) do 
        table.insert(bosses, {boss,enemy_dt:FindRow(boss)})
    end

    for i, boss in ipairs(enemy_categories["chromatics"]) do 
        table.insert(bosses, {boss,enemy_dt:FindRow(boss)})
    end

    for i, boss in ipairs(enemy_categories["bosses"]) do
        if include_a3_renoir or not string.find(boss,"L_Boss_Curator") then
            table.insert(bosses, {boss,enemy_dt:FindRow(boss)})
        end
    end


    if include_cut_content then
        for i, boss in ipairs(enemy_categories["cut content bosses"]) do 
            table.insert(bosses, {boss,enemy_dt:FindRow(boss)})
        end
    end

    if include_superbosses_except_duo then 
        for i, boss in ipairs(enemy_categories["superbosses"]) do 
            table.insert(bosses, {boss,enemy_dt:FindRow(boss)})
        end
    end

    if include_duolliste then
        for i, boss in ipairs(enemy_categories["duollistes"]) do 
            table.insert(bosses, {boss,enemy_dt:FindRow(boss)})
        end
    end

    if include_mime_enemies then 
        if mimes_are_bosses then
            for i, boss in ipairs(enemy_categories["mimes"]) do
                table.insert(bosses,{boss,enemy_dt:FindRow(boss)})
            end                
        end            
    end

    if include_tutorial_enemies then 
        for i, boss in ipairs(enemy_categories["tutorials"]) do
            table.insert(bosses,{boss,enemy_dt:FindRow(boss)})
        end
    end

    if include_gimmick_enemies then 
        for i, boss in ipairs(enemy_categories["gimmicks"]) do
            table.insert(bosses,{boss,enemy_dt:FindRow(boss)})
        end
        
    end
end

function RefillEnemyList()
    local enemies_temp = {}
    for i,enemy in ipairs(enemies) do
        table.insert(enemies_temp,enemy)
    end
    return enemies_temp
end

function RefillBossList()
    local bosses_temp = {}
    for i,boss in ipairs(bosses) do
        table.insert(bosses_temp,boss)
    end
    return bosses_temp
end


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

        PopulateEnemies()
        PopulateBosses()

        print("Enemy Datatable get :3")

        local add_str = "|"   
        for _,add in ipairs(enemy_categories["adds"]) do
            add_str = add_str..add.."|"
        end

        local white_nevron_str = "|"
        for _,white_nevron in ipairs(enemy_categories["white nevrons"]) do
            white_nevron_str = white_nevron_str..white_nevron.."|"
        end

        local super_str = "|"
        for _,super in ipairs(enemy_categories["superbosses"]) do
            super_str = super_str..super.."|"
        end

        local duo_str = "|"
        for _,duo in ipairs(enemy_categories["duollistes"]) do
            duo_str = duo_str..duo.."|"
        end

        local mime_str = "|"
        for _,mime in ipairs(enemy_categories["mimes"]) do
            mime_str = mime_str..mime.."|"
        end

        local petank_str = "|"
        for _,petank in ipairs(enemy_categories["petanks"]) do
            petank_str = petank_str..petank.."|"
        end

        local tuto_str = "|"
        for _,tuto in ipairs(enemy_categories["tutorials"]) do
            tuto_str = tuto_str..tuto.."|"
        end

        local gimmick_str = "|"
        for _,gimmick in ipairs(enemy_categories["gimmicks"]) do
            gimmick_str = gimmick_str..gimmick.."|"
        end

        local merchant_str = "|"
        for _,merchant in ipairs(enemy_categories["merchants"]) do
            merchant_str = merchant_str..merchant.."|"
        end

        local cut_content_str = "|"
        for _,cut_enemy in ipairs(enemy_categories["cut regular enemies"]) do
            cut_content_str = cut_enemy.."|"
        end
        for _,cut_enemy in ipairs(enemy_categories["cut content bosses"]) do
            cut_content_str = cut_enemy.."|"
        end

        if not keep_bosses_in_boss_encounters then 
            for i=1,#bosses,1 do
                enemies[#enemies+1] = bosses[i]
            end
        end

        local enemies_temp = {}
        local bosses_temp = {}

        enemy_dt:ForEachRow(function(enemy_name,enemy_data)
            if string.find(cut_content_str,enemy_name) then
                goto nextrow
            end
            local index
            local random_new_enemy
            if #enemies_temp == 0 then
                enemies_temp = RefillEnemyList()
            end
            if #bosses_temp == 0 then
                bosses_temp = RefillBossList()
            end

            if keep_bosses_in_boss_encounters and (enemy_data.IsBoss_46_F2839289483FE917FB914594C70C7CE4 or (mimes_are_bosses and string.find(enemy_name,"Mime")) or string.find(string.lower(enemy_name),"alpha")) then
                index = math.random(#bosses_temp)
                random_new_enemy = bosses_temp[index][1]
                table.remove(bosses_temp,index)
            else
                index = math.random(#enemies_temp)
                random_new_enemy = enemies_temp[index][1]
                table.remove(enemies_temp,index)
            end

            --print("COE33 Encounter - New Enemy: "..random_new_enemy)
            local new_enemy_row = enemy_dt:FindRow(random_new_enemy) -- UScriptStruct

            local check_adds = randomise_adds or not string.find(enemy_name,add_str)
            local check_white_nevron_encounter = randomise_white_nevron_encounters or not string.find(white_nevron_str,enemy_name)
            local check_supers_encounter = randomise_superboss_encounters_except_duo or not string.find(super_str,enemy_name)
            local check_duo_encounter = randomise_duolliste_encounter or not string.find(duo_str,enemy_name)
            local check_mime_encounter = randomise_mime_encounters or not string.find(mime_str,enemy_name)
            local check_petank_encounter = randomise_petank_encounters or not string.find(petank_str,enemy_name)
            local check_tuto_encounter = randomise_tutorial_encounters or not string.find(tuto_str,enemy_name)
            local check_gimmick_encounter = randomise_gimmick_encounters or not string.find(gimmick_str,enemy_name)
            local check_merchant_encounter = randomise_merchant_encounters or not string.find(merchant_str,enemy_name)
            
            if enemy_name == "SC_MirrorRenoir_GustaveEnd" then
                if randomise_swc_renoir_encounter then
                    enemy_dt:AddRow(enemy_name,new_enemy_row)
                end
            elseif enemy_name =="L_Boss_Curator" then

            
            elseif check_adds or check_white_nevron_encounter or check_supers_encounter or check_duo_encounter or check_mime_encounter or check_petank_encounter or check_tuto_encounter or check_gimmick_encounter or check_merchant_encounter then
                enemy_dt:AddRow(enemy_name,new_enemy_row)            
            end

            ::nextrow::
        end)

        if not randomise_every_encounter then 
            enemies_shuffled = true
        end

    end



end)

--coward button
RegisterKeyBind(Key.F6, {ModifierKey.CONTROL}, function ()
    local date = os.date("*t")
    math.randomseed(date["min"] + date["sec"],rng_encounter_count)
    enemies_shuffled = false

end)




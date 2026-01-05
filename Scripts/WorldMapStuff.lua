local portal_transform_array = {}
local wm_exit

function GetPortalLoop()
    local a = FindFirstOf("BP_WorldInfoComponent_C") ---@cast a UBP_WorldInfoComponent_C
        if a == nil or not a:IsValid() then return end

        local portal_array = a.WorldTeleportPoints

        portal_array:ForEach(function(_, portal)
        
            portal = portal:get()
            --local name = portal.LevelDestination.RowName:ToString()
            local destination_name = portal.DestinationSpawnPointTag.TagName:ToString()
            --print(destination_name)
            --local return_name = portal.ReturnSpawnPointTag.TagName:ToString()
            --print("COE33 Portal Name: ".. name)
            --print("COE33 Portal Destination: ".. destination_name)
            --print("COE33 Portal Return: ".. return_name)
            portal_transform_array[destination_name] = {portal,portal:K2_GetActorLocation(),portal:K2_GetActorRotation()}
        end)
end
--[[
local function_name = "/Game/jRPGTemplate/Blueprints/Basics/FL_jRPG_CustomFunctionLibrary.FL_jRPG_CustomFunctionLibrary_C:GetCurrentLevelData"
RegisterHook(function_name, function (self, _worldContext, found, levelData, rowName)

    local level = rowName:get():ToString()
    
end)
]]
RegisterHook("/Game/Gameplay/WorldMap/BP_PlayerController_WorldMap.BP_PlayerController_WorldMap_C:UnpauseGameplay", function ()
    GetPortalLoop()
    local shuffled_portals = ShufflePortals(portal_transform_array,false,true)
    for k,v in pairs(shuffled_portals) do
        print(k.. " randomised to " .. v[1].DestinationSpawnPointTag.TagName:ToString())
        portal_transform_array[k][1]:K2_SetActorLocationAndRotation(v[2],v[3],false,{},true)
        
    end

    if wm_exit ~= nil then
        for k,v in pairs(shuffled_portals) do
            
            if string.find(k,wm_exit[1]) and wm_exit[2] and (string.find(k,"Entry") ~= nil or string.find(k,"Entrance") ~= nil) then
                TeleportPlayer(v[1].DestinationSpawnPointTag.TagName:ToString())
                print("Tele to: "..v[1].DestinationSpawnPointTag.TagName:ToString())
                wm_exit = nil
                goto break_loop
            elseif string.find(k,wm_exit[1]) and not wm_exit[2] and (string.find(k,"Exit") ~= nil or string.find(k,"EndPath") ~= nil )then
                TeleportPlayer(v[1].DestinationSpawnPointTag.TagName:ToString())
                print("Tele to: "..v[1].DestinationSpawnPointTag.TagName:ToString())
                wm_exit = nil
                goto break_loop
            
            end
        end
        if wm_exit ~= nil then print("COE33 WorldMapStuff: Unknown Location Specified") end
    end
    ::break_loop::
end)

RegisterHook("/Game/LevelTools/BP_jRPG_MapTeleportPoint.BP_jRPG_MapTeleportPoint_C:ProcessChangeMap", function (self)
    local teleport_point_tag = self:get().DestinationSpawnPointTag.TagName:ToString()
    local entry
    if string.find(teleport_point_tag,"Entry") then entry = true
    else entry = false
    end
    
    local area_name = string.gsub(string.gsub(string.gsub(teleport_point_tag,"Entry",""),"Exit",""), "Level.SpawnPoint.WorldMap.", "")
    wm_exit = {area_name,entry}
    print(area_name)


end)


-- get shuffled portal_array
function ShufflePortals(portals,shuffle_et,include_endgame_areas) 
    --temporary vars
    local seed = 33



    --in the actual thing maybe just read from save json or save the correspondence in the save json
    math.randomseed(seed)

    --[[
    Tags are in format: Level.SpawnPoint.x.Entry/Exit
    Except:
    Old Lumiere's exit is .EndPath
    Painting Workshop is .Path1/.Path2/.Path3
    Monoco's Station has other names (see below)
    The Monolith has 5 sections instead of 4 which is weird
    Gestral Beaches have .Volleyball .WipeOut .OnlyUp .Race .Climb

    Two Entrances
    Flying Waters .Goblu
    Ancient Sanctuary .AncientSanctuary
    Yellow Harvest .YellowForest
    Forgotten Battlefield .Forgotten Battlefield
    Stone Wave Cliffs .SeaCliff
    Old Lumiere .OldLumiere

    Three Entrances
    Monoco's Station .MonocoStation - .EntryForgotten is the actual entrance, .EntryFrozenHearts and .EntryOldLumiere can be considered exits
    

    Weird
    Stone Wave Cliffs .SeaCliff
    Old Lumiere .OldLumiere
    Painting Workshop .CleaWorkshop

    Optional
    Endless Tower .CleasTower

    Also Renoir's Drafts is .AxonPath for some reason
    ]]

    --theoretically we can also shuffle all entrances and exits seperately and there will still be a path through but i dunno how the logic is gonna work, i'll just
    --replace entire areas for now, skipping monoco's station, spring meadows, painting workshop and gestral beaches

    local one_entrance, one_entrance_copy, two_entrances = {},{},{}
    local two_entrances_temp_tags = {}
    local two_entrance_tags = {".Goblu",".AncientSanctuary",".YellowForest",".ForgottenBattlefield",".SeaCliff",".OldLumiere"}
    local two_entrance_tags_copy = {".Goblu",".AncientSanctuary",".YellowForest",".ForgottenBattlefield",".SeaCliff",".OldLumiere"}
    table.sort(two_entrance_tags)

    for key,value in pairs(portal_transform_array) do
        for _, value2 in pairs(two_entrance_tags) do
            if string.find(key,value2) ~= nil then
                two_entrances[#two_entrances+1] = {key,value}

                goto continue 
            end
        end

        if string.find(key,"MonocoStation") or (string.find(key,"CleasTower") and not shuffle_et) or string.find(key,"SpringMeadows")  or string.find(key,"CleaWorkshop") or string.find(key,"GestralBeach") then
            goto continue
        else 
            one_entrance[#one_entrance+1] = {key,value}
            one_entrance_copy[#one_entrance_copy+1] = {key,value}
        end

        ::continue::
    end


    local one_entrance_out,two_entrances_out = {},{}
    local n = #one_entrance
    --shuffle one entrance maps    table format: n | {dest_tag, {portal, portal_transform}}
    while #one_entrance_out < n do
        local j = math.random(#one_entrance)
        table.insert(one_entrance_out,one_entrance[j])
        table.remove(one_entrance,j)
    end
    for i = 1, #one_entrance_copy, 1 do
        one_entrance_out[i] = {one_entrance_out[i][1],one_entrance_copy[i][2]}
        --print(one_entrance_out[i][1])
    end

    --shuffle two entrance maps    table format: n | short_tag

    n = #two_entrance_tags
    while #two_entrances_temp_tags < n do
        local j = math.random(#two_entrance_tags)
        table.insert(two_entrances_temp_tags,two_entrance_tags[j])
        table.remove(two_entrance_tags,j)
    end
    
    --table format: n | {shuffled_short_tag, short_tag}
    for i = 1, #two_entrance_tags_copy, 1 do
        two_entrances_temp_tags[i] = {two_entrances_temp_tags[i],two_entrance_tags_copy[i]}
    end

    --swap corresponding entrance/exit pairs

    for i = 1, #two_entrances_temp_tags, 1 do
        local shuffled_tag = two_entrances_temp_tags[i][1] --{shuffled_short_tag, short_tag}
        local original_tag = two_entrances_temp_tags[i][2]
        local shuffled_area_prefix = "Level.SpawnPoint" .. shuffled_tag





        for j = 1, #two_entrances, 1 do
            
            
            local orig_portal = two_entrances[j]-- {dest_tag, {portal, portal_loc, portal_rot}}

    
            local suffix

            if string.find(orig_portal[1],original_tag) == nil then
                goto continue
            end 

            if string.find(orig_portal[1],".Entry") then
                suffix = ".Entry"
            elseif string.find(shuffled_area_prefix,".OldLumiere") then
                suffix = ".EndPath"
            else
                suffix = ".Exit"
            end


            two_entrances_out[#two_entrances_out+1] = {shuffled_area_prefix..suffix,orig_portal[2]}
            --print(original_tag .. " to " .. shuffled_area_prefix)

            


            ::continue::
        end



    
    end
    
    --combine the 2 tables to return
    local output = {}

    for k,v in pairs(two_entrances_out) do
        output[v[1]] = v[2]
    end
    for k,v in pairs(one_entrance_out) do
        output[v[1]] = v[2]
    end

    return output
end

--get tp to world map details
RegisterKeyBind(Key.F5, {ModifierKey.CONTROL}, function ()
    local teleport = FindFirstOf("BP_jRPG_MapTeleportPoint_C")
    print(teleport.DestinationSpawnPointTag.TagName:ToString())

end) 

function TeleportPlayer(destination)
    local player_pawn = FindFirstOf("BP_jRPG_Character_World_C")

    -- use portal destination tags as key
    print("COE33 Portal - Warp To: ".. destination)
    local teleport_loc = portal_transform_array[destination][2]
    if teleport_loc == nil then 
        print("COE33 WorldMapStuff - Location doesn't exist!")
        return 
    end
    --increase height so player doesn't clip into the map 
    teleport_loc.Z = teleport_loc.Z + 700

    local teleport_rot = portal_transform_array[destination][3]
    --adjust player position to be in front of portal

    local xy_forward_vector = {
        X=portal_transform_array[destination][1]:GetActorForwardVector().X,
        Y=portal_transform_array[destination][1]:GetActorForwardVector().Y,
    }
    
    local scale_factor = 1500
    teleport_loc.X = teleport_loc.X + xy_forward_vector.X * scale_factor
    teleport_loc.Y = teleport_loc.Y + xy_forward_vector.Y * scale_factor

    player_pawn:K2_SetActorLocationAndRotation(teleport_loc,teleport_rot,false,{},true)
end


--teleport player
--just used to check area names and teleport function
RegisterKeyBind(Key.F6, {ModifierKey.CONTROL}, function ()

    --todo:remove after testing
    GetPortalLoop()
    local destination = "Level.SpawnPoint.ChromaZoneEntrance.Entry"
    TeleportPlayer(destination)


    
    

end)
--[[
RegisterKeyBind(Key.F7,{ModifierKey.CONTROL}, function () 
    local player_pawn = FindFirstOf("BP_jRPG_Character_World_C")
    local adjust_loc = {
        X = player_pawn:K2_GetActorLocation().X,
        Y = player_pawn:K2_GetActorLocation().Y +100000,
        Z = player_pawn:K2_GetActorLocation().Z + 100000
    }

    player_pawn:K2_SetActorLocation(adjust_loc,false,{},true)

end)
]]

RegisterHook("/Game/UI/Widgets/HUD_Exploration/WorldMap/WBP_LevelNameWidget.WBP_LevelNameWidget_C:PlayAppearAnimation", function(self)
    local level_text = self:get() ---@type WBP_LevelNameWidget_C
    local entered = true --placeholder var

    local possible_text = {"GOOD\nLUCK","WHO\nKNOWS","UNKNOWN\nAREA","LITERALLY\nJUST 33 SIMONS","According to all known laws of aviation, there is no way a bee should be able to fly.","hi\ndemorck","the game\nawards 2025","???"}

    if not entered then
        level_text:SetLevelNameText(FText(possible_text[math.random(#possible_text)]))

    end

end)

--[[RegisterHook("/Game/UI/Widgets/HUD_Exploration/WorldMap/WBP_LevelNameWidget.WBP_LevelNameWidget_C:PlayDisappearAnimation", function(self)
    local level_text = self:get() ---@type WBP_LevelNameWidget_C
    level_text.TextBlock_LevelName.Font.Size = 50


end)]]
JSON = require("json")

local file = JSON.read_file("ue4ss/Mods/COE33_HELPER/Scripts/data/chests.json") -- JUST CHANGE THIS
local current_level = ""
local current_data_in_area = {}
local current_names_in_area = {}
local data = {}
local tp_index = 1

function TP()
    if current_level == "" or data == nil then return end

    if next(current_names_in_area) == nil then
        if current_data_in_area == nil then
            print("No chests here")
            return
        end

        for key, value in pairs(current_data_in_area) do
            table.insert(current_names_in_area, key)
        end

        table.sort(current_names_in_area, function(a, b)
            local numA = tonumber(a:match("_(%d+)$")) or math.huge
            local numB = tonumber(b:match("_(%d+)$")) or math.huge
            return numA < numB
        end)


        tp_index = 1
    end
    
    local name = current_names_in_area[tp_index]
    if name == nil then
        print("All chests are visited, return to start.")
        tp_index = 1
    end

    local info = current_data_in_area[name]

    print("Teleporing to : " .. name .. "...")

    local manager = FindFirstOf("BP_jRPG_Character_World_C") ---@type ABP_jRPG_Character_World_C
    local t =  {
        Rotation= {
            X=0.000000,
            Y=0.000000,
            Z=-0.994888,
            W=-0.100987
        },
        
        Translation = {
            X= info.X,
            Y= info.Y,
            Z= info.Z + 150
        },
        
        Scale3D = {
            X=1.000000,
            Y=1.000000,
            Z=1.000000
        }
    }

    local c = {
        Pitch=0.000000,Yaw=168.407962,Roll=0.000000
    }

    manager:TeleportCharacter(t, c)

    tp_index = tp_index + 1 
end

RegisterKeyBind(MODS.TPToChest.PressedKey, MODS.TPToChest.Modifier_keys, function()
    ExecuteInGameThread(function()
        TP()
    end)
end)


RegisterHook("/Game/jRPGTemplate/Blueprints/Basics/FL_jRPG_CustomFunctionLibrary.FL_jRPG_CustomFunctionLibrary_C:GetCurrentLevelData", function (self, _worldContext, found, levelData, rowName)
    local name = rowName:get()
    local level = name:ToString()

    if current_level ~= level then
        print("DEBUG: Level changing, name of this level: " .. level)
        current_data_in_area = data[level]
        current_names_in_area = {}
        
        current_level = level
    end
end)

if file ~= nil then
    data = file
    if data then print(data) end
else
    print("Json nil")
end

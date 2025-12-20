MODS = {
    TPToChest = {
        activate = true,
        PressedKey = Key.F1,
        Modifier_keys = { ModifierKey.ALT },
    },
    ChangeQuestStatus = {
        activate = false,
        PressedKey = Key.F1,
        Modifier_keys = { ModifierKey.ALT },
    },
    PrintEncounter = {
        activate = true
    }
}


for key, value in pairs(MODS) do
    if value.activate then
        require(key)
    end
end
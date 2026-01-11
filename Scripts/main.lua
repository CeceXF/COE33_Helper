MODS = {
    TPToChest = {
        activate = false,
        PressedKey = Key.F1,
        Modifier_keys = { ModifierKey.ALT },
    },
    ChangeQuestStatus = {
        activate = false,
        PressedKey = Key.F1,
        Modifier_keys = { ModifierKey.ALT },
    },
    Encounter = {
        activate = true
    },
    WorldMapStuff = {
        activate = false,
        PressedKey = Key.F5,
        Modifier_keys = {ModifierKey.CONTROL}
    }
}


for key, value in pairs(MODS) do
    if value.activate then
        require(key)
    end
end

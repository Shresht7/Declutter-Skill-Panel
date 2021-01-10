--  =======
--  IMPORTS
--  =======

Ext.Require('Auxiliary.lua')

--  ===========================
--  GIVE FORGETINATOR TO PLAYER
--  ===========================

function AddForgetinator()
    if not Ext.OsirisIsCallable() then return end

    local player = Osi.CharacterGetHostCharacter()
    local check = math.max(Osi.ItemTemplateIsInPartyInventory(player, ForgetinatorTemplate, 1), Osi.ItemTemplateIsInPartyInventory(player, ForgetinatorSafetyOffTemplate, 1))
    if check == 0 then
        Osi.ItemTemplateAddTo(ForgetinatorTemplate, player, 1, 1)
        Debug:FPrint("Forgetinator added to host-character's inventory")
    end
end

ConsoleCommander:Register({
    ['Name'] = "AddForgetinator",
    ['Description'] = "Adds Forgetinator to Host-Character's Inventory",
    ['Context'] = "Server",
    ['Action'] = AddForgetinator
})

Ext.RegisterOsirisListener('SavegameLoaded', 4, 'after', function ()
    local exceptions = {
        ["TUT_Tutorial_A"] = true,
        ["FJ_FortJoy_Main"] = true
    }

    local host = Osi.CharacterGetHostCharacter()
    local region = Osi.GetRegion(host)

    if not exceptions[region] and Osi.IsGameLevel(region) then AddForgetinator() end
end)

--  ===================
--  CHARACTER USED ITEM
--  ===================

Ext.RegisterOsirisListener('CharacterUsedItemTemplate', 3, 'after', function (character, itemTemplate)
    if not Osi.CharacterIsPlayer(character) then return end
    if itemTemplate ~= ForgetinatorTemplate and itemTemplate ~= ForgetinatorSafetyOffTemplate then return end

    local char = Ext.GetCharacter(character)
    for i, skill in pairs(char:GetSkills()) do
        local memCost = Ext.StatGetAttribute(skill, "Memory Cost")
        if memCost ~= 0 then
            if itemTemplate == ForgetinatorTemplate then
                if char:GetSkillInfo(skill).IsActivated then Osi.CharacterRemoveSkill(character, skill) end
            elseif itemTemplate == ForgetinatorSafetyOffTemplate then
                if not char:GetSkillInfo(skill).IsActivated then Osi.CharacterRemoveSkill(character, skill) end
            end
        end
    end
    Osi.ApplyStatus(character, "BLIND", 30.0, 1)
end)

--  ====================
--  CONTEXT MENU HANDLER
--  ====================

if Ext.IsModLoaded("b66d56c6-12f9-4abc-844f-0c30b89d32e4") then -- UI Components Library Loaded
    Ext.Require('Server/ContextMenu.lua')
end
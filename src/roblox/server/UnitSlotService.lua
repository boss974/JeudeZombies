--[[
    UnitSlotService.lua

    Gère le nombre d'unités équipables.

    Règle actuelle :
    - Début du jeu : 3 unités équipées maximum.
    - Niveau 30 : +3 emplacements supplémentaires.
    - Maximum après déblocage : 6 unités.
]]

local UnitSlotService = {}

function UnitSlotService:GetMaxEquippedUnits(playerLevel, config)
    playerLevel = playerLevel or 1

    if playerLevel >= config.Game.ExtraUnitSlotsUnlockLevel then
        return config.Game.MaxEquippedUnitsAfterUnlock
    end

    return config.Game.StartEquippedUnits
end

function UnitSlotService:CanEquipUnit(currentEquippedCount, playerLevel, config)
    local maxUnits = self:GetMaxEquippedUnits(playerLevel, config)
    return currentEquippedCount < maxUnits
end

function UnitSlotService:GetUnlockMessage(config)
    return "Au niveau " .. config.Game.ExtraUnitSlotsUnlockLevel .. ", tu débloques " .. config.Game.ExtraUnitSlots .. " emplacements d'unités supplémentaires."
end

return UnitSlotService

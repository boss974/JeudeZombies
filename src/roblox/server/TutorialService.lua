--[[
    TutorialService.lua

    Gère le tutoriel du début.
    Le but est d'expliquer simplement où jouer, comment invoquer et comment améliorer.
]]

local TutorialService = {}

function TutorialService:ShouldShowTutorial(player, playerData)
    if not playerData then
        return true
    end

    return playerData.HasCompletedTutorial ~= true
end

function TutorialService:GetTutorialSteps(config)
    return config.Tutorial.Steps
end

function TutorialService:MarkTutorialCompleted(playerData)
    playerData.HasCompletedTutorial = true
    return playerData
end

return TutorialService

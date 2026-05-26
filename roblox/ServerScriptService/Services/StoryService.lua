-- StoryService.lua
-- Pilote la progression narrative côté serveur.
-- Pousse les évènements via Remote vers le client (lignes de dialogue, missions).

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config    = require(Shared:WaitForChild("Config"))
local Constants = require(Shared:WaitForChild("Constants"))
local Remotes   = require(Shared:WaitForChild("Remotes"))
local Story     = require(Shared:WaitForChild("Story"))

-- Branche le mode adulte sur Story.PickLine (Config.AdultMode → lignes crues)
Story.SetAdultModeReader(function() return Config.AdultMode end)

local StoryService = {}
StoryService.CurrentMissionIndex = 1

-- Tire une ligne contextuelle (priorité aux hooks de ville)
local function pickLine(category)
	local mission = Story.Missions[StoryService.CurrentMissionIndex]
	local city = mission and mission.city
	return Story.PickLine(category, city)
end

local function pushDialog(player, text, kind)
	local r = Remotes.Get(Constants.RemoteName.WaveUpdate)
	if r then r:FireClient(player, text, kind or "dialog") end
end

function StoryService.PushLine(player, category, kind)
	if not player then return end
	pushDialog(player, pickLine(category), kind or category)
end

function StoryService.BroadcastLine(category, kind)
	for _, plr in ipairs(Players:GetPlayers()) do
		StoryService.PushLine(plr, category, kind)
	end
end

function StoryService.GetCurrentMission()
	return Story.Missions[StoryService.CurrentMissionIndex]
end

function StoryService.AdvanceMission()
	if StoryService.CurrentMissionIndex < #Story.Missions then
		StoryService.CurrentMissionIndex += 1
	end
	return StoryService.GetCurrentMission()
end

function StoryService.OnWaveStart(wave)
	for _, plr in ipairs(Players:GetPlayers()) do
		pushDialog(plr, pickLine("waveStart"), "waveStart")
	end
end

function StoryService.OnWaveCleared(wave)
	local mission = StoryService.GetCurrentMission()
	for _, plr in ipairs(Players:GetPlayers()) do
		pushDialog(plr, pickLine("waveCleared"), "waveCleared")
	end
	if mission and wave >= mission.waves then
		for _, plr in ipairs(Players:GetPlayers()) do
			pushDialog(plr, ("%s : %s"):format(mission.city, pickLine("cityCleared")), "cityCleared")
		end
		StoryService.AdvanceMission()
	end
end

function StoryService.OnBossWave()
	for _, plr in ipairs(Players:GetPlayers()) do
		pushDialog(plr, pickLine("bossWarning"), "bossWarning")
	end
end

function StoryService.SendIntro(player)
	-- Envoie la mission courante à la connexion
	local mission = StoryService.GetCurrentMission()
	if mission then
		pushDialog(player, mission.title .. " — " .. mission.city, "missionStart")
	end
end

function StoryService.Init()
	Players.PlayerAdded:Connect(function(plr)
		task.wait(2)  -- laisse le temps au client de charger
		StoryService.SendIntro(plr)
	end)
end

return StoryService

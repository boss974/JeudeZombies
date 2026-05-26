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

-- Fallback global Config.AdultMode (override admin). Le mode adulte
-- *par joueur* est lu via SettingsService.
Story.SetAdultModeReader(function() return Config.AdultMode end)

local StoryService = {}
StoryService.CurrentMissionIndex = 1

-- Charge SettingsService quand dispo (load tardif pour éviter cycle)
local _SettingsService
local function getSettings()
	if not _SettingsService then
		local ok, mod = pcall(function()
			return require(script.Parent:WaitForChild("SettingsService", 5))
		end)
		if ok then _SettingsService = mod end
	end
	return _SettingsService
end

-- Tire une ligne contextuelle pour un joueur donné.
-- Mode adulte = setting individuel du joueur (sinon fallback global Config).
local function pickLineFor(player, category)
	local mission = Story.Missions[StoryService.CurrentMissionIndex]
	local city = mission and mission.city
	local isAdult = false
	local s = getSettings()
	if s and player then
		isAdult = s.IsAdultMode(player)
	elseif not s then
		isAdult = Config.AdultMode  -- fallback si SettingsService pas chargé
	end
	return Story.PickLine(category, city, isAdult)
end

local function pushDialog(player, text, kind)
	local r = Remotes.Get(Constants.RemoteName.WaveUpdate)
	if r then r:FireClient(player, text, kind or "dialog") end
end

function StoryService.PushLine(player, category, kind)
	if not player then return end
	pushDialog(player, pickLineFor(player, category), kind or category)
end

-- Conservé pour rétrocompat (sans player → ligne générique)
local function pickLine(category)
	return pickLineFor(nil, category)
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

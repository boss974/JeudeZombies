-- GameController.server.lua
-- Point d'entrée serveur. Initialise services et boucle de vague.

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Remotes = require(Shared:WaitForChild("Remotes"))
local Config  = require(Shared:WaitForChild("Config"))
local Constants = require(Shared:WaitForChild("Constants"))

Remotes.Init()

local Services = ServerScriptService:WaitForChild("Services")
local WaveService       = require(Services:WaitForChild("WaveService"))
local ZombieService     = require(Services:WaitForChild("ZombieService"))
local WeaponService     = require(Services:WaitForChild("WeaponService"))
local DefenseService    = require(Services:WaitForChild("DefenseService"))
local MonetizationService = require(Services:WaitForChild("MonetizationService"))
local AdPlacementService = require(Services:WaitForChild("AdPlacementService"))
local RewardService     = require(Services:WaitForChild("RewardService"))
local PlayerDataService = require(Services:WaitForChild("PlayerDataService"))
local ShopService       = require(Services:WaitForChild("ShopService"))
local StoryService      = require(Services:WaitForChild("StoryService"))
local SettingsService   = require(Services:WaitForChild("SettingsService"))
local MissionService    = require(Services:WaitForChild("MissionService"))

SettingsService.Init()
MissionService.Init()

PlayerDataService.Init()
ShopService.Init()
ZombieService.Init()
StoryService.Init()
WeaponService.Init({
	OnPlayerShoot = function(player)
		StoryService.PushLine(player, "playerShoot")
	end,
})
DefenseService.Init()
MonetizationService.Init()
AdPlacementService.Init()
WaveService.Init({
	OnZombieKilled = function(player, zombieType)
		RewardService.GiveKillReward(player, zombieType)
	end,
	OnWaveStart = function(waveNumber)
		StoryService.OnWaveStart(waveNumber)
		-- Son de démarrage de vague
		if _G.SoundManager then _G.SoundManager.Play("WaveStart") end
	end,
	OnBossWave = function()
		StoryService.OnBossWave()
	end,
	OnWaveCleared = function(waveNumber)
		for _, plr in ipairs(Players:GetPlayers()) do
			RewardService.GiveWaveClearBonus(plr)
		end
		StoryService.OnWaveCleared(waveNumber)
		MissionService.OnWaveCleared(waveNumber)
		-- Son de victoire de vague
		if _G.SoundManager then _G.SoundManager.Play("Victory") end
		print(("[GameController] Vague %d nettoyée"):format(waveNumber))
	end,
})

Players.PlayerAdded:Connect(function(player)
	local data = PlayerDataService.Load(player)
	local scoreRemote = Remotes.Get(Constants.RemoteName.ScoreUpdate)
	if scoreRemote and data then scoreRemote:FireClient(player, data.Score, data.Coins, data.BestScore) end
	player.CharacterAdded:Connect(function(char)
		local hum = char:WaitForChild("Humanoid")
		hum.MaxHealth = Config.Player.MaxHealth
		hum.Health = hum.MaxHealth
		hum.WalkSpeed = Config.Player.WalkSpeed
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	PlayerDataService.Save(player)
end)

-- Démarre les vagues quand au moins 1 joueur est présent
task.spawn(function()
	while true do
		if #Players:GetPlayers() > 0 and not WaveService.Running then
			WaveService.Start()
		end
		task.wait(2)
	end
end)

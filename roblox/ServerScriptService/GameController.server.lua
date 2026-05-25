-- GameController.server.lua
-- Point d'entrée serveur. Initialise services et boucle de vague.

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Remotes = require(Shared:WaitForChild("Remotes"))
local Config  = require(Shared:WaitForChild("Config"))

Remotes.Init()

local Services = ServerScriptService:WaitForChild("Services")
local WaveService       = require(Services:WaitForChild("WaveService"))
local ZombieService     = require(Services:WaitForChild("ZombieService"))
local RewardService     = require(Services:WaitForChild("RewardService"))
local PlayerDataService = require(Services:WaitForChild("PlayerDataService"))
local ShopService       = require(Services:WaitForChild("ShopService"))

PlayerDataService.Init()
ShopService.Init()
ZombieService.Init()
WaveService.Init({
	OnZombieKilled = function(player, zombieType)
		RewardService.GiveKillReward(player, zombieType)
	end,
	OnWaveCleared = function(waveNumber)
		for _, plr in ipairs(Players:GetPlayers()) do
			RewardService.GiveWaveClearBonus(plr)
		end
		print(("[GameController] Vague %d nettoyée"):format(waveNumber))
	end,
})

Players.PlayerAdded:Connect(function(player)
	PlayerDataService.Load(player)
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

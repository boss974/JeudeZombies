-- RewardService.lua
-- Distribue score et coins. S'appuie sur PlayerDataService pour la persistance.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config    = require(Shared:WaitForChild("Config"))
local Constants = require(Shared:WaitForChild("Constants"))
local Remotes   = require(Shared:WaitForChild("Remotes"))

local PlayerDataService = require(script.Parent:WaitForChild("PlayerDataService"))

local RewardService = {}
local MonetizationService = nil

local function pushUpdate(player)
	local data = PlayerDataService.Get(player)
	local r = Remotes.Get(Constants.RemoteName.ScoreUpdate)
	if r and data then r:FireClient(player, data.Score, data.Coins, data.BestScore) end
end

function RewardService.GiveKillReward(player, zombieType)
	local stats = Config.Zombie[zombieType]
	if not stats then return end
	local data = PlayerDataService.Get(player)
	if not data then return end
	if not MonetizationService then
		MonetizationService = require(script.Parent:WaitForChild("MonetizationService"))
	end
	local coinMultiplier = MonetizationService.GetCoinMultiplier(player)
	data.Score += stats.Score
	data.Coins += math.floor(stats.Coins * coinMultiplier)
	if data.Score > (data.BestScore or 0) then data.BestScore = data.Score end
	pushUpdate(player)
end

function RewardService.GiveWaveClearBonus(player)
	local data = PlayerDataService.Get(player)
	if not data then return end
	data.Score += Config.Scoring.WaveClearBonus
	pushUpdate(player)
end

return RewardService

-- PlayerDataService.lua
-- Stockage en mémoire + DataStore. Garde l'API : Load, Save, Get.
-- DataStoreService ne marche qu'en jeu publié - le pcall protège en Studio.

local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config    = require(Shared:WaitForChild("Config"))
local Constants = require(Shared:WaitForChild("Constants"))

local store = DataStoreService:GetDataStore(Constants.DataStoreKey)

local PlayerDataService = {}
local cache = {}

local function defaultData()
	return {
		Score = 0,
		Coins = Config.Player.StartCoins,
		BestScore = 0,
		Upgrades = { Health = 0, Speed = 0, Damage = 0 },
	}
end

function PlayerDataService.Init()
	cache = {}
end

function PlayerDataService.Load(player)
	local saved
	pcall(function()
		saved = store:GetAsync(tostring(player.UserId))
	end)
	local data = defaultData()
	if saved then
		for k, v in pairs(saved) do data[k] = v end
	end
	-- Reset score de session : seul BestScore persiste
	data.Score = 0
	cache[player.UserId] = data
	return data
end

function PlayerDataService.Save(player)
	local data = cache[player.UserId]
	if not data then return end
	pcall(function()
		store:SetAsync(tostring(player.UserId), data)
	end)
end

function PlayerDataService.Get(player)
	return cache[player.UserId]
end

return PlayerDataService

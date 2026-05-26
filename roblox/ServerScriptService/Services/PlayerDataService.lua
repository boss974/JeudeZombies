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
		Monetization = {
			CoinMultiplier = 1,
			CoinBoostEndsAt = 0,
			PendingRevives = 0,
			OwnedSkins = {},
			LastDailyBonus = 0,
		},
		-- Paramètres joueur (saisis dans SettingsUI au premier lancement)
		Settings = {
			HasCompletedSetup = false,
			Pseudo = "",
			BirthDate = "",
			Age = 0,
			AdultModeEnabled = false,
		},
		-- ===== Phase 3 : collection / galerie / achievements =====
		-- Souvenirs : items thématiques gagnés à la fin de chaque mission
		-- (cf. Story.Missions[i].reward_item) → { ["Photo du Barachois"]=true, ... }
		Souvenirs = {},
		-- Galerie : photos prises (touche E sur POI)
		-- → { { poiId="barachois", missionId="stdenis", timestamp=os.time() }, ... }
		Photos = {},
		-- Achievements débloqués : { ["first_zombie"]=true, ... }
		Achievements = {},
		-- Compteurs utilisés pour valider les achievements
		Stats = {
			ZombieKills    = 0,
			PhotoCount     = 0,
			CityComplete   = 0,
			PickupCount    = 0,
			BossKilled     = 0,
			MegaJumpCount  = 0,
			PortalUseCount = 0,
			GotHitCount    = 0,
		},
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
	data.Upgrades = data.Upgrades or { Health = 0, Speed = 0, Damage = 0 }
	data.Monetization = data.Monetization or defaultData().Monetization
	data.Settings = data.Settings or defaultData().Settings
	-- Migration phase 3 : assure que les nouveaux champs existent
	local d = defaultData()
	data.Souvenirs    = data.Souvenirs    or d.Souvenirs
	data.Photos       = data.Photos       or d.Photos
	data.Achievements = data.Achievements or d.Achievements
	data.Stats        = data.Stats        or d.Stats
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

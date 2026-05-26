-- Constants.lua
-- Identifiants partagés. Tout ce qui est texte critique passe par ici.

local Constants = {}

Constants.ZombieType = {
	Normal = "Normal",
	Fast = "Fast",
	Heavy = "Heavy",
	MiniBoss = "MiniBoss",
	Boss = "Boss",
}

Constants.RemoteName = {
	WaveUpdate = "WaveUpdate",
	ScoreUpdate = "ScoreUpdate",
	PlayerData = "PlayerData",
	BuyUpgrade = "BuyUpgrade",
	StartGame = "StartGame",
	GameOver = "GameOver",
	ShootWeapon = "ShootWeapon",
	PlaceDefense = "PlaceDefense",
	PurchaseProduct = "PurchaseProduct",
	MonetizationUpdate = "MonetizationUpdate",
	-- Settings joueur (pseudo, date naissance, mode adulte par joueur)
	SaveSettings = "SaveSettings",
	GetSettings = "GetSettings",
	SettingsUpdate = "SettingsUpdate",
	-- Missions séquentielles
	MissionUpdate = "MissionUpdate",      -- server → client : push état objectifs
	MissionAction = "MissionAction",      -- client → server : photo, touch_poi
	-- Phase 3 : souvenirs, galerie, achievements
	AchievementUnlocked = "AchievementUnlocked",  -- server → client : trophée débloqué
	CollectionUpdate = "CollectionUpdate",        -- server → client : push souvenirs+photos+achievements
}

Constants.DataStoreKey = "PlayerData_v1"

return Constants

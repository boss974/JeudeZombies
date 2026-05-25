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
}

Constants.DataStoreKey = "PlayerData_v1"

return Constants

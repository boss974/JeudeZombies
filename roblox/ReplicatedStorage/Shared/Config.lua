-- Config.lua
-- Valeurs partagées entre serveur et client. Garde tout simple et lisible.

local Config = {}

Config.Arena = {
	SpawnRadius = 60,    -- studs autour du centre
	BorderRadius = 80,   -- limite hard avant respawn forcé
}

Config.Player = {
	MaxHealth = 100,
	WalkSpeed = 16,
	StartCoins = 0,
}

Config.Zombie = {
	Normal   = { Health = 50,  Damage = 10, Speed = 8,  Score = 10, Coins = 1 },
	Fast     = { Health = 30,  Damage = 8,  Speed = 14, Score = 15, Coins = 2 },
	Heavy    = { Health = 140, Damage = 20, Speed = 5,  Score = 25, Coins = 3 },
	MiniBoss = { Health = 350, Damage = 35, Speed = 7,  Score = 80, Coins = 12 },
	Boss     = { Health = 900, Damage = 50, Speed = 6,  Score = 250, Coins = 40 },
}

Config.Wave = {
	BaseEnemies = 6,
	EnemiesPerWave = 3,
	InterWaveDelay = 4,
	SpawnInterval = 1.2,
	MaxActive = 25,
	MiniBossEveryN = 5,
	BossEveryN = 10,
	FastUnlockAt = 2,
	HeavyUnlockAt = 4,
}

Config.Scoring = {
	WaveClearBonus = 25,
}

Config.Shop = {
	-- Améliorations en coins
	HealthUpgrade  = { Cost = 50,  Amount = 25 },   -- +25 max HP
	SpeedUpgrade   = { Cost = 75,  Amount = 2 },    -- +2 walkspeed
	DamageUpgrade  = { Cost = 100, Amount = 5 },    -- +5 dégâts arme
}

return Config

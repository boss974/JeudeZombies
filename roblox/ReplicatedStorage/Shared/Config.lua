-- Config.lua
-- Valeurs partagées entre serveur et client. Garde tout simple et lisible.

local Config = {}

-- ============================================================================
-- MODE ADULTE (+18) — désormais GÉRÉ PAR JOUEUR via SettingsService.
-- Ce flag global reste comme fallback admin (ex: forcer tout le monde en
-- adulte sur une instance privée). En jeu normal, on lit
-- PlayerData.Settings.AdultModeEnabled par joueur (validation âge serveur).
-- ⚠️ Ne pas publier publiquement sur Roblox sans âge-gating officiel 17+.
-- ============================================================================
Config.AdultMode = false  -- fallback global (défaut OFF)

-- ============================================================================
-- MULTIJOUEUR — Roblox = multi par défaut. Limite serveur :
-- ============================================================================
Config.Multiplayer = {
	MaxPlayers = 6,         -- coop jusqu'à 6
	PvpEnabled = false,     -- pas de PvP (coop pur)
}

Config.Brand = {
	Colors = {
		BleuLagon = Color3.fromRGB(0, 153, 184),
		JauneSoleil = Color3.fromRGB(244, 185, 66),
		RougeFlamboyant = Color3.fromRGB(233, 78, 27),
		OrangeFournaise = Color3.fromRGB(255, 107, 53),
		VertTropical = Color3.fromRGB(28, 139, 62),
		SableNoir = Color3.fromRGB(45, 45, 45),
		RoseHibiscus = Color3.fromRGB(233, 30, 99),
	},
}

Config.Arena = {
	SpawnRadius = 60,    -- studs autour du centre
	BorderRadius = 80,   -- limite hard avant respawn forcé
}

Config.Player = {
	MaxHealth = 100,
	WalkSpeed = 16,
	StartCoins = 24,
}

Config.Weapon = {
	BaseDamage = 25,
	Range = 180,
	Cooldown = 0.22,
	RecoilStuds = 0.8,
}

Config.Defense = {
	Turret = {
		Cost = 18,
		Health = 180,
		Range = 70,
		Damage = 16,
		FireRate = 0.8,
	},
	Barricade = {
		Cost = 10,
		Health = 300,
	},
}

Config.Zombie = {
	Normal   = { Health = 50,  Damage = 10, Speed = 8,  Score = 10, Coins = 1 },
	Fast     = { Health = 30,  Damage = 8,  Speed = 14, Score = 15, Coins = 2 },
	Heavy    = { Health = 140, Damage = 20, Speed = 5,  Score = 25, Coins = 3 },
	MiniBoss = { Health = 350, Damage = 35, Speed = 7,  Score = 80, Coins = 12 },
	Boss     = { Health = 900, Damage = 50, Speed = 6,  Score = 250, Coins = 40 },
	RoiCendre = { Health = 1800, Damage = 65, Speed = 5, Score = 700, Coins = 120 },
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

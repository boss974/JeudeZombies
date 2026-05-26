--[[
    Config.lua

    Configuration centrale du prototype Roblox Tower Defense Zombie.
    Ce fichier doit rester simple pour être modifié facilement.
]]

local Config = {}

Config.Game = {
    Name = "Zombie Tower Defense",
    MaxPlayersDefault = 4,
    MaxPlayersGamePass = 8,
    StartEquippedUnits = 3,
    ExtraUnitSlotsUnlockLevel = 30,
    ExtraUnitSlots = 3,
    MaxEquippedUnitsAfterUnlock = 6,
}

Config.UI = {
    ShowZombieHealthBarsDefault = true,
    AllowPlayerToHideZombieHealthBars = true,
}

Config.Audio = {
    LobbyMusicName = "RelaxedLobbyTheme",
    CombatMusicName = "DefenseWaveTheme",
    DefaultMusicVolume = 0.25,
}

Config.Map = {
    TileSize = 8,
    PathWidth = 10,
    ZombieBaseHealth = 100,
}

Config.Waves = {
    MaxWaveMVP = 10,
    BossWave = 10,
    TimeBetweenWaves = 8,
}

Config.Zombies = {
    Normal = {
        Health = 100,
        Speed = 8,
        Reward = 10,
    },
    Fast = {
        Health = 70,
        Speed = 13,
        Reward = 14,
    },
    Tank = {
        Health = 250,
        Speed = 5,
        Reward = 25,
    },
    Boss = {
        Health = 1500,
        Speed = 4,
        Reward = 200,
    },
}

Config.Units = {
    StarterUnits = {
        "Survivor",
        "Turret",
        "Sniper",
    },
}

Config.Tutorial = {
    Enabled = true,
    Steps = {
        "Bienvenue dans le lobby.",
        "Va dans la salle Invocation pour obtenir des unités.",
        "Va dans la salle Amélioration pour renforcer tes unités.",
        "Va dans la salle Tower Defense pour lancer une partie.",
        "Place tes unités autour du chemin.",
        "Protège la base jusqu'à la dernière vague.",
    },
}

return Config

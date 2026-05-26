--[[
    GameController.server.lua

    Point d'entrée serveur du prototype Roblox.

    Compatible Rojo :
    - ce fichier est placé directement dans ServerScriptService
    - les services Roblox du projet sont aussi placés directement dans ServerScriptService
]]

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")

local Config = require(Shared:WaitForChild("Config"))
local MapPathService = require(ServerScriptService:WaitForChild("MapPathService"))
local UnitSlotService = require(ServerScriptService:WaitForChild("UnitSlotService"))

print("[JeuDeZombies] Démarrage serveur : " .. Config.Game.Name)

local map = MapPathService:CreatePrototypeMap()
print("[JeuDeZombies] Map générée : " .. map.Name)

local startSlots = UnitSlotService:GetMaxEquippedUnits(1, Config)
local level30Slots = UnitSlotService:GetMaxEquippedUnits(30, Config)

print("[JeuDeZombies] Slots niveau 1 : " .. startSlots)
print("[JeuDeZombies] Slots niveau 30 : " .. level30Slots)

print("[JeuDeZombies] Tutoriel activé : " .. tostring(Config.Tutorial.Enabled))
print("[JeuDeZombies] Barre HP zombies par défaut : " .. tostring(Config.UI.ShowZombieHealthBarsDefault))

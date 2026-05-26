--[[
    GameController.server.lua

    Point d'entrée serveur du prototype Roblox.

    Ce fichier charge la configuration, génère la map prototype et vérifie
    les règles principales du jeu.
]]

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Services = ServerScriptService:WaitForChild("Services")
local Shared = ReplicatedStorage:WaitForChild("Shared")

local Config = require(Shared:WaitForChild("Config"))
local MapPathService = require(Services:WaitForChild("MapPathService"))
local UnitSlotService = require(Services:WaitForChild("UnitSlotService"))

print("[JeuDeZombies] Démarrage serveur : " .. Config.Game.Name)

local map = MapPathService:CreatePrototypeMap()
print("[JeuDeZombies] Map générée : " .. map.Name)

local startSlots = UnitSlotService:GetMaxEquippedUnits(1, Config)
local level30Slots = UnitSlotService:GetMaxEquippedUnits(30, Config)

print("[JeuDeZombies] Slots niveau 1 : " .. startSlots)
print("[JeuDeZombies] Slots niveau 30 : " .. level30Slots)

print("[JeuDeZombies] Tutoriel activé : " .. tostring(Config.Tutorial.Enabled))
print("[JeuDeZombies] Barre HP zombies par défaut : " .. tostring(Config.UI.ShowZombieHealthBarsDefault))
